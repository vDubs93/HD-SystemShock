
class battery : HDPickup
{
	action bool Charge(float amount)
	{
		let hpl=Hacker(invoker.owner);
		if (!invoker.owner)
			return false;
		if (hpl.InternalCharge < 255) {
			hpl.InternalCharge += amount;
			if(hpl.InternalCharge > 255) {
				hpl.InternalCharge = 255;
			}
			A_StartSound("battery/charge");
			return true;
		} else {
			console.printf("You're already fully charged!");
			return false;
		}
	}
	default
	{
		//$Category "System Shock/Pickups"
		//$Title "Battery"
		//$Sprite "BATTA0"
		Inventory.icon "BATTA0";
		Inventory.PickupMessage "Picked up a battery that can recharge your neural interface.";
		hdpickup.bulk 10;
	}
	states
	{
		Success:
			TNT1 A 0;
			stop;
		usefail:
			TNT1 A 1;
			goto spawn;
	}
}

class NormalBattery : battery
{
	default
	{
		hdpickup.refid "ssb";
	}
	states
	{
		Spawn:
			BATT A -1;
			wait;
		use:
			TNT1 A 1 Charge(82);
			stop;
		
	}
}

class ICBattery : battery
{
	default
	{
		//$Category "System Shock/Pickups"
		//$Title "ICad Battery"
		//$Sprite "BATTB0"
		Inventory.icon "BATTB0";
		Inventory.PickupMessage "Picked up an Illumium-cadmium battery.";
		hdpickup.refid "sib";
	}
	states
	{
		Spawn:
			BATT B -1;
			wait;
		use:
			TNT1 A 1 Charge(255);
			stop;
	}
}
