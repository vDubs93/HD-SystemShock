class SS1Weapon : HDWeapon
{
	int penetration;
	property penetration: penetration;
	int offenseValue;
	property offenseValue: offenseValue;
	override string getHelpText()
	{
		return "";
	}
	int random_bell_modifier(){
		int dies = 5;
		int die_value = 20;
		int retval;
		int rtotal;
		for (int i=0; i< dies; i++){
			rtotal += random(0, die_value);
		}
		if (rtotal <= 2)        retval = -12;     // 00-02
		else if (rtotal <= 8)   retval = -8;      // 03-08
		else if (rtotal <= 16)  retval = -6;      // 09-16
		else if (rtotal <= 28)  retval = -3;      // 17-28
		else if (rtotal <= 40)  retval = -1;      // 29-40
		else if (rtotal <= 60)  retval =  0;      // 41-60
		else if (rtotal <= 72)  retval =  1;      // 61-72
		else if (rtotal <= 84)  retval =  3;      // 73-84
		else if (rtotal <= 92)  retval =  6;      // 85-92
		else if (rtotal <= 98)  retval =  8;      // 93-98
		else                    retval = 12;   
		return retval;
	}
	Void SetWeaponFrame (int InputFrame, int InputLayer = PSP_WEAPON)
   {
      If(Owner.Player) // Check if weapon has an owner and it's a player
      {
         // Do retrieve user's (weapon) sprite from specified layer. Default one is PSP_WEAPON, which is used by the engine for the actual weapons
         // "PSprites" are HUD states, and they are stored into players
   
         PSprite WFrame = Owner.Player.GetPSprite(InputLayer);   
         if(WFrame && WFrame.CurState != null) {WFrame.frame = InputFrame;}   // Set input frame to the desired layer
      }
   }
}

class SS1Puff : HDPuff {
	int penetration;
	property penetration: penetration;
	int offenseValue;
	property offenseValue: offenseValue;
	float dmg;
	property dmg: dmg;
	int random_bell_modifier(){
		int dies = 5;
		int die_value = 20;
		int retval;
		int rtotal;
		for (int i=0; i< dies; i++){
			rtotal += random(0, die_value);
		}
		if (rtotal <= 2)        retval = -12;     // 00-02
		else if (rtotal <= 8)   retval = -8;      // 03-08
		else if (rtotal <= 16)  retval = -6;      // 09-16
		else if (rtotal <= 28)  retval = -3;      // 17-28
		else if (rtotal <= 40)  retval = -1;      // 29-40
		else if (rtotal <= 60)  retval =  0;      // 41-60
		else if (rtotal <= 72)  retval =  1;      // 61-72
		else if (rtotal <= 84)  retval =  3;      // 73-84
		else if (rtotal <= 92)  retval =  6;      // 85-92
		else if (rtotal <= 98)  retval =  8;      // 93-98
		else                    retval = 12;   
		return retval;
	}
	default
	{
		damage 0;
	}
}

class SS1SlowProjectile : SlowProjectile {
	int penetration;
	property penetration: penetration;
	int offenseValue;
	property offenseValue: offenseValue;
	float dmg;
	property dmg: dmg;
	int random_bell_modifier(){
		int dies = 5;
		int die_value = 20;
		int retval;
		int rtotal;
		for (int i=0; i< dies; i++){
			rtotal += random(0, die_value);
		}
		if (rtotal <= 2)        retval = -12;     // 00-02
		else if (rtotal <= 8)   retval = -8;      // 03-08
		else if (rtotal <= 16)  retval = -6;      // 09-16
		else if (rtotal <= 28)  retval = -3;      // 17-28
		else if (rtotal <= 40)  retval = -1;      // 29-40
		else if (rtotal <= 60)  retval =  0;      // 41-60
		else if (rtotal <= 72)  retval =  1;      // 61-72
		else if (rtotal <= 84)  retval =  3;      // 73-84
		else if (rtotal <= 92)  retval =  6;      // 85-92
		else if (rtotal <= 98)  retval =  8;      // 93-98
		else                    retval = 12;   
		return retval;
	}
	default
	{
		damage 0;
	}
}

class SS1Bullet:HDBulletActor{
	int penetration;
	property penetration: penetration;
	int offenseValue;
	property offenseValue: offenseValue;
	float dmg;
	property dmg: dmg;
	
	override void onHitActor(actor hitactor,vector3 hitpos,vector3 vu,int flags){
		if (hitactor is 'SS1Door' && SS1Door(hitactor).closed == false)
			return;
		if(max(abs(pos.x),abs(pos.y))>=32768){destroy();return;}
		actor a=spawn("IdleDummy",pos,ALLOW_REPLACE);
		a.stamina=10;
		explodemissile(blockingline,null);
		FLineTraceData data;
		LineTrace(angle, 56, pitch, TRF_NOSKY, offsetz: height, data: data);
		Actor pActor = data.hitactor;
		if (pActor && !(pActor is 'Hacker')) {
			if (penetration <  SS1MobBase(pActor).armorValue) {
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
			dmg *= frandom(0.9, 1.1);	
			if (hd_debug)
				console.printf("final damage is "..dmg..".");
			pActor.damageMobj(self,HDPlayerPawn(self),int(dmg),"Bullet");
			class<actor> hitblood;
			bool noblood = pactor.bNoBlood;
			if(noblood)hitblood="FragPuff";else hitblood=pActor.bloodtype;
			double ath=angleto(pActor);
			double zdif=pos.z-pActor.pos.z;
			bool gbg;actor blood;
			[gbg,blood]=pActor.A_SpawnItemEx(
				hitblood,
				-pActor.radius,0,zdif,
				angle:ath,
					flags:SXF_ABSOLUTEANGLE|SXF_USEBLOODCOLOR|SXF_NOCHECKPOSITION|SXF_SETTARGET
			);
			if(blood)blood.vel=-3 * vel+(frandom(-0.6,0.6),frandom(-0.6,0.6),frandom(-0.2,0.4)
			);
		setstatelabel("disappear");
		}
		return;
	}
	int random_bell_modifier(){
		int dies = 5;
		int die_value = 20;
		int retval;
		int rtotal;
		for (int i=0; i< dies; i++){
			rtotal += random(0, die_value);
		}
		if (rtotal <= 2)        retval = -12;     // 00-02
		else if (rtotal <= 8)   retval = -8;      // 03-08
		else if (rtotal <= 16)  retval = -6;      // 09-16
		else if (rtotal <= 28)  retval = -3;      // 17-28
		else if (rtotal <= 40)  retval = -1;      // 29-40
		else if (rtotal <= 60)  retval =  0;      // 41-60
		else if (rtotal <= 72)  retval =  1;      // 61-72
		else if (rtotal <= 84)  retval =  3;      // 73-84
		else if (rtotal <= 92)  retval =  6;      // 85-92
		else if (rtotal <= 98)  retval =  8;      // 93-98
		else                    retval = 12;   
		return retval;
	}
}