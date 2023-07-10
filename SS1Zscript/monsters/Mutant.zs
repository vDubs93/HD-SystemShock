class HumanoidMutant : SS1Mutant
{
	bool user_cantmove;
	override void postbeginplay() {
		super.postbeginplay();
		array<int> lootList = {7, 7, 7, 3, 3, 8, 0, 0, 0, 0, 0, 0, 0};
		initializeLoot(lootList, 2);
	}
	Default
	{
		//$Category "System Shock/Monsters"
		//$Title "Humanoid Mutant"
		//$Sprite "MTIDA1"
		-NOBLOCKMAP;
		-NOBLOOD
		scale 0.7;
		HitObituary "Mutant strength is nothing to laugh at.";
		speed 2;
		health 50;
		SS1MobBase.defenceValue 3;
		SS1MobBase.armorValue 0;
		painchance 102;
		meleerange 48;
		seesound "humanoidMutant/see";
		activesound "humanoidMutant/act";
		+SS1MobBase.ISSTUNNABLE;
		Tag "Humanoid Mutant";
	}
	States
	{
		spawn:
			MTMV A 1 {
				A_HDLook();
				A_Recoil(frandom(-0.1,0.1));
				}
			#### AAA random(5,17) A_HDLook();
			#### A 1 {
				A_Recoil(frandom(-0.1,0.1));
				A_SetTics(random(10,40));
			}
			#### B 0 A_Jump(132, "spawnswitch");
			#### B 8 A_Recoil(frandom(-0.2,0.2));
			loop;
		spawnswitch:
			#### A 0 A_JumpIf(bambush,"spawnstill");
			#### A 0 A_JumpIf(user_cantmove, "spawnstill");
			goto spawnwander;
		spawnstill:
			MTID A 0 A_Look();
			#### A 0 A_Recoil(random(-1,1)*0.4);
			#### AB 5 A_SetAngle(angle+random(-4,4));
			#### A 0 {
				A_Look();
				if(!random(0,127))A_Vocalize(activesound);
			}
			#### AB 5 A_SetAngle(angle+random(-4,4));
			#### B 1 A_SetTics(random(10,40));
			#### A 0 A_Jump(256,"spawn");
		spawnwander:
			MTMV ABCDEFGH 5 A_HDWander();
			#### A 0 A_Jump(64,"spawn");
			loop;
		see:
			MTMV ABCDEFGH random(3,4) A_HDChase();
			loop;
		melee:
			MTAT AB 4;
			#### C 4 A_FaceTarget();
			#### D 4 A_StartSound("humanoidMutant/hit");
			#### E 4 A_MeleeAttack(height*0.6, target);
			#### FG 4;
			#### H 4;
			Goto see;
		pain:
			MTPN D 5;
			MTPN E 5;
			goto see;
		death:
			MTDI A 5 {
				A_Vocalize("humanoidmutant/die");
				A_TakeInventory("TranqHandler",9999);
			}
			MTDI B 5 A_NoBlocking();
			MTDI CDE 5;
			MTDI F 1;
		dead:
			#### E 3 canraise{if(abs(vel.z)<2.)frame++;}
			#### F 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
			wait;
	}
	
	void A_MeleeAttack(double hitheight, Actor target, double mult=1.){
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

		double dmg=random(20,100);

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
		addz(-hitheight);
	}
	 override int DamageMobj(
        actor inflictor,
        actor source,
        int damage,
        name mod,
        int flags,
        double angle
    ){
        if(
			mod == "Magnetic"
        )return 0;
		if(
			mod == "Needle"
			
		)return super.DamageMobj(inflictor,source,damage * 2,mod,flags,angle);
        return super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }
}