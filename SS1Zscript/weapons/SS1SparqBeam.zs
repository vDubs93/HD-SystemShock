enum SparqProperties
	{
		SB_OverHeat,
		SB_PowerLevel,
		SB_HeatLevel
	};
Class SS1SparqBeam : SS1Weapon
{
	int curFrame;
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
		Inventory.pickupMessage "SparqBeam sidearm. Now with 3 power settings";
		SS1Weapon.penetration 25;
		SS1Weapon.offenseValue 3;
	}
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_RELOAD.."  Increase Power Level\n"
		..WEPHELP_UNLOAD.."  Decrease Power Level\n"
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
		if (weaponstatus[SB_PowerLevel] == 4){
			HUDFont font = HUDFont.Create(smallfont, 0, false);
			sb.drawstring(font, "OVER", (-46, -16),sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM);
		}
		
		sb.drawwepnum(weaponStatus[SB_PowerLevel], 3);
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
	override void postbeginplay()
	{
		super.postbeginplay();
		weaponStatus[SB_PowerLevel] = 1;
		weaponStatus[SB_Overheat] = 0;
		weaponStatus[SB_HeatLevel] = 0;
		A_OverlayFlags(5, PSPF_ADDBOB, true);
	}
	override void tick()
	{
		super.tick();
		if (weaponStatus[SB_HeatLevel] >=100 && !weaponstatus[SB_Overheat]){
			weaponStatus[SB_Overheat] = 1;
			owner.A_StartSound("weapon/overheat", CHAN_AUTO, CHANF_OVERLAP);
			
		}
		if (weaponStatus[SB_HeatLevel] == 95 && weaponStatus[SB_Overheat])
			owner.A_StartSound("weapon/error", CHAN_AUTO, CHANF_OVERLAP);
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
		LineTrace(angle, 10000, pitch, TRF_NOSKY, offsetz: height, data: data);
		Actor pActor = data.hitactor;
		if (pActor) {
			if (invoker.penetration <  SS1MobBase(pActor).armorValue) {
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
			dmg *= frandom(0.9, 1.1);	
			if (hd_debug)
				console.printf("final damage is "..dmg..".");
			dmg *= frandom(0.9, 1.1);
			pActor.damageMobj(self, self, dmg, "Beam");
			if (hd_debug)
				console.printf("initial damage is "..dmg..".");
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
					if (invoker.weaponStatus[SB_PowerLevel] < 4){
						invoker.setWeaponFrame(invoker.weaponStatus[SB_PowerLevel]-1);}
			}
			goto select0small;
		Deselect0:
			SPRQ A 0{
					if (invoker.weaponStatus[SB_PowerLevel] < 4){
						invoker.setWeaponFrame(invoker.weaponStatus[SB_PowerLevel]-1);}
			}
			goto deselect0small;
		ready:
			SPRQ A 1 {
				A_WeaponReady(WRF_ALL);
				if (invoker.weaponstatus[sb_overheat] == 0) {
					if (invoker.weaponStatus[SB_PowerLevel] < 4){
						invoker.setWeaponFrame(invoker.weaponStatus[SB_PowerLevel]-1);
						A_StopSound(19);
					}
					else {
						A_StartSound("sparqbeam/overload", 19, CHANF_LOOPING,1, ATTN_NORM, 1.3);
						if (gametic % 4 == 0)
							invoker.curFrame = 0;
						else if (gametic % 3 == 0)
							invoker.curFrame = 1;
						else if (gametic % 2 == 0)
							invoker.curFrame = 2;
						else if (gametic % 1 == 0)
							invoker.curFrame = 1;
						invoker.setWeaponFrame(invoker.curFrame);
					}
				} else {
					invoker.setWeaponFrame(3);
					A_StopSound(19);
				}
			}
			goto readyEnd;
		fire:
			#### A 0 {
				if (Hacker(invoker.owner).internalCharge > 0 && ! invoker.weaponstatus[SB_Overheat]) {
					switch (invoker.weaponStatus[SB_PowerLevel]) {
						case 1:
							return state(resolveState("shoot1"));
							break;
						case 2:
							return state(resolveState("shoot2"));
							break;
						case 3:
							return state(resolveState("shoot3"));
							break;
					}
					return state(resolveState("shoot4"));
				}
				else return state(resolveState("dryfire"));
			}
			goto Ready;
		shoot1:
			SPQF A 1 {
				A_SparqAttack(6, "04aebb", 10);
				
				A_StartSound("sparqBeam/fire");
				Hacker(invoker.owner).internalCharge -= 2;
				invoker.weaponStatus[SB_HeatLevel] += 20;
			}
			SPQF BCDE 1;
			SPQF F 2;
			goto ready;
		shoot2:
			SPQF G 1 {
				A_SparqAttack(18, "14beca", 17);
				
				A_StartSound("sparqBeam/fire", CHAN_AUTO, 0, 1, ATTN_NORM, 0.9);
				Hacker(invoker.owner).internalCharge -= 4;
				invoker.weaponStatus[SB_HeatLevel] += 35;
			}
			SPQF HIJK 1;
			SPQF L 2;
			goto ready;
		shoot3:
			SPQF M 1 {
				A_SparqAttack(36, "24cedb", 25);
				A_StartSound("sparqBeam/fire", CHAN_AUTO, 0, 1, ATTN_NORM, 0.8);
				A_StartSound("stungun/zap", CHAN_AUTO, 0, 0.25);
				Hacker(invoker.owner).internalCharge -= 6;
				invoker.weaponStatus[SB_HeatLevel] += 50;
			}
			SPQF NOPQ 1;
			SPQF R 2;
			Goto Ready;
				
		shoot4:
			SPQF A 1 {
				A_SparqAttack(60, "34deeb", 40);
				A_StartSound("sparqBeam/fire");
				A_StartSound("weapon/fullcharge");
				invoker.owner.A_SetPitch(invoker.owner.pitch-5, SPF_INTERPOLATE); 
				Hacker(invoker.owner).internalCharge -= 8;
				invoker.weaponStatus[SB_HeatLevel] = 100;
			}
			SPQF HODK 1;
			SPQF F 2 {
				invoker.weaponStatus[SB_PowerLevel] = 1;

			}
			Goto Ready;
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
				if (invoker.weaponStatus[SB_PowerLevel] < 4)
					invoker.weaponStatus[SB_PowerLevel]++;
				else
					invoker.weaponStatus[SB_PowerLevel] = 1;
				A_StartSound("weapon/toggle");
			}
			goto changeFinish;
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
			#### # 1 offset(1,34);
			goto ready;
	}
}