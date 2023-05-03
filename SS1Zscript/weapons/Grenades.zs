class SS1GrenadeThrower : HDGrenadeThrower
{
	int grenadeType;
	int cooldown;
	override string,double getpickupsprite(){return "FRGRA0",0.6;}
	default
	{
		+Inventory.UNDROPPABLE;
		weapon.selectionorder 1020;
		weapon.slotnumber 0;
		tag "fragmentation grenades";
		hdgrenadethrower.ammotype "SS1FragGrenadeAmmo";
		hdgrenadethrower.throwtype "SS1FragGrenade";
		hdgrenadethrower.spoontype "SS1FragSpoon";
		hdgrenadethrower.wiretype "Tripwire";
		inventory.icon "FRGRA0";
	}
	
	override string gethelptext(){
		if(weaponstatus[0]&FRAGF_SPOONOFF)return
		WEPHELP_FIRE.."  Wind up, release to throw\n(\cxSTOP READING AND DO THIS"..WEPHELP_RGCOL..")";
		String helpString = WEPHELP_FIRE.."  Pull pin/wind up (release to throw)\n";
		if (grenadeType == 1)
			helpString = helpString..WEPHELP_ALTFIRE.."  Pull pin, again to drop spoon\n";
		helpString = helpString..WEPHELP_RELOAD.."  Abort/Replace pin\n"
		..WEPHELP_ZOOM.."  Switch grenade type";
		return helpString;
	}
	
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			if (grenadeType == 1){
			sb.drawimage(
				(weaponstatus[0]&FRAGF_PINOUT)?"FRGRF0":"FRGRA0",
				(-52,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.6,0.6)
			);
			} else if (grenadeType == 2){
				sb.drawimage(
				(weaponstatus[0]&FRAGF_PINOUT)?"GSGRF0":"GSGRA0",
				(-52,-4),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.6,0.6)
			);
			}
			sb.drawnum(hpl.countinv(grenadeammotype),-45,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		sb.drawwepnum(
			hpl.countinv(grenadeammotype),
			(HDCONST_MAXPOCKETSPACE/ENC_FRAG)
		);
		sb.drawwepnum(hdw.weaponstatus[FRAGS_FORCE],50,posy:-10,alwaysprecise:true);
		if(!(hdw.weaponstatus[0]&FRAGF_SPOONOFF)){
			sb.drawrect(-21,-19,5,4);
			if(!(hdw.weaponstatus[0]&FRAGF_PINOUT))sb.drawrect(-25,-18,3,2);
		}else{
			int timer=hdw.weaponstatus[FRAGS_TIMER];
			if(timer%3)sb.drawwepnum(140-timer,140,posy:-15,alwaysprecise:true);
		}
	}
	override void tick(){
		super.tick();
		if (cooldown > 0)
			cooldown--;
		
	}
	void changeGrenadeType()
	{
		
		int buttons = owner.getPlayerInput(INPUT_BUTTONS);
		int oldButtons = owner.getPlayerInput(INPUT_OLDBUTTONS);
		if((buttons & (BT_ZOOM)) && !(oldButtons & (BT_ZOOM))){
			switch(grenadeType){
				case 1:
					grenadeammoType = "SS1GasGrenadeAmmo";
					grenadeType = 2;
					throwtype = "SS1GasGrenade";
					A_SetHelpText();
					break;
				case 2:
					grenadeammoType = "SS1FragGrenadeAmmo";
					grenadeType = 1;
					throwtype = "SS1FragGrenade";
					A_SetHelpText();
					break;
			}
		}
	}
	override void postbeginplay()
	{
		super.postbeginplay();
		grenadeType = 1;
	}
	action bool NoGrenades(){
		bool result;
		switch (invoker.grenadeType){
			case 1:
				result = !(invoker.weaponstatus[0]&FRAGF_INHAND)&&!countinv("SS1FragGrenadeAmmo");
				break;
			case 2:
				result = !(invoker.weaponstatus[0]&FRAGF_INHAND)&&!countinv("SS1GasGrenadeAmmo");
				break;
		}
		return result;
	}
	states
	{
	select0:
		TNT1 A 0 A_JumpIf(NoGrenades(),"selectinstant");
		TNT1 A 8{
			if(!countinv("NulledWeapon"))A_SetTics(tics+4);
			A_TakeInventory("NulledWeapon");
			invoker.weaponstatus[FRAGS_REALLYPULL]=0;
			invoker.weaponstatus[FRAGS_FORCE]=0;
		}
		FRGG B 1 A_Raise(32);
		wait;
	selectinstant:
		TNT1 A 0 A_WeaponBusy(false);
	readytodonothing:
		TNT1 A 0 A_JumpIf(pressing(BT_SPEED),2);
		TNT1 A 0 A_JumpIf(!NoGrenades(), "select");
		TNT1 A 1 A_WeaponReady(WRF_NOFIRE | WRF_ALLOWZOOM);
		loop;
		//TNT1 A 0 A_SelectWeapon("HDFist");
		TNT1 A 1 A_WeaponReady(WRF_NOFIRE | WRF_ALLOWZOOM);
		wait;
	deselect0:
		---- A 1{
			if(invoker.weaponstatus[0]&FRAGF_PINOUT)A_SetTics(8);
			else if(NoGrenades())setweaponstate("deselectinstant");
			invoker.ReturnHandToOwner();
		}
		---- A 1 A_Lower(72);
		wait;
	deselectinstant:
		TNT1 A 0 A_Lower(999);
		wait;
	ready:
		FRGG B 0{
			invoker.weaponstatus[FRAGS_FORCE]=0;
			invoker.weaponstatus[FRAGS_REALLYPULL]=0;
			if (noGrenades())
				setWeaponState("selectInstant");
		}
		FRGG B 1 A_WeaponReady(WRF_ALL);
		goto ready3;
	ready3:
		---- A 0{
			invoker.weaponstatus[0]&=~FRAGF_JUSTTHREW;
			A_WeaponBusy(false);
		}goto readyend;

	zoom:
		TNT1 A 0 {invoker.changeGrenadeType();}
		goto ready;

	pinout:
		FRGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		loop;

	altfire:
		TNT1 A 0 A_JumpIf(invoker.grenadeType==2,"nope");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&FRAGF_SPOONOFF,"nope");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&FRAGF_PINOUT,"startcooking");
		TNT1 A 0 A_JumpIf(NoGrenades(),"selectinstant");
		TNT1 A 0 A_Refire();
		goto ready;
	althold:
		TNT1 A 0 A_JumpIf(invoker.grenadeType==2,"nope");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&FRAGF_SPOONOFF,"nope");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&FRAGF_PINOUT,"nope");
		TNT1 A 0 A_JumpIf(NoGrenades(),"selectinstant");
		goto startpull;
	startpull:
		FRGG B 1{
			if(invoker.weaponstatus[FRAGS_REALLYPULL]>=26)setweaponstate("endpull");
			else invoker.weaponstatus[FRAGS_REALLYPULL]++;
		}
		FRGG B 0 A_Refire();
		goto ready;
	endpull:
		FRGG B 1 offset(0,34);
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,38);
		TNT1 A 6;
		TNT1 A 3 A_PullPin();
		TNT1 A 0 A_Refire();
		goto ready;
	startcooking:
		TNT1 A 6 A_StartCooking();
		TNT1 A 0 A_Refire();
		goto ready;
	fire:
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&FRAGF_JUSTTHREW,"nope");
		TNT1 A 0 A_JumpIf(NoGrenades(),"selectinstant");
		TNT1 A 0 A_JumpIfInventory("PowerStrength",1,3);
		FRGG B 1 offset(0,34);
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,38);
		TNT1 A 0 A_Refire();
		goto ready;
	hold:
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&FRAGF_JUSTTHREW,"nope");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&FRAGF_PINOUT,"hold2");
		TNT1 A 6 A_JumpIf(invoker.weaponstatus[FRAGS_FORCE]>=1,"hold2");
		TNT1 A 6 A_JumpIfInventory("PowerStrength",1,1);
		TNT1 A 0 A_JumpIf(NoGrenades(),"selectinstant");
		TNT1 A 3 A_PullPin();
	hold2:
		TNT1 A 0 A_JumpIf(NoGrenades(),"selectinstant");
		FRGG E 0 A_JumpIf(invoker.weaponstatus[FRAGS_FORCE]>=40,"hold3a");
		FRGG D 0 A_JumpIf(invoker.weaponstatus[FRAGS_FORCE]>=30,"hold3a");
		FRGG C 0 A_JumpIf(invoker.weaponstatus[FRAGS_FORCE]>=20,"hold3");
		FRGG B 0 A_JumpIf(invoker.weaponstatus[FRAGS_FORCE]>=10,"hold3");
		goto hold3;
	hold3a:
		FRGG # 0{
			if(invoker.weaponstatus[FRAGS_FORCE]<50)invoker.weaponstatus[FRAGS_FORCE]++;
		}
	hold3:
		FRGG # 1{
			A_WeaponReady(
				invoker.weaponstatus[0]&FRAGF_SPOONOFF?WRF_NOFIRE:WRF_NOFIRE|WRF_ALLOWRELOAD
			);
			if(invoker.weaponstatus[FRAGS_FORCE]<50)invoker.weaponstatus[FRAGS_FORCE]++;
		}
		TNT1 A 0 A_Refire();
		goto throw;
	throw:
		TNT1 A 0 A_JumpIf(NoGrenades(),"selectinstant");
		FRGG A 1 offset(0,34) A_TossGrenade();
		FRGG A 1 offset(0,38);
		FRGG A 1 offset(0,48);
		FRGG A 1 offset(0,52);
		FRGG A 0 A_Refire();
		goto ready;
	reload:
		TNT1 A 0 A_JumpIf(NoGrenades(),"selectinstant");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[FRAGS_FORCE]>=1,"pinbackin");
		TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&FRAGF_PINOUT,"altpinbackin");
		goto ready;
	pinbackin:
		FRGG B 1 offset(0,34) A_ReturnHandToOwner();
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,38);
	altpinbackin:
		FRGG A 0 A_JumpIf(invoker.weaponstatus[FRAGS_TIMER]>0,"juststopthrowing");
		TNT1 A 8 A_ReturnHandToOwner();
		TNT1 A 0 A_Refire("nope");
		FRGG B 1 offset(0,38);
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,34);
		goto ready;
	juststopthrowing:
		TNT1 A 10;
		FRGG A 0{invoker.weaponstatus[FRAGS_FORCE]=0;}
		TNT1 A 0 A_Refire();
		FRGG B 1 offset(0,38);
		FRGG B 1 offset(0,36);
		FRGG B 1 offset(0,34);
		goto ready;
	spawn:
		TNT1 A 1;
		TNT1 A 0 A_SpawnItemEx(invoker.grenadeammotype,SXF_NOCHECKPOSITION);
		stop;

	}
}

