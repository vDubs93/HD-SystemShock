
class cyberHacker : SixDoFPlayer
{
	default
	{
		height 4;
		radius 4;
		health 100;
	}
	override void Travelled()
	{
		super.travelled();
		if (level.LevelNum < 20) {
			Unmorph(self, 0, true);
		}
	}
}
class Hacker : HDPlayerPawn
{
	float InternalCharge;
	float energyUse;
	float prevCharge;
	property InternalCharge: InternalCharge;
	int medPatchCount;
	int gameTime;
	int Bpatch;
	int sightPatch;
	int staminaPatch;
	bool looting;
	int accesses;
	property Accesses: accesses;
	weapon prevWeapon;
	int doPuzzle;
	int cursorX;
	int cursorY;
	int btCooldown;
	int respawnCounter;
	SS1Puzzle currPuzz;
	bool onGravLift;
	default
	{
		Hacker.InternalCharge 85.0;
		MaxSlopeSteepness 45000. / 65536.;
		DamageFactor "Gas", 0.001;
		DamageFactor "Magnetic", 0;
		health 83;
		//gravity 0.4;
	}
	
	override void GiveBasics(){
		if(!player)return;
		A_GiveInventory("SelfBandage");
		A_GiveInventory("SS1Grenadethrower");
		A_GiveInventory("MagManager");
		A_GiveInventory("PickupManager");
		A_GiveInventory("EmptyHands");
		
	}
	override void postbeginplay()
	{
		super.postbeginplay();
		accesses = 0;
		energyUse = 0;
		health = 83;
		HDWeaponSelector.Select(self,"EmptyHands");
	}
	override void Travelled()
	{
		if (level.LevelNum>=20) {
			//Wee cyberspace! lots to do there still.
			Morph(self, "cyberhacker", NULL,0x7FFFFFFF, 0, "", "");
		}
	}
	
