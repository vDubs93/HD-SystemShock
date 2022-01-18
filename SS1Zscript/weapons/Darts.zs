class HDB_NDart:SS1SlowProjectile{
	override void gunsmoke(){}
	override void postbeginplay(){
		super.postbeginplay();
		A_ChangeVelocity(speed*cos(pitch),0,speed*sin(-pitch),CVF_RELATIVE);
	}
	override void ExplodeSlowMissile(){
		if(max(abs(pos.x),abs(pos.y))>=32768){destroy();return;}
		actor a=spawn("IdleDummy",pos,ALLOW_REPLACE);
		a.stamina=10;
		a.A_StartSound("dartgun/wallhit",CHAN_AUTO);
		explodemissile(blockingline,null);
		FLineTraceData data;
		LineTrace(angle, 56, pitch, TRF_NOSKY, offsetz: height, data: data);
		Actor pActor = data.hitactor;
		if (pActor) {
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
			pActor.damageMobj(self,HDPlayerPawn(self),int(dmg),"Dart");
			class<actor> hitblood;
			bool noblood = pActor.bNoBlood;
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
	}
	default{
		pushfactor 0.4;
		mass 2;
		speed 200;//475;
		accuracy 300;
		stamina 100;
		scale 0.2;
		SS1SlowProjectile.penetration 6;
		SS1SlowProjectile.dmg 15.0;
	}
	States {
		Spawn:
			ONED A 1 A_SetRoll(pitch);
			loop;

		death:
			ONED B -1;
			stop;
		disappear:
			TNT1 A 0;
			stop;
	}
}

class HDB_TDart:SS1SlowProjectile{
	override void gunsmoke(){}
	override void postbeginplay(){
		super.postbeginplay();
		A_ChangeVelocity(speed*cos(pitch),0,speed*sin(-pitch),CVF_RELATIVE);
	}
	override void ExplodeSlowMissile(){
		if(max(abs(pos.x),abs(pos.y))>=32768){destroy();return;}
		actor a=spawn("IdleDummy",pos,ALLOW_REPLACE);
		a.stamina=10;
		a.A_StartSound("dartgun/wallhit",CHAN_AUTO);
		explodemissile(blockingline,null);
		FLineTraceData data;
		LineTrace(angle, 56, pitch, TRF_NOSKY, offsetz: height, data: data);
		Actor pActor = data.hitActor;
		if (pActor) {
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
			pActor.damageMobj(self,HDPlayerPawn(self),int(dmg),"Tranq");
			if (CanTranq(pActor)) {
				pActor.setStateLabel("Pain");
				pActor.GiveInventory("TranqHandler",1);
			}
			setstatelabel("disappear");
		}
	}
	bool CanTranq(actor o) {
		return (
			!(SS1MobBase(o).bISROBOT) ||
			o is 'Serpentipede' ||
			o is 'HDHumanoid'
		);
	}
	default{
		pushfactor 0.4;
		mass 2;
		speed 200;//475;
		accuracy 300;
		stamina 100;
		scale 0.2;
		DamageType "Dart";
		SS1SlowProjectile.penetration 0;
		SS1SlowProjectile.dmg 5.0;
	}
	States {
		Spawn:
			ONET A 1 A_SetRoll(pitch);
			loop;

		death:
			ONET B -1;
			stop;
		disappear:
			TNT1 A 0;
			stop;
	}
}

class NeedleDart:HDRoundAmmo{
	default{
		+forcexybillboard +cannotpush
		+inventory.ignoreskill
		+hdpickup.multipickup
		xscale 0.2;yscale 0.2;
		inventory.pickupmessage "Picked up a needle dart.";
		hdpickup.refid "svn";
		tag "SV Needle Dart";
		hdpickup.bulk ENC_776;
		inventory.icon "ONEDA3A7";
	}
	/*override void SplitPickup(){
		SplitPickupBoxableRound(10,50,"HD7mBoxPickup","TEN7A0","RBRSA0");
		if(amount==10)scale.y=(0.8*0.83);
		else scale.y=0.8;
	}*/
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HD_SS1DartGun");
	}
	states{
	spawn:
		ONED A -1;
		ONED A -1;
	}
}

class TranqDart:HDRoundAmmo{
	default{
		+forcexybillboard +cannotpush
		+inventory.ignoreskill
		+hdpickup.multipickup
		xscale 0.2;yscale 0.2;
		inventory.pickupmessage "Picked up an SV tranq dart.";
		hdpickup.refid "svt";
		tag "SV tranq Dart";
		hdpickup.bulk ENC_776;
		inventory.icon "ONETA3A7";
	}
	/*override void SplitPickup(){
		SplitPickupBoxableRound(10,50,"HD7mBoxPickup","TEN7A0","RBRSA0");
		if(amount==10)scale.y=(0.8*0.83);
		else scale.y=0.8;
	}*/
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HD_SS1DartGun");
	}
	states{
	spawn:
		ONET A -1;
		ONET A -1;
	}
}

