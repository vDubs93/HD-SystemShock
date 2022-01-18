
Enum MagnumStatus
{
	MGNM_UNLOADED,
	MGNM_JUSTUNLOAD=4,
	MGNM_MAGTYPE,
	MGNM_MAG
	
	
}
class Magnum2100 : SS1Weapon
{
	int nextAmmoType;
	default
	{
		//$category "System Shock/Weapons"
		//$Title "Magnum 2100"
		//$Sprite "MNPPA0"
		weapon.slotnumber 2;
		+WEAPON.NOAUTOFIRE;
		scale 0.15;
		hdweapon.refid "mgn";
		Tag "Magnum 2100";
		Inventory.PickupMessage "Magnum 2100 Pistol.  Comes with a kick!";
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_RELOAD.."  Reload with hollow-point rounds\n"
		..WEPHELP_ALTRELOAD.." Reload with heavy osmium slugs\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		vector2 scc;
		vector2 bobb=bob*1.6;

		//if slide is pushed back, throw sights off line
		if(hpl.player.getpsprite(PSP_WEAPON).frame>=1){
			sb.SetClipRect(
				-10+bob.x,-5+bob.y,20,14,
				sb.DI_SCREEN_CENTER
			);
			scc=(0.7,0.8);
			bobb.y=clamp(bobb.y*1.1-3,-10,10);
		}else{
			sb.SetClipRect(
				-8+bob.x,-4+bob.y,16,10,
				sb.DI_SCREEN_CENTER
			);
			scc=(0.6,0.6);
			bobb.y=clamp(bobb.y,-8,8);
		}
		sb.drawimage(
			"frntsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"backsite",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
	}
	override double WeaponBulk() { return 10; }
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if(sb.hudlevel==1){
			
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("MGHollowMag")));
			if(nextmagloaded>=12){
				sb.drawimage("MGHMA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("MGHMB0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"MGHMA0","MGMGGREY",
				nextmagloaded,12,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("MGSlugMag")));
			if(nextmagloaded>=12){
				sb.drawimage("MGSMA0",(-58,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("MGSMB0",(-58,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"MGSMB0","MGMGGREY",
				nextmagloaded,12,
				(-58,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawimage("MGHMA0",(-20,-8),sb.DI_SCREEN_CENTER_BOTTOM,alpha:(!weaponstatus[MGNM_MAGType]&&weaponstatus[MGNM_MAG]>0)?1.:0.6,scale:(0.5,0.5));
			sb.drawimage("MGSMA0",(-29,-8),sb.DI_SCREEN_CENTER_BOTTOM,alpha:(weaponstatus[MGNM_MAGType]&&weaponstatus[MGNM_MAG]>0)?1.:0.6,scale:(0.5,0.5));
			sb.drawnum(hpl.countinv("MGHollowMag"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("MGSlugMag"),-55,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		sb.drawImage("MGNMICON", (-84, -3), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM, scale: (0.3, 0.3));
		sb.drawwepnum(weaponStatus[MGNM_MAG], 12);
		
	}
	
	override string,double getpickupsprite()
	{
		return "MGPKA0",.4;
	}
	

	
	action bool A_FireMagnum()
	{
		if (invoker.weaponStatus[MGNM_MAG] > 0){
			A_StartSound("magnum/fire");
			invoker.weaponStatus[MGNM_MAG]--;
			HDBulletActor.FireBullet(self, invoker.weaponstatus[MGNM_MAGTYPE]==0 ? "MGB_H" : "MGB_S");
			return true;
		} else A_StartSound("weapon/dryfire");
		return false;
			
	}
	states
	{
		Spawn:
			MGPK A -1;
			wait;
		Select0:
			MGNM A 0 { 
				if (invoker.weaponstatus[MGNM_MAG]>0)
					return state(resolveState("select0small"));
				else
					return state(resolveState("selectEmpty"));
			}
		selectEmpty:
			MGNM D 0;
			goto select0small;
		Deselect0:
			MGNM A 0{ 
				if (invoker.weaponstatus[MGNM_MAG]>0)
					return state(resolveState("Deselect0small"));
				else
					return state(resolveState("DeselectEmpty"));
			}
		DeselectEmpty:
			MGNM D 0;
			goto deselect0small;
		ready:
			TNT1 A 0 {
					if (invoker.weaponstatus[MGNM_MAG]>0)
						return state(resolveState("actualReady"));
					else
						return state(resolveState("readyEmpty"));
			}			
		actualReady:
			MGNM A 1 A_WeaponReady(WRF_ALL);
			goto readyEnd;
		ReadyEmpty:
			MGNM D 1 A_WeaponReady(WRF_ALL);
			goto readyend;
		Fire:
			TNT1 A 0 { 
				if (A_FireMagnum())
					return state(resolveState("Shoot"));
				else
					return state(resolveState("Ready"));
			}
		Shoot:
			MGNM B 1;
			#### C 1{
				if (!invoker.weaponstatus[MGNM_MAGTYPE])
					A_EjectCasing("MGHollowSpent",32,frandom(89,92),frandom(6,7),frandom(0,1));
				else
					A_EjectCasing("MGSlugSpent", 32, frandom(89,92), frandom(6,7),frandom(0,1));
			}
			#### D 1;
			#### E 1 A_MuzzleClimb(0,-3.5);
			#### F 10;
			#### E 4;
			goto Ready;
		user4:
		unload:
			MGNM A 0{
				invoker.weaponstatus[0]|=MGNM_JustUnload;
				if(invoker.weaponStatus[MGNM_MAG]>=0)setweaponstate("unmag");
			} goto Ready;
		
		reload:
			---- A 0{
				invoker.nextAmmoType = 0;
				invoker.weaponstatus[0]&=~MGNM_JustUnload;
				bool nomags=HDMagAmmo.NothingLoaded(self,"MGHollowMag");
				if(invoker.weaponStatus[MGNM_MAG]>=12 && invoker.weaponStatus[MGNM_MAGType] == 0)setweaponstate("nope");
				else if(nomags)setweaponstate("nope"); else setweaponstate("unmag");
			}goto unmag;
		user1:
		altreload:
			---- A 0 {
				invoker.nextAmmoType = 1;
				invoker.weaponstatus[0]&=~MGNM_JustUnload;
				bool nomags=HDMagAmmo.NothingLoaded(self,"MGSlugMag");
				if(invoker.weaponStatus[MGNM_MAG]>=15 && invoker.weaponStatus[MGNM_MAGType] == 1)setweaponstate("nope");
				else if(nomags)setweaponstate("nope"); else setweaponstate("unmag");
			}goto unmag;
		unmag:

			---- A 1 offset(0,34) A_SetCrosshair(21);
			---- A 1 offset(1,38);
			MGNM G 2 offset(2,42);
			MGNM H 3 offset(3,46);
			---- A 0{
				int pmg=invoker.weaponStatus[MGNM_MAG];
				invoker.weaponStatus[MGNM_MAG]=-1;
				
				int MType = invoker.weaponStatus[MGNM_MAGType];

				class<HDMagAmmo> WhichMag = (MType == 0 ? 'MGHollowMag' : 'MGSlugMag');
				if(pmg<0)
					setweaponstate("magout"); 
				else if(
					(!PressingUnload()&&!PressingReload() &&!PressingAltReload()))
				{
					A_StartSound("weapons/magout",8,CHANF_OVERLAP);
					HDMagAmmo.SpawnMag(self,WhichMag,pmg);
					setweaponstate("magout");
				}
				else{
					A_StartSound("weapons/magout",8,CHANF_OVERLAP);
					HDMagAmmo.GiveMag(self,WhichMag,pmg);
					A_StartSound("weapons/pocket",9);
					setweaponstate("pocketmag");
				}
			}
		pocketmag:
			---- AAA 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			goto magout;
		magout:
			---- A 0{
				if(invoker.weaponstatus[0]&MGNM_JustUnload)setweaponstate("unloadend");
				else { 
					setweaponstate("loadmag");
				}
			}
	
		loadmag:
			---- HHH 5;
			MGNM G 2;
			MGNM D 4 offset(0,46) { A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
					A_StartSound("weapons/magout",9,CHANF_OVERLAP);
					}
			---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			---- A 3;
			MGNM A 0 {
					int MType = invoker.nextAmmoType;
					invoker.weaponStatus[MGNM_MAGType] = Mtype;
				class<HDMagAmmo> WhichMag = MType == 0 ? 'MGHollowMag' : 'MGSlugMag';
				let mmm=hdmagammo(findinventory(WhichMag));
				if(mmm){
					invoker.weaponStatus[MGNM_MAG]=mmm.TakeMag(true);
					A_StartSound("Dartgun/LoadClip",8);
					invoker.weaponstatus[MGNM_unloaded] = 0;
				}
			}
			goto reloadend;
		reloadend:
			---- A 2 offset(3,46);
			---- A 1 offset(2,42);
			---- A 1 offset(2,38);
			---- A 1 offset(1,34);
			goto Ready;
		unloadend:
			MGNM H 2 offset(3,46);
			MGNM G 1 offset(2,42);
			MGNM D 1 offset(2,38);
			---- A 1 offset(1,34);
			goto nope;
		}
	override void initializewepstats(bool idfa){
		weaponstatus[MGNM_MAG]=12;
		weaponstatus[MGNM_MAGTYPE]=0;
	}
}

class MGHollowMag:HDMagAmmo {
	default{
		//$Category "System Shock/Ammunition"
		//$Title "Hollow-point Magazine"
		//$Sprite "MGHMA0"

		hdmagammo.maxperunit 12;
		hdmagammo.roundtype "MGHollowRound";
		hdmagammo.roundbulk ENC_9_LOADED;
		hdmagammo.magbulk ENC_9MAG_EMPTY;
		hdpickup.refid "mgh";
		tag "12-round Hollow-point Magazine";
		inventory.pickupmessage "Picked up a hollow-point Magazine";
		scale 0.3;
		inventory.maxamount 100;
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite;
		if(thismagamt>12)magsprite="MGHMA0";
		else magsprite="MGHMB0";
		return magsprite,"MGNRA0","MGHollowRound",.4;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("SS1Magnum");
	}
	states(actor){
	spawn:
		MGHM A -1 nodelay;
		stop;
	spawnempty:
		MGHM B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1,1,3,3,3,3,0,2)*90;
		}stop;
	}
}

class MGHollowRound:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+cannotpush
		+forcexybillboard
		+rollsprite +rollcenter
		+hdpickup.multipickup
		xscale 0.5;
		yscale 0.7;
		inventory.pickupmessage "Picked up a hollow-point magnum round.";
		hdpickup.refid "hpr";
		tag "Hollow-point magnum round";
		hdpickup.bulk ENC_355;
		inventory.icon "MGNRA0";
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("SS1Magnum");
	}
	states{
	spawn:
		MGNR A -1;
	}
}

class MGHollowSpent:HDDebris{
	default{
		bouncesound "misc/casing3";scale 0.6;
	}
	states{
	spawn:
		MGRS A 2 nodelay{
			A_SetRoll(roll+45,SPF_INTERPOLATE);
		}loop;
	death:
		MGRS # -1;
	}
}


class MGSlugMag:HDMagAmmo {
	default{
		//$Category "System Shock/Ammunition"
		//$Title "Slug Magazine"
		//$Sprite "MGSMA0"

		hdmagammo.maxperunit 12;
		hdmagammo.roundtype "MGSlugRound";
		hdmagammo.roundbulk ENC_9_LOADED;
		hdmagammo.magbulk ENC_9MAG_EMPTY;
		hdpickup.refid "mgS";
		tag "12-round slug Magazine";
		inventory.pickupmessage "Picked up a heavy osmium slug Magazine";
		scale 0.3;
		inventory.maxamount 100;
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite;
		if(thismagamt>12)magsprite="MGSMA0";
		else magsprite="MGSMB0";
		return magsprite,"MGNRA0","MGSlugRound",.4;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("SS1Magnum");
	}
	states(actor){
	spawn:
		MGSM AB -1 nodelay{
			int amt=mags[0];
			if(amt>14)frame=0;
			else if(amt>0)frame=1;
		}stop;
	spawnempty:
		MGSM B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1,1,3,3,3,3,0,2)*90;
		}stop;
	}
}
class MGSlugRound:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+cannotpush
		+forcexybillboard
		+rollsprite +rollcenter
		+hdpickup.multipickup
		xscale 0.5;
		yscale 0.7;
		inventory.pickupmessage "Picked up a heavy osmium slug magnum round.";
		hdpickup.refid "osr";
		tag "Osmium slug magnum round";
		hdpickup.bulk ENC_355;
		inventory.icon "MGNRB0";
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("SS1Magnum");
	}
	states{
	spawn:
		MGNR B -1;
	}
}

