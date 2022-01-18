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

class SS1MobBase : HDMobBase
{	
	uint SS1MobFlags;
	flagdef isRobot:SS1MobFlags, 0;
	flagdef isStunnable:SS1MobFlags, 1;
	int armorValue;
	property armorValue: armorValue;
	int defenceValue;
	property defenceValue: defenceValue;
	
	
	string lootTable[12][2];
	override void postbeginplay() {
		super.postbeginplay();
		lootTable[0][0] = "none";				lootTable[0][1] = "none";
		lootTable[1][0] = "normalBattery";		lootTable[1][1] = "BATTA0";
		lootTable[2][0] = "Wrapper";			lootTable[2][1] = "WRAPA0";
		lootTable[3][0] = "bevContainer";		lootTable[3][1] = "BEVCA0";
		lootTable[4][0] = "beaker";				lootTable[4][1] = "BEAKA0";
		lootTable[5][0] = "flask";				lootTable[5][1] = "FLSKA0";
		lootTable[6][0] = "vial";				lootTable[6][1] = "VIALA0";
		lootTable[7][0] = "SS1MedPatch";		lootTable[7][1] = "MEDPA0";
		lootTable[8][0] = "SS1BerzerkPatch";	lootTable[8][1] = "BZKPA0";
		lootTable[9][0] = "SS1FragGrenadeAmmo";	lootTable[9][1] = "FRGRF0";
		lootTable[10][0] = "NeedleDartClip";	lootTable[10][1] = "DBOXA0";
		lootTable[11][0] = "TranqDartClip";		lootTable[11][1] = "TBOXA0";
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
		console.printf("Stunned for "..(tranqTimer/35.).." seconds");
	}
}