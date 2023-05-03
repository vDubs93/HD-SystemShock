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

Class ControlPedestal : SS1SwitchableActor {
	Default {
		Radius 16;
		Height 48;
		+SOLID
		+INVULNERABLE
		+NODAMAGE
		+SHOOTABLE
		+NOTAUTOAIMED
		+NEVERTARGET
		+DONTTHRUST
		//$Category "System Shock/Interactables"
		//$Title "Control Pedestal"
	}

	States {
		Spawn:
			PLAY A -1;
			Stop;
	}
}

class ElevatorMusic : Actor
{
	bool musicOff;
	override void postBeginPlay()
	{
		musicOff = false;
		super.postBeginPlay();
		A_StartSound("env/ElevatorMusic",20,CHANF_LOOPING, 0.0001, ATTN_NONE);
		A_SoundVolume(20, 0);
		
	}
	
	override void tick()
	{	
		if (!CheckProximity("Hacker", 32)){
			if (musicOff == true){
				SetMusicVolume(1.0);
				A_SoundVolume(20, 0);
				musicOff = false;
			}
		} else{
			if (musicOff == false){
				musicOff = true;
				A_SoundVolume(20,1);
				SetMusicVolume(0);	
			}
		}	
	}
}


class SS1SwitchableActor : Actor
{
	bool active;
	virtual void switchState(){}
	bool isActive () { return active; }
	default
	{
		mass 4000;
	}
}

class SS1RespawnPoint : SS1SwitchableActor
{
	default
	{
		//$Category "System Shock/World Objects
		//$Title "Respawn Point"
		height 64;
		radius 8;
	}
	override void switchState()
	{
		if (!active)
			A_StartSound("env/RespawnActive", 19, 0, 1.0, ATTN_NONE);
		else
			A_StartSound("env/RespawnInactive", 19, 0, 1.0, ATTN_NONE);
		active = !active;
	}
}

