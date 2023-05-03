const SS1ACCESS_NONE = 0;
const SS1ACCESS_STANDARD = 1;
const SS1ACCESS_GROUP1 = 2;
const SS1ACCESS_MED = 4;
const SS1ACCESS_PER1 = 8;
const SS1ACCESS_SCI = 16;
const SS1ACCESS_GROUP4 = 32;
const SS1ACCESS_ENG = 64;
const SS1ACCESS_GROUP3 = 128;
const SS1ACCESS_ADM = 256;
const SS1ACCESS_GROUPB = 512;
const SS1ACCESS_STOMNTSEC = 1024;
const SS1ACCESS_PER5 = 2048;

class SS1AccessCard : HDPickup
{
	int accessLevel;
	string cardSprite;
	property cardSprite: cardSprite;
	property accessLevel: accessLevel;
	default
	{
		//$Category "System Shock/Access Cards"
		-Inventory.INVBAR
		SS1AccessCard.accessLevel SS1ACCESS_NONE;
		SS1AccessCard.cardSprite "";
		Inventory.icon "";
		scale 0.4;
		+FLATSPRITE;
	}
	override void ActualPickup(Actor other)
	{
		super.ActualPickup(other);
		if (!(Hacker(other).accesses & accessLevel))
		{
			Hacker(other).accesses |= accessLevel;
		}
		else
			other.A_Print("No new accesses gained");
	}
}

class standardCard : SS1AccessCard
{
	default
	{
		//$Title "Standard Access Card"
		//$Sprite "STAIA0"
		SS1AccessCard.accessLevel SS1ACCESS_STANDARD;
		SS1AccessCard.cardSprite "STAIA0";
		Inventory.icon "STAIA0";
		Inventory.pickupMessage "Standard Access Card";
	}
	states
	{
		spawn:
			STAI A -1;
			wait;
	}
}
class group1Card : SS1AccessCard
{
	default
	{
		//$Title "Group-1 Access Card"
		//$Sprite "STAIB0"
		SS1AccessCard.accessLevel SS1ACCESS_Group1;
		SS1AccessCard.cardSprite "STAIB0";
		Inventory.icon "STAIB0";
		Inventory.pickupMessage "Group-1 Access Card";
	}
	states
	{
		spawn:
			STAI B -1;
			wait;
	}
}

class medCard : SS1AccessCard
{
	default
	{
		//$Title "Med Access Card"
		//$Sprite "STAIC0"
		SS1AccessCard.accessLevel SS1ACCESS_MED;
		SS1AccessCard.cardSprite "STAIC0";
		Inventory.icon "STAIC0";
		Inventory.pickupMessage "Medical Access Card";
	}
	states
	{
		spawn:
			STAI C -1;
			wait;
	}
}

class per1Card : SS1AccessCard
{
	default
	{
		//$Title "PER-1 Access Card"
		//$Sprite "STAIE0"
		SS1AccessCard.accessLevel SS1ACCESS_PER1 | SS1ACCESS_MED;
		SS1AccessCard.cardSprite "STAID0";
		Inventory.icon "STAID0";
		Inventory.pickupMessage "Personal Access Card (Nathan D'Arcy)";
	}
	states
	{
		spawn:
			STAI D -1;
			wait;
	}
}

class SCICard : SS1AccessCard
{
	default
	{
		//$Title "SCI Access Card"
		//$Sprite "STAIE0"
		SS1AccessCard.accessLevel SS1ACCESS_SCI;
		SS1AccessCard.cardSprite "STAIE0";
		Inventory.icon "STAIE0";
		Inventory.pickupMessage "Science Access Card";
	}
	states
	{
		spawn:
			STAI E -1;
			wait;
	}
}
class group4Card : SS1AccessCard
{
	default
	{
		//$Title "Group-4 Access Card"
		//$Sprite "STAIF0"
		SS1AccessCard.accessLevel SS1ACCESS_GROUP4;
		SS1AccessCard.cardSprite "STAIB0";
		Inventory.icon "STAIB0";
		Inventory.pickupMessage "Group-4 Access Acquired";
	}
	states
	{
		spawn:
			STAI F -1;
			wait;
	}
}

class engCard : SS1AccessCard
{
	default
	{
		//$Title "Engineering Access Card"
		//$Sprite "STAIG0"
		SS1AccessCard.accessLevel SS1ACCESS_ENG;
		SS1AccessCard.cardSprite "STAIG0";
		Inventory.icon "STAIG0";
		Inventory.pickupMessage "Engineering Access Card";
	}
	states
	{
		spawn:
			STAI G -1;
			wait;
	}
}

class group3Card : SS1AccessCard
{
	default
	{
		//$Title "Group-3 Access Card"
		//$Sprite "STAIB0"
		SS1AccessCard.accessLevel SS1ACCESS_GROUP3;
		SS1AccessCard.cardSprite "STAIB0";
		Inventory.icon "STAIB0";
		Inventory.pickupMessage "Group-3 Access Card";
	}
	states
	{
		spawn:
			STAI B -1;
			wait;
	}
}


class ADMCard : SS1AccessCard
{
	default
	{
		//$Title "Administrative Access Card"
		//$Sprite "STAIH0"
		SS1AccessCard.accessLevel SS1ACCESS_ADM;
		SS1AccessCard.cardSprite "STAIH0";
		Inventory.icon "STAIH0";
		Inventory.pickupMessage "Administrative Access Card";
	}
	states
	{
		spawn:
			STAI H -1;
			wait;
	}
}

class groupBCard : SS1AccessCard
{
	default
	{
		//$Title "Group-B Access Card"
		//$Sprite "STAIB0"
		SS1AccessCard.accessLevel SS1ACCESS_GROUPB;
		SS1AccessCard.cardSprite "STAIB0";
		Inventory.icon "STAIB0";
		Inventory.pickupMessage "Group-B Access Card";
	}
	states
	{
		spawn:
			STAI B -1;
			wait;
	}
}

class stoMntSecCard : SS1AccessCard
{
	default
	{
		//$Title "Command Access Card"
		//$Sprite "STAII0"
		SS1AccessCard.accessLevel SS1ACCESS_STOMNTSEC;
		SS1AccessCard.cardSprite "STAII0";
		Inventory.icon "STAII0";
		Inventory.pickupMessage "Command Access Card";
	}
	states
	{
		spawn:
			STAI I -1;
			wait;
	}
}

class DiegoCard : SS1AccessCard
{
	default
	{
		//$Title "Diego's Access Card"
		//$Sprite "STAID0"
		SS1AccessCard.accessLevel SS1ACCESS_PER5;
		SS1AccessCard.cardSprite "STAID0";
		Inventory.icon "STAID0";
		Inventory.pickupMessage "Personal Access Card (Edward Diego)";
	}
	states
	{
		spawn:
			STAI D -1;
			wait;
	}
}
