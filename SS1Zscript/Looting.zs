class lootingHandler : Inventory {
	int cooldown;
	Actor currTarget;
	default {
		+INVENTORY.PERSISTENTPOWER;
		+INVENTORY.UNDROPPABLE;
		-INVENTORY.INVBAR;
		+INVENTORY.UNTOSSABLE;
	}
	
	override void tick() {
		if(owner.player.cmd.buttons & BT_USE && !cooldown) {
			cooldown = 17;
			
			FLineTraceData trace;
			owner.LineTrace(owner.angle, 64, owner.pitch, offsetz: owner.height*0.8, data: trace);
			Actor pActor = trace.hitactor;
			Inventory item;
			if (pActor && (trace.HitActor.bCorpse || pActor is 'Crate')) {
				for(item=pActor.inv;item!=null;item=item.inv){
					if (hd_debug)
					{
						A_Log(item.getclassname());
						A_LogInt(pActor.countInv(item.getClassName()));
					}
				}
				if (!(owner.player.readyWeapon is 'LootMenu') || pActor != currTarget)
					BeginLoot(pActor);
			}
		}
		if (cooldown) cooldown--;
	}
	void BeginLoot(Actor pActor) {
		Hacker(owner).looting = true;
		currTarget = pActor;
		Inventory lm = owner.findInventory("LootMenu");
		if(!lm) {
			owner.A_GiveInventory("LootMenu");
			lm = owner.findInventory("LootMenu");
		}
		LootMenu(lm).initList(pActor, Hacker(owner).prevWeapon);
		if (hd_debug) {
			console.printf("Looting corpse "..pActor.getClassName());
		}
		owner.A_SelectWeapon("LootMenu");
		Hacker(owner).looting = true;
	}
}

class LootMenu : HDWeapon
{
	default
	{
		+Weapon.CHEATNOTWEAPON;
		+Weapon.NOAUTOFIRE;
	}
	Actor target;
	String loot[4][2];
	int index;
	int outlineX;
	Array<Class<Inventory> > targetInv;
	bool deselect;
	weapon lastWeapon;
	override string getHelpText()
	{
		return
		WEPHELP_FIRE.."  Cycle selected item forward\n"
		..WEPHELP_ALTFIRE.."  Cycle selected item back\n"
		..WEPHELP_UNLOAD.."  Take selected item\n"
		..WEPHELP_MAGMANAGER
		;
	}
	override void drawHudStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (target){
			sb.drawImage("LootOutline",(outlineX,-48),sb.DI_SCREEN_LEFT_BOTTOM);
			int x, y;
			for(int i=0; i<4; i++) {
				switch(i) {
					case 0:
						x=78;y=-85;
						break;
					case 1:
						x = 108; y=-85;
						break;
					case 2:
						x = 78; y=-61;
						break;
					case 3:
						x = 108; y=-61;
						break;
				}
				x += outlineX;
				if (x>0) {
					sb.DrawImage(loot[i][1],(x,y),sb.DI_ITEM_VCENTER);		
				}
				
			}
			if (outlineX>=0) {
				switch(index) {
					case 0:
						x=78; y=-85;
						break;
					case 1:
						x = 108; y=-85;
						break;
					case 2:
						x = 78; y=-61;
						break;
					case 3:
						x = 108; y=-61;
						break;
				}
					x+=outlineX;
					sb.DrawImage("select"..(gametic%18)/6,(x,y),sb.DI_ITEM_VCENTER,alpha:0.4,scale:(2,2));
				}
		}
	}
	override void tick()
	{
		super.tick();
		if(target){
			console.printf(lastweapon.getClassName());
			float distance =  owner.Distance3D(target);
			if (self.outlineX < 0 && distance < 64 && !deselect)
				self.outlineX += 8;
			if (owner.player.cmd.buttons & BT_ZOOM) deselect = true;
			if (distance > 64 || deselect) {
				self.outlineX-=8;
				if (self.outlineX <= -120) {
					Hacker(owner).looting = false;
				}
			}
		}
	}
	void initList(actor target, weapon lastweapon)
	{
		if (target){
			HDStatusBar sb;
			self.index = 0;
			self.outlineX=-160;
			self.target = target;
			for(int i = 0; i<4; i++) {
				int lootIndex = ss1MobBase(target).getLoot(i);
				loot[i][0] = SS1MobBase(target).lootTable[lootIndex][0];
				loot[i][1] = SS1MobBase(target).lootTable[lootIndex][1];
			}
			self.lastWeapon = lastWeapon;
		}
	}
	action void A_RemoveItem() {
		if (invoker.loot[invoker.index][0]){
			let hpl = Hacker(self);
			hpl.A_GiveInventory(invoker.loot[invoker.index][0], 1);
			SS1MobBase(invoker.target).removefromloot(invoker.index);
			invoker.loot[invoker.index][0] = "none";
			invoker.loot[invoker.index][1] = "none";
		}
	}
	states
	{
		select0:
			TNT1 A 0 { invoker.deselect = false;}
		Ready:
			TNT1 A 1 A_WeaponReady(WRF_ALL | WRF_NOSWITCH);
			goto ReadyEnd;
		Fire:
			TNT1 A 0;
			TNT1 A 1 {
				invoker.index++;
				if (invoker.index > 3)
					invoker.index = 0;
			}
			goto Ready;
		altFire:
			TNT1 A 0;
			TNT1 A 1 {
				invoker.index--;
				if (invoker.index < 0)
					invoker.index = 3;
			}
			goto Ready;
		unload:
		user4:
			TNT1 A 0;
			TNT1 A 1 A_RemoveItem();
			goto Ready;
	}
}

class LootHandlerGiver : EventHandler {
	override void WorldTick() {
		for (int i = 0; i < MAXPLAYERS; i++) {
			if (!playeringame[i]) { continue; }
			PlayerInfo p = players[i];
			if (!p.mo) { return; }
			if (!p.mo.countinv("lootingHandler")) {
				p.mo.giveinventory("lootingHandler", 1);
				if(HD_Debug)
					console.printf("Looting: Player "..i.." given tracker.");
			}
		}
	}
}
