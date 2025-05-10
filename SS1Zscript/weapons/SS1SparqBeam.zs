enum SparqProperties
	{
		SB_OverHeat,
		SB_PowerLevel,
		SB_HeatLevel,
		SB_OVERLOAD
	};
Class SS1SparqBeam : SS1Handgun
{
	int curFrame;
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	default
	{
		//$category "System Shock/Weapons"
		//$Title "Sparqbeam Sidearm"
		//$sprite "SPQPA0"
		+WEAPON.NOAUTOFIRE;
		weapon.SlotNumber 2;
		hdweapon.refid "spb";
		HDWeapon.barrelSize 10, 0.2, 0.2;
		scale 0.2;
		tag "SparqBeam sidearm";
		Inventory.pickupMessage "SparqBeam sidearm. More pew-pew for your pew-pew.";
		SS1Weapon.penetration 25;
		SS1Weapon.offenseValue 3;
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_FIREMODE.."+"..WEPHELP_UPDOWN.."  Power level\n"
		..WEPHELP_RELOAD.."  Toggle Overcharge\n"
		..WEPHELP_MAGMANAGER
		;
	}
	override double WeaponBulk() { return 10; }
	override string,double getpickupsprite()
	{
		return "SPQPA0",0.4;
	}
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		sb.drawImage("SPRQICON", (-84, -3), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM, scale: (0.5, 0.5));
		HUDFont font = HUDFont.Create(smallfont, 0, false);
		int percent = min(floor(((weaponStatus[SB_PowerLevel]+1)/3000.)*100)+1, 100);
		if (weaponstatus[SB_OVERLOAD]){
			
			sb.drawstring(font, "OVER", (-38, -16),sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM,0,1,-1,4,(0.5,0.5));
		} else sb.drawString(font, ""..percent, (-36, -16),sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM,0,1,-1,4,(0.5,0.5));
		
		sb.drawwepnum(weaponStatus[SB_PowerLevel]+100, 3000, -16, -6, true);
		sb.drawwepnum(weaponStatus[SB_HeatLevel], 90, -16, -8, true);
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
			"sprqback",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			scale:scc
		);
	}
	override void initializewepstats()
	{
		weaponStatus[SB_PowerLevel] = random(0,3000);
		weaponStatus[SB_Overheat] = 0;
		weaponStatus[SB_HeatLevel] = 0;
	}
	override inventory CreateTossable(int amt)
	{
		owner.A_StopSound(19);
		return super.createTossable(amt);
		
	}
	override void tick()
	{
		super.tick();
		if (weaponStatus[SB_OVERLOAD]){
			if (owner)
				owner.A_StartSound("sparqbeam/overload", 19, CHANF_LOOPING | CHANF_NOSTOP,1, ATTN_NORM, 1.3);
			else A_StopSound(19);
		}
		if (weaponStatus[SB_HeatLevel] >= 100 && !weaponstatus[SB_Overheat]){
			weaponStatus[SB_Overheat] = 1;
			owner.A_StartSound("weapon/overheat", CHAN_AUTO, CHANF_OVERLAP);
			owner.A_StartSound("weapon/error", CHAN_AUTO, CHANF_OVERLAP);
		}
		if (weaponStatus[SB_Overheat]){
			drainHeat(SB_HeatLevel);
			if (weaponStatus[SB_HeatLevel] == 0){
				owner.A_StartSound("sparqbeam/cooled");
				weaponStatus[SB_Overheat] = 0;
			}
		} else
			drainHeat(SB_HeatLevel, 0, 0, 0, 0);
	}
	action void A_SparqAttack(int dmg, string hue, int duration) {
		FLineTraceData data;
		LineTrace(angle, 2048, pitch, TRF_NOSKY, offsetz: height, data: data);
		Actor pActor = data.hitactor;
		if (pActor) {
			if (pActor is 'SS1MobBase'){
				if (invoker.penetration <  SS1MobBase(pActor).armorValue) {
					if (hd_debug)
						console.printf("Damage reduced by "..SS1MobBase(pActor).armorValue - invoker.penetration);
					dmg -= (SS1MobBase(pActor).armorValue - invoker.penetration);
				}
				if (hd_debug)
					console.printf("initial damage is "..dmg..".");
				int defenceValue = SS1MobBase(pActor).defenceValue;
				int modifier;
				if (invoker.offenseValue > defenceValue) {
	
					modifier = (invoker.offenseValue - defenceValue) + invoker.random_bell_modifier();
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
			dmg *= frandom(0.9, 1.1);
			if (hd_debug)
				console.printf("final damage is "..dmg..".");
			pActor.damageMobj(self, self, dmg, "Beam");
		}
		A_RailAttack(0, 0, 0, "", hue, RGF_SILENT | RGF_NOPIERCING | RGF_FULLBRIGHT, 0, "", 0, 0, 0, duration, 0.1, 0.0);
	}
	states
	{
		Spawn:
			SPQP A -1;
			wait;
		Select0:
			SPRQ A 0{
					if (!invoker.weaponStatus[SB_OVERLOAD] < 4){
						invoker.setWeaponFrame(0);}
			}
			goto select0small;
		Deselect0:
			SPRQ A 0{
					A_StopSound(19);
					if (!invoker.weaponStatus[SB_OVERLOAD] < 4){
						invoker.setWeaponFrame(0);}
			}
			goto deselect0small;
		ready:
			SPRQ A 1 {
				A_WeaponReady(WRF_ALL);
				A_SetPowerFrame();
			}
			goto readyEnd;
		fire:
			#### A 0 {
				if (Hacker(invoker.owner).internalCharge > 0 && ! invoker.weaponstatus[SB_Overheat]) {
					return state(resolveState("shoot1"));
				}
				else return state(resolveState("dryfire"));
			}
			goto Ready;
		shoot1:
			SPQF A 1 {
				if (invoker.weaponStatus[SB_OVERLOAD] && Hacker(invoker.owner).internalCharge >= 24) {
					Hacker(invoker.owner).internalCharge -= 24;
					Hacker(invoker.owner).energyUse += 24;
					A_SparqAttack(60, "34deeb", 40);
					A_StartSound("sparqBeam/fire");
					A_StartSound("weapon/fullcharge");
					invoker.owner.A_SetPitch(invoker.owner.pitch-5, SPF_INTERPOLATE); 
					invoker.weaponStatus[SB_HeatLevel] = 100;
					invoker.weaponStatus[SB_OVERLOAD] = 0;
					Hacker(invoker.owner).energyUse -= 24;
					return state(resolveState("overloadfinish"));
				}
				else {
					if (invoker.weaponStatus[SB_OVERLOAD]) {
						invoker.weaponStatus[SB_OVERLOAD] = 0;
					}
					while (Hacker(invoker.owner).internalCharge <= 8 * (1/(31.-(invoker.weaponstatus[SB_POWERLEVEL]/100.)))
							&& Hacker(invoker.owner).internalCharge > 0 && invoker.weaponStatus[SB_PowerLevel] > 0){
						if (Hacker(invoker.owner).internalCharge <= 8 * (1/(31.-(invoker.weaponstatus[SB_POWERLEVEL]/100.)))	
							&& Hacker(invoker.owner).internalCharge > 0)
							invoker.weaponstatus[SB_POWERLEVEL]--;
						else break;
					}
					if (Hacker(invoker.owner).internalCharge > 0) {
						float slope = 1/5.;
						int powerdraw = 2 + slope * (invoker.weaponstatus[SB_POWERLEVEL]/100);
						Hacker(invoker.owner).energyUse += powerdraw;
						Hacker(invoker.owner).internalCharge -= powerdraw;
						if (hd_debug) {
							console.printf(string.format("%d", invoker.weaponstatus[SB_POWERLEVEL]/100.));
							console.printf(string.format("%f", powerdraw));
						}
						invoker.weaponStatus[SB_OVERLOAD] = 0;
						invoker.weaponStatus[SB_HeatLevel] += 20;
						A_SparqAttack((invoker.weaponstatus[SB_POWERLEVEL]/100)+6, "04aebb", 10);
						A_StartSound("sparqBeam/fire");
						Hacker(invoker.owner).energyUse -= powerdraw;
					} else return state(resolveState("dryfire"));
				}
				return state(resolveState("shootFinish"));
			}
		shootFinish:
			SPQF BCDE 1;
			SPQF F 2;
			goto ready;
		overloadFinish:
			SPQF R 4 {A_SetCrosshair(21);
					A_WeaponOffset(0,38);
					}
			#### # 4 A_WeaponOffset(0,6, WOF_ADD);
			goto ready;
		dryFire:
			SPRQ D 1 {
					A_WeaponOffset(0, -2, WOF_ADD);
					A_StartSound("weapon/dryfire");
			}
			goto ready;
		reload:
			SPRQ D 1 offset(0,34) A_SetCrosshair(21);
			#### # 1 offset(1,38);
			#### # 2 offset(2,42);
			#### # 3 offset(3,46) { 
				invoker.weaponstatus[SB_OVERLOAD] = !invoker.weaponstatus[SB_OVERLOAD];
				A_StartSound("weapon/toggle");
				
			}
			
			goto changeFinish;
		firemode:
			---- A 1 A_PowerLevelReady();
			---- A 0 A_JumpIf(pressingfiremode(),"firemode");
			goto readyend;
		user4:
		unload:
			SPRQ D 1 offset(0,34) A_SetCrosshair(21);
			#### # 1 offset(1,38);
			#### # 2 offset(2,42);
			#### # 3 offset(3,46) { 
				if (invoker.weaponStatus[SB_PowerLevel] > 1)
					invoker.weaponStatus[SB_PowerLevel]--;
				else
					invoker.weaponStatus[SB_PowerLevel] = 4;
				A_StartSound("weapon/toggle");
			}
		changeFinish:
			#### # 2 offset(3,46);
			#### # 1 offset(2,42);
			#### # 1 offset(2,38);
			#### # 1 offset(1,34) {if (!invoker.weaponStatus[SB_OVERLOAD]) A_StopSound(19);}
			goto ready;
	}
	action void A_PowerLevelReady(){
		A_WeaponReady(WRF_NONE);
		A_SetPowerFrame();
		int iab=invoker.weaponStatus[SB_PowerLevel];
		int cab=0;
		int mmy=-GetMouseY(true);
		if(justpressed(BT_ATTACK))cab=-100;
		else if(justpressed(BT_ALTATTACK))cab=100;
		else if(mmy){
			cab=-mmy;
			if(abs(cab)>(1<<1))cab>>=1;else cab=clamp(cab,-1,1);
		}
		iab+=cab;
		/*if(iab<1000){
			if(cab>0)iab=1000;
			else iab=0;
		}*/
		invoker.weaponStatus[SB_PowerLevel]=clamp(iab,0,3000);
	}
	action void A_SetPowerFrame(){
		if (invoker.weaponstatus[sb_overheat] == 0) {
			if (invoker.weaponStatus[SB_OVERLOAD]){
				if (gametic % 4 == 0)
					invoker.curFrame = 0;
				else if (gametic % 3 == 0)
					invoker.curFrame = 1;
				else if (gametic % 2 == 0)
					invoker.curFrame = 2;
				else if (gametic % 1 == 0)
					invoker.curFrame = 1;
				
			} else {
				if (invoker.weaponStatus[SB_PowerLevel] > 2000)
					invoker.curFrame = 2;
				else if (invoker.weaponStatus[SB_PowerLevel] > 1000)
					invoker.curFrame = 1;
				else invoker.curFrame = 0;
			}
			invoker.setWeaponFrame(invoker.curFrame);
		} else {
			invoker.setWeaponFrame(2);
			A_StopSound(19);
		}
	}
}