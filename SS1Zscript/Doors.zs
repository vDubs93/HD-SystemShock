class SS1Door : SS1SwitchableActor
{
	int doorType;
	bool closed;
	int user_clearance;
	property doorType: doorType;
	int user_wait;
	bool user_locked;
	bool locked;
	int timer;
	int numFrames;
	string user_lockedmessage;
	override void postBeginPlay() {
		timer = 0; 
		line_setblocking(tid,913,0);
		closed = true;
	}
	override bool used(Actor user)
	{
		super.used(user);
		if (!user_locked || (user_clearance & Hacker(user).accesses)) {
			unlock();
			SS1Door next;
			ActorIterator iterator = Level.createActorIterator(tid,"SS1Door");
			for(next=SS1Door(iterator.next());next!=null;next=SS1Door(iterator.next())){
				next.switchState();
			}
		} else {
			user.A_Print(user_lockedMessage);
		}
		return true;
	}
	void unlock() {
		user_locked = false;
	}
	override void switchState()
	{
		if(instatesequence(CurState,ResolveState("open"))){
			if (!CountProximity("Hacker",10)) {
				setStateLabel("close");
				closed = true;
				timer = 0;
				line_setBlocking(tid, 913, 0);
				A_StartSound(seesound);
			}
		} else {
			setStateLabel("open");
			line_setBlocking(tid, 0, 913);
				A_StartSound(seesound);
				closed = false;
			if (user_wait > 0)
				timer = user_wait * 35;
			else
				timer = -1;
		}
		
	}
	override void tick()
	{
		super.tick();
		if (health < 2 && user_locked)
		{
		A_Log("Unlocked");
			unlock();
			SS1Door next;
			ActorIterator iterator = Level.createActorIterator(tid,"SS1Door");
			for(next=SS1Door(iterator.next());next!=null;next=SS1Door(iterator.next())){
				next.switchState();
			}
		}
		
		if(instatesequence(CurState,ResolveState("open")))
		{
			if (timer > 0)
				timer--;
			else if (timer == 0){
				if (!CountProximity("Hacker",10)) {
					used(self);
				}
			}
		}
	}
	default
	{
		//$Category "System Shock/Doors
		+WALLSPRITE;
		+NONSHOOTABLE;
		height 64;
		radius 16;
		health 2;
	}
	states
	{
		spawn:
			TNT1 A 1;
			loop;
		open:
			#### # 4 { frame += frame < self.numFrames-1 ? 1 : 0;}
			wait;
		close:
			#### # 4 { frame -= frame > 0 ? 1 : 0;}
			wait;
	}
}

class forceDoor : SS1Door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 2;
	}
	default
	{
		//$Category "System Shock/Doors"
		//$Title "Force Door"
		RenderStyle "Translucent";
		Alpha 0.5;
		radius 0;
	}
	states
	{
		spawn:
			FRCD A -1;
			wait;
	}
}

class SS1door1 : SS1door
{
	
	default
	{
		//$Title "Blast Door"
		SS1Door.doortype 1;
		seesound "door2";
	}
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 7;
	}
	states
	{
		spawn:
			DOR1 A 1;
			wait;
	}
}
class SS1door2 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 7;
	}	
	default
	{
		//$Title "Service Access Door"
		SS1Door.doortype 2;
		seesound "door2";
		 
	}
	states
	{
		spawn:
			DOR2 A 1;
			wait;
	}
}
class SS1door3 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 8;
	}
	default
	{
		//$Title "Blast Door 2"
		SS1Door.doortype 3;
		seesound "door2";
		 
	}
	states
	{
		spawn:
			DOR3 A 1;
			wait;
	}
}
class SS1door4 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 8;
	}	
	default
	{
		//$Title "Medical Door"
		SS1Door.doortype 4;
		seesound "door1";
		 
	}
	states
	{
		spawn:
			DOR4 A 1;
			wait;
	}
}
class SS1door5 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 6;
	}	
	default
	{
		//$Title "Science door"
		SS1Door.doortype 5;
		seesound "door1";
		 
	}
	states
	{
		spawn:
			DOR5 A 1;
			wait;
	}
}

class SS1door6 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 6;
	}	
	default
	{
	//$Title "Storage Door"
		SS1Door.doortype 6;
		seesound "door2";
		 
	}
	states
	{
		spawn:
			DOR6 A 1;
			wait;
	}
}

class SS1door7 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 8;
	}
	default
	{
		//$Title "Shielded Door"
		SS1Door.doortype 7;
		seesound "door2";
		 
	}
	states
	{
		spawn:
			DOR7 A 1;
			wait;
	}
}

class SS1door8 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 7;
	}
	default
	{
		//$Title "Executive Door"
		SS1Door.doortype 8;
		seesound "door5";
		 
	}
	states
	{
		spawn:
			DOR8 A 1;
			wait;
	}
}

class SS1door9 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 8;
	}
	default
	{
		//$Title "Laser Door"
		SS1Door.doortype 9;
		seesound "door3";
		 
	}
	states
	{
		spawn:
			DOR9 A 1;
			wait;
	}
}

class SS1door10 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 6;
	}
	default
	{
		//$Title "Grating Door"
		SS1Door.doortype 10;
		seesound "door3";
	}
	states
	{
		spawn:
			DR10 A 1;
			wait;
	}
}
class SS1door11 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 8;
	}
	default
	{
		//$Title "Single Large Blast Door"
		SS1Door.doortype 11;
		seesound "door4";
		radius 24;
	}
	states
	{
		spawn:
			DR11 A 1;
			wait;
	}
}
class SS1door12 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 7;
	}
	default
	{
		//$Title "Iris Door"
		SS1Door.doortype 12;
		seesound "door5";
	}
	states
	{
		spawn:
			DR12 A 1;
			wait;
	}
}
class SS1door13 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 5;
	}
	default
	{
		//$Title "Secret Duralloy Door"
		SS1Door.doortype 13;
		seesound "door1";
	}
	states
	{
		spawn:
			DR13 A 1;
			wait;
	}
}
class SS1door14 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 6;
	}
	default
	{
		//$Title "Secret Soft-Panelling Door"
		SS1Door.doortype 14;
		seesound "door1";
	}
	states
	{
		spawn:
			DR14 A 1;
			wait;
	}
}
class SS1door15 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 6;
	}
	default
	{
		//$Title "Secret Storage Door"
		SS1Door.doortype 15;
		seesound "door1";
	}
	states
	{
		spawn:
			DR15 A 1;
			wait;
	}
}
class ss1door16 : ss1door11
{

	default
	{
		//$Title "Large Double Door"

	}
	states
	{
		spawn:
			DR16 A 1;
			wait;
	}
}
class SS1ElevatorDoor01 : ss1Door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 7;
	}
	default
	{
		//$Title "Executive Elevator Door"
		seesound "door1";
		
	}
	states
	{
		spawn:
			DR17 A 1;
			wait;
	}
}
class SS1ElevatorDoor02 : ss1Door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 7;
	}
	default
	{
		//$Title "Main Elevator Door"
		seesound "door1";
	}
	states
	{
		spawn:
			DR18 A 1;
			wait;
	}
}
class SS1ElevatorDoor03 : ss1Door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 8;
	}
	default
	{
		//$Title "Grove Elevator Door"
		seesound "door1";
	}
	states
	{
		spawn:
			DR19 A 1;
			wait;
	}
}
class SS1ElevatorDoor04 : ss1Door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 8;
	}
	default
	{
		//$Title "Freight Elevator Door"
		seesound "door2";
	}
	states
	{
		spawn:
			DR20 A 1;
			wait;
	}
}