class SS1Door : SS1SwitchableActor
{
	int doorType;
	bool closed;
	int user_clearance;
	property doorType: doorType;
	int user_wait;
	bool user_locked;
	int user_startframe;
	bool locked;
	int timer;
	int numFrames;
	bool dummyActivate;
	string user_lockedmessage;
	property lockedmessage: user_lockedmessage;
	bool isLookingAt(Actor user){
		user = Hacker(user);
		if(!user)
			return false;
		FLineTraceData ray;
		user.LineTrace(user.angle, 1024, user.pitch, TRF_ALLACTORS, Hacker(user).viewheight, data: ray);
		Actor pActor = ray.HitActor;
		if (pActor){
			if (pActor == self)
				return true;
		}
		return false;
	}
	override void postBeginPlay() {
		timer = 0; 
		line_setblocking(tid,913,0);
		closed = true;
		A_SpawnItemEx("doorDummy", 0,22,0, 0,0,0,0,SXF_SETMASTER);
		A_SpawnItemEx("doorDummy", 0,-22,0, 0,0,0,0,SXF_SETMASTER);
	}
	override bool used(Actor user)
	{
		super.used(user);
		if (instatesequence(CurState,ResolveState("open")) && !dummyActivate && user != self)
			return false;
		vector3 userpos = (user.pos.x, user.pos.y, user.pos.z+(user.height/2));
		float distance = abs((userpos- pos).length());
		if (user == self || isLookingAt(user) && distance < 128 || dummyActivate) {
			dummyActivate = false;
			if (user == self || !user_locked || (
				user_clearance & Hacker(user).accesses 
				)) {
				unlock();
				SS1Door next;
				ActorIterator iterator = Level.createActorIterator(tid,"SS1Door");
				for(next=SS1Door(iterator.next());next!=null;next=SS1Door(iterator.next())){
					next.switchState();
				}
			} else {
				user.A_Print(user_lockedMessage);
			}
		}
		dummyActivate = false;
		return true;
	}
	void unlock() {
		user_locked = false;
	}
	void lock() {
		user_locked = true;
	}
	bool isLocked(){ 
		return user_locked; 
	}
	override void switchState()
	{
		if(instatesequence(CurState,ResolveState("open"))){
			if (!CountProximity("Hacker",10)) {
				A_StartSound(seesound);
				 bSHOOTABLE = True;
				 bNOINTERACTION = false;
				 A_ChangeLinkFlags(false);
				setStateLabel("close");
				closed = true;
				timer = 0;
				line_setBlocking(tid, 913, 0);
				
			}
		} else {
			setStateLabel("open");
			 bSHOOTABLE = false;
			 bNOINTERACTION = true;
			 A_ChangeLinkFlags(true);
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
		/*if (health < 2 && user_locked)
		{
			unlock();
			SS1Door next;
			ActorIterator iterator = Level.createActorIterator(tid,"SS1Door");
			for(next=SS1Door(iterator.next());next!=null;next=SS1Door(iterator.next())){
				next.switchState();
			}
		}*/
		
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
		+SHOOTABLE;
		+NOBLOOD;
		+NOGRAVITY;
		height 64;
		radius 16;
		health -1;
		SS1Door.lockedmessage "This door is locked.";
	}
	states
	{
		spawn:
			TNT1 A 1;
			loop;
		setFrame:
			#### # -1 {frame = user_startFrame;}
			loop;
		open:
			#### # 4 {
				frame += frame < self.numFrames-1 ? 1 : 0;}
			wait;
		close:
			#### # 4 {
				frame -= frame > 0 ? 1 : 0;}
			wait;
	}
}

class SS1FloorDoor : SS1Door
{
	default
	{
		//$Category "System Shock/Doors
		+FLATSPRITE;
		-WALLSPRITE;
		height 1;
		radius 32;
		+NOGRAVITY;
		+SOLID;
		+DONTTHRUST;
	}
	override void postBeginPlay() {
		timer = 0; 
		closed = true;
	}
	override bool used(Actor user){
		vector3 userpos = (user.pos.x, user.pos.y, user.pos.z+(user.height/2));
		float distance = abs((userpos- pos).length());
		if (isLookingAt(user) && distance < 128) {
			if (closed || (!closed && distance > 32)) {
				switchState();
				return true;
			}
		}
		return false;
	}
	
	override void switchState()
	{
		if(instatesequence(CurState,ResolveState("open"))){
			A_StartSound(seesound);
			setStateLabel("close");
			closed = true;
			timer = 0;
			bSOLID = true;
		} else {
			bSOLID = false;
			setStateLabel("open");
			A_StartSound(seesound);
			closed = false;
			if (user_wait > 0)
				timer = user_wait * 35;
			else
				timer = -1;
		}
	}
}

class doorDummy : Actor
{
	default
	{
		radius 6;
		height 64;
		+NONSHOOTABLE;
		-SOLID;
		+WALLSPRITE;
		+NOGRAVITY;
	}
	bool isLookingAt(Actor user){
		user = Hacker(user);
		FLineTraceData ray;
		user.LineTrace(user.angle, 1024, user.pitch, TRF_ALLACTORS, Hacker(user).viewheight, data: ray);
		Actor pActor = ray.HitActor;
		if (pActor){
			if (pActor == self)
				return true;
		}
		return false;
	}
	
	override bool used(Actor user){
		vector3 userpos = (user.pos.x, user.pos.y, user.pos.z+(user.height/2));
		float distance = abs((userpos- pos).length());
		if (isLookingAt(user) && distance<128) {
			SS1Door(master).dummyActivate = true;
			master.used(user);
			return true;
		}
		return false;
	}
	states
	{
		spawn:
			TNT1 A 1;
			loop;
	}
}

class forceDoor : SS1Door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 2;
	}
	override bool used(Actor user) {return null;}
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
			goto SetFrame;
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
			goto SetFrame;
	}
}
class SS1door2 : SS1door
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 8;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
	}
}
class SS1FloorDoor1 : SS1FloorDoor
{
	override void postbeginplay()
	{
		super.postbeginplay();
		numframes = 6;
	}
	default
	{
		//$Title "Secret Soft-Panelling Door - Floor"
		SS1Door.doortype 14;
		seesound "door1";
	}
	states
	{
		spawn:
			FDR1 A 1;
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
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
			goto SetFrame;
	}
}