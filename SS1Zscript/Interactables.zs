/*class PipeReplacer : Actor {
	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 1 {

				A_SpawnItemEx('Chainsaw');
			}
			stop;
					
	}
}

class PistolReplacer : Actor {
	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 1 {

				A_SpawnItemEx('Pistol');
			}
			stop;
					
	}
}

class ClipReplacer : Actor {
	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 1 {

				A_SpawnItemEx('Clip');
			}
			stop;
					
	}
}

class zombiemanReplacer : Actor {
	States
	{
		Spawn:
			TNT1 A 0;
			TNT1 A 1 {

				A_SpawnItemEx('ZombieMan');
			}
			stop;
					
	}
}
*/
class ElevatorMusic : Actor
{
	Actor player;
	override void postBeginPlay()
	{
		super.postBeginPlay();
		A_StartSound("env/ElevatorMusic",20,CHANF_LOOPING, 1.0, 4);
	}
}
class SS1SwitchableActor : Actor
{
	virtual void switchState(){}
}

class SS1Switch : SS1SwitchableActor
{
	bool active;
	int user_switchtype;
	int user_arg1;
	int user_arg2;
	int user_arg3;
	int user_arg4;
	override bool used(Actor user)
	{
		switchState();
		SS1Switch next;
		ActorIterator iterator = Level.createActorIterator(tid,"SS1Switch");
		iterator.reinit();
		for(next=SS1Switch(iterator.next());next!=null;next=SS1Switch(iterator.next())){
			if (next != self)
			next.switchState();
		}
		iterator.reinit();
		switch (user_switchtype) {
			case 0:
				SS1SwitchableActor Actor;
				ActorIterator eiterator = level.createActorIterator(tid,"SS1SwitchableActor");
				for(Actor=SS1SwitchableActor(eiterator.next());actor!=NULL;actor=SS1SwitchableActor(eiterator.next())){
					if (!(self == Actor))
						Actor.switchstate();
					if (Actor is 'SS1Door')
						SS1Door(Actor).unlock();
				}
				break;
			case 1:
				Light_stop(tid);
				if (!active)
					Light_changeToValue(tid, user_arg1);
				else
					Light_fade(tid, user_arg2, 35);
				
				break;
			default:
				break;
		}
		
		return true;
	}
	override void switchState()
	{
		active = !active;
		A_StartSound(activeSound);
		if (instatesequence(CurState,ResolveState("on"))) {
			setStateLabel("off");
		} else {
			setStateLabel("on");
		}
	}
	Default
	{
		//$Category "System Shock/Interactables"
		
		+FLATSPRITE
		+NOGRAVITY
		height 16;
		radius 8;
		ActiveSound "Switches/switch";
	}
	States
	{
		Spawn:
			TNT1 AA 1 { active = false; }
			goto Off;	
		Off:
			#### A -1;
			wait;
		On:
			#### B -1;
			wait;
		
	}
}
class SS1Puzzle : SS1SwitchableActor {}

class numPadPuzzle : SS1Puzzle
{
	string user_code;
	string input;
	bool solved;
	Hacker solver;
	default
	{
		//$Category "System Shock/Interactables/Puzzles
		//$Title "Keypad"
		//$sprite "NUMPA0"
		+WALLSPRITE;
		height 16;
		radius 8;
	}
	override bool used(Actor user)
	{
		if (!solved) {
			solver = Hacker(user);
			if (!solver.doPuzzle) {
				solver.doPuzzle = 1;
				input = "";
				return true;
			}
		}
		return false;
	}
	override void tick()
	{
		if (solver){
			if (!checkProximity("Hacker", 32)) {
				solver.doPuzzle = 0;
				solver = NULL;
			}
		}
	}
	override void switchState()
	{
		SS1SwitchableActor Actor;
		ActorIterator eiterator = level.createActorIterator(tid,"SS1SwitchableActor");
		for(Actor=SS1SwitchableActor(eiterator.next());actor!=NULL;actor=SS1SwitchableActor(eiterator.next())){
			if (!(self == Actor))
				Actor.switchstate();
			if (Actor is 'SS1Door')
				SS1Door(Actor).unlock();
		}
		setStateLabel("solved");
		solver.doPuzzle = 0;
		self.master = NULL;
		solver = NULL;
		solved = true;
	}
	void resetInput()
	{
		input = "";
	}
	void pressNumber(int num)
	{
		A_StartSound("env/puzzleButton");
		if (input.length() < 3)
		input = input..num;
	}
	void checkInput()
	{
		if (input == user_code && !instateSequence(CurState, ResolveState("Solved"))){
			switchState();
			A_StartSound("env/PuzzleSolved");
		} else {
			input = "Err";
			
		}
	}
	ui string getInput()
	{
		return input;
	}
	states
	{
		spawn:
			NUMP A -1;
			wait;
		solved:
			NUMP B -1;
			wait;
	}
}

