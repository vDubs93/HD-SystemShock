class SS1Screen : SS1Decal
{
	int numFrames;
	int firstFrame;
	int index;
	Array<int> frames;
	override void postbeginplay()
	{
		super.postbeginplay();
		int xOffset = 4;
		if (pitch > 270)
			xOffset += 2;
		else if (pitch == 270)
			xOffset = 1;
		for(int i=0; i<4; i++){
			xOffset += pitch > 270 ? 4 : pitch < 270 ? -4 : 0;
			for(int j=-1; j<2; j++){
				A_SpawnItemEx("SS1ScreenCollisionDummy", xOffset, 10*j, 9*i, 0, 0, 0, 0, SXF_SETMASTER);
			}
		}
	}
	default
	{
		//$Category "System Shock/Screens"
		-WALLSPRITE;
		+FLATSPRITE;
		+NOINTERACTION;
	}
	states
	{
		xdeath:
		death:
			TNT1 AA 0 A_StartSound("env/ScreenBreak");
			SCRB A 4 bright
			{
				float xOffset = 16*sin(pitch-270)+8;
				float zOffset = 16*cos(pitch-270);
				A_KillChildren("none", 0, "SS1ScreenCollisionDummy");
				A_SpawnItemEx("Explosion1",xOffset, 0, zOffset,0,0,0,0,SXF_TRANSFERPITCH);
			}
			SCRB BCD 4 bright;
			SCRB E -1;
			stop;
			
	}
}

class SS1ScreenCollisionDummy : Actor
{
	default
	{
		radius 8;
		height 12;
		health 1;
		+SHOOTABLE;
		+DONTFALL;
		+DONTTHRUST;
		+NOBLOOD;
		+NOGRAVITY;
		
	}
	states
	{
		spawn:
			TNT1 A -1;
			wait;
		death:
			TNT1 A 1 {
				master.setStateLabel("death");
				
			}
			stop;
	}

}

class SS1Logo1 : SS1Screen
{	
	default
	{
		//$Title "Logo Screen 1"
		//$Sprite "LOGOI0"
	}
	states
	{
		Spawn:
			LOGO IJKLM 5 bright;
			loop;
	}
}

class SS1DiegoScreen1 : SS1Screen
{
	
	default
	{
		//$Title "Diego Screen 1"
		//$Sprite "SCR6A0"
	}
	states
	{
		Spawn:
			SCR6 ABCDACBDCBADABDA 5 bright;
			SCST GHIJ 5 bright;
			loop;
	
	}
}

class SS1StationScreen1 : SS1Screen
{	
	default
	{
		//$Title "Station Screen 1"
	}
	states
	{
		Spawn:
			SCR9 ABCD 5 bright;
			loop;
	}
}

class SS1StationScreen2 : SS1Screen
{	
	default
	{
		//$Title "Station Screen 1"
	}
	states
	{
		Spawn:
			SCRA ABCDEFGH 5 bright;
			loop;
	}
}

class SS1StaticScreen : SS1Screen
{
	default
	{
		//$Title "Static Screen"
	}
	states
	{
		Spawn:
			SCST GHIJ 5 bright;
			loop;
	}
}