	override int DamageMobj(
		actor inflictor,
		actor source,
		int damage,
		name mod,
		int flags,
		double angle
	){
			//"You have to be aware of recursively called code pointers in death states.
		//It can easily happen that Actor A dies, calling function B in its death state,
		//which in turn nukes the data which is being checked in DamageMobj."
		if(!self || health<1)return damage;

		//don't do all this for voodoo dolls
		if(!player)return super.DamageMobj(inflictor,source,damage,mod,flags,angle);

		int originaldamage=damage;

		silentdeath=false;

		//replace all armour with custom HD stuff
		if(countinv("PowerIronFeet")){
			A_GiveInventory("WornRadsuit");
			A_TakeInventory("PowerIronFeet");
		}
		if(countinv("BasicArmor")){
			A_GiveInventory("HDArmourWorn");
			A_TakeInventory("BasicArmor");
		}

		if(
			damage==TELEFRAG_DAMAGE
			&&source
		){
			if(source==self){
				flags|=DMG_FORCED;
			}

			//because spawn telefrags are bullshit
			else if(
				(
					(
						source.player
						&&source.player.mo==source
						&&self.player
						&&self.player.mo==self
					)||botbot(source)
				)&&(
					!deathmatch
					||level.time<TICRATE
					||source.getage()<10
				)
			){
				return -1;
			}
		}


		int towound=0;
		int toburn=0;
		int tostun=0;
		int tobreak=0;


		if(inflictor&&inflictor.bpiercearmor)flags|=DMG_NO_ARMOR;


		//deal with some synonyms
		HDMath.ProcessSynonyms(mod);


		//factor in cheats and server settings
		if(
			!(flags&DMG_FORCED)
			&&damage!=TELEFRAG_DAMAGE
		){
			if(
				binvulnerable||!bshootable
				||(player&&(
					player.cheats&CF_GODMODE2 || player.cheats&CF_GODMODE
				))
			){
				A_TakeInventory("Heat");
				woundcount=0;
				oldwoundcount=0;
				unstablewoundcount=0;
				burncount=0;
				aggravateddamage=0;
				return 0;
			}
			double dfl=damage*hd_damagefactor;
			damage=int(dfl);
			if(frandom(0,1)<dfl-damage)damage++;
		}

		//credit and blame where it's due
		if(source is "BotBot")source=source.master;

		//abort if zero team damage, otherwise save factor for wounds and burns
		double tmd=1.;
		if(
			source is "PlayerPawn"
			&&source!=self
			&&isteammate(source)
			&&player!=source.player
		){
			if(teamdamage<=0) return 0;
			else tmd=teamdamage;
		}

		if(source&&source.player)flags|=DMG_PLAYERATTACK;



		//process all items (e.g. armour) that may affect the damage
		array<HDDamageHandler> handlers;
		if(
			!(flags&DMG_FORCED)
			&&damage<TELEFRAG_DAMAGE
		){
			HDDamageHandler.GetHandlers(self,handlers);
			for(int i=0;i<handlers.Size();i++){
				let hhh=handlers[i];
				if(hhh&&hhh.owner==self)
				[damage,mod,flags,towound,toburn,tostun,tobreak]=hhh.HandleDamage(
					damage,
					mod,
					flags,
					inflictor,
					source,
					towound,
					toburn,
					tostun,
					tobreak
				);
			}
		}


		//excess hp
		if(mod=="maxhpdrain"){
			damage=min(health-1,damage);
			flags|=DMG_NO_PAIN|DMG_THRUSTLESS;
		}
		//bleeding
		else if(
			mod=="bleedout"||
			mod=="internal"||
			mod=="invisiblebleedout"
		){
			flags|=(DMG_NO_ARMOR|DMG_NO_PAIN|DMG_THRUSTLESS);
			silentdeath=true;

			if(regenblues>0&&health<=damage){
				regenblues--;
				damage=health-random(1,3);
			}else{
				damage=min(health,damage);
				if(!random(0,127))oldwoundcount++;
			}

			bool actuallybleeding=(mod!="internal");
			if(actuallybleeding){
				if(hd_nobleed){
					woundcount=0;
					return 0;
				}

				bloodloss+=(originaldamage<<2);

				if(
					!waterlevel
					&&!checkliquidtexture()
					&&bloodloss<HDCONST_MAXBLOODLOSS*1.4
				){
					for(int i=0;i<damage;i+=2){
						a_spawnitemex("HDBloodTrailFloor",
							random(-12,12),random(-12,12),0,
							0,0,0,
							0,SXF_NOCHECKPOSITION|SXF_USEBLOODCOLOR
							|SXF_SETMASTER
						);
					}
				}

				if(level.time&(1|2))return -1;
				if(bloodloss<HDCONST_MAXBLOODLOSS){
					if(!(flags&DMG_FORCED))damage=clamp(damage>>2,1,health-1);
					if(!random(0,health)){
						beatcap--;
						if(!(level.time%4))bloodpressure--;
					}
				}
				if(damage<health)source=null;
			}
		}else if(
			mod=="hot"
			||mod=="cold"
		){
			//burned
			if(damage<=1){
				if(!random(0,27))toburn++;
				if(!random(0,95))towound++;
			}else{
				toburn+=int(max(damage*frandom(0.1,0.6),random(0,1)));
				if(!random(0,60))towound+=max(1,damage*3/100);
			}
		}else if(
			mod=="electrical"
		){
			//electrocuted
			toburn+=int(max(damage*frandom(0.2,0.5),random(0,1)));
			if(!random(0,35))towound+=max(1,(damage>>4));
			if(!random(0,1))tostun+=damage;
		}else if(
			mod=="balefire"
		){
			//balefired
			toburn+=int(damage*frandom(0.6,1.1));
			if(!random(0,2))towound+=max(1,damage>>4);
			if(random(1,50)<damage*tmd)aggravateddamage++;
			if(!(level.time&(1|2|4|8)))A_AlertMonsters();
		}else if(
			mod=="teeth"
			||mod=="claws"
			||mod=="natural"
		){
			if(!random(0,mod=="teeth"?12:36))aggravateddamage++;
			if(random(1,15)<damage)towound++;
			tostun+=int(damage*frandom(0,0.6));
		}else if(
			mod=="GhostSquadAttack"
		){
			//do nothing here, rely on TalismanGhost.A_GhostShot
		}else if(
			mod=="staples"
			||mod=="falling"
			||mod=="drowning"
			||mod=="slime"
		){
			//noarmour
			flags|=DMG_NO_ARMOR;

			if(mod=="falling"){
				if(!source)return -1; //ignore regular fall damage
				tostun+=damage*random(8,12);
				damage>>=1;
			}
			else if(mod=="slime"&&!random(0,99-damage))aggravateddamage++;
		}else if(
			mod=="slashing"
		){
			//swords, chainsaw, etc.
			if(!random(0,15))towound+=max(1,damage*4/100);
		}else if(mod=="bashing"){
			tostun+=damage;
			damage>>=2;
		}else if (mod=="Gas"){
			tostun+=max(1,damage/100);
			toburn+=random(1,3);
		}else{
			//anything else
			if(!random(0,15))towound+=max(1,damage*3/100);
		}



		//do more insidious damage from blunt impacts
		if(
			mod=="falling"
			||mod=="bashing"
		){
			int owc=random(1,100);
			if(owc<damage){
				int agg=(random(-owc,owc)>>3);
				if(agg>0){
					owc-=agg;
					aggravateddamage+=agg;
				}
				oldwoundcount+=owc;
			}
		}


		//abort if damage is less than zero
		if(damage<=0)return damage;


		//HDBulletActor has its separate wound handling
		if(inflictor is "HDBulletActor")towound=0;




		//process all items (e.g. spiritualarmour) that may affect damage after all the above
		if(
			!(flags&DMG_FORCED)
			&&damage<TELEFRAG_DAMAGE
		){
			HDDamageHandler.GetHandlers(self,handlers);
			for(int i=0;i<handlers.Size();i++){
				let hhh=handlers[i];
				if(hhh&&hhh.owner==self)
				[damage,mod,flags,towound,toburn,tostun,tobreak]=hhh.HandleDamagePost(
					damage,
					mod,
					flags,
					inflictor,
					source,
					towound,
					toburn,
					tostun,
					tobreak
				);
			}
		}



		//add to wounds and burns after team damage multiplier
		//(super.damagemobj() takes care of the actual damage amount)
		towound=int(towound*tmd);
		toburn=int(toburn*tmd);
		if(towound>0){
			lastthingthatwoundedyou=source;
			woundcount+=towound;
		}
		if(toburn>0)burncount+=toburn;
		if(tostun>0)stunned+=tostun;
		if(tobreak>0)oldwoundcount+=tobreak;

		//stun the player randomly
		if(damage>60 || (!random(0,5) && damage>20)){
			tostun+=damage;
		}

		if(hd_debug&&player){
			string st="the world";
			if(inflictor)st=inflictor.getclassname();
			A_Log(string.format("%s took %d %s damage from %s",
				player.getusername(),
				damage,
				mod,
				st
			));
		}



		//disintegrator mode keeps things simple
		//also do this while zerk sometimes, to reflect loss of self-preservation reflexes
		if(
			hd_disintegrator
			||(zerk&&abs(zerk)>400)
		)return super.DamageMobj(
			inflictor,
			source,
			damage,
			mod,
			flags|DMG_NO_ARMOR,
			angle
		);


		//player survives at cost
		if(
			damage>=health
		){
			if(
				mod!="internal"
				&&mod!="bleedout"
				&&mod!="invisiblebleedout"
				&&damage<random(12,70)
				&&random(0,3)
			){
				int wnddmg=random(0,max(0,damage>>2));
				if(mod=="bashing")wnddmg>>=1;
				damage=health-random(1,3);
				if(
					mod=="hot"
					||mod=="cold"
				){
					burncount+=wnddmg;
				}else if(
					mod=="slime"
					||mod=="balefire"
				){
					aggravateddamage+=wnddmg;
				}else{
					unstablewoundcount+=wnddmg;
				}
			}
		}


		//flinch
		if(
			!(flags&DMG_NO_PAIN)
			&&damage>0
			&&health>0
			&&!instatesequence(curstate,resolvestate("pain"))
		){
			double jerkamt=(stimcount>8)?0.5:1.5;
			let iii=inflictor;if(!iii)iii=source;
			double jerkleft=0;
			double jerkdown=0;
			if(iii){
				double aaaa=deltaangle(self.angle,angleto(iii));
				if(aaaa>1)jerkleft=jerkamt;
				else if(aaaa<-1)jerkleft=-jerkamt;

				double zzzz=(iii.pos.z+iii.height*0.5)-(pos.z+height*0.9);
				if(abs(zzzz)>10){
					if(zzzz<0)jerkdown=jerkamt;
					else jerkdown=-jerkamt;
				}
			}
			if(!jerkleft)jerkleft=frandom(-jerkamt,jerkamt);
			if(!jerkdown)jerkdown=frandom(-jerkamt,jerkamt);
			A_MuzzleClimb(
				(0,0),
				(frandom(0,jerkleft),frandom(0,jerkdown)),
				(frandom(0,jerkleft),frandom(0,jerkdown)),
				(0,0)
			);
		}


		//finally call the real one but ignore all armour
		int finaldmg=super.DamageMobj(
			inflictor,
			source,
			damage,
			mod,
			flags|DMG_NO_ARMOR,
			angle
		);

		//transfer pointers to corpse
		if(deathcounter&&inflictor&&!inflictor.bismonster&&playercorpse){
			if(inflictor.tracer==self)inflictor.tracer=playercorpse;
			if(inflictor.target==self)inflictor.target=playercorpse;
			if(inflictor.master==self)inflictor.master=playercorpse;
		}

		//go into dying/collapsed mode
		if(
			health>0
			&&player
			&&incapacitated<1
			&&(
				health<random(-1,max((originaldamage>>3),3))
				||tostun>(health<<2)
			)&&(
				mod!="bleedout"
				||bloodloss>random(2048,3072)
			)
		)A_Incapacitated((originaldamage>10)?HDINCAP_SCREAM:0,originaldamage<<3);


		return finaldmg;
	}
	override void DeathThink(){
		if(player.cheats&CF_PREDICTING){
			super.DeathThink();
			return;
		}
		
		if(player){
			if(
				respawndelay>0
			){
				
				player.attacker=null;
				player.cmd.buttons&=~BT_USE;
				if(!(level.time&(1|2|4|8|16))){
					switch(CheckPoF()){
					case -1:
						//start losing sequence
						let hhh=hdlivescounter.get();
						if(hhh.endgametypecounter<-35)hhh.startendgameticker(hdlivescounter.HDEND_WIPE);
						break;
					case 1:
						respawndelay--;
						A_Log(player.getusername().." friend wait time: "..respawndelay);
						break;
					default:
						respawndelay=HDCONST_POFDELAY;
						break;
					}
				}
			}else if(hd_pof){
				player.cmd.buttons|=BT_USE;
				let hhh=hdhandlers(eventhandler.find("hdhandlers"));
				hhh.corpsepos[playernumber()]=(pos.xy,floor(pos.z)+0.001*angle);
			}
			if(!player.bot){
				if (respawnCounter > 0)
					respawnCounter--;
				if (respawnCounter==0) {
					SS1RespawnPoint point;
					ThinkerIterator eiterator = ThinkerIterator.create("SS1RespawnPoint");
					point = SS1RespawnPoint(eiterator.next());
					if (point && point.isActive()){
						vector3 newpos = (point.pos.x, point.pos.y, point.pos.z);
						SetOrigin(newpos, false);
						self.player.Resurrect();
						levelreset();
						healthreset();
						health = random(50, 80);
						incaptimer=0;
						A_Capacitated();
						if (playercorpse){
							playercorpse.Destroy();
						}
						
						return;
					}
				}
				if(deathcounter==144&&!(player.cmd.buttons&BT_USE)){
					showgametip();
					specialtip=specialtip.."\n\n\clPress \cdUse\cl to continue.";
					deathcounter=145;
				}else if(
					deathcounter<144
					&&player
				){
					player.cmd.buttons&=~BT_USE;
					deathcounter++;
				}
				if(playercorpse){
					setorigin((playercorpse.pos.xy+angletovector(angle)*3,playercorpse.pos.z),true);
				}
			}
		}

		if(hd_dropeverythingondeath){
			array<inventory> keys;keys.clear();
			for(inventory item=inv;item!=null;item=item.inv){
				if(item is "Key"){
					keys.push(item);
					item.detachfromowner();
				}else if(item is "HDPickup"||item is "HDWeapon"){
					DropInventory(item);
				}
				if(!item||item.owner!=self)item=inv;
			}
			for(int i=0;i<keys.size();i++){
				keys[i].attachtoowner(self);
			}
		}


		viewbob=0;

		double oldangle=angle;
		double oldpitch=pitch;
		super.DeathThink();

		vel=(0,0,0);
		angle=oldangle;
		pitch=min(oldpitch+1,45);
	}
	