class SS1FragGrenade : HDFragGrenade
{
	default
	{
		hdfraggrenade.rollertype "SS1FragGrenadeRoller";
	}
	states{
	spawn:
		FRGR BCD 2;
		loop;
	}
}

class SS1GasGrenade : HDFragGrenade
{
	default
	{
		hdfraggrenade.rollertype "SS1GasGrenadeRoller";
	}
	states{
	spawn:
		GSTH ABCDEFGH 2;
		loop;
	death:
		TNT1 A 10{
			bmissile=false;
			let gr=HDFragGrenadeRoller(spawn(rollertype,self.pos,ALLOW_REPLACE));
			if(!gr)return;
			gr.target=self.target;gr.master=self.master;
			gr.fuze=self.fuze;
			gr.vel=self.keeprolling;
			gr.keeprolling=self.keeprolling;
			gr.A_StartSound("misc/fragknock",CHAN_BODY);
			gr.A_StartSound("gasgrenade/hiss",0);
			HDMobAI.Frighten(gr,512);
		}stop;
	}
}


class SS1FragGrenadeRoller:HDFragGrenadeRoller
{
	states
	{
		spawn:
			FRGR A 0 nodelay{
				HDMobAI.Frighten(self,512);
			}
			goto spawn2;
	}
}

class SS1GasGrenadeRoller:HDFragGrenadeRoller
{
	override void tick(){
		console.printf(""..fuze);
		if(isfrozen())return;
		else if(bnointeraction){
			NextTic();
			return;
		}else{
			fuze++;
			if(fuze>=280 && !bnointeraction) {
				setstatelabel("destroy");
				NextTic();
				return;
			} else HDActor.tick();
		}
	}
	states
	{
		spawn:
			GSGR A 0 nodelay{
				HDMobAI.Frighten(self,512);
			}
		spawn2:
			#### BCDE 2{
				if(abs(vel.z-keeprolling.z)>10)A_StartSound("misc/fragknock",CHAN_BODY);
				else if(floorz>=pos.z)A_StartSound("misc/fragroll");
				keeprolling=vel;
				if(abs(vel.x)<0.4 && abs(vel.y)<0.4) setstatelabel("death");
				A_SpawnItemEx("GasGrenadeCloud",0,0,0,frandom(-1,1),frandom(-1,1),frandom(0.01,0.5));
			}
			loop;
		bounce:
		---- A 0{
			bmissile=false;
			vel*=0.3;
			A_SpawnItemEx("GasGrenadeCloud",0,0,0,frandom(-1,1),frandom(-1,1),frandom(0.01,0.5));
		}goto spawn2;
		death:
		---- A 2{
			if(abs(vel.z-keeprolling.z)>3){
				A_StartSound("misc/fragknock",CHAN_BODY);
				keeprolling=vel;
			}
			A_SpawnItemEx("GasGrenadeCloud",0,0,0,frandom(-1,1),frandom(-1,1),frandom(0.01,0.5));
			if(abs(vel.x)>0.4 || abs(vel.y)>0.4) setstatelabel("spawn");
		}wait;
		destroy:
			#### # 1 {
				
