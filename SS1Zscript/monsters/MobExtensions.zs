const numLoots = 17;
const SS1CONST_NOLOOT = 0;
const SS1CONST_NBATTERY = 1;
const SS1CONST_WRAPPER = 2;
const SS1CONST_POPCAN = 3;
const SS1CONST_BEAKER = 4;
const SS1CONST_FLASK = 5;
const SS1CONST_VIAL = 6;
const SS1CONST_MEDPATCH = 7;
const SS1CONST_BZKPATCH = 8;
const SS1CONST_FRAGGRENADE = 9;
const SS1CONST_NEEDLECLIP = 10;
const SS1CONST_TRANQCLIP = 11;
const SS1CONST_STDACCESS = 12;
const SS1CONST_SKULL = 13;
const SS1CONST_GROUP1 = 14;
const SS1CONST_MLSTD = 15;
const SS1CONST_MLTEF = 16;


class SS1MobBase : HDMobBase
{	
	uint SS1MobFlags;
	flagdef isRobot:SS1MobFlags, 0;
	flagdef isStunnable:SS1MobFlags, 1;
	int armorValue;
	property armorValue: armorValue;
	int defenceValue;
	property defenceValue: defenceValue;
	
	
	string lootTable[numLoots][2];
	override void postbeginplay() {
		super.postbeginplay();
		lootTable[SS1CONST_NOLOOT][0] = "none";						lootTable[SS1CONST_NOLOOT][1] = "none";
		lootTable[SS1CONST_NBATTERY][0] = "normalBattery";			lootTable[SS1CONST_NBATTERY][1] = "BATTC0";
		lootTable[SS1CONST_WRAPPER][0] = "Wrapper";					lootTable[SS1CONST_WRAPPER][1] = "WRAPB0";
		lootTable[SS1CONST_POPCAN][0] = "bevContainer";				lootTable[SS1CONST_POPCAN][1] = "BEVCB0";
		lootTable[SS1CONST_BEAKER][0] = "beaker";					lootTable[SS1CONST_BEAKER][1] = "BEAKB0";
		lootTable[SS1CONST_FLASK][0] = "flask";						lootTable[SS1CONST_FLASK][1] = "FLSKB0";
		lootTable[SS1CONST_VIAL][0] = "vial";						lootTable[SS1CONST_VIAL][1] = "VIALB0";
		lootTable[SS1CONST_MEDPATCH][0] = "SS1MedPatch";			lootTable[SS1CONST_MEDPATCH][1] = "MEDPA0";
		lootTable[SS1CONST_BZKPATCH][0] = "SS1BerzerkPatch";		lootTable[SS1CONST_BZKPATCH][1] = "BZKPA0";
		lootTable[SS1CONST_FRAGGRENADE][0] = "SS1FragGrenadeAmmo";	lootTable[SS1CONST_FRAGGRENADE][1] = "FRGRF0";
		lootTable[SS1CONST_NEEDLECLIP][0] = "NeedleDartClip";		lootTable[SS1CONST_NEEDLECLIP][1] = "DBOXA0";
		lootTable[SS1CONST_TRANQCLIP][0] = "TranqDartClip";			lootTable[SS1CONST_TRANQCLIP][1] = "TBOXA0";
		lootTable[SS1CONST_STDACCESS][0] = "standardCard";			lootTable[SS1CONST_STDACCESS][1] = "STAIA0";
		lootTable[SS1CONST_SKULL][0] = "Skull";						lootTable[SS1CONST_SKULL][1] = "SKULB0";
		lootTable[SS1CONST_GROUP1][0] = "Group1Card";				lootTable[SS1CONST_GROUP1][1] = "STAIB0";
		lootTable[SS1CONST_MLSTD][0] = "MPStandardMag";				lootTable[SS1CONST_MLSTD][1] = "MPSMA0";
		lootTable[SS1CONST_MLTEF][0] = "MPTeflonMag";				lootTable[SS1CONST_MLTEF][1] = "MPTMA0";
	}
	int actualLoot[4];
	virtual void initializeLoot(array<int> lootList, int numItems)
	{
		for(int i=0; i<numItems; i++){
			int index = random(0, lootList.size()-1);
			actualLoot[i] = lootList[index];
			if (hd_debug)
				if (actualLoot[i] > 0)
					console.printf("Adding "..lootTable[actualLoot[i]][0].." to "..getTag().." inventory");
		}
	}
	int getLoot(int index)
	{
		return self.actualLoot[index];
	}
	void removeFromLoot(int index)
	{
		self.actualLoot[index] = 0;
	}
}
class SS1Monster : SS1MobBase {}
class SS1Cyborg : SS1Monster {}
class SS1Robot : SS1Monster {}
class SS1Mutant : SS1Monster {}



class TranqHandler : Inventory {
	int counter;
	int tranqTimer;
	override void postBeginPlay() {
		counter = random(17,35);
		tranqTimer = random(110,140);
	}
	override void tick() {
		super.tick();
		if (owner) {
			if (tranqTimer > 0 && owner.health > 2) {
				if (counter==0){
					owner.setStateLabel("Pain");
					tranqTimer--;
				} else {
					counter--;
				}
			} else {
				if (owner.health <= 0)
					owner.setStateLabel("Death");
				setStateLabel("null");
			}
		} else setStateLabel("null");
	}
}

class StunHandler : TranqHandler
{
	int stunLevel;
	override void postBeginPlay()
	{
		counter = 0;
		tranqTimer = random(70,105) + 35 * stunLevel;
		if (hd_debug)
			console.printf("Stunned for "..(tranqTimer/35.).." seconds");
	}
}