class NeedleDartClip:HDMagAmmo {
	default{
		//$Category "System Shock/Ammunition"
		//$Title "Needle Dart Clip"
		//$Sprite "DBOXA0"

		hdmagammo.maxperunit 15;
		hdmagammo.roundtype "NeedleDart";
		hdmagammo.roundbulk ENC_776;
		hdmagammo.magbulk ENC_776MAG_EMPTY;
		hdpickup.refid "ndc";
		tag "SV Needle Dart clip";
		inventory.pickupmessage "Picked up an SV Needle Dart clip.";
		scale 0.2;
		inventory.maxamount 100;
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite;
		if(thismagamt>14)magsprite="DBOXA0";
		else if(thismagamt>13)magsprite="DBOXB0";
		else if(thismagamt>12)magsprite="DBOXC0";
		else if(thismagamt>11)magsprite="DBOXD0";
		else if(thismagamt>10)magsprite="DBOXE0";
		else if(thismagamt>9)magsprite="DBOXF0";
		else if(thismagamt>8)magsprite="DBOXG0";
		else if(thismagamt>7)magsprite="DBOXH0";
		else if(thismagamt>6)magsprite="DBOXI0";
		else if(thismagamt>5)magsprite="DBOXJ0";
		else if(thismagamt>4)magsprite="DBOXK0";
		else if(thismagamt>3)magsprite="DBOXL0";
		else if(thismagamt>2)magsprite="DBOXM0";
		else if(thismagamt>1)magsprite="DBOXN0";
		else if(thismagamt>0)magsprite="DBOXO0";
		else magsprite="DBOXP0";
		return magsprite,"ONEDA3A7","NeedleDart",.4;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("SS1DartGun");
	}
	states(actor){
	spawn:
		DBOX ABCDEFGHIJKLMNO -1 nodelay{
			int amt=mags[0];
			if(amt>14)frame=0;
			else if(amt>13)frame=1;
			else if(amt>12)frame=2;
			else if(amt>11)frame=3;
			else if(amt>10)frame=4;
			else if(amt>9)frame=5;
			else if(amt>8)frame=6;
			else if(amt>7)frame=7;
			else if(amt>6)frame=8;
			else if(amt>5)frame=9;
			else if(amt>4)frame=10;
			else if(amt>3)frame=11;
			else if(amt>2)frame=12;
			else if(amt>1)frame=13;
			else if(amt>0)frame=14;
		}stop;
	spawnempty:
		DBOX P -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1,1,3,3,3,3,0,2)*90;
		}stop;
	}
}

class TranqDartClip:HDMagAmmo{
	default{
		//$Category "System Shock/Ammunition"
		//$Title "Tranq Dart Clip"
		//$Sprite "TBOXA0"

		hdmagammo.maxperunit 15;
		hdmagammo.roundtype "TranqDart";
		hdmagammo.roundbulk ENC_776;
		hdmagammo.magbulk ENC_776MAG_EMPTY;
		hdpickup.refid "tdc";
		tag "SV Tranq Dart clip";
		inventory.pickupmessage "Picked up an SV Tranq Dart clip.";
		scale 0.2;
		inventory.maxamount 100;
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite;
		if(thismagamt>14)magsprite="TBOXA0";
		else if(thismagamt>13)magsprite="TBOXB0";
		else if(thismagamt>12)magsprite="TBOXC0";
		else if(thismagamt>11)magsprite="TBOXD0";
		else if(thismagamt>10)magsprite="TBOXE0";
		else if(thismagamt>9)magsprite="TBOXF0";
		else if(thismagamt>8)magsprite="TBOXG0";
		else if(thismagamt>7)magsprite="TBOXH0";
		else if(thismagamt>6)magsprite="TBOXI0";
		else if(thismagamt>5)magsprite="TBOXJ0";
		else if(thismagamt>4)magsprite="TBOXK0";
		else if(thismagamt>3)magsprite="TBOXL0";
		else if(thismagamt>2)magsprite="TBOXM0";
		else if(thismagamt>1)magsprite="TBOXN0";
		else if(thismagamt>0)magsprite="TBOXO0";
		else magsprite="TBOXP0";
		return magsprite,"ONETA3A7","TranqDart",.4;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("SS1DartGun");
	}
	states(actor){
	spawn:
		TBOX ABCDEFGHIJKLMNO -1 nodelay{
			int amt=mags[0];
			if(amt>14)frame=0;
			else if(amt>13)frame=1;
			else if(amt>12)frame=2;
			else if(amt>11)frame=3;
			else if(amt>10)frame=4;
			else if(amt>9)frame=5;
			else if(amt>8)frame=6;
			else if(amt>7)frame=7;
			else if(amt>6)frame=8;
			else if(amt>5)frame=9;
			else if(amt>4)frame=10;
			else if(amt>3)frame=11;
			else if(amt>2)frame=12;
			else if(amt>1)frame=13;
			else if(amt>0)frame=14;
		}stop;
	spawnempty:
		TBOX P -1{
			brollsprite=true;brollcenter=true;
			roll=randompick(1,1,1,1,3,3,3,3,0,2)*90;
		}stop;
	}
}

class HDLooseNeedleDart:HDdebris{
	override void postbeginplay(){
		HDDebris.postbeginplay();
	}
	default{
		bouncefactor 0.5;
	}
	states{
	death:
		TNT1 A 1{
			actor a=spawn("NeedleDart",self.pos,ALLOW_REPLACE);
			a.roll=self.roll;a.vel=self.vel;
		}stop;
	}
}

class HDLooseTranqDart:HDdebris{
	override void postbeginplay(){
		HDDebris.postbeginplay();
	}
	default{
		bouncefactor 0.5;
	}
	states{
	death:
		TNT1 A 1{
			actor a=spawn("TranqDart",self.pos,ALLOW_REPLACE);
			a.roll=self.roll;a.vel=self.vel;
		}stop;
	}
}

class needleEmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"needleDartClip",0);
		destroy();
	}
}
class tranqEmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"tranqDartClip",0);
		destroy();
	}
}