class SS1DartGun : SS1Weapon {
	int nextAmmoType;
	
	override void postbeginplay()
	{
		super.postbeginplay();
	}
	override void failedpickupunload()
	{
		int MType = weaponStatus[DG_CurrAmmoType];

		class<HDMagAmmo> WhichMag = MType == 0 ? 'needleDartClip' : 'tranqDartClip';
		failedpickupunloadmag(DG_CurrAmmo,WhichMag);
	}
	override double gunMass() {return 10 + weaponstatus[DG_CurrAmmo];}
	override double WeaponBulk() { return 10; }
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	override string,double getpickupsprite()
	{
		return "DRTPA0",.4;
	}
	
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_ALTRELOAD.." Load tranquilizer darts\n"
		..WEPHELP_RELOAD.."  Reload mag\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if (weaponStatus[DG_CurrAmmoType] == 0) {
				if(owner.countinv("NeedleDart"))owner.A_DropInventory("NeedleDart",amt*15);
				else owner.A_DropInventory("needleDartClip",amt);
			} else {
				if(owner.countinv("TranqDart"))owner.A_DropInventory("TranqDart",amt*15);
				else owner.A_DropInventory("tranqDartClip",amt);
			}
		}
	}
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if(sb.hudlevel==1){
			
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("needleDartClip")));
			if(nextmagloaded>=15){
				sb.drawimage("DBOXA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.5,0.5));
			}else if(nextmagloaded<1){
				sb.drawimage("DBOXP0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(0.5,0.5));
			}else sb.drawbar(
				"DBOXEMPT","DBOXGREY",
				nextmagloaded,15,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("tranqDartClip")));
			if(nextmagloaded>=15){
				sb.drawimage("TBOXA0",(-58,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(0.5,0.5));
			}else if(nextmagloaded<1){
				sb.drawimage("TBOXP0",(-58,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(0.5,0.5));
			}else sb.drawbar(
				"TBOXEMPT","DBOXGREY",
				nextmagloaded,15,
				(-53,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawimage("NIcon",(-20,-8),sb.DI_SCREEN_CENTER_BOTTOM,alpha:(!weaponstatus[DG_CurrAmmoType]&&weaponstatus[DG_CurrAmmo]>0)?1.:0.6,scale:(0.5,0.5));
			sb.drawimage("TIcon",(-29,-8),sb.DI_SCREEN_CENTER_BOTTOM,alpha:(weaponstatus[DG_CurrAmmoType]&&weaponstatus[DG_CurrAmmo]>0)?1.:0.6,scale:(0.5,0.5));
			sb.drawnum(hpl.countinv("needleDartClip"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
			sb.drawnum(hpl.countinv("tranqDartClip"),-55,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		sb.drawImage("DRTICON", (-84, -3), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM, scale: (0.5, 0.5));
		sb.drawwepnum(weaponStatus[DG_CurrAmmo], 15);
		
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
		if(hpl.player.getpsprite(PSP_WEAPON).frame>=2){
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
	action void A_FireDart() {
		if (invoker.weaponStatus[DG_CurrAmmo] > 0){
			if (invoker.weaponStatus[DG_CurrAmmoType] == 0) {
				HDB_NDart drt;
				class<actor> ddd;
				ddd="HDB_NDart";
				drt=HDB_NDart(spawn(ddd,(
					pos.xy,
					pos.z+HDWeapon.GetShootOffset(
						self,invoker.barrellength,
						invoker.barrellength-HDCONST_SHOULDERTORADIUS
					)
				),ALLOW_REPLACE));
				drt.angle=angle;drt.target=self;drt.master=self;
				drt.pitch=pitch;
			} else {
				HDB_TDart drt;
				class<actor> ddd;
				ddd="HDB_TDart";
				drt=HDB_TDart(spawn(ddd,(
					pos.xy,
					pos.z+HDWeapon.GetShootOffset(
						self,invoker.barrellength,
						invoker.barrellength-HDCONST_SHOULDERTORADIUS
					)
				),ALLOW_REPLACE));
				drt.angle=angle;drt.target=self;drt.master=self;
				drt.pitch=pitch;
			}
			invoker.weaponStatus[DG_CurrAmmo]--;
			A_StartSound("dartgun/fire",8,CHANF_OVERLAP,0.9);
			setweaponstate("shoot");
		} else {
			A_StartSound("weapon/dryfire",8,CHANF_OVERLAP,0.9);
			setweaponstate("nope");
		}
	}
	Default
	{
		//$Category "System Shock/Weapons"
		//$Title "SV-23 Dartgun"
		//$Sprite "DRTPA0"
		+WEAPON.NOAUTOFIRE
		Weapon.SlotNumber 2;
		scale 0.2;
		hdweapon.refid "sdg";
		Tag "SV-23 Dartgun";
		Inventory.PickupMessage "SV-23 Dartgun. Good for fleshy targets";
		Obituary "%k wouldn't stop needling %o.";
		SS1Weapon.currAmmo 15;
		
	}
	states
	{
		Spawn:
			DRTP A -1;
			wait;
		Select0:
			DGUN A 0;
			goto select0small;
		Deselect0:
			DGUN A 0;
			goto deselect0small;
		ready:
			DGUN A 1 A_WeaponReady(WRF_ALL);
			Goto ReadyEnd;
		fire:
			DGUN A 0 A_FireDart();
			goto ready;
		shoot:
			DGUN B 1;
			#### C 1;
			#### D 1;
			#### E 1;
			#### F 1;
			#### G 1;
			Goto Ready;
		user4:
		unload:
			---- A 0{
				invoker.weaponstatus[0]|=DG_JustUnload;
				if(invoker.weaponStatus[DG_CurrAmmo]>=0)setweaponstate("unmag");
			} goto Ready;
		
		reload:
			---- A 0{
				invoker.nextAmmoType = 0;
				invoker.weaponstatus[0]&=~DG_JustUnload;
				bool nomags=HDMagAmmo.NothingLoaded(self,"needleDartClip");
				if(invoker.weaponStatus[DG_CurrAmmo]>=15 && invoker.weaponStatus[DG_CurrAmmoType] == 0)setweaponstate("nope");
				else if(nomags)setweaponstate("nope"); else setweaponstate("unmag");
			}goto unmag;
		user1:
		altreload:
			---- A 0 {
				invoker.nextAmmoType = 1;
				invoker.weaponstatus[0]&=~DG_JustUnload;
				bool nomags=HDMagAmmo.NothingLoaded(self,"tranqDartClip");
				if(invoker.weaponStatus[DG_CurrAmmo]>=15 && invoker.weaponStatus[DG_CurrAmmoType] == 1)setweaponstate("nope");
				else if(nomags)setweaponstate("nope"); else setweaponstate("unmag");
			}goto unmag;
		unmag:

			---- A 1 offset(0,34) A_SetCrosshair(21);
			---- A 1 offset(1,38);
			---- A 2 offset(2,42);
			---- A 3 offset(3,46);
			---- A 0{
				int pmg=invoker.weaponStatus[DG_CurrAmmo];
				invoker.weaponStatus[DG_CurrAmmo]=-1;
				
				int MType = invoker.weaponStatus[DG_CurrAmmoType];

				class<HDMagAmmo> WhichMag = (MType == 0 ? 'needleDartClip' : 'tranqDartClip');
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
				if(invoker.weaponstatus[0]&DG_JustUnload)setweaponstate("reloadend");
				else setweaponstate("loadmag");
			}
	
		loadmag:
			---- A 4 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			---- A 0 A_StartSound("weapons/magout",9,CHANF_OVERLAP);
			---- A 5 offset(0,46) A_MuzzleClimb(frandom(-0.2,0.8),frandom(-0.2,0.4));
			---- A 3;
			---- A 0{
					int MType = invoker.nextAmmoType;
					invoker.weaponStatus[DG_CurrAmmoType] = Mtype;
				class<HDMagAmmo> WhichMag = MType == 0 ? 'needleDartClip' : 'tranqDartClip';
				let mmm=hdmagammo(findinventory(WhichMag));
				if(mmm){
					invoker.weaponStatus[DG_CurrAmmo]=mmm.TakeMag(true);
					A_StartSound("Dartgun/LoadClip",8);
					invoker.weaponstatus[DG_unloaded] = 0;
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
		weaponstatus[DG_Unloaded] = 0;
		weaponStatus[DG_CurrAmmoType] = 0;
		switch(user_ammo){
			case -1:
				weaponstatus[DG_CurrAmmo]=0;
				break;
			case 0:
				weaponstatus[DG_CurrAmmo]=15;
				break;
			default:
				weaponstatus[DG_CurrAmmo]=user_ammo;
		}
	}
	override void loadoutconfigure(string input){
			int loadedAmmo=getloadoutvar(input,"tranq",1);
			if (loadedAmmo>0) {
				weaponStatus[dg_currAmmoType] = 1;
			} else {
				weaponStatus[dg_currAmmoType] = 0;
			}
	}		
}

enum DartGunProperties
	{
		DG_Unloaded,
		DG_JustUnload = 4,
		DG_CurrAmmoType,
		DG_CurrAmmo
	};