class SS1Switch : SS1SwitchableActor
{
	int user_switchtype;
	int user_arg1;
	int user_arg2;
	int user_arg3;
	int user_arg4;
	override bool used(Actor user)
	{
		if (distance3d(user) > Hacker(user).userange)
			return false;
		switchState();
		SS1Switch next;
		ActorIterator iterator = Level.createActorIterator(tid,"SS1Switch");
		iterator.reinit();
		for(next=SS1Switch(iterator.next());next!=null;next=SS1Switch(iterator.next())){
			
		}
		iterator.reinit();
		switch (user_switchtype) {
			case 0:
				SS1SwitchableActor pActor;
				ActorIterator eiterator = level.createActorIterator(tid,"SS1SwitchableActor");
				for(pActor=SS1SwitchableActor(eiterator.next());pActor!=NULL;pActor=SS1SwitchableActor(eiterator.next())){
					if (pActor is 'SS1Door'){
						if (!(pActor is 'ForceDoor')){
							SS1Door door = SS1Door(pActor);
							if (door.isLocked()) {
								door.unlock();
								door.switchState();
							} else {
								door.lock();
								if(!door.closed)
									door.switchState();
							}
						} else ForceDoor(pActor).switchState();
					} else if (pActor is 'SS1Elevator'){
						SS1Elevator elevator = SS1Elevator(pActor);
						if (elevator.isLocked()){
							elevator.unlock();
						} else
							elevator.switchstate();
					} else if (!(pActor is 'SS1Switch')){
							pActor.switchState();
						}
					
				}
				break;
			case 1:
				Light_stop(tid);
				if (!active){
					Light_changeToValue(tid, user_arg1);
					Thing_Deactivate(tid);
				}else{
					Light_fade(tid, user_arg2, 35);
					Thing_Activate(tid);
				}
				
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
class SS1Puzzle : SS1SwitchableActor {
	Hacker solver;
	bool solved;
	default
	{
		+NOGRAVITY;
	}
	override void switchState()
	{
		if (!solved){
			A_StartSound("env/PuzzleSolved");
			SS1SwitchableActor pActor;
			ActorIterator eiterator = level.createActorIterator(tid,"SS1SwitchableActor");
			for(pActor=SS1SwitchableActor(eiterator.next());pActor!=NULL;pActor=SS1SwitchableActor(eiterator.next())){
				if (pActor is 'SS1Door'){
					if (!(pActor is 'ForceDoor')){
						SS1Door door = SS1Door(pActor);
						if (door.isLocked()) {
							door.unlock();
							door.switchState();
						} else {
							door.lock();
							if(!door.closed)
								door.switchState();
						}
					} else ForceDoor(pActor).switchState();
				} else if (pActor is 'SS1Elevator'){
					SS1Elevator elevator = SS1Elevator(pActor);
					if (elevator.isLocked()){
						elevator.unlock();
					}
				}
			}
			setStateLabel("solved");
			self.master = NULL;
			solved = true;
		}
	}
}

class AccessPanelPuzzle : SS1Puzzle {
	String user_puzzle;
	int gridArray[5][7][2];
	bool visited[5][7];
	int nX[4];
	int nY[4];
	default
	{
		//$Category "System Shock/Interactables/Puzzles
		//$Title "AccessPanel"
		//$sprite "APANA0"
		+WALLSPRITE;
		height 16;
		radius 8;
	}
	override void tick()
	{
		if (solver){
			if (!checkProximity("Hacker", 32) || solved) {
				solver.doPuzzle = 0;
				solver = NULL;
			}

		}
	}
	override bool used(Actor user)
	{
		if (checkProximity("Hacker", 32) && !solved) {
			setStateLabel("opened");
			solver = Hacker(user);
			if (!solver.doPuzzle) {
				solver.doPuzzle = 2;
				solver.currPuzz = self;
				return true;
			}
		}
		return false;
	}
	override void postbeginplay()
	{
		nX[0] = 0;
		nX[1] = 1;
		nX[2] = 0;
		nX[3] = -1;
		nY[0] = -1;
		nY[1] = 0;
		nY[2] = 1;
		nY[3] = 0;
		for(int i = 0; i < 5; i++){
			for(int j=0; j < 7; j++) {
				gridArray[i][j][0] = user_puzzle.Mid((i * 7) + j,1).toInt();
				gridArray[i][j][1] = 0;
			}
		}

		route();
		
		super.postbeginplay();
	}
	
	void route(){

		for(int y=0; y<5; y++) {
			for(int x=0; x<7; x++) {
				gridArray[y][x][1] = 0;
				visited[y][x] = false;
			}
		}
		dfs(0,2);
		if (gridArray[2][6][1] == 1)
			switchState();
	}
	void dfs(int x, int y) {
		
		int dx;
		int dy;
		visited[y][x] = true;
		gridArray[y][x][1] = 1;
		for (int i = 0; i < 4; i++) {
			dx = x + nX[i];
			dy = y + nY[i];
			
			if (isValidSpace(dx, dy) && !visited[dy][dx])
			{
				dfs(dx, dy);
			}
		}
	}
	bool isValidSpace(int x, int y) {
		return (x >=0 && x <= 6 && y >= 0 && y <= 4 && gridArray[y][x][0] == 1);
	}
	
	void flipSpace(int x, int y)
	{
		if (gridArray[y][x][0] < 2) {
			gridArray[y][x][0] = gridArray[y][x][0]? 0 : 1;
			route();
		}
	}
	ui int getGridSpaceFlipped(int x, int y){
		return gridArray[y][x][0];
	}
	ui int getGridSpaceStatus(int x, int y){
		return gridArray[y][x][1];
	}
	states
	{
		spawn:
			APAN A -1;
			wait;
		solved:
		opened:
			APAN B -1;
			wait;
	}
}

class numPadPuzzle : SS1Puzzle
{
	string user_code;
	string input;

	default
	{
		//$Category "System Shock/Interactables/Puzzles
		//$Title "Keypad"
		//$sprite "NUMPA0"
		+WALLSPRITE;
		height 16;
		radius 8;
	}
	override void tick()
	{
		if (solver){
			if (!checkProximity("Hacker", 32) || solved) {
				solver.doPuzzle = 0;
				solver = NULL;
			}
		}
	}
	override bool used(Actor user)
	{
		if (!solved) {
			solver = Hacker(user);
			if (!solver.doPuzzle) {
				solver.doPuzzle = 1;
				solver.currPuzz = self;
				input = "";
				return true;
			}
		}
		return false;
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
	bool user_locked;
	int user_light;
	int dir;
	int topHeight;
	int bottomHeight;
	bool hasUsed;
	override void postbeginplay()
	{
		dir = user_direction;
		topHeight = user_topHeight;
		bottomHeight = user_bottomHeight;
		if (!isLocked() && user_light)
			A_AttachLight("floorLight", DynamicLight.SectorLight,"white",8,0,DYNAMIClIGHT.LF_ATTENUATE,(0,0,16));
	}
	bool isLocked()
	{
		return user_locked;
	}
	void unlock(){
		user_locked = false;
		Thing_Activate(tid);
		if (user_light) {
			A_AttachLight("floorLight", DynamicLight.SectorLight,"white",8,0,DYNAMIClIGHT.LF_ATTENUATE,(0,0,16));
		}
	}
	override void tick()
	{
		super.tick();
		
		
		if (user_touchActivate && (getzAt()==topHeight || getZAt()==bottomHeight) && CheckProximity("Hacker",16,1) && !hasUsed) {
			switchState();
		}
		if (dir == 0)
		{
			if(getZAt() > bottomHeight)
				Generic_Floor(tid,4,4,0,0);
			else{
				if (!CheckProximity("Hacker",32) && hasUsed && (getzAt()==topHeight || getZAt()==bottomHeight))
					hasUsed = false;
				A_StopSound();
			}
		} else if (dir == 1) {
			if(getzAt() < topHeight)
				Generic_Floor(tid,4,4,0,8);
			else{
				if (!CheckProximity("Hacker",32) && hasUsed && (getzAt()==topHeight || getZAt()==bottomHeight))
					hasUsed = false;
				A_StopSound();
			}
		}
		
	}
	override void switchState()
	{
		hasUsed = true;
		if(!user_locked){
			if (user_onlyonce)
				user_touchActivate = false;
			A_Startsound("plat/SS1Move",CHAN_VOICE,CHANF_LOOP);
			if (dir == 0)
				dir = 1;
			else
				dir = 0;
		}
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

class Lever2 : SS1switch
{
	Default
	{
		//$Category "System Shock/Interactables"
		//$Title "Lever 2"
		//$Sprite "LVR2A0"
		height 16;
		ActiveSound "switches/lever";
	}
	States
	{
		
		Spawn:
			LVR2 A -1;
			wait;

		
	}
}


class RechargeStation : SS1Prop
{
	int cooldown;
	default
	{
		radius 12;
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

class SurgeryBed : SS1Prop
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
		let hpl = hacker(user);
		hpl.healthreset();
		hpl.incaptimer = 0;
		hpl.health = hpl.maxhealth();
		hpl.fatigue = 0;
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
	bool user_setCeiling;
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
		let it = Level.CreateSectorTagIterator(tid);
		Sector sec;
		int index;
		while ((index = it.next()) >= 0) {
			sec = Level.Sectors[index];
			let tex = TexMan.CheckForTexture(dir?"GRAVA0":"GRAVB0");
			sec.setTexture(Sector.floor, tex);
			if (user_setCeiling)
				sec.setTexture(Sector.ceiling, tex);
		}
	}
	override void tick()
	{
		super.tick();
		BlockThingsIterator it = BlockThingsIterator.Create(self,32);
		Actor mo;
		while (it.Next())
		{
			mo = it.thing; // Get the Actor it's currently on
			if (!mo || Distance2D(mo) > 32)
				continue;
			else {
				if (!(mo is "gravlift")){
					if (dir == 0) {
						if (mo is 'Hacker'){
							mo.player.onground = true;
						}
						if (mo.pos.z < getZAt() + user_height){
							if (mo.vel.z < 1)
								mo.vel.z = 1;
						} else if (mo.vel.z < 0 && abs(mo.pos.z - (getZAt() + user_height)) < 2) {
							mo.vel.z = 0;
							mo.setOrigin((mo.pos.x, mo.pos.y, getZAt() + user_height), true);
						}
					} else {
						if (mo.pos.z > getZAt())
							mo.vel.z = -1;
						else {
							mo.vel.z = 0;
							mo.setOrigin((mo.pos.x, mo.pos.y, getZAt()), true);
						}
					}
				}
			}
		}
	}
	override void switchState()
	{
		let it = Level.CreateSectorTagIterator(tid);
		Sector sec;
		int index;
		while ((index = it.next()) >= 0) {
			sec = Level.Sectors[index];
			let tex = TexMan.CheckForTexture(dir?"GRAVB0":"GRAVA0");
			sec.setTexture(Sector.floor, tex);
			if (user_setCeiling)
				sec.setTexture(Sector.ceiling, tex);
		}
		dir = dir ? 0 : 1;
	}
	states
	{
		spawn:
			TNT1 A -1;
			wait;
	}
}

class CSpaceTerm : Actor
{
	default
	{
		//$Category "System Shock/Interactables"
		//$Title "C-Space Terminal"
		//$Sprite "CSpaceIcon"
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
		//$Sprite "ForceBridge"
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
			BATT A 65 bright A_StartSound("env/forcebridge");
		on:
			BATT B -1 bright{ invoker.bSolid = true; }
			wait;
		turnOff:
			BATT B 65 bright A_StartSound("env/forcebridge");
			
		off:
			BATT A 1 { invoker.bSolid = false; }
			TNT1 A -1;
			wait;
		
	}
}

class CPUNode : HDActor
{
	default
	{
		//$Category "System Shock/Interactables"
		//$Title "CPU Node"
		//$Sprite "CNodeIcon"
		radius 32;
		height 64;
		health 50;
		+SOLID;
		+SHOOTABLE;
		+DONTTHRUST;
		-NOBLOCKMAP;
		+NOBLOOD;
	}
	States
	{
		Spawn:
			BATT A 1;
			loop;
		Death:
			BATT A 10 {
				A_StartSound("env/cpunodebreak");
				A_SpawnItemEx("cpuexplosion", 0, 0, 32);
			}
			TNT1 A 1 A_HDBlast(128, frandom(10, 70),192,"none",64,8,128);
			stop;
	}
	
	override int DamageMobj(
        actor inflictor,
        actor source,
        int damage,
        name mod,
        int flags,
        double angle
    ){
        if(
			mod == "Magnetic"
        ) damage *= 2;
		if(
			mod == "Gas"
		) damage = 0;
        return super.DamageMobj(inflictor,source,damage,mod,flags,angle);
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
		+WALLSPRITE;
		+MOVEWITHSECTOR;
		
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
				if (user is 'Hacker' && isLookingAt(user))
				{
					if (Hacker(user).incapacitated)
						return false;
					self.user = hpl;
					hpl.angle = angle;
					hpl.viewbob = 0;

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
	bool isLookingAt(Actor user){
		user = Hacker(user);
		FLineTraceData ray;
		user.LineTrace(user.angle, radius * 2, user.pitch, TRF_ALLACTORS, 0, data: ray);
		Actor pActor = ray.HitActor;
		if (pActor){
			if (pActor == self)
				return true;
		}
		return false;
	}
	override void tick()
	{
		super.tick();
		if (pos.z != GetZAt())
			setOrigin((pos.x, pos.y, GetZAt()),true);
		if (hd_debug){
			CheckProximity("Hacker", 32, 1, CPXF_SETMASTER);
			if (master){
				A_Log("" .. isLookingAt(master));
				A_Log("playerAngle: " .. (master.angle % 360));
				A_Log("ladderAngle: " .. self.angle);
			}
		}
		master = null;
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
			loop;
	}
}