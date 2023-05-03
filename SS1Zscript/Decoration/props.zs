class SS1Prop : Actor
{
	default
	{
		//$Category "System Shock/Decoration/props"
		mass 4000;
		
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

class slab : SS1Prop
{
	Default
	{
		//$Title "Slab bed"
	}
}
class xray : SS1Prop
{
	Default
	{
		//$Title "X-Ray Machine"
	}
}

class microScope : SS1Prop
{
	Default
	{
		//$Title "Microscope"
		mass 100;
	}
}
class chair : SS1Prop
{
	Default
	{
		//$Title "Chair"
		mass 400;
	}
}
class TestTubeRack : SS1Prop
{
	Default
	{
		//$Title "Test Tube Rack"
		mass 100;
	}
}
class cart : SS1Prop
{
	default
	{
		//$Title "Cart"
		mass 300;
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
		radius 4;

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
		radius 4;
		mass 500;
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
		radius 4;
		mass 500;
	}
	states
	{
		spawn:
			BAR3 A -1;
			wait;
	}
}

class lumpofClothes : SS1Prop
{
	default
	{
		//$Title "Lump of clothes"
		scale 0.24;
		-SOLID;
	}
	states
	{
		spawn:
			CLTH A -1;
			wait;
	}
}