				bsolid=false;bpushable=false;bmissile=false;bnointeraction=true;bshootable=false;}
			
			stop;
	}
}
class GasGrenadeCloud : SS1SlowProjectile
{
	default
	{
		height 32;
		radius 32;
		renderstyle "Translucent";
		alpha 0.5;
		+THRUACTORS
		+NOCLIP;
		+NoGravity
		Damage 150;
		DamageType "Gas";
		SS1SlowProjectile.penetration 100;
		SS1SlowProjectile.offenseValue 3;
		SS1SlowProjectile.dmg 150;
	}
	
	override void postbeginplay(){
		if(max(abs(pos.x),abs(pos.y),abs(pos.z))>=32768){destroy();return;}
	}
	
	action void A_GasDamage(){
		invoker.doDamage();
	}
	override void explodeslowmissile(){}
	void doDamage(){
		if (alpha <= 0)
			setStateLabel("Death");
		alpha-= 0.005;
		BlockThingsIterator itr = BlockThingsIterator.Create(self,128);
            while (itr.next()) {
                let next = itr.thing;
                double dist = Distance3D(next);
				if (next.bKILLED || 
					next.countinv("WornRadsuit") ||
					next.bNOBLOOD ||
					dist > radius ||
					!CheckSight (next, SF_IGNOREVISIBILITY | SF_IGNOREWATERBOUNDARY)
					)
                    continue;  
			dmg = 150;
			if (next is 'SS1MobBase'){
				if (penetration < SS1MobBase(next).armorValue) {
					console.printf("Damage reduced by "..SS1MobBase(next).armorValue - penetration);
					dmg -= (SS1MobBase(next).armorValue - penetration);
				}
			
			if (hd_debug)
				console.printf("initial damage is "..dmg..".");
			int defenceValue = SS1MobBase(next).defenceValue;
			int modifier;
			if (offenseValue > defenceValue) {

				modifier = (offenseValue - defenceValue) + random_bell_modifier();
				if (hd_debug)
					console.printf("Chance for critical hit, modifier is %d", modifier);
				if (modifier < -3) {
					dmg /= (modifier+3)^2;
				} else if (modifier > 3) {
					if (modifier > 12)
						modifier = 12;
					dmg = (dmg * modifier)/3;
					if (hd_debug)
						console.printf(string.format("Critical Hit for %d damage",dmg)); 
				}
			} else if(hd_debug)
				console.printf("No chance for critical hit");
			}
			if (hd_debug)
				console.printf("randomizing damage");
			dmg *= frandom(0.9, 1.1);
			name damagetype = 'Gas';
			next.poisonMobj(self, target, dmg, 10, 0, damagetype);
			if (hd_debug)
				console.printf(string.format("Final damage is %d", dmg));
			
		}
	}
	states{
		spawn:
			GCLD A 1;
		doDamage:
			GCLD A 1 A_GasDamage();
			loop;
		death:
			TNT1 A 0;
			stop;
	}
}

