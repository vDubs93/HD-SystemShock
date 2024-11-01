class SS1EventHandler : EventHandler
{
	override void CheckReplacement(ReplaceEvent e)
	{
		
		if (!e.Replacement)
		{
			return;
		}
		switch (e.Replacement.GetClassName())
		{
			case 'Lumberjack':
				if (random[defrand]() <= 48)
				{
					e.Replacement = "SS1Pipe";
				}
				break;
			case 'HDPistol':
				if (random[defrand]() <=48)
				{
					e.Replacement = "SS1DartGun";
				}
				break;
			case 'ClipMagPickup':
				if (random[defrand]() <=48) {
					if (!random(0, 1)) 
						{e.Replacement = "NeedleDartClip";
						break;}
					if (!random(0, 1)) 
						{e.Replacement = "TranqDartClip";
						break;}
				}
				break;
				
		}
	}
}
class disableMapTweaks : StaticEventHandler
{

}
const STATE_WALKING = 0;
const STATE_PERIL = 1;
const STATE_COMBAT = 2;
class MusicHandler : Eventhandler
{
	String walking[4];
	String combat[4];
	String peril[3];
	String robot[4];
	String mutant[4];
	String intro;
	String combatTransition;
	String lowHealth;
	String perilToCombat;
	String cyborg;
	int segmentIndex;
	int segLength;
	int counter;
	bool inCombat;
	PlayerInfo p;
	int playerState;
	int prevPlayerHealth;
	bool transitionToCombat;
	int combatTimer;
	override void WorldLoaded(WorldEvent e)
	{
		string prefix;
		name levelname = name(level.MapName);
		switch (levelname)
		{
			case 'test':
			case 'Map01':
				prefix = "Med";
				segLength = 388;
				break;
			default:
				prefix = "";
		}
		intro = prefix.."Intro";
		combatTransition = prefix.."Trns";
		perilToCombat = prefix.."PerilToCombat";
		lowHealth = prefix.."LowHelth";
		cyborg = prefix.."Cyborg";
		walking[0] = prefix.."W1";
		walking[1] = prefix.."W2";
		walking[2] = prefix.."W3";
		walking[3] = prefix.."W4";
		peril[0] = prefix.."C1";
		peril[1] = prefix.."C2";
		peril[2] = prefix.."C3";
		combat[0] = prefix.."C6";
		combat[1] = prefix.."C7";
		combat[2] = prefix.."C3";
		combat[3] = prefix.."C4";
		robot[0] = prefix.."Robot1";
		robot[1] = prefix.."Robot1";
		robot[2] = prefix.."Robot1";
		robot[3] = prefix.."Robot1";

		mutant[0] = prefix.."Mut1";
		mutant[1] = prefix.."Mut2";
		mutant[2] = prefix.."Mut3";
		mutant[3] = prefix.."Mut3";
		segmentIndex = -1;
		counter = 0;
		p = players[consoleplayer];
		prevPlayerHealth = p.mo.health;
		playerState = STATE_WALKING;
		transitionToCombat = false;
	}
	
