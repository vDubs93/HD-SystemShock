enum StunGunProperties
	{
		SG_OverHeat,
		SG_PowerLevel
	};
Class SS1StunGun : SS1Weapon
{
	default
	{
		//$Category "System Shock/Weapons"
		//$Title "DH-07 Stun Gun"
		//$Sprite "STGPA0"
		+WEAPON.NOAUTOFIRE;
		weapon.SlotNumber 2;
		hdweapon.refid "stg";
		HDWeapon.barrelSize 10, 0.2, 0.2;
		scale 0.2;
		tag "DH-07 Stun Gun";
		Inventory.pickupMessage "DH-07 Stun Gun.  Not completely useless.";
		SS1Weapon.penetration 0;
		SS1Weapon.OffenseValue 3;
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_RELOAD.."  Change Power Level (Max will stun robots)\n"
		..WEPHELP_MAGMANAGER
		;
	}
	override string,double getpickupsprite()
	{
		return "STGPA0",0.4;
	}
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		sb.drawImage("STGICON", (-84, -3), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM, scale: (0.5, 0.5));
		sb.drawwepnum(weaponStatus[SG_PowerLevel], 3);
		
	}
	
	action bool A_FireStun(int level)
	{
		let hpl = Hacker(invoker.owner);
		
		if (hpl && hpl.internalCharge > 0 && !invoker.weaponStatus[SG_OverHeat]) {
			

			if (invoker.weaponStatus[SG_PowerLevel] == 3) {
				if (hpl.InternalCharge >= 8) {
					A_StartSound("stungun/FullCharge", CHAN_AUTO, CHANF_OVERLAP);
				} else if (hpl.InternalCharge >= 2) invoker.weaponStatus[SG_powerlevel] = 2;
			}
			if (invoker.weaponStatus[SG_PowerLevel] >= 2) {
				if (hpl.InternalCharge < 2) 
					invoker.weaponStatus[SG_powerlevel] = 1;
				else {
					A_StartSound("stungun/fire", CHAN_AUTO, CHANF_OVERLAP, 1.0, ATTN_NORM, 0.8);
				}
			}
			if (invoker.weaponStatus[SG_PowerLevel] >= 1) {
					A_StartSound("stungun/fire", CHAN_AUTO, CHANF_OVERLAP);
			}
			int level = invoker.weaponstatus[SG_powerlevel];
			hpl.internalCharge -= level < 3 ? level : 8;
			HDB_StunRay str;
			class<actor> sss;
			sss="HDB_StunRay";
			str=HDB_StunRay(spawn(sss,(
				pos.xy,
				pos.z+HDWeapon.GetShootOffset(
					self,invoker.barrellength,
					invoker.barrellength-HDCONST_SHOULDERTORADIUS
				)
			),ALLOW_REPLACE));

			str.angle=angle;str.target=self;str.master=self;
			str.pitch=pitch;
			str.stunLevel = invoker.weaponStatus[SG_PowerLevel];
			if (invoker.weaponStatus[SG_PowerLevel] == 3)
				invoker.owner.A_SetPitch(invoker.owner.pitch-5, SPF_INTERPOLATE); 
			return true;
		} else {
			return false;
		}	
	}
	override void postbeginplay()
	{
		super.postbeginplay();
		weaponStatus[SG_PowerLevel] = 1;
		weaponStatus[SG_OverHeat] = 0;
		A_OverlayFlags(5, PSPF_ADDBOB, true);
	}
	override void tick()
	{
		super.tick();
		if (weaponStatus[SG_OverHeat] > 0){
			drainHeat(SG_OverHeat);
		}
	}
	states
	{
		Spawn:
			STGP A -1;
			wait;
		Select0:
			STNG A 0;
			goto select0small;
		Deselect0:
			STNG A 0;
			goto deselect0small;
		ready:
			STNG A 1 {
				A_WeaponReady(WRF_ALL);
				if (invoker.weaponStatus[SG_PowerLevel] == 3 && Hacker(invoker.owner).internalCharge >= 8) {
					int rand = random(1, 100);
					if (rand < 4){
						invoker.owner.A_StartSound("stungun/zap", CHAN_AUTO, CHANF_OVERLAP, 0.4, ATTN_NORM, frandom(0.9, 1.1));
						switch(rand){
							case 0:
								A_Overlay(5, "zap0");
								break;
							case 1:
								A_Overlay(5, "zap1");
								break;
							case 2:
								A_Overlay(5, "zap2");
								break;
							case 3:
								A_Overlay(5, "zap3");
								break;
							case 4:
								A_Overlay(5, "zap4");
								break;
						}
					}
				}
			}
			
			Goto readyEnd;
		fire:
			STGF A 0 {
				
				if (Hacker(invoker.owner).internalCharge > 0 && ! invoker.weaponstatus[SG_Overheat])
					return state(resolveState("shoot"));
				else return state(resolveState("dryfire"));
			}
			goto Ready;
		shoot:
			STGF ABCD 1;
			STGF E 1 A_FireStun(1);
			STGF FGHI 1;
			STGF J 4;
			STGF K 2 {
				if (invoker.weaponStatus[SG_powerLevel] == 3) {
					invoker.weaponStatus[SG_powerLevel] = 1;
					invoker.weaponStatus[SG_Overheat] = 70;
					A_StartSound("weapon/overheat", CHAN_AUTO, CHANF_OVERLAP);
				}
			}
			Goto Ready;
		dryFire:
			STNG A 1 {
					A_WeaponOffset(0, -2, WOF_ADD);
					A_StartSound("weapon/dryfire");
			}
			goto ready;
		reload:
			---- A 1 offset(0,34) A_SetCrosshair(21);
			---- A 1 offset(1,38);
			---- A 2 offset(2,42);
			---- A 3 offset(3,46) { 
				if (invoker.weaponStatus[SG_PowerLevel] < 3)
					invoker.weaponStatus[SG_PowerLevel]++;
				else
					invoker.weaponStatus[SG_PowerLevel] = 1;
				A_StartSound("weapon/toggle");
			}
			goto changeFinish;
		changeFinish:
			---- A 2 offset(3,46);
			---- A 1 offset(2,42);
			---- A 1 offset(2,38);
			---- A 1 offset(1,34);
			goto ready;
		overheat:
			---- A 1 offset(0,34) A_SetCrosshair(21);
			loop;
		Zap0:
			SARC ABCDABCD 1;
			stop;
		Zap1:
			SARC DCBADCBA 1;
			stop;
		Zap2:
			SARC ACBDACBD 1;
			stop;
		Zap3:
			SARC DBCADBCA 1;
			stop;
		Zap4:
			SARC DBACBDBABCBDBABDBACBDBACDABDAB 1;
			stop;
		
		
	}
}