class SS1FragSpoon:HDDebris{
	default{
		scale 0.3;bouncefactor 0.6;
		bouncesound "misc/casing4";
	}
	override void postbeginplay(){
		super.postbeginplay();
		A_StartSound("weapons/grenopen",CHAN_VOICE);
	}
	states{
	spawn:
		FRSP A 2{roll+=40;}wait;
	death:
		FRSP A -1;
	}
}

class SS1FragGrenadeAmmo:HDAmmo{
	default{
		//$Category "System Shock/Ammunition"
		//$Title "Frag Grenade"
		//$Sprite "FRGRA0"
	
		+forcexybillboard
		inventory.icon "FRGRA0";
		inventory.amount 1;
		scale 0.3;
		inventory.maxamount 50;
		inventory.pickupmessage "Picked up a fragmentation hand grenade.";
		inventory.pickupsound "weapons/pocket";
		tag "fragmentation grenades";
		hdpickup.refid "grf";
		hdpickup.bulk ENC_FRAG;
	}
	states{
	spawn:
		FRGR A -1;stop;
	}
}

class SS1GasGrenadeAmmo:HDAmmo{
	default{
		//$Category "System Shock/Ammunition"
		//$Title "Gas Grenade"
		//$Sprite "GSGRA0"
	
		+forcexybillboard
		inventory.icon "GSGRA0";
		inventory.amount 1;
		scale 0.3;
		inventory.maxamount 50;
		inventory.pickupmessage "Picked up a Gas grenade.";
		inventory.pickupsound "weapons/pocket";
		tag "Gas grenades";
		hdpickup.refid "grg";
		hdpickup.bulk ENC_FRAG;
	}
	states{
	spawn:
		GSGR A -1;stop;
	}
}