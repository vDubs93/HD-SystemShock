class CyborgDrone : SS1Cyborg
{
	bool user_cantmove;
	int turnamount;
	override void postbeginplay() {
		super.postbeginplay();
		array<int> lootList = {10, 10, 10, 10, 10, 10, 10, 10, 10, 15, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 9, 9, 7, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		initializeLoot(lootList, 2);
	}
	Default
	{
		//$Category "System Shock/Monsters"
		//$Title "Cyborg Drone"
		//$Sprite "CDRIA1"
		-NOBLOCKMAP;
		-NOBLOOD
		scale 0.7;
		radius 12;
		HitObituary "%o got droned.";
		speed 4;
		health 60;
		SS1MobBase.defenceValue 2;
		SS1MobBase.armorValue 0;
		painchance 76.5;
		meleerange 0;
		seesound "humanoidMutant/see";
		activesound "CyborgDrone/act";
		+SS1MobBase.ISSTUNNABLE;
		+SS1MobBase.isRobot;
		Tag "Humanoid Mutant";
	}
	States
	{
		spawn:
			CDRI A 1 {
				A_HDLook();
				A_Recoil(frandom(-0.1,0.1));
				}
			
			#### BCD random(5,17) A_HDLook();
			#### A 1 {
				A_Recoil(frandom(-0.1,0.1));
				A_SetTics(random(10,40));
			}
			#### B 0 A_Jump(132, "spawnswitch");
			#### B 8 A_Recoil(frandom(-0.2,0.2));

			loop;
		spawnswitch:
			#### A 0 A_JumpIf(bambush,"spawnstill");
			goto spawnwander;
		spawnstill:
			CDRI A 0 A_Look();
			#### A 0 A_Recoil(random(-1,1)*0.4);
			#### ABCD 5 A_SetAngle(angle+random(-4,4));
			#### A 0 {
				A_Look();
				if(!random(0,127))A_Vocalize(activesound);
			}
			#### ABCD 5 A_SetAngle(angle+random(-4,4));
			#### CB 1 A_SetTics(random(10,40));
			#### A 0 A_Jump(256,"spawn");
		spawnwander:
			TNT1 A 0 A_JumpIf(user_cantmove, "spawnstill");
			CDRW ABCD 5 A_HDWander();
			CDRW EFG 5;
			#### A 0{
				if(!random(0,127))A_Vocalize(activesound);
				A_HDLook();
			}
			#### A 0 A_Jump(64,"spawn");
			loop;
		see:
			CDRW ABCDEFG random(3,4) A_HDChase();
			loop;
		missile:
			#### A 0 A_JumpIf(!hdmobai.tryshoot(self),"see");
			#### A 0 {
				double enemydist=distance3d(target);
				if(enemydist<200)turnamount=50;
				else if(enemydist<600)turnamount=30;
				else turnamount=10;
				}goto turntoaim;
		turntoaim:
			#### E 2 A_FaceTarget(turnamount,turnamount);
			#### A 0 A_JumpIfTargetInLOS(2);
			---- A 0 setstatelabel("see");
			#### A 0 A_JumpIfTargetInLOS(1,10);
			loop;
			CDRA AB 4;
		Shoot:
			#### C 4 A_CyborgGun();
			#### D 4;
			#### EF 4;
			Goto see;
		pain:
			CDRP ABC 5;
			goto see;
		death:
			CDRD A 5 {
				A_Vocalize("humanoidmutant/die");
				A_TakeInventory("TranqHandler",9999);
			}
			CDRD B 5 A_NoBlocking();
			CDRD CD 5;
		dead:
			#### C 3 canraise{if(abs(vel.z)<2.)frame++;}
			#### D 5 canraise{if(abs(vel.z)>=2.)setstatelabel("dead");}
			wait;
	}
	
	action void A_CyborgGun(){
		A_FaceTarget();
		A_StartSound("minipistol/fire");
		HDBulletActor.FireBullet(self,"DroneBullet", 32, speedfactor:1.1);
		HDBulletActor.FireBullet(self,"DroneBullet", 32, speedfactor:1.1);
		HDWeapon.EjectCasing(self,"MPStandardSpent",11,-frandom(79,81),frandom(7,7.5));
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
        )return super.DamageMobj(inflictor, source, 2 * damage, mod, flags, angle);
        return super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }
}

class DroneBullet:SS1Bullet{
	default{
		pushfactor 2;
		mass 80;
		speed 200;//475;
		accuracy 300;
		stamina 900;
		woundhealth 10;
		hdbulletactor.hardness 1;
		SS1Bullet.penetration 20;
		SS1Bullet.dmg 20;
	}
	
}