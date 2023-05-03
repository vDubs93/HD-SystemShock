class SS1junk : HDPickup
{
	Default
	{
		//$Category "System Shock/Junk"
		radius 2;
		height 2;
		hdpickup.bulk 3;
		scale 0.24;
		-hdpickup.DropTranslation;
	}
}

class Skull : SS1Junk {
	Default
	{
		//$Title "Skull"
		//$Sprite "SKULB0"
		Inventory.pickupMessage "Picked up a human skull.  Why?";
		Inventory.icon "SKULB0";
		hdpickup.bulk 8;
		radius 4;
		height 4;
	}
	states
	{
		spawn:
			SKUL A -1;
			stop;
	}
}

class Wrapper : SS1Junk {
	Default
	{
		//$Title "Empty Wrapper"
		//$Sprite "WRAPB0"
		Inventory.pickupMessage "Picked up an empty wrapper.";
		inventory.icon "WRAPB0";
	}
	states
	{
		spawn:
			WRAP A -1;
			stop;
	}
}
class bevContainer :SS1Junk {
	Default
	{
		//$Title "Empty Can"
		//$Sprite "BEVCB0"
		Inventory.pickupMessage "Picked up an empty beverage container.";
		inventory.icon "BEVCB0";
	}
	states
	{
		spawn:
			BEVC A -1;
			stop;
	}
}
class GlassWare : RandomSpawner
{
	default
	{
		dropitem "beaker";
		dropitem "flask";
		dropitem "vial";
	}
}
class beaker :SS1Junk {
	Default
	{
		//$Title "Beaker"
		//$Sprite "BEAKA0"
		Inventory.pickupMessage "Picked up a glass beaker.";
		Inventory.Icon "BEAKB0";
	}
	states
	{
		spawn:
			BEAK A 0;
			goto death;
		death:
			#### # -1;
			stop;
	}
}

class flask : beaker {
	default
	{
		//$Title "Flask"
		//$Sprite "FLSKA0"
		Inventory.pickupMessage "Picked up a glass flask.";
		inventory.icon "FLSKB0";
		scale 0.24;
	}
	states
	{
		spawn:
			FLSK A 0;
			goto death;
	}
}

class vial : beaker {
	default
	{
		//$Title "Vial"
		//$Sprite "VIALA0"
		Inventory.pickupMessage "Picked up a glass vial.";
		inventory.icon "VIALB0";
	}
	states
	{
		spawn:
			VIAL A 0;
			goto death;
	}
}