class SS1Medikit : HDPickup
{
	default
	{
		//$Category "System Shock/Items
		//$Title "First-Aid Kit"
		scale 0.24;
		-hdpickup.DropTranslation;
		Tag "First-Aid Kit";
	}
	bool fullRestore()
	{
		let hpl = hacker(owner);
		hpl.healthreset();
		hpl.incaptimer = 0;
		owner.A_SetBlend("99 99 99",1.0,35,"99 99 99",0.0);
		hpl.health = hpl.maxhealth();
		hpl.fatigue = 0;
		return true;
	}
	states
	{
		spawn:
			MKIT A -1;
			wait;
		use:
			TNT1 A 1 { 
				if (invoker.owner.health < 100) {
					A_StartSound("patch/apply",0);
					A_StartSound("battery/charge",0);
					invoker.fullRestore();
				} else {
					A_Print("Patient in perfect health.  Aborting...");
					A_GiveInventory("SS1Medikit");
				};
			}
			stop;
	}
}

class SS1medpatchDummy:IdleDummy{
	hdplayerpawn tg;
	states{
	spawn:
		TNT1 A 6 nodelay{
			tg=Hacker(target);
			if(!tg||tg.bkilled){destroy();return;}
			if(tg.zerk)tg.aggravateddamage+=int(ceil(accuracy*0.01*random(1,3)));
		}
		TNT1 A 1{
			if(!target||target.bkilled){destroy();return;}
			Hacker(target).medpatchcount += 20;
		}stop;
	}
}
class SS1MedPatchSpentDummy: Actor {
	states
	{
		spawn:
			TNT1 A 0;
			stop;
	}
}

class SS1MedikitDummy:IdleDummy{
	hdplayerpawn tg;
	states{
	spawn:
		TNT1 A 6 nodelay{
			tg=Hacker(target);
			if(!tg||tg.bkilled){destroy();return;}
		}
		TNT1 A 1{
			if(!target||target.bkilled){destroy();return;}
			Hacker(target).UseInventory(Hacker(target).findInventory("SS1Medikit"));
		}stop;
	}
}
class SS1SpentMedikit: SpentZerk
{
	states
	{
		Spawn:
			MKSP A 0;
			goto spawn2;
	}
}
