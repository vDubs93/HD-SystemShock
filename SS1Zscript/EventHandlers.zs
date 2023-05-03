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

class berserkHandler : StaticEventHandler {
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