class SS1Elevator : SS1SwitchableActor
{
	default
	{
		//$Category "System Shock/World Objects"
		//$Title "Floor Controller"
		//$sprite "CRT2A0"
	}
	int user_topHeight;
	int user_bottomHeight;
	int user_direction;
	bool user_touchActivate;
	bool user_onlyonce;
	int dir;
	int topHeight;
	int bottomHeight;
	bool hasUsed;
	override void postbeginplay()
	{
		dir = user_direction;
		topHeight = user_topHeight;
		bottomHeight = user_bottomHeight;
	}
	override void tick()
	{
		super.tick();
		if (!CheckProximity("Hacker",32)){
			hasUsed = false;
		}
		
		if (user_touchActivate && (getzAt()==topHeight || getZAt()==bottomHeight) && CheckProximity("Hacker",16,1) && !hasUsed) {
			switchState();
		}
		if (dir == 0)
		{
			if(getZAt() > bottomHeight)
				Generic_Floor(tid,4,4,0,0);
			else
				A_StopSound();
		} else if (dir == 1) {
			if(getzAt() < topHeight)
				Generic_Floor(tid,4,4,0,8);
			else
				A_StopSound();
		}
	}
	override void switchState()
	{
		if (user_onlyonce)
			user_touchActivate = false;
		A_Startsound("plat/SS1Move",CHAN_VOICE,CHANF_LOOP);
		hasUsed = true;
		if (dir == 0)
			dir = 1;
		else
			dir = 0;
	}
	states
	{
		spawn:
		keepgoing:
			TNT1 A 1;
			loop;
	}
}
class SS1Ceiling : SS1SwitchableActor
{
	default
	{
		//$Category "System Shock/World Objects"
		//$Title "Ceiling Controller"
		//$sprite "CRT3A0"
		+SPAWNCEILING;
		+NOGRAVITY;
	}
	int user_topHeight;
	int user_bottomHeight;
	int user_direction;
	
	int dir;
	int topHeight;
	int bottomHeight;
	
	override void postbeginplay()
	{
		dir = user_direction;
		topHeight = user_topHeight;
		bottomHeight = user_bottomHeight;
	}
	override void tick()
	{
		super.tick();
		if (dir == 0)
		{
			if(getZAt(0,0,0,GZF_CEILING) > bottomHeight)
				Generic_Ceiling(tid,4,4,0,0);
			else
				A_StopSound();
		} else if (dir == 1) {
			if(getZAt(0,0,0,GZF_CEILING) < topHeight)
				Generic_Ceiling(tid,4,4,0,8);
			else
				A_StopSound();
		}
	}
	override void switchState()
	{
		A_Startsound("plat/SS1Move",CHAN_VOICE,CHANF_LOOP);
		if (dir == 0)
			dir = 1;
		else
			dir = 0;
	}
	states
	{
		spawn:
		keepgoing:
			TNT1 A 1;
			loop;
	}
}

class Switch1 : SS1switch
{
	default
	{
		//$Title "Switch 1"
		//$Sprite "SWCHA0"
	}
	States
	{
		
		Spawn:
			SWCH A 1 { active = false; }
			goto Off;		
	}
}

class Switch2 : SS1switch
{
	default
	{
		//$Title "Switch 2"
		//$Sprite "SWH2A0"
	}
	States
	{
		
		Spawn:
			SWH2 A 1 { active = false; }
			goto Off;		
	}
}


class Button1 : SS1switch
{
	Default
	{
		//$Category "System Shock/Interactables"
		//$Title "Button 1"
		//$Sprite "BUTNA0"
		ActiveSound "switches/button";
	}
	States
	{
		Spawn:
			BUTN A -1;
	}
}

class Button2 : SS1switch
{
	Default
	{
		//$Category "System Shock/Interactables"
		//$Title "Button 2"
		//$Sprite "BTN2A0"
		ActiveSound "switches/button";
	}
	States
	{
		Spawn:
			BTN2 A -1;
	}
}

class BigButton : SS1switch
{
	Default
	{
		//$Category "System Shock/Interactables"
		//$Title "Big Button"
		//$Sprite "BBTNA0"
		ActiveSound "switches/bigbutton";
	}
	States
	{
		Spawn:
			BBTN A -1;
	}
}



