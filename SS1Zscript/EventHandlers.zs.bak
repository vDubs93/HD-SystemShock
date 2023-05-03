class SS1ReplacementHandler : EventHandler
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