	override void Die(actor source,actor inflictor,int dmgflags,name MeansOfDeath) {
		respawnCounter = 35;
		super.Die(source, inflictor, dmgflags, MeansOfDeath);
		
	}
	override void tick()
	{
		super.tick();
		if (level.LevelNum<20){
			if (vel == (0,0,0))
				viewbob = 0;
			
			gameTime++;
			let player = self.player;
			if (!(player.readyWeapon is 'LootMenu' || 
				  player.readyWeapon is "HDIncapWeapon" || 
				  player.readyWeapon is 'nullweapon'))
				prevWeapon = player.readyWeapon;
			else if (looting == false && !(getplayerinput(INPUT_BUTTONS)&BT_SPEED) && prevweapon)
				hdweaponselector.select(self, prevweapon.getClassName(), 0);
			
			DoPatches();
			
			if (looting == false)
				A_TakeInventory("LootMenu");
			if (doPuzzle) {
				runPuzzle();
			} else {
				player.cheats &= ~CF_FROZEN;
				if (currPuzz)
					currPuzz = NULL;
			}
		}
		self.IncapacitatedCheck();
	}
	
	void DoPatches()
	{
		let p = self.player;
		Shader.setEnabled(p,"poisoned", true);
		if (medPatchCount){
			if (gameTime%16==0){
				
				medPatchCount--;
				incapTimer = incapTimer>0?incapTimer-5:0;
				health += health < maxhealth() ? 1 : 0 ;
				woundcount = woundcount > 1 ? woundcount - 2 : 0;
				unstablewoundcount = unstablewoundcount > 1 ? unstablewoundcount - 2 : 0;
				oldwoundcount = oldwoundcount > 0 ? oldwoundcount - 1 : 0;
				bloodloss = bloodloss > 20 ? bloodloss - 20 : 0;
				burncount = burncount > 1 ? burncount - 1 : 0;
				fatigue += fatigue < 95 ? 1 : 0;
			}
		}
		if (Bpatch){
			Shader.setEnabled(p,"Berserk", true);
			A_GiveInventory("bPatchStrength");
			A_GiveInventory("PowerNightSight");
			if (gameTime %8 == 0)
				Bpatch--;
			if (BPatch == 0 && sightPatch <= 40)
				A_TakeInventory("PowerNightSight");
		} else {
			Shader.setEnabled(p,"Berserk", false);
			A_TakeInventory("bPatchStrength", 100);
		}
		if (sightPatch > 0) {
			if (sightPatch == 40){
				Shader.setEnabled(p, "Blindness", true);
				A_TakeInventory("PowerNightSight");
			}
			if (gameTime % 16 == 0) sightPatch--;
		} else Shader.setEnabled(p, "Blindness", false);
		
		if (staminaPatch) {
			if (random(0, 43 > staminaPatch)) {
				staminaPatch = 0;
				fatigue = 100;
			}
			else { 
				fatigue = 0;
				if (gameTime%16 == 0) staminaPatch--;
			}
		}
	}
	
