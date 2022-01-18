class CyberSpaceExit : Actor
{
	int user_mapnum;
	int user_playerstart;
	default
	{
		//$Category "System Shock/Cyberspace"
		//$Title "Exit portal
		//$Sprite "BATTA0"
		radius 16;
		height 32;
	}
	override void tick()
	{	
		if (CheckProximity("CyberHacker", 32))
		{
			Teleport_NewMap(user_mapnum, user_playerStart, 0);
		}
	}
	states
	{
		Spawn:
			BATT A -1;
			wait;
	}
}
class cyberToggle : Actor
{
	int user_switchTID;
	string user_message;
	int user_map;
	default
	{
		//$Category "System Shock/Cyberspace"
		//$Title "CyberToggle"
		//$Sprite "BATTA0"
		radius 8;
		height 16;
		+NOGRAVITY;
	}
	override void tick()
	{
		if (CheckProximity("CyberHacker", 32, 1, CPXF_SETTARGET) && !inStateSequence(CurState, ResolveState("Flipped")))
		{
			target.A_Print(user_message);
			ACS_Execute(2, user_map, user_switchTID);
		setStateLabel("Flipped");
		}
	}
	states
	{
		spawn:
			BATT A -1;
			wait;
		Flipped:
			BATT B -1;
			wait;
	}
}