	/* Basic Idea:
	 * Play music segments as sound effects
	 * every [segment length] tics, check what's going on around the player
	 * change track accordingly
	 * Check for enemies, play layers on top of music
	 * Music is on channel 45, layers will be on 46 and up
	 */
	override void WorldTick()
	{
		if(p.mo is 'hacker') {
			ThinkerIterator finder = ThinkerIterator.Create("Actor");
			Actor mo;
			int chasers = 0;
			bool nearRobot = false;
			bool nearCyborg = false;
			bool nearMutant = false;
			bool nearMonster = false;
			while ((mo = Actor(Finder.Next()))) {
				if (mo is 'SS1Monster' && mo.health > 0){
					if (mo.target is 'hacker' && mo.CheckSight(mo.target))
						chasers++;
					if (mo.Distance3D(p.mo) <=256){
						if (mo is 'SS1Robot')
							nearRobot = true;
						else if (mo is 'SS1Cyborg')
							nearCyborg = true;
						else if (mo is 'SS1Mutant')
							nearMutant = true;
					}
				}
			}
			//console.printf(""..prevPlayerHealth - p.mo.health.." "..transitionToCombat);			
			if (segmentIndex == -1){
				p.mo.A_StartSound(intro, 45, 0, snd_musicvolume, 0);
				transitionToCombat = false;
				segmentIndex ++;
			}
			if (counter == segLength){
				if (chasers == 0)
					playerState = STATE_WALKING;
				if (nearRobot)
					p.mo.A_StartSound(robot[segmentIndex], 47, 0, snd_musicvolume, 0);
				if (nearCyborg) {
					console.printf("Near Cyborg");
					if (random(0, 4) > 0)
						p.mo.A_StartSound(cyborg, 48, 0, snd_musicvolume, 0);
				}
				if (nearMutant){
					p.mo.A_StartSound(mutant[segmentIndex], 49, 0, snd_musicvolume, 0);
					console.printf("Near Mutant");
					console.printf("%s",mutant[segmentIndex]);
				}
				if (p.mo.health < 25)
					p.mo.A_StartSound(lowHealth, 46, 0, snd_musicvolume, 0);
				if (playerState == STATE_WALKING) {
					p.mo.A_StartSound(walking[segmentIndex], 45, 0, snd_musicvolume, 0);
					transitionToCombat = false;
					segmentIndex = (segmentIndex + 1) % 4;
				} else if (playerState == STATE_PERIL){
					if (transitionToCombat){
						transitionToCombat = false;
						playerState = STATE_COMBAT;
						p.mo.A_StartSound(perilToCombat, 45, 0, snd_musicvolume, 0);
						segmentIndex = 0;
						combatTimer = 3500;
					} else {
						if (segmentIndex > 2)
							segmentIndex = 0;
						p.mo.A_StartSound(peril[segmentIndex], 45, 0, snd_musicvolume, 0);
						segmentIndex = (segmentIndex + 1) % 3;
					}
				
				} else {
					p.mo.A_StartSound(combat[segmentIndex], 45, 0, snd_musicvolume, 0);
					segmentIndex = (segmentIndex + 1) % 4;
					combatTimer--;
					if (combatTimer == 0 || chasers == 0) {
						if (chasers == 0)
							playerState = STATE_WALKING;
						else
							playerState = STATE_PERIL;
					}
				}
				counter = 0;
			}

			if (counter == int(segLength / 2.0)) {
				if (chasers > 0 && playerState == STATE_WALKING){
					p.mo.A_StartSound(CombatTransition, 46, 0, snd_musicvolume, 0);
					playerState = STATE_PERIL;
					nearMonster = false;
				}
			}
			if (gametic > 35 && prevPlayerHealth - p.mo.health >= 5) {
				if (!transitionToCombat)
					transitionToCombat = true;
				combatTimer = 350;
			}
			if (p.mo.checkProximity("ElevatorMusic", 32))
				p.mo.A_SoundVolume(45, 0);
			prevPlayerHealth = p.mo.health;
			if (counter == segLength) counter = 0;
			counter++;
		}
	}
	
}

class berserkHandler : EventHandler {
	override void RenderOverlay(RenderEvent e) {
		
		// set the player's timer up correctly (more-than-1-tick precision)
		PlayerInfo p = players[consoleplayer];
		if (p.mo is 'hacker') {
			if (gametic % 35 == 0)
				Shader.SetUniform1f(p, "poisoned", "timer", random(0,100));
			Shader.SetUniform1f(p,"HudCycle", "timer", (gametic - e.Fractic));
			hacker hpl = hacker(p.mo);
			if (hpl.Bpatch){
				Shader.SetUniform1f(p, "Berserk", "timer", (gametic - e.Fractic));
			} else {
				Shader.SetUniform1f(p, "Berserk", "timer", 0);
			}
			
			if (hpl.sightPatch > 0 && hpl.sightPatch <= 40)
			{
				Shader.SetUniform1f(p, "Blindness", "multiplier", hpl.sightPatch);
			}
		}
	}
}