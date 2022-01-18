class SS1Pipe : SS1Weapon {

	override double GunMass() { return 10; }
	override double WeaponBulk() { return 10; }
	override string, double GetPickupSprite() { return "PICKA0", 0.20; }
	override string GetHelpText()
	{
		return WEPHELP_FIRE.."  Swing\n"
		..WEPHELP_ALTFIRE.."  Shove\n";
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		sb.drawImage("PIPEICON", (-84, -3), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM, scale: (0.75, 0.5));
	}
	
	override void tick() {
		super.tick();
		owner.A_TakeInventory("HDFist");
	}
	action bool A_Swing(double dmg)
	{
		FLineTraceData data;
		bool hasSwung = LineTrace(angle, 64, pitch, TRF_NOSKY, offsetz: height - 12, data: data);
		if (!(hasSwung))
		{
			return false;
		}
		
		
			LineAttack(angle, 64, pitch, 
				0, 
				"None", 
				"PipePuff", 
				flags: LAF_NORANDOMPUFFZ | LAF_OVERRIDEZ, 
				offsetz: height - 12);
			if (!data.HitActor)	{
				if(data.HitLine != null || data.HitSector != null)
				{
					setWeaponState("WallHit");
					return true;
				} else {
					return false;
				}
			}
		

		Actor pActor = data.HitActor;
		//dmg += HDMath.TowardsEachOther(self, pActor) * 2;
		if (pActor){
			if (invoker.penetration < SS1MobBase(pActor).armorValue) {
				dmg -= (SS1MobBase(pActor).armorValue - invoker.penetration);
			}
		}
		/*
		int hswing = player.cmd.yaw >> 5;
		int vswing = player.cmd.pitch >> 6;
		if (hswing <= 0 && vswing != 0)
		{
			dmg += min(max(abs(hswing), abs(vswing)), dmg * 2);
		}

		if (floorz < pos.z)
		{
			dmg *= 0.5;
		}*/
		A_StartSound("pipe/monsterHit");
		//dmg *= frandom(0.7, 1.2);

		let plr = Hacker(self);
		if (plr && !pActor.bDONTTHRUST && (pActor.mass < 200 || pActor.radius * 2 < pActor.Height && data.HitLocation.z > pActor.pos.z + pActor.Height * 0.6))
		{
			double iyaw = player.cmd.yaw * (65535.0 / 360.0);
			if (abs(iyaw) > 0.5)
			{
				pActor.A_SetAngle(clamp(Normalize180(pActor.angle - iyaw * 100), -50, 50), SPF_INTERPOLATE);
			}
			double ipitch = player.cmd.pitch * (65535.0 / 360.0);
			if (abs(ipitch) > 0.5 * 65535.0 / 360.0)
			{
				pActor.A_SetPitch(clamp((pActor.angle + ipitch * 100) % 90, -30, 30), SPF_INTERPOLATE);
			}
		}

		if (!pActor.bNOPAIN && pActor.Health > 0 && !(pActor is "HDBarrel") && data.HitLocation.z > pActor.pos.z + pActor.height * 0.75)
		{
			if (hd_debug)
			{
				A_Log("HEAD SHOT");
			}
			HDMobBase.ForcePain(pActor);
			dmg *= frandom(1.75, 2.0);
			
		}
		if (countInv("bPatchStrength"))
		{
				
				dmg *= 2;
		}
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
		{
			A_Log(string.format("Whacked %s for %i damage!", pActor.GetClassName(), dmg));
		}

		pActor.DamageMobj(invoker, self, int(dmg), 'Melee', angle);

		return true;
	}

	action void A_Block(){
		let hdp = HDPlayerPawn(self);

		hdp.VelFromAngle(3 * (hdp.countinv("PowerStrength") ? 3 : 1));
		if (hdp)
		{
			hdp.fatigue += 3;
		}
		FLineTraceData data;
		LineTrace(angle, 64, pitch, TRF_NOSKY, offsetz: height - 12, data: data);
		if (data.HitActor)
		{
			let target = data.HitActor;
			if (target is "Babuin") {
				if(target.InStateSequence(CurState, ResolveState("Jump"))) {
					target.A_ChangeVelocity(0);
				}
			}
			target.setStateLabel("Pain");
			target.A_StartSound("weapons/smack",CHAN_AUTO);
			bool kzk = hdp.countinv("PowerStrength");
			vector3 kickdir=(target.pos-hdp.pos).unit();
			target.vel=kickdir*(kzk?15:5)*hdp.mass/max(hdp.mass*0.3,target.mass);
		}
		if (CheckInventory('PowerStrength', 1))
		{
			A_SetTics(8);
		}
	}

	Default
		{
			//$Category "System Shock/Weapons"
			//$Title "Lead Pipe"
			//$Sprite "PICKA0"
			+WEAPON.MELEEWEAPON
			+WEAPON.NOALERT
			+FORCEPAIN
			Obituary "%o got %p head bashed in by %k.";
			Inventory.PickupMessage "Lead Pipe.  For when something needs hitting";
			Inventory.PickupSound "weapons/pocket";
			Weapon.SelectionOrder 100;
			Weapon.kickback 50;
			Weapon.BobStyle "Alpha";
			Weapon.BobSpeed 2.6;
			Weapon.BobRangeX 0.5;
			Weapon.BobRangeY 0.8;
			Weapon.SlotNumber 1;
			Scale 0.1;
			Tag "Lead Pipe";
			HDWeapon.Refid "s1p";
			HDWeapon.barrelSize 10, 0.2, 0.2;
			SS1Weapon.penetration 40;
			SS1Weapon.offenseValue 3;

		}
	States
	{
		Spawn:
			PICK A -1;
			stop;
		select0:
			PIPE A 0 A_TakeInventory("HDFist");
			goto select0big;
		deselect0:
			PIPE A 0;
			goto deselect0big;
		Ready:
			PIPE A 1
				{
					A_WeaponReady(WRF_ALL);
					A_ReadyEnd();
				}
			Goto Ready;
		Fire:
		Hold:
		AltHold:
			TNT1 A 0 A_WeaponBusy(true);
			PIPE ABCDEF 2;
			#### G 6 {invoker.barrellength = 5.5;}
			#### H 2;
			#### I 2;
			#### J 1 A_StartSound("pipe/swing");
			#### K 1 {invoker.barrellength = 25;}
			#### L 1;
			#### M 1 A_Swing(15);
		FinishSwing:
			TNT1 A 10 A_WeaponBusy(false);
			PIPE N 2 A_Refire();
			#### OPQ 2;
			#### R 3;
			#### S 3 {invoker.barrellength = 10;}
			Goto Ready;
		Wallhit:
			#### KJIHGTU 1;
			Goto FinishSwing;
		AltFire:
			PIPB FGHI 1;
			#### H 15 A_Block();
			#### IHGFDCBA 1;
			#### ## 0 A_Refire();
			PIPE YXWV 1;
			Goto ready;

			stop;
		Goto Ready;
	}
}