	void runPuzzle()
	{
		if (!currPuzz) {
			CheckProximity("SS1Puzzle",48,1, CPXF_ANCESTOR | CPXF_CHECKSIGHT | CPXF_SETTARGET);
			cursorX = 0;
			cursorY = 0;

		} else {
			if (doPuzzle){
				player.cheats |= CF_FROZEN;
			}
			int input = getPlayerInput(INPUT_BUTTONS);
			int oldInput = getPlayerInput(INPUT_OLDBUTTONS);
			if (doPuzzle == 1) {
				int numArray[4][3];
				numArray[0][0] = 0;
				numArray[0][0] = 0;
				numArray[0][0] = 0;
				numArray[1][0] = 1;
				numArray[1][1] = 2;
				numArray[1][2] = 3;
				numArray[2][0] = 4;
				numArray[2][1] = 5;
				numArray[2][2] = 6;
				numArray[3][0] = 7;
				numArray[3][1] = 8;
				numArray[3][2] = 9;
				if ((input & BT_FORWARD) && !(oldInput & BT_FORWARD) && cursorY < 3){
					cursorY ++;
				} else if ((input & BT_BACK) && !(oldInput & BT_BACK) && cursorY > 0) {
					cursorY --;
				} else if ((input & BT_MOVELEFT) && !(oldInput & BT_MOVELEFT) && cursorX > 0){
					cursorX --;
				} else if ((input & BT_MOVERIGHT) && !(oldInput & BT_MOVERIGHT) && cursorX < 2) {
					cursorX ++;
				}
				if ((input & BT_USE) && !(oldInput & BT_USE)) {
					if (!(cursorX + cursorY)){
						numPadPuzzle(currPuzz).resetInput();
					}else if (cursorX == 2 && !cursorY){
						numPadPuzzle(currPuzz).checkInput();
					}else if (cursorX == 1 || cursorY > 0) {
						//console.printf("X: "..cursorX.."Y: "..cursorY);
						numPadPuzzle(currPuzz).pressNumber(numArray[cursorY][cursorX]);
					}
				}
			}
			if (doPuzzle == 2) {
				
				if ((input & BT_FORWARD) && !(oldInput & BT_FORWARD) && cursorY > 0){
					cursorY --;
				} else if ((input & BT_BACK) && !(oldInput & BT_BACK) && cursorY < 4) {
					cursorY ++;
				} else if ((input & BT_MOVELEFT) && !(oldInput & BT_MOVELEFT) && cursorX > 0){
					cursorX --;
				} else if ((input & BT_MOVERIGHT) && !(oldInput & BT_MOVERIGHT) && cursorX < 6) {
					cursorX ++;
				}
				if ((input & BT_USE) && !(oldInput & BT_USE)) {
					AccessPanelPuzzle(currPuzz).flipSpace(cursorX, cursorY);
				}
			}
			if ((input & BT_ZOOM)) {
				doPuzzle = 0;
			}
		}
	}
	override void UseButtonCheck(int input){
		if(!(input&BT_USE)){
			bpickup=false;
			return;
		}
		if(oldinput&BT_ATTACK)hasgrabbed=true;
		else if(!(oldinput&BT_USE))hasgrabbed=false;

		//check here because we still need the above pickup checks when incap'd
		if(incapacitated)return;
		bpickup=!hasgrabbed;
		PickupGrabber();
	}


}

class bPatchStrength : PowerStrength
{
	default
	{
		Powerup.Duration 1;
		Powerup.Color "00 00 00", 0.0;
		+INVENTORY.HUBPOWER;
	}
}