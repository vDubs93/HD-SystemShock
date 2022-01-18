class SS1MedPatch : HDPickup
{
	default
	{
		//$Category "System Shock/Items"
		//$Title	"Med Patch"
		//$Sprite 	"MEDPA0"
		scale 0.3;
		hdpickup.refid "smp";
		+inventory.ishealth;
		Inventory.pickupMessage "Picked up a Medipatch Healing Agent dermal patch";
	}
	States
	{
		Spawn:
			MEDP A -1;
			wait;
		use:
			TNT1 A 0;
			TNT1 A 1 {
				let hpl = Hacker(invoker.owner);
				if(!hpl.medPatchCount)
					hpl.medPatchCount+=20;
				else if (hpl.medPatchCount < 30)
					hpl.medPatchCount+=15;
				else if (hpl.medPatchCount < 40)
					hpl.medPatchCount+=7;
				else if (hpl.medPatchCount < 45)
					hpl.medPatchCount+=3;
				else if (hpl.medPatchCount>=45)
					setStateLabel("useFail");
			}
			stop;
		useFail:
			TNT1 A 0 A_Print("--Overdose prevention activated--");
			wait;
	}
}

class SS1BerzerkPatch : HDPickup
{
	default
	{
		//$Category "System Shock/Items"
		//$Title	"Berzerk Patch"
		//$Sprite 	"BZKPA0"
		scale 0.3;
		hdpickup.refid "sbp";
		+inventory.ishealth;
		Inventory.pickupMessage "Picked up a Berzerk Combat Booster dermal patch";
	}
	States
	{
		spawn:
			BZKP A -1;
			wait;
		use:
			TNT1 A 0;
			TNT1 A 1 {
				let hpl = Hacker(invoker.owner);
				if (!hpl.Bpatch)
					hpl.Bpatch = 100;
				else
					setStateLabel("useFail");
			}
			stop;
		useFail:
			TNT1 A 0;
			wait;
	}
}