class Lever1 : SS1switch
{
	Default
	{
		//$Category "System Shock/Interactables"
		//$Title "Lever 1"
		//$Sprite "LEVRA0"
		height 16;
		ActiveSound "switches/lever";
	}
	States
	{
		
		Spawn:
			LEVR A -1;
			wait;

		
	}
}


class RechargeStation : Actor
{
	int cooldown;
	default
	{
		radius 4;
		height 4;
	}
	override void tick()
	{
		super.tick();
		cooldown -= cooldown > 0 ? 1 : 0;
	}
	override bool Used(Actor user)
	{
		let hpl=Hacker(user);
		if (!cooldown){
			setStateLabel("used");
			hpl.InternalCharge = 255;
			cooldown = 2100;
			return true;
		} else {
			user.a_print("This recharge station is currently charging.");
			return false;
		}
	}
	States
	{
		Spawn:
			BATT A 1;
			loop;
		used:
			BATT AA 0 A_Startsound("rechargestation/recharge");
			goto Spawn;
	}
}

class SurgeryBed : Actor
{
	bool heal;
	int warmup;
	default
	{
		radius 16;
		height 32;
	}
	void fullrestore(Hacker currUser)
	{
		currUser.incapacitated=0;
		currUser.incapacitated=0;
		currUser.incaptimer=0;
		currUser.beatcap=35;currUser.beatmax=35;
		currUser.bloodpressure=0;currUser.beatcounter=0;
		currUser.fatigue=0;
		currUser.stunned=0;
		currUser.stimcount=0;
		currUser.zerk=0;
	
		currUser.bloodloss=0;
	
		currUser.A_Capacitated();
	
		currUser.feetangle=angle;
		currUser.hasgrabbed=false;

		//heat persists after zero value, so it must be destroyed
		let hhh=currUser.findinventory("Heat");if(hhh)hhh.destroy();
		currUser.woundcount=0;
		currUser.unstablewoundcount=0;
	
		currUser.oldwoundcount=0;
		currUser.burncount=0;

		currUser.givebody(max(0,currUser.maxhealth()-health));
	}
	override bool Used(Actor user)
	{
		setStateLabel("used");
		let currUser = Hacker(user);
		heal = true;
		warmup = 0;
		currUser.A_SetBlend("99 99 99",1.0,35,"99 99 99",0.0);
		fullRestore(currUser);
		return true;
	}
	States
	{
		Spawn:
			BATT A 1;
			loop;
		used:
			BATT AA 0 A_Startsound("SurgeryBed/Operate");
			goto Spawn;
	}
}

class gravlift : SS1SwitchableActor
{
	int user_direction;
	int dir;
	float user_height;
	default
	{
		//$Category "System Shock/Interactables"
		//$Title "Gravity Lift"
		//$sprite "GRAVB0"
		+FLATSPRITE;
		scale 0.5;
	}

	override void postbeginplay()
	{
		super.postbeginplay();
		dir = user_direction;
		height = user_height;
	}
	override void tick()
	{
		super.tick();
		if (dir == 0) setStateLabel("up");
		else setStateLabel("down");
		BlockThingsIterator it = BlockThingsIterator.Create(self,32);
		Actor mo;
		while (it.Next())
		{
			mo = it.thing; // Get the Actor it's currently on
			if (!mo || !mo.bSolid || Distance2D(mo) > 32)
				continue;
			else {
				if (!(mo is "gravlift")){
					if (dir == 0) {
						if (mo.pos.z < getZAt() + user_height)
							mo.vel.z = 1;
						else if (mo.pos.z < getZAt() + user_height+3)
							mo.vel.z = 0;
					} else {
						if (mo.pos.z-mo.height > getZAt())
							mo.vel.z = -1;
					}
				}
			}
		}
	}
	override void switchState()
	{
		if (dir)
			dir = 0;
		else
			dir = 1;
	}
	states
	{
		spawn:
		up:
			GRAV B -1;
			wait;
		down:
			GRAV A -1;
			wait;
	}
}

class CSpaceTerm : Actor
{
	default
	{
		//$Category "System Shock/Interactables"
		//$Title "C-Space Terminal"
		+NOGRAVITY;
		radius 16;
		height 32;
		+USESPECIAL
	}
	states
	{
		spawn:
			BATT A 1;
			loop;
	}
}

