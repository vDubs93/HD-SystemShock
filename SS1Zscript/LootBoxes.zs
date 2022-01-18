class Crate : SS1MobBase
{
	float user_scale;
	int user_loot1;
	int user_loot2;
	int user_loot3;
	int user_loot4;
	override void postbeginplay()
	{
		super.postbeginplay();
		array<int> lootList;
		for (int i=0; i<4; i++) {
			int lootindex;
			switch (i) {
				case 0:
					lootindex = user_loot1;
					break;
				case 1:
					lootindex = user_loot2;
					break;
				case 2:
					lootindex = user_loot3;
					break;
				case 3:
					lootindex = user_loot4;
					break;
			}
			lootList.push(lootindex);
		}
		initializeLoot(lootList, 4);
	}
	override void initializeLoot(array<int> lootList, int numItems)
	{
		for(int i=0; i<numItems; i++){
			actualLoot[i] = lootList[i];
			if (hd_debug)
				if (actualLoot[i] > 0)
					console.printf("Adding "..lootTable[actualLoot[i]][0].." to "..getTag().." inventory");
		}
	}
	default
	{
		//$Category "System Shock/Loot Boxes"
		//$Title "Crate"
		//$Sprite "CRT3A0"
		-ismonster;
		mass 80;
		+noblood;
		-SOLID;
		+invulnerable;
		height 32;
		radius 8;
		tag "Crate";
	}
	states
	{
		spawn:
			CRT3 AA 0 {
				if(user_scale>0)
				{
					A_Setscale(user_scale);
					A_SetSize(user_scale*radius,user_scale*height);
				}
			}
			CRT3 A 1;
			wait;
	}
}

class Thermos : crate
{
	default
	{
		//$Title "Thermos"
		//$Sprite "THRMA0"
	}
	states
	{
		spawn:
			THRM A -1;
			wait;
	}
}