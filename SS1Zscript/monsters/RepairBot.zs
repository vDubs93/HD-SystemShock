
class RepairBot : SS1Robot
{
	override void postbeginplay() {
		super.postbeginplay();
		array<int> lootList = {7, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 0, 0, 0};
		initializeLoot(lootList, 2);
	}
	Default
	{
		-NOBLOCKMAP
		//$Category "System Shock/Monsters"
		//$Title "Repair-Bot"
		//$Sprite "RPBIA1"
		height 24;
		radius 16;
		scale 0.7;
		HitObituary "%o got fixed.";
		speed 4;
		+noblood
		health 20;
		SS1MobBase.armorValue 25;
		SS1MobBase.defenceValue 3;
		PainChance 102;
		meleerange 48;
		seesound "servbot/see";
		activesound "servbot/act";
		+SS1MobBase.ISROBOT;
		+hdmobbase.headless
		Tag "Repair-Bot";
	}

	States
	{
		spawn:
			RPBI A 1{
				A_HDLook();
				A_Recoil(frandom(-0.1,0.1));
				}
			#### ABCB random(5,17) A_HDLook();
			#### B 0 A_Jump(132,"spawnswitch");
			#### B 8 A_Recoil(frandom(-0.2,0.2));
			loop;
		spawnswitch:
			#### A 0 A_JumpIf(bambush,"spawnstill");
			goto spawnwander;
		spawnstill:
			RPBI A 0 A_Look();
			#### A 0 A_Recoil(random(-1,1)*0.4);
			#### ABC 5 A_SetAngle(angle+random(-4,4));
			#### A 0{
				A_Look();
				if(!random(0,127))A_Vocalize(activesound);
			}
			#### ABC 5 A_SetAngle(angle+random(-4,4));
			#### B 1 A_SetTics(random(10,40));
			#### A 0 A_Jump(256,"spawn");
		spawnwander:
			RPBM A 0;
			#### ABCD 5 A_HDWander();
			#### A 0 A_Jump(64,"spawn");
			loop;
		see:
			RPBM ABCD random(3,4) A_HDChase();
			loop;
			
		missile:
			RPAA A 0;
			goto see;
		melee:
			RPBA A 4 A_FaceTarget();
			#### B 4 A_StartSound("servbot/hit");
			#### C 4;
			#### D 4 A_WelderAttack(height*0.6, target);
			#### E 4;
			#### F 4;
			Goto see;
		pain:
			RPBP A 5;
			RPBP B 5;
			goto see;
		death:
			RPBD A 5 A_StartSound("servbot/die");
			RPBD BCDE 5;
			RPBD F 1 A_NoBlocking();
		dead:
			#### E 3 canraise{if(abs(vel.z)<2.)frame++;}
			#### F 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
			wait;
	}
	
	 override int DamageMobj(
        actor inflictor,
        actor source,
        int damage,
        name mod,
        int flags,
        double angle
    ){
		if (mod == "Gas")
			return 0;
		else if (mod == "Dart" || mod == "Needle")
			return super.DamageMobj(inflictor, source, 1, mod, flags, angle);
		else if (mod == "Magnetic")
			return super.DamageMobj(inflictor, source, damage * 4, mod, flags, angle);
		else
			return super.DamageMobj(inflictor, source, damage, mod, flags, angle);
	}
	
	void A_WelderAttack(double hitheight, Actor target, double mult=1.){
		flinetracedata mtrace;
		if (HDPlayerPawn(target).incapacitated > 0)
		hitheight = 8;
		linetrace(
			angle,
			meleerange,
			pitch,
			offsetz:hitheight,
			data:mtrace
		);
		if(!mtrace.hitactor){
			A_StartSound("misc/fwoosh",CHAN_WEAPON,CHANF_OVERLAP,volume:min(0.1*mult,1.));
			return;
		}
		A_StartSound("weapons/smack",CHAN_WEAPON,CHANF_OVERLAP);

		hitheight=mtrace.hitlocation.z-mtrace.hitactor.pos.z;
		double hitheightproportion=hitheight/mtrace.hitactor.height;
		string hitloc="";
		int dmfl=0;

		double dmg=random(20, 100)*1.2;

		if(hitheightproportion>0.8){
			hitloc="HEAD";
			dmg*=2.;
		}else if(hitheightproportion>0.5){
			hitloc="BODY";
		}else{
			hitloc="LEGS";
			dmg*=1.3;
		}

		if(hd_debug)console.printf(gettag().." hit "..mtrace.hitactor.gettag().." in the "..hitloc.." for "..dmg);

		addz(hitheight);
		mtrace.hitactor.damagemobj(self,self,int(dmg),"bashing",flags:dmfl);
		if (!mtrace.hitActor.bDONTTHRUST){
			vector3 kickdir=(mtrace.hitActor.pos-self.pos).unit();
			mtrace.hitActor.vel=kickdir*5*self.mass/max(self.mass*0.3,mtrace.hitActor.mass);
		}
		addz(-hitheight);
	}
}