class PipePuff : HDBulletPuff
{
	Default
	{
		stamina 5;
		missiletype "TinyWallChunk";
		alpha 0.8;
		+NOINTERACTION
		+ALLOWTHRUFLAGS
		+MTHRUSPECIES
		+PUFFGETSOWNER
		+NOEXTREMEDEATH
		DamageType "Melee";
		AttackSound "pipe/wallhit";
		Decal "PipeHitBlack";
	}
}

class SS1PunchDummy:HDActor{
	default{
		//$Category "Misc/Hideous Destructor/"
		//$Title "Punching Dummy"
		//$Sprite "BEXPB0"

		+noblood +shootable +ghost
		height 54;radius 12;health TELEFRAG_DAMAGE;
		xscale 1.22;
		yscale 1.69;
		translation "0:255=%[0,0,0]:[1.7,1.3,0.4]";
	}
	override int damagemobj(
		actor inflictor,actor source,int damage,
		name mod,int flags,double angle
	){
		if(!inflictor||!source)return 0;
		if(
			inflictor is "HDFistPuncher"
			||(inflictor.player && inflictor.player.readyweapon is "HDFist") ||(mod == 'melee' )
		){
			vel.z+=damage*0.1;
			string d="u";
			if(damage>100){
				d="x";
				A_StartSound("misc/p_pkup",CHAN_WEAPON,attenuation:0.6);
			}else if(damage>60)d="y";
			else if(damage>30)d="g";
			if(!hd_debug&&source)source.A_Log(
				string.format("\ccPunched for \c%s%i\cc damage!",d,damage)
			,true);
			A_StartSound("misc/punch",CHAN_AUTO);
		}
		return 0; //indestructible
	}
	states{
	spawn:
	pain:
		BEXP B -1;
	}
}