class MGSlugSpent:HDDebris{
	default{
		bouncesound "misc/casing3";scale 0.6;
	}
	states{
	spawn:
		MGRS B 2 nodelay{
			A_SetRoll(roll+45,SPF_INTERPOLATE);
		}loop;
	death:
		MGRS # -1;
	}
}




/* Taken from a comment by HexaDoken on the HD discord
-speed: in mu/tic. divide by 1.2 to get meters/second
-mass: gram x10
-pushfactor: apparently just completely arbitrary. most bullets have 0.4, .355 has 0.3 and shot has 0.5.
 7mm and bronto have 0.05, which confuses me enormously because they are basically nothing alike. pushfactor significantly
 affects penetration and shield damage, but doesn't affect flesh damage much at all. it also affects how straight a bullet flies,
 but you need to exceed like 5 push before it starts significantly deviating.
-accuracy: how pointy a bullet is. shot is 200 which is just spherical. 0 is presumably flat. rifles are 600+ which is Hella Pointy
-stamina: bullet diameter, in mm x100
-hardness: arbitrary value, most bullets are 3
-woundhealth: unlisted parameter, how frangible a bullet is. most bullets are 5-10. 4mm is designed to be Frangible As Heck and gets 40
*/

class MGB_H:SS1Bullet{
	default{
		pushfactor 2;
		mass 130;
		speed 300;//475;
		accuracy 300;
		stamina 900;
		woundhealth 10;
		hdbulletactor.hardness 1;
		SS1Bullet.penetration 30;
		SS1Bullet.dmg 60;
		SS1Bullet.OffenseValue 4;
	}
	
}

class MGB_S:SS1Bullet{
	default{
		pushfactor 0.4;
		mass 150;
		speed 350;//475;
		accuracy 600;
		stamina 900;
		woundhealth 10;
		hdbulletactor.hardness 5;
		SS1Bullet.penetration 25;
		SS1Bullet.dmg 85;
		SS1Bullet.OffenseValue 5;
	}

}