class HDB_StunRay : SS1SlowProjectile
{
	int stunLevel;
	float childRadius;
	override void postbeginplay(){
		super.postbeginplay();
		A_ChangeVelocity(speed*cos(pitch),0,speed*sin(-pitch),CVF_RELATIVE);
		childRadius = 0;
	}
	override void ExplodeSlowMissile(){
		switch(stunLevel){
			case 1:
				dmg = 2;
				break;
			case 2:
				dmg = 8;
				break;
			case 3:
				dmg = 15;
				break;
		}
		if(max(abs(pos.x),abs(pos.y))>=32768){destroy();return;}
		actor a=spawn("IdleDummy",pos,ALLOW_REPLACE);
		a.stamina=10;
		a.A_StartSound("stunGun/Zap",CHAN_AUTO, 0, 1.0, ATTN_STATIC);
		explodemissile(blockingline,null);
		FLineTraceData data;
		LineTrace(angle, 56, pitch, TRF_NOSKY, offsetz: height, data: data);
		Actor pActor = data.hitActor;
		if (pActor) {
			pActor.damageMobJ(self, master, dmg, "Beam");
			if (CanStun(pActor)) {
				pActor.setStateLabel("Pain");
				pActor.GiveInventory("StunHandler",1);
				StunHandler sh = stunHandler(pActor.findInventory("stunHandler"));
				if (SS1MobBase(pActor).bISROBOT)
					stunLevel = 0;
				sh.stunLevel = stunLevel;
			}
		}
		setstatelabel("death");
	}
	bool Canstun(actor o) {
		return (
			o is 'Serpentipede' ||
			o is 'HDHumanoid' ||
			(SS1MobBase(o).bISROBOT && stunLevel == 3) ||
			SS1MobBase(o).bISSTUNNABLE
			);
	}
	override void tick()
	{
		super.tick();
		childRadius+= childRadius < 3?0.1:0;
		A_SetScale(0.15*(childRadius/3));
	}
	default
	{
		+NOGRAVITY;
		mass 0;
		speed 4;//475;
		accuracy 300;
		//stamina 100;
		DamageType "Stun";
		scale 0.1;
		SS1SlowProjectile.penetration 0.0;
		+ROLLSPRITE;
	}
	states
	{
		Spawn:
			TNT1 A 1 bright {
					roll += 5;
					for (int i = 0; i < 5; i+=1){
					bool spawned;
					Actor zap;
					for (int j = 0; j < 360; j+=(360/stunLevel)){
						int toAdd = stunLevel>1?j:0;
						childRadius = stunLevel>1?childRadius:0;
						toAdd += roll + i;
						[spawned, zap] = A_SpawnItemEx("Shotzap", 0, i, 0, 0, 0, 0, 90, SXF_SETMASTER);
						zap.pitch = toAdd + j;
						if (stunLevel > 1){
							[spawned, zap] = A_SpawnItemEx("Shotzap", childRadius * cos(toAdd), i, childRadius * sin(0-toAdd), 0, 0, 0, 90, SXF_SETMASTER);
							zap.pitch = toAdd + j;
						}
					}
				}
			}
			wait;
		Crash:
		Death:
			SPRK ABC 2 bright;
			TNT1 A 0;
			stop;
	}
}
class shotzap : Actor
{
	default
	{
		speed 0;
		+FLATSPRITE;
		+NOGRAVITY;
		+NOINTERACTION;
		-SOLID;
		damagetype "none";
		mass 0;
		scale 0.2;
	}
	override void postbeginplay(){
		super.postbeginplay();
		A_ChangeVelocity(speed*cos(pitch),0,speed*sin(-pitch),CVF_RELATIVE);
	}
	states
	{
		spawn:
			STRC ABCD 1 bright {
						frame = random(0,3);
						A_Fadeout(0.05);
						}
			loop;
		death:
			TNT1 A 0;
			stop;
	}
	
}