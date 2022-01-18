
Enum MiniPistolStatus
{
	MP_UNLOADED,
	MP_JUSTUNLOAD=4,
	MP_MAGTYPE,
	MP_MAG
	
	
}
class ML41Minipistol : SS1Weapon
{
	int nextAmmoType;
	default
	{
		//$category "System Shock/Weapons"
		//$Title "ML-41 Minipistol"
		//$Sprite "MNPPA0"
		weapon.slotnumber 2;
		+WEAPON.NOAUTOFIRE;
		scale 0.2;
		hdweapon.refid "mlp";
		Tag "ML-41 MiniPistol";
		Inventory.PickupMessage "ML-41 9mm MiniPistol. Does the job";
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_RELOAD.."  Reload with standard bullets\n"
		..WEPHELP_ALTRELOAD.." Reload with Teflon-coated bullets\n"
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
			
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("MPStandardMag")));
			if(nextmagloaded>=15){
				sb.drawimage("MPSMA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("MPSMB0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"MPSMB0","MPMGGREY",
				nextmagloaded,15,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("MPTeflonMag")));
			if(nextmagloaded>=15){
				sb.drawimage("MPTMA0",(-58,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("MPTMB0",(-58,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"MPTMB0","MPMGGREY",
				nextmagloaded,15,
				(-58,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawimage("MPSMA0",(-20,-8),sb.DI_SCREEN_CENTER_BOTTOM,alpha:(!weaponstatus[MP_MAGType]&&weaponstatus[MP_MAG]>0)?1.:0.6,scale:(0.5,0.5));
			sb.drawimage("MPTMA0",(-29,-8),sb.DI_SCREEN_CENTER_BOTTOM,alpha:(weaponstatus[MP_MAGType]&&weaponstatus[MP_MAG]>0)?1.:0.6,scale:(0.5,0.5));
			sb.drawnum(hpl.countinv("MPStandardMag"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("MPTeflonMag"),-55,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		sb.drawImage("MPICON", (-84, -3), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM, scale: (0.5, 0.5));
		sb.drawwepnum(weaponStatus[MP_MAG], 15);
		
	}
	
	override string,double getpickupsprite()
	{
		return "MNPPA0",.4;
	}
	

	
	action bool A_FireMP()
	{
		if (invoker.weaponStatus[MP_MAG] > 0){
			A_StartSound("minipistol/fire");
			invoker.weaponStatus[MP_MAG]--;
			HDBulletActor.FireBullet(self, invoker.weaponstatus[MP_MAGTYPE]==0 ? "MPB_S" : "MPB_T");
			return true;
		} else A_StartSound("weapon/dryfire");
		return false;
			
	}
	states
	{
		Spawn:
			MNPP A -1;
			wait;
		Select0:
			MNPS A 0 { 
				if (invoker.weaponstatus[MP_MAG]>0)
					return state(resolveState("select0small"));
				else
					return state(resolveState("selectEmpty"));
			}
		selectEmpty:
			MNPF B 0;
			goto select0small;
		Deselect0:
			MNPS A 0{ 
				if (invoker.weaponstatus[MP_MAG]>0)
					return state(resolveState("Deselect0small"));
				else
					return state(resolveState("DeselectEmpty"));
			}
		DeselectEmpty:
			MNPF B 0;
			goto deselect0small;
		ready:
			TNT1 A 0 {
					if (invoker.weaponstatus[MP_MAG]>0)
						return state(resolveState("actualReady"));
					else
						return state(resolveState("readyEmpty"));
			}			
		actualReady:
			MNPS A 1 A_WeaponReady(WRF_ALL);
			goto readyEnd;
		ReadyEmpty:
			MNPF B 1 A_WeaponReady(WRF_ALL);
			goto readyend;
		Fire:
			TNT1 A 0 { 
				if (A_FireMP())
					return state(resolveState("Shoot"));
				else
					return state(resolveState("Ready"));
			}
		Shoot:
			MNPF A 2;
			#### B 2{
				if (!invoker.weaponstatus[MP_MAGTYPE])
					A_EjectCasing("MPStandardSpent",12,-frandom(89,92),frandom(6,7),frandom(0,1));
				else
					A_EjectCasing("MPTeflonSpent", 12, -frandom(89,92), frandom(6,7),frandom(0,1));
			}
			#### C 3;
			#### D 2;
			goto Ready;
		user4:
		unload:
			MNPF B 0{
				invoker.weaponstatus[0]|=MP_JustUnload;
				if(invoker.weaponStatus[MP_MAG]>=0)setweaponstate("unmag");
			} goto Ready;
		
		reload:
			---- A 0{
				invoker.nextAmmoType = 0;
				invoker.weaponstatus[0]&=~MP_JustUnload;
				bool nomags=HDMagAmmo.NothingLoaded(self,"MPStandardMag");
				if(invoker.weaponStatus[MP_MAG]>=15 && invoker.weaponStatus[MP_MAGType] == 0)setweaponstate("nope");
				else if(nomags)setweaponstate("nope"); else setweaponstate("unmag");
			}goto unmag;
		user1:
		altreload:
			---- A 0 {
				invoker.nextAmmoType = 1;
				invoker.weaponstatus[0]&=~MP_JustUnload;
				bool nomags=HDMagAmmo.NothingLoaded(self,"MPTeflonMag");
				if(invoker.weaponStatus[MP_MAG]>=15 && invoker.weaponStatus[MP_MAGType] == 1)setweaponstate("nope");
				else if(nomags)setweaponstate("nope"); else setweaponstate("unmag");
			}goto unmag;
		unmag:

			---- A 1 offset(0,34) A_SetCrosshair(21);
			---- A 1 offset(1,38);
			---- A 2 offset(2,42);
			---- A 3 offset(3,46);
			---- A 0{
				int pmg=invoker.weaponStatus[MP_MAG];
				invoker.weaponStatus[MP_MAG]=-1;
				
				int MType = invoker.weaponStatus[MP_MAGType];

				class<HDMagAmmo> WhichMag = (MType == 0 ? 'MPStandardMag' : 'MPTeflonMag');
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
				if(invoker.weaponstatus[0]&MP_JustUnload)setweaponstate("reloadend");
				else setweaponstate("loadmag");
			}
	
		loadmag:
			---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			---- A 0 A_StartSound("weapons/magout",9,CHANF_OVERLAP);
			---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			---- A 3;
			MNPS A 0{
					int MType = invoker.nextAmmoType;
					invoker.weaponStatus[MP_MAGType] = Mtype;
				class<HDMagAmmo> WhichMag = MType == 0 ? 'MPStandardMag' : 'MPTeflonMag';
				let mmm=hdmagammo(findinventory(WhichMag));
				if(mmm){
					invoker.weaponStatus[MP_MAG]=mmm.TakeMag(true);
					A_StartSound("Dartgun/LoadClip",8);
					invoker.weaponstatus[MP_unloaded] = 0;
				}
			}
			goto reloadend;
		reloadend:
			---- A 2 offset(3,46);
			---- A 1 offset(2,42);
			---- A 1 offset(2,38);
			---- A 1 offset(1,34);
			goto nope;
	
		}
	override void initializewepstats(bool idfa){
		weaponstatus[MP_MAG]=15;
		weaponstatus[MP_MAGTYPE]=0;
	}
}

class MPStandardMag:HDMagAmmo {
	default{
		//$Category "System Shock/Ammunition"
		//$Title "Minipistol Standard Magazine"
		//$Sprite "MPSMA0"

		hdmagammo.maxperunit 15;
		hdmagammo.roundtype "MPStandardRound";
		hdmagammo.roundbulk ENC_9_LOADED;
		hdmagammo.magbulk ENC_9MAG_EMPTY;
		hdpickup.refid "mps";
		tag "Minipistol Standard Magazine";
		inventory.pickupmessage "Picked up a standard Minipistol Magazine";
		scale 0.3;
		inventory.maxamount 100;
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite;
		if(thismagamt>14)magsprite="MPSMA0";
		else magsprite="MPSMB0";
		return magsprite,"MPSRA0","MPStandardRound",.4;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("ML41Minipistol");
	}
	states(actor){
	spawn:
		MPSM AB -1 nodelay{
			int amt=mags[0];
			if(amt>14)frame=0;
			else if(amt>0)frame=1;
		}stop;
	spawnempty:
		MPSM B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1,1,3,3,3,3,0,2)*90;
		}stop;
	}
}

class MPStandardRound:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+cannotpush
		+forcexybillboard
		+rollsprite +rollcenter
		+hdpickup.multipickup
		xscale 0.5;
		yscale 0.7;
		inventory.pickupmessage "Picked up a standard Minipistol round.";
		hdpickup.refid HDLD_NINEMIL;
		tag "Standard Minipistol Round";
		hdpickup.bulk ENC_9;
		inventory.icon "MPSRA0";
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("ML41Minipistol");
	}
	states{
	spawn:
		MPSR A -1;
	}
}

class MPStandardSpent:HDDebris{
	default{
		bouncesound "misc/casing3";scale 0.6;
	}
	states{
	spawn:
		MPSS A 2 nodelay{
			A_SetRoll(roll+45,SPF_INTERPOLATE);
		}loop;
	death:
		MPSS # -1;
	}
}

class MPTeflonMag:HDMagAmmo {
	default{
		//$Category "System Shock/Ammunition"
		//$Title "Minipistol Teflon Magazine"
		//$Sprite "MPTMA0"

		hdmagammo.maxperunit 15;
		hdmagammo.roundtype "MPTeflonRound";
		hdmagammo.roundbulk ENC_9_LOADED;
		hdmagammo.magbulk ENC_9MAG_EMPTY;
		hdpickup.refid "mpT";
		tag "Minipistol Teflon Magazine";
		inventory.pickupmessage "Picked up a teflon Minipistol Magazine";
		scale 0.3;
		inventory.maxamount 100;
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite;
		if(thismagamt>14)magsprite="MPTMA0";
		else magsprite="MPTMB0";
		return magsprite,"MPTRA0","MPTeflonRound",.4;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("ML41Minipistol");
	}
	states(actor){
	spawn:
		MPTM AB -1 nodelay{
			int amt=mags[0];
			if(amt>14)frame=0;
			else if(amt>0)frame=1;
		}stop;
	spawnempty:
		MPTM B -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1,1,3,3,3,3,0,2)*90;
		}stop;
	}
}

class MPTeflonRound:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+cannotpush
		+forcexybillboard
		+rollsprite +rollcenter
		+hdpickup.multipickup
		xscale 0.5;
		yscale 0.7;
		inventory.pickupmessage "Picked up a Teflon-coated Minipistol round.";
		hdpickup.refid HDLD_NINEMIL;
		tag "Teflon-coated Minipistol Round";
		hdpickup.bulk ENC_9;
		inventory.icon "MPTRA0";
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("ML41Minipistol");
	}
	states{
	spawn:
		MPTR A -1;
	}
}

class MPTeflonSpent:HDDebris{
	default{
		bouncesound "misc/casing3";scale 0.6;
	}
	states{
	spawn:
		MPTS A 2 nodelay{
			A_SetRoll(roll+45,SPF_INTERPOLATE);
		}loop;
	death:
		MPTS # -1;
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

class MPB_S:SS1Bullet{
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

class MPB_T:SS1Bullet{
	default{
		pushfactor 0.4;
		mass 120;
		speed HDCONST_MPSTODUPT*350;//475;
		accuracy 600;
		stamina 900;
		woundhealth 10;
		hdbulletactor.hardness 5;
		SS1Bullet.penetration 30;
		SS1Bullet.dmg 30;
	}

}