class SS1Decal : Actor
{
	default
	{
		//$Category "System Shock/Decoration/Decals"
		+WALLSPRITE;
		+NOGRAVITY;
		+NOINTERACTION;
	}
}

class SS1WallDamage1 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Damage"
		//$Title "Wall Damage 1"
	}
	states
	{
		spawn:
			WDMG A -1;
			stop;
	}
}

class SS1WallDamage2 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Damage"
		//$Title "Wall Damage 2"
	}
	states
	{
		spawn:
			WDMG B -1;
			stop;
	}
}

class SS1WallDamage3 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Damage"
		//$Title "Wall Damage 3"
	}
	states
	{
		spawn:
			WDMG C -1;
			stop;
	}
}

class SS1WallDamage4 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Damage"
		//$Title "Wall Damage 4"
	}
	states
	{
		spawn:
			WDMG D -1;
			stop;
	}
}

class SS1wallIcon1 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 1"
	}
	states
	{
		spawn:
			WICN A -1;
			wait;
			
	}
}

class SS1wallIcon2 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 2"
	}
	states
	{
		spawn:
			WICN B -1;
			wait;
			
	}
}
class SS1wallIcon3 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 3"
	}
	states
	{
		spawn:
			WICN C -1;
			wait;
			
	}
}
class SS1wallIcon4 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 4"
	}
	states
	{
		spawn:
			WICN D -1;
			wait;
			
	}
}
class SS1wallIcon5 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 5"
	}
	states
	{
		spawn:
			WICN E -1;
			wait;
			
	}
}
class SS1wallIcon6 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 6"
	}
	states
	{
		spawn:
			WICN F -1;
			wait;
			
	}
}
class SS1wallIcon7 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 7"
	}
	states
	{
		spawn:
			WICN G -1;
			wait;
			
	}
}
class SS1wallIcon8 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 8"
	}
	states
	{
		spawn:
			WICN H -1;
			wait;
			
	}
}
class SS1wallIcon9 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 9"
	}
	states
	{
		spawn:
			WICN I -1;
			wait;
			
	}
}
class SS1wallIcon10 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 10"
	}
	states
	{
		spawn:
			WICN J -1;
			wait;
			
	}
}
class SS1wallIcon11 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 11"
	}
	states
	{
		spawn:
			WICN K -1;
			wait;
			
	}
}
class SS1wallIcon12 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 12"
	}
	states
	{
		spawn:
			WICN L -1;
			wait;
			
	}
}
class SS1wallIcon13 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 13"
	}
	states
	{
		spawn:
			WICN M -1;
			wait;
			
	}
}
class SS1wallIcon14 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 14"
	}
	states
	{
		spawn:
			WICN N -1;
			wait;
			
	}
}
class SS1wallIcon15 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 15"
	}
	states
	{
		spawn:
			WICN O -1;
			wait;
			
	}
}
class SS1wallIcon16 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 16"
	}
	states
	{
		spawn:
			WICN P -1;
			wait;
			
	}
}
class SS1wallIcon17 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 17"
	}
	states
	{
		spawn:
			WICN Q -1;
			wait;
			
	}
}
class SS1wallIcon18 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Wall Icons"
		//$Title "Icon 18"
	}
	states
	{
		spawn:
			WICN R -1;
			wait;
			
	}
}

class SS1Graffiti01 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "Stay Away"
		-WALLSPRITE;
		+FLATSPRITE;
	}
	states
	{
		spawn:
			GRAF A -1;
			wait;
			
	}
}

class SS1Graffiti02 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "Scrawl"
		-WALLSPRITE;
		+FLATSPRITE;
	}
	states
	{
		spawn:
			GRAF B -1;
			wait;
			
	}
}

class SS1Graffiti03 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "DIE"
		-WALLSPRITE;
		+FLATSPRITE;
	}
	states
	{
		spawn:
			GRAF C -1;
			wait;
			
	}
}

class SS1Graffiti04 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "Diego"
		-WALLSPRITE;
		+FLATSPRITE;
	}
	states
	{
		spawn:
			GRAF D -1;
			wait;
			
	}
}

class SS1Graffiti05 : SS1Decal
{
		default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "SHODAN"
		-WALLSPRITE;
		+FLATSPRITE;
	}
	states
	{
		spawn:
			GRAF E -1;
			wait;
			
	}
}

class SS1Graffiti06 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "RESIST"
		-WALLSPRITE;
		+FLATSPRITE;
	}
	states
	{
		spawn:
			GRAF F -1;
			wait;
			
	}
}

class SS1Graffiti07 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "Danger"
		-WALLSPRITE;
		+FLATSPRITE;
	}
	states
	{
		spawn:
			GRAF G -1;
			wait;
			
	}
}

class SS1Graffiti08 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "Shodan <3 Diego"
		-WALLSPRITE;
		+FLATSPRITE;
	}
	states
	{
		spawn:
			GRAF H -1;
			wait;
			
	}
}

class SS1Graffiti09 : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Graffiti"
		//$Title "Carl's last Message"
	}
	states
	{
		spawn:
			GRAF I -1;
			wait;
	}
}

class SS1HealingSuiteSign : SS1Decal
{
	default
	{
		//$Category "System Shock/Decoration/Decals/Signs"
		//$Title "Healing Suite"
	}
	states
	{
		spawn:
			HLST A -1;
			wait;
	}
}