class ForceBridge : SS1SwitchableActor
{
	string user_startState;
	default
	{
		//$Category "System Shock/World Objects"
		//$Title "Force Bridge"
		RenderStyle "Translucent";
		Alpha 0.5;
		radius 32;
		height 4;
		+SOLID;
		+NOGRAVITY;
		+NOLIFTDROP;
		+ACTLIKEBRIDGE;
	}
	override void switchState()
	{
		if (instateSequence(CurState, ResolveState("turnOff")))
			setStateLabel("turnOn");
			else setStateLabel("turnOff");
	}
	States
	{
		Spawn:
			TNT1 A 1 NODELAY { 
						if (user_startState == "on")
							return state(resolveState("on"));
						else {
							invoker.bSolid = false;
							return state(resolveState("off"));
						}
					}
			goto off;
		turnOn:
			BATT A 65 A_StartSound("env/forcebridge");
		on:
			BATT B 1 { invoker.bSolid = true; }
			loop;
		turnOff:
			BATT B 65 A_StartSound("env/forcebridge");
			BATT A 1 { invoker.bSolid = false; }
		off:
			TNT1 A 1;
			loop;
		
	}
}

class CPUNode : Actor
{
	default
	{
		//$Category "System Shock/Interactables"
		//$Title "CPU Node"
		radius 16;
		height 16;
		+SOLID;
	}
	States
	{
		Spawn:
			BATT A -1;
			wait;
	}
}
class SS1ladder : Actor
{
	int user_height;
	int user_radius;
	int user_width;
	int width;
	int dir;
	int hdir;
	Hacker user;
	int top;
	int soundCounter;
	default
	{
		//$Category "System Shock/Interactables"
		//$Title "Ladder"
		//$sprite "SLADA0"
		scale 0.5;
		+WALLSPRITE
		-NOGRAVITY
		
	}
	override void postBeginPlay()
	{
		A_SetSize(user_radius, user_height);
		if (user_width)
			width = user_width;
		else
			width = 64;
	}
	override bool used(Actor user)
	{
		if (!self.user) {
			if (distance2d(user) < radius*2){
				let hpl = hacker(user);
				if (user is 'Hacker')
				{
					if (Hacker(user).incapacitated)
						return false;
					self.user = hpl;
					hpl.angle = angle;
					hpl.viewbob = 0;
					hpl.pitch = 0;
					hpl.player.cheats |= CF_FROZEN;
					soundcounter = 17;
					A_StartSound("env/ladder");
					vector3 newpos = (pos.x, pos.y, hpl.pos.z);
					hpl.setOrigin(newpos,true);
					hpl.vel = (0,0,0);
					dir = 0;
					hdir = 0;
				}
			}
		}
		return true;
	}
	override void tick()
	{
		super.tick();
		if (user) {
			user.vel.z = 0;
			user.vel.x = 0;
			user.vel.y = 0;
			int input = user.getPlayerInput(INPUT_BUTTONS);
			if (input & (BT_FORWARD | BT_BACK | BT_MOVELEFT | BT_MOVERIGHT)) {
				if (soundCounter <= 0)
				{
					soundCounter = 17;
				}
			}

			if (input & BT_FORWARD)
				dir = 1;
			else if (input & BT_BACK)
				dir = -1;
			if (input & BT_MOVELEFT)
				hdir = 1;
			else if (input & BT_MOVERIGHT)
				hdir = -1;
			user.viewbob = 0;
			if (hd_debug) {
				A_LogFloat(user.pos.z);
				A_LogFloat(pos.z + height);
				A_LogFloat(height);
				A_LogInt(soundCounter);
			}
			
			if (soundCounter){
				soundCounter--;
				if (input & BT_SPEED)
					soundCounter--;
				int speed = input & BT_SPEED ? 3 : 2;
				if (soundCounter < 10) {
					if (dir == 1) {
						user.vel.z = speed;
					} else if (dir == -1) {
						user.vel.z = -speed;
					} 
	
					if (hdir == 1) {
						user.velFromAngle(speed, angle+90);
					} else if (hdir == -1) {
						user.velFromAngle(speed, angle-90);
					}
				}
				if (soundCounter <= 0)
				{
					A_StartSound("env/ladder");
				}
			}
			if (distance2d(user) > width ||
			   (user.pos.z == user.getZAt() && input & BT_BACK) ||
			    user.pos.z > pos.z + height || 
				input & BT_JUMP){
				if (user.pos.z > height)
					user.velFromAngle(3);
				Hacker(user).player.cheats &= ~CF_FROZEN;
				user = NULL;
			}
			
		}
	}
	states
	{
		spawn:
			TNT1 A -1;
			wait;
	}
}