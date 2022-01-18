class SS1Decoration : Actor
{
	default
	{
		//$Category "System Shock/Decoration/Foliage"
		-SOLID;
		scale 0.65;
	}
}

class Tree1 : SS1Decoration
{
	default
	{
		//$Title "Tree 1"
		//$Sprite "TRE1A0"
	}
	states
	{
		spawn:
			TRE1 A -1;
			stop;
	}
}
class Tree2 : SS1Decoration
{
	default
	{
		//$Title "Tree 2"
		//$Sprite "TRE2A0"
	}
	states
	{
		spawn:
			TRE2 A -1;
			stop;
	}
}
class Tree3 : SS1Decoration
{
	default
	{
		//$Title "Tree 3"
		//$Sprite "TRE3A0"
	}
	states
	{
		spawn:
			TRE3 A -1;
			stop;
	}
}
class SmallPlant :  SS1Decoration
{
	default
	{
		//$Title "Small Plant"
		//$Sprite "PLNTA0"
	}
	states
	{
		spawn:
			PLNT A -1;
			stop;
	}
}
class Grass :  SS1Decoration
{
	default
	{
		//$Title "Grass"
		//$Sprite "GRASA0"
	}
	states
	{
		spawn:
			GRAS A -1;
			stop;
	}
}
class Fern :  SS1Decoration
{
	default
	{
		//$Title "Fern"
		//$Sprite "FERNA0"
	}
	states
	{
		spawn:
			FERN A -1;
			stop;
	}
}