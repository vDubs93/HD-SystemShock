class SS1junk : HDPickup
{
	Default
	{
		radius 2;
		height 2;
		hdpickup.bulk 3;
		scale 0.8;
		-hdpickup.DropTranslation;
	}
}

class Wrapper :SS1Junk {
	Default
	{
		//$Category "System Shock/Junk"
		//$Title "Empty Wrapper"
		//$Sprite "WRAPA0"
		Inventory.pickupMessage "Picked up an empty wrapper.";
		inventory.icon "WRAPA0";
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
		//$Category "System Shock/Junk"
		//$Title "Empty Can"
		//$Sprite "BEVCA0"
		Inventory.pickupMessage "Picked up an empty beverage container.";
		inventory.icon "BEVCA0";
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
		//$Category "System Shock/Junk"
		//$Title "Beaker"
		//$Sprite "BEAKA0"
		Inventory.pickupMessage "Picked up a glass beaker.";
		Inventory.Icon "BEAKA0";
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
		//$Category "System Shock/Junk"
		//$Title "Flask"
		//$Sprite "FLSKA0"
		Inventory.pickupMessage "Picked up a glass flask.";
		inventory.icon "FLSKA0";
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
		//$Category "System Shock/Junk"
		//$Title "Vial"
		//$Sprite "VIALA0"
		Inventory.pickupMessage "Picked up a glass vial.";
		inventory.icon "VIALA0";
	}
	states
	{
		spawn:
			VIAL A 0;
			goto death;
	}
}