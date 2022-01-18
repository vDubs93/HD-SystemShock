enum MagPulseProperties
{
		MagP_CurrAmmo,
		MagP_JustUnload
};
	
Class SS1MagCart : HDBattery
{
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("SS1MagPulse");
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite;
		if(thismagamt>13)magsprite="MPMGA0";
		else if(thismagamt>6)magsprite="MPMGB0";
		else if(thismagamt>0)magsprite="MPMGC0";
		else magsprite="MPMGD0";
		return magsprite,"MPPKA0","SS1MagCart",0.4;
	}
	default
	{
		hdmagammo.maxperunit 25;
		hdmagammo.roundtype "";
		tag "Magnetic Cartridge";
		hdpickup.refid HDLD_BATTERY;
		hdpickup.bulk ENC_BATTERY;
		hdmagammo.magbulk ENC_BATTERY;
		hdmagammo.mustshowinmagmanager true;
		inventory.pickupmessage "Picked up a magnetic cartridge.";
		inventory.icon "MPMGA0";
		scale 0.25;
	}
	states(actor){
		spawn:
			MPMG CAB -1 nodelay{
				int amt=mags[0];
				if(amt>17)frame=0;
				else if(amt>9)frame=1;
			}stop;
		spawnempty:
			MPMG D -1;
			stop;
	}
}
Class SS1MagPulse : SS1Weapon
{
	int user_ammo;
	property currAmmo: user_ammo;
	default
	{
		//$Category "System Shock/Weapons"
		//$Title "Mag-Pulse"
		//$Sprite "MPPKA0"
		+WEAPON.NOAUTOFIRE;
		weapon.SlotNumber 2;
		hdweapon.refid "mgp";
		HDWeapon.barrelSize 10, 0.2, 0.2;
		scale 0.25;
		tag "SB-20 Mag-pulse rifle";
		Inventory.pickupMessage "SB-20 Mag-pulse rifle.  Great for robots, not much else.";
		SS1MagPulse.currAmmo 25;
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_RELOAD.."  Reload mag cartridge\n"
		..WEPHELP_MAGMANAGER
		;
	}
	override string,double getpickupsprite()
	{
		return "MPPKA0",0.25;
	}
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if(sb.hudlevel==1){
			
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("SS1MagCart")));
			if(nextmagloaded>=17){
				sb.drawimage("MPMGA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.4,0.4));
			}else if(nextmagloaded<1){
				sb.drawimage("MPMGD0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(0.4,0.4));
			} else if (nextmagloaded > 9)
				sb.drawimage("MPMGB0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.4,0.4));
			else if (nextmagloaded > 0)
				sb.drawimage("MPMGC0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.4,0.4));
			/*sb.drawbar(
				"MPMGE0","MPLSGREY",
				nextmagloaded,15,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);*/
		}
		sb.drawImage("MGPICON", (-84, -3), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM, scale: (0.25, 0.25));
		sb.drawwepnum(weaponStatus[MagP_CurrAmmo], 25);
	}
	
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		vector2 scc;
		vector2 bobb=bob*1.6;
		sb.SetClipRect(
				-8+bob.x,-4+bob.y,16,10,
				sb.DI_SCREEN_CENTER
			);
		
		scc=(1,1);
		bobb.y=clamp(bobb.y,-8,8);
		
		sb.drawimage(
			"sprqfrnt",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9,scale:scc
		);
		sb.SetClipRect(cx,cy,cw,ch);
		sb.drawimage(
			"MGPback",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
	}
	
	override void postbeginplay()
	{
		super.postbeginplay();
		weaponStatus[MagP_CurrAmmo] = user_ammo;
	}
	
	action bool A_FirePulse()
	{
		let hpl = Hacker(invoker.owner);
		
		if (hpl && invoker.weaponstatus[MagP_CurrAmmo] > 0) {
			A_StartSound("MagPulse/Fire");
			SS1MagPulseProjectile mpp;
			class<actor> mmm;
			mmm="SS1MagPulseProjectile";
			mpp=SS1MagPulseProjectile(spawn(mmm,(
				pos.xy,
				pos.z+HDWeapon.GetShootOffset(
					self,invoker.barrellength,
					invoker.barrellength-HDCONST_SHOULDERTORADIUS
				)
			),ALLOW_REPLACE));
			mpp.angle=angle;mpp.target=self;mpp.master=self;
			mpp.pitch=pitch;
			return true;
		} else {
			return false;
		}	
	}
	states
	{
		Spawn:
			MPPK A -1;
			wait;
		Select0:
			MPLS A 0;
			goto select0small;
		Deselect0:
			MPLS A 0;
			goto deselect0small;
		ready:
			MPLS A 1 {
				A_WeaponReady(WRF_ALL);
			}
			Goto readyEnd;
		fire:
			MPLS A 0 { 
				if (A_FirePulse()){
					invoker.weaponstatus[MagP_CurrAmmo]--;
					return state(resolveState("shoot"));
				}
				else return state(resolveState("dryfire"));
			}
			goto Ready;
		shoot:
			MPLS D 1;
			#### FHI 1;
			#### JKL 1;
			#### L 1;
			#### KJA 2;
			#### B 1 A_StartSound("weapons/magout",8,CHANF_OVERLAP);
			#### C 4;
			#### B 1 A_StartSound("weapons/magout",8,CHANF_OVERLAP);
			Goto Ready;
		dryFire:
			MPLS A 1 {
					A_WeaponOffset(0, 34);
					A_StartSound("weapon/dryfire");
			}
			goto ready;
		user4:
		unload:
			MPLS A 0{
				invoker.weaponstatus[MagP_JustUnload] = 1;
				if(invoker.weaponStatus[MagP_CurrAmmo]>=0)setweaponstate("unmag");
			} goto Ready;
		
		reload:
			---- A 0{
				invoker.weaponstatus[MagP_JustUnload] = 0;
				bool nomags=HDMagAmmo.NothingLoaded(self,"SS1MagCart");
				if(invoker.weaponStatus[MagP_CurrAmmo]>=25)setweaponstate("nope");
				else if(nomags) {
					setweaponstate("nope");
				}
				else {
					setweaponstate("unmag");
				}
			}goto unmag;
		unmag:

			---- A 1 offset(0,34) A_SetCrosshair(21);
			---- A 1 offset(1,38);
			---- A 2 offset(2,42);
			---- A 3 offset(3,46);
			---- A 0{
				int pmg=invoker.weaponStatus[MagP_CurrAmmo];
				invoker.weaponStatus[MagP_CurrAmmo]=-1;
				if(pmg<0)
					setweaponstate("magout"); 
				else if(
					(!PressingUnload()&&!PressingReload() &&!PressingAltReload()))
				{
					A_StartSound("weapons/magout",8,CHANF_OVERLAP);
					HDMagAmmo.SpawnMag(self,"SS1MagCart",pmg);
					setweaponstate("magout");
				}
				else{
					A_StartSound("weapons/magout",8,CHANF_OVERLAP);
					HDMagAmmo.GiveMag(self,"SS1MagCart",pmg);
					A_StartSound("weapons/pocket",9);
					setweaponstate("pocketmag");
				}
			}
		pocketmag:
			---- AAA 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			goto magout;
		magout:
			---- A 0{
				if(invoker.weaponstatus[MagP_JUSTUNLOAD])setweaponstate("reloadend");
				else setweaponstate("loadmag");
			}
	
		loadmag:
			---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			---- A 0 A_StartSound("weapons/magout",9,CHANF_OVERLAP);
			---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			---- A 3;
			MPLS A 0{
				let mmm=hdmagammo(findinventory("SS1MagCart"));
				if(mmm){
					invoker.weaponStatus[MagP_CurrAmmo]= mmm.TakeMag(true);
					Console.printf("Reload Succeeded");
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
}

class SS1MagPulseProjectile : SS1SlowProjectile
{
	override void postbeginplay(){
		super.postbeginplay();
		A_ChangeVelocity(speed*cos(pitch),0,speed*sin(-pitch),CVF_RELATIVE);
	}

	override void ExplodeSlowMissile(){
		if(max(abs(pos.x),abs(pos.y))>=32768){destroy();return;}
		actor a=spawn("IdleDummy",pos,ALLOW_REPLACE);
		a.stamina=10;
		
		explodemissile(blockingline,null);
		FLineTraceData data;
		LineTrace(angle, 56, pitch, TRF_NOSKY, offsetz: height, data: data);
		Actor pActor = data.hitActor;
		if(pActor && !(pActor is 'Hacker')){
			if (penetration < SS1MobBase(pActor).armorValue) {
				console.printf("Damage reduced by "..SS1MobBase(pActor).armorValue - penetration);
				dmg -= (SS1MobBase(pActor).armorValue - penetration);
			}
			if (hd_debug)
				console.printf("initial damage is "..dmg..".");
			int defenceValue = SS1MobBase(pActor).defenceValue;
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
			if (hd_debug)
				console.printf("randomizing damage");
			dmg *= frandom(0.9, 1.1);
			dmg = pActor.damageMobj(self, target, dmg, "Magnetic");
			if (hd_debug)
				console.printf(string.format("Final damage is %d", dmg));
			
		}
		setstatelabel("death");
	}
	
	default
	{
		mass 0;
		speed 9;//475;
		accuracy 300;
		//stamina 100;
		scale 0.5;
		gravity 0.03;
		//damagetype "Magnetic";
		SS1SlowProjectile.penetration 100;
		SS1SlowProjectile.offenseValue 4;
		SS1SlowProjectile.dmg 45;
		woundhealth 0;
	}
	states
	{
		Spawn:
			MPRJ ABCD 3;
			loop;
		Death:
			TNT1 A 0 {
					invoker.speed = 0;
					A_StartSound("MagPulse/hit");
					bnointeraction=true;
			bmissile=false;
					}
			MPEX ABCD 1;
			#### EFG 2;
			stop;
	}
}

class MagCartEmpty:IdleDummy{
	default{
		//$Category "System Shock/ Ammo"
		//$Title "Mag Cart (Spent)"
		//$Sprite "MPMGD0"
	}
	override void postbeginplay(){
		super.postbeginplay();
		angle=frandom(0,360);
		HDMagAmmo.SpawnMag(self,"SS1MagCart",0);
		destroy();
	}
}
