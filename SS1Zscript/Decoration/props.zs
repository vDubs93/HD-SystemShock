class SS1Prop : Actor
{
	default
	{
		//$Category "System Shock/Decoration/props"
	}
	states
	{
		Spawn:
			BATT A -1;
			wait;
	}
}
class MedBed : SS1Prop
{
	Default
	{
		//$Title "Medical Bed"
		+NOGRAVITY;
	}
}

class microScope : SS1Prop
{
	Default
	{
		//$Title "Microscope"
	}
}
class chair : SS1Prop
{
	Default
	{
		//$Title "Chair"
	}
}
class TestTubeRack : SS1Prop
{
	Default
	{
		//$Title "Test Tube Rack"
	}
}
class cart : SS1Prop
{
	default
	{
		//$Title "Cart"
	}
}
class Barrel1 : SS1Prop
{
	Default
	{
		//$Title "Barrel 1"
		+SOLID;
		scale 0.6;
		height 32;
	}
	states
	{
		spawn:
			BAR1 A -1;
			wait;
	}
}

class Barrel2 : SS1Prop
{
	Default
	{
		//$Title "Barrel 2"
		+SOLID;
		scale 0.6;
		height 32;
	}
	states
	{
		spawn:
			BAR2 A -1;
			wait;
	}
}
class Barrel3 : SS1Prop
{
	Default
	{
		//$Title "Barrel 3"
		+SOLID;
		scale 0.6;
		height 32;
	}
	states
	{
		spawn:
			BAR3 A -1;
			wait;
	}
}