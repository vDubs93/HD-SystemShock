class SS1PatchBase : SS1FlatPickup
{
	default
	{
		//$Category "System Shock/Items/Patches"
	}
}

class SS1MedPatch : SS1PatchBase
{
	default
	{
		
		//$Title	"Med Patch"
		//$Sprite 	"MEDPA0"
		hdpickup.refid "smp";
		+inventory.ishealth;
		Inventory.pickupMessage "Picked up a Medipatch Healing Agent dermal patch";
	}
	
	
	
	States
	{
		spawn:
			MEDP A -1;
			wait;
		use:
			TNT1 A 0;
			TNT1 A 1 {
				let hpl = Hacker(invoker.owner);
				bool success = true;
				if(hpl.medPatchCount < 1)
					hpl.medPatchCount+=20;
				else if (hpl.medPatchCount < 30)
					hpl.medPatchCount+=15;
				else if (hpl.medPatchCount < 40)
					hpl.medPatchCount+=7;
				else if (hpl.medPatchCount < 45)
					hpl.medPatchCount+=3;
				else if (hpl.medPatchCount>=45) {
					A_Print("--Overdose prevention activated--");
					A_GiveInventory("SS1MedPatch", 1);
					success = false;
				}
				if (success)
					A_StartSound("patch/apply");
			}
			stop;
	}
}

class SS1BerzerkPatch : SS1PatchBase
{
	default
	{
		//$Title	"Berzerk Patch"
		//$Sprite 	"BZKPA0"
		hdpickup.refid "sbp";
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
				if (!hpl.Bpatch){
					hpl.Bpatch = 100;
					A_StartSound("patch/apply");
				} else {
					A_Print("--Overdose prevention activated--");
					A_GiveInventory("SS1BerzerkPatch", 1);
				}
			}
			stop;
	}
}

class SS1SightPatch : SS1PatchBase
{
	default
	{
		//$Title	"Sight Patch"
		//$Sprite 	"SITPA0"
		hdpickup.refid "ssp";
		Inventory.pickupMessage "Picked up a Sight Vision Enhancement dermal patch";
	}
	States
	{
		spawn:
			SITP A -1;
			wait;
		use:
			TNT1 A 0;
			TNT1 A 1 {
				let hpl = Hacker(invoker.owner);
				if (!hpl.sightPatch)
					hpl.sightPatch = 185;
				else
					hpl.sightPatch += 145;
				A_GiveInventory("PowerNightSight");
				A_StartSound("patch/apply");
			}
			stop;
	}
}

class PowerNightSight : PowerLightAmp
{
	default
	{
		+INVENTORY.PERSISTENTPOWER
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE
		Powerup.Duration 0x7FFFFFFF;
	}
}

class SS1StaminaPatch : SS1PatchBase
{
	default
	{
		//$Title	"Stamina Patch"
		//$Sprite 	"STMPA0"
		hdpickup.refid "stp";
		Inventory.pickupMessage "Picked up a Staminup Stimulant dermal patch";
	}
	States
	{
		spawn:
			STMP A -1;
			wait;
		use:
			TNT1 A 0;
			TNT1 A 1 {
				let hpl = Hacker(invoker.owner);
				hpl.staminaPatch += 93;
				A_StartSound("patch/apply");
			}
			stop;
	}
}