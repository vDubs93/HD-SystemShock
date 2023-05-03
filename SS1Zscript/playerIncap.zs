extend class Hacker{
	int incapacitated;
	int incaptimer;
	inventory invselbak;
	void IncapacitatedCheck(){
		//abort if there's nothing at all to do
		if(
			!incapacitated
			&&incaptimer<1
		)return;


		double fullheight=max(1,default.height*heightmult);
		double downedheight=max(1,16*heightmult);


		//deplete and damage
		if(incaptimer>0){
			incaptimer--;
			muzzleclimb1.y+=(level.time&1)?-1:1;
			if(incaptimer>TICRATE*360){
				damagemobj(null,null,1,"maxhpdrain");
				incaptimer-=(incaptimer>>4);
			}
		}
		if (player&&countinv("HDIncapWeapon")&&!countInv("SS1IncapWeapon")){
			A_SetInventory("SS1IncapWeapon",1);
			A_SelectWeapon("SS1IncapWeapon");
		}
		//fall down and stay down
		if(incapacitated>0){
			A_SetSize(radius,max(downedheight,height-3));
			if(!countinv("SS1IncapWeapon")){
				A_SetInventory("SS1IncapWeapon",1);
				if(player&&player.readyweapon){
					if(
						!HDFist(player.readyweapon)&&(
							player.cmd.buttons&(
								BT_ATTACK|BT_ALTATTACK|BT_RELOAD|BT_ZOOM
								|BT_USER1|BT_USER2|BT_USER3|BT_USER4
							)||(
								hdweapon(player.readyweapon)
								&&hdweapon(player.readyweapon).bweaponbusy
							)
						)
					)DropInventory(player.readyweapon);
					else player.setpsprite(PSP_WEAPON,player.readyweapon.findstate("deselect"));
				}
			}
			A_SelectWeapon("SS1IncapWeapon");
		}else{
			//get up
			A_SetSize(radius,min(fullheight,height+3));
		}
		player.viewz=min(ceilingz-6,pos.z+viewheight*(height/fullheight)+hudbob.y*0.1);


		//clear selected inventory so you can't use things easily
		if(invsel){
			invselbak=invsel;
			invsel=null;
		}


		//set the appropriate frame
		if(incapacitated){
			frame=clamp(6+abs(incapacitated>>2),6,11);

			//update if in the process of getting up
			if(incapacitated<0){
				if(zerk>0&&incapacitated<0)incapacitated=min(0,incapacitated+4);
			}
			incapacitated++;

			//set stuff
			runwalksprint=-1;
			speed=0.02;
			userange=20*heightmult;

		}else if(incaptimer>0){

			//set stuff - hobbling
			runwalksprint=-1;
			speed=0.2+(0.001*heightmult)*health;
			userange=20*heightmult;
		}


		//jitters
		if(
			incaptimer>0
			&&pitch<70
			&&!fallroll
		)muzzleclimb1.y+=frandom(0.1,0.4);


		//check for ability to stand despite incap
		double mshbak=maxstepheight;
		maxstepheight=20;
		int maxincaptimerstand=(
			health>HDCONST_MINSTANDHEALTH
			&&!checkmove(
				self.pos.xy+(cos(angle),sin(angle))*8,false
			)
			&&(
				!blockingmobj
				||!blockingmobj.bismonster
				||blockingmobj.isfriend(self)
				||blockingmobj.player  //what if an opponent wanted to do this?
			)
		?(TICRATE*900):1);
		maxstepheight=mshbak;


		//conditions for getting back up
		if(
			health>HDCONST_MINSTANDHEALTH+1
			&&incapacitated>0
			&&incaptimer<maxincaptimerstand
			&&(
				player.cmd.buttons&BT_JUMP
				||player.bot
				||(zerk>500&&!random(0,255))
			)
		){
			scale.y=skinscale.y*heightmult;
			incapacitated=-HDCONST_INCAPFRAME;
		}

		//conditions for falling back down
		if(
			!incapacitated
			&&incaptimer>maxincaptimerstand
		)incapacitated=1;


		if(
			incaptimer>0
			&&health>HDCONST_MINSTANDHEALTH
			&&health<HDCONST_MINSTANDHEALTH+3
		){
			damagemobj(null,null,min(5,health-10),"maxhpdrain");
		}

		if(
			!incapacitated
			||zerk>4000
		){
			A_Capacitated();
		}
	}
	void A_Capacitated(){
		incapacitated=0;
		A_TakeInventory("SS1IncapWeapon");
		A_SetSize(default.radius*heightmult,default.height*heightmult);
		userange=default.userange*heightmult;
		player.viewheight=viewheight*player.crouchfactor;
		if(invselbak&&invselbak.owner==self)invsel=invselbak;else{
			for(let item=inv;item!=null;item=item.inv){
				if(
					item.binvbar
				){
					invsel=item;
					break;
				}
			}
		}
		if(pos.z+height>ceilingz)player.crouchfactor=((ceilingz-pos.z)/height);
	}
	void A_Incapacitated(int flags=0,int incaptime=35){
		let ppp=player;
		if(!ppp)return;
		incapacitated=1;
		if(
			!(flags&HDINCAP_FAKING)
			&&!random(0,15)
		)Disarm(self);
		else{
			let www=hdweapon(ppp.readyweapon);
			if(www)www.OnPlayerDrop();
			if(flags&HDINCAP_SCREAM){
				if(!fallroll)A_StartSound(deathsound,CHAN_VOICE);
				else A_StartSound(painsound,CHAN_VOICE);
			}
		}
		if(
			!(flags&HDINCAP_FAKING)
			&&health<10
		)GiveBody(7);
		incapacitated=1;
		incaptimer=max(incaptimer,incaptime);
		setstatelabel("spawn");
	}
	enum IncapFlags{
		HDINCAP_FAKING=1,
		HDINCAP_SCREAM=2,
	}
}


class SS1IncapWeapon : HDIncapWeapon
{
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		super.DrawHUDStuff(sb,hdw,hpl);
		if(hpl.player.cmd.buttons&BT_ATTACK)return;
		int yofss=weaponstatus[INCS_YOFS]-((hpl.player.cmd.buttons&BT_ALTATTACK)?(50+5*hpl.flip):60);
		vector2 bob=(hpl.hudbob.x*0.2,hpl.hudbob.y*0.2+yofss);
		if(inventorytype=="HDFragGrenadeAmmo"){
			sb.drawimage(
				(weaponstatus[0]&INCF_PINOUT)?"FRGRF0":"FRGRA0",
				bob,sb.DI_SCREEN_CENTER_BOTTOM,scale:(1.6,1.6)
			);
		}else if(inventorytype=="SS1Medikit"){
			sb.drawimage("MKITB0",bob,sb.DI_SCREEN_CENTER_BOTTOM,scale:(2.,2.));
		}else if(inventorytype=="SS1MedPatch"){
			sb.drawimage("MEDPA0",bob,sb.DI_SCREEN_CENTER_BOTTOM,scale:(2.,2.));
		}
	}
	action void A_PickInventoryType(){
		static const class<inventory> types[]={
			"HDIncapWeapon",
			"SS1Medikit",
			"SS1Medpatch",
			"SS1FragGrenadeAmmo"
		};
		if(
			!invoker.weaponstatus[INCS_INDEX]
			&&!countinv("SS1Medpatch")
			&&countinv("SS1Medikit")
		){
			player.cmd.buttons|=BT_USE;
			UseInventory(findinventory("SS1Medikit"));
			invoker.spentinjecttype=null;
			invoker.injecttype="SS1MedikitDummy";
			return;
		}


		int which=invoker.weaponstatus[INCS_INDEX];
		do{
			which++;
			if(which>=types.size())which=0;
		}while(!countinv(types[which]));
		invoker.weaponstatus[INCS_INDEX]=which;

		let inventorytype=types[which];
		if(
			!countinv(inventorytype)
		){
			inventorytype="SS1IncapWeapon";
			return;
		}else if(inventorytype=="SS1Medikit"){
			invoker.spentinjecttype="SS1SpentMedikit";
			invoker.injecttype="SS1MedikitDummy";
		}
		else if(inventorytype=="SS1Medpatch"){
			invoker.spentinjecttype="SS1MedPatchSpentDummy";
			invoker.injecttype="SS1MedpatchDummy";
		}
		else if(inventorytype=="SS1FragGrenadeAmmo"){
			invoker.spentinjecttype="SS1FragSpoon";
			invoker.injecttype="SS1FragGrenadeRoller";
		}
		invoker.inventorytype=inventorytype;
	}
	states
	{
		nope:
		---- A 1{
			A_ClearRefire();
			if(invoker.bweaponbusy){
				let ppp=hdplayerpawn(self);
				if(!ppp)return;
				double hdbbx=(ppp.hudbobrecoil1.x+ppp.hudbob.x)*0.5;
				double hdbby=max(0,(ppp.hudbobrecoil1.y+ppp.hudbob.y)*0.5+invoker.bobrangey*2);
				A_WeaponOffset(hdbbx,hdbby+WEAPONTOP,WOF_INTERPOLATE);
			}
		}
		---- A 0{
			if(player.cmd.buttons&(
					BT_ATTACK|
					BT_ALTATTACK|
					BT_RELOAD|
					BT_ZOOM|
					BT_USER1|
					BT_USER2|
					BT_USER3|
					BT_USER4|
					BT_JUMP
			))setweaponstate("nope");
			else setweaponstate("ready");
		}
		select:
			TNT1 A 30;
			goto nope;
		ready:
			TNT1 A 0 A_WeaponReady(WRF_ALLOWUSER2|WRF_ALLOWRELOAD|WRF_DISABLESWITCH);
			TNT1 A 1{
				invoker.weaponstatus[INCS_YOFS]=invoker.weaponstatus[INCS_YOFS]*2/3;
				A_SetHelpText();
			}
			goto readyend;
		try2:
			TNT1 A 0 A_SetTics(max(0,random(0,100-health)));
			goto super::try2;
		firemode:
			TNT1 A 1{
				int yofs=max(4,invoker.weaponstatus[INCS_YOFS]*3/2);
				if(
					yofs>100
					&&pressingfiremode()
				)setweaponstate("fumbleforsomething");
				else invoker.weaponstatus[INCS_YOFS]=yofs;
			}
			TNT1 A 0 A_JumpIf(pressingfiremode(),"firemode");
			goto readyend;
		fumbleforsomething:
			TNT1 A 20 A_StartSound("weapons/pocket",CHAN_WEAPON);
			TNT1 A 0 A_PickInventoryType();
			goto nope;
			altfire:
			althold:
				TNT1 A 0 A_JumpIf(invoker.weaponstatus[0]&INCF_PINOUT,"holdfrag");
				TNT1 A 10 A_JumpIf(health<HDCONST_MINSTANDHEALTH&&!random(0,7),"nope");
				TNT1 A 20 A_StartSound("weapons/pocket",CHAN_WEAPON);
				TNT1 A 0 A_JumpIf(!countinv(invoker.inventorytype),"fumbleforsomething");
				TNT1 A 0 A_JumpIf(invoker.inventorytype=="SS1FragGrenadeAmmo","pullpin");
				TNT1 A 0 A_JumpIf(
					!HDWoundFixer.CheckCovered(self,true)
					&&(
						invoker.inventorytype=="SS1Medikit"
						||invoker.inventorytype=="SS1Medpatch"
					)
					,"injectstim");
			goto nope;
		injectstim:
			TNT1 A 1{
				if (invoker.inventorytype == "SS1Medikit") {
					A_SetBlend("7a 3a 18",0.1,4);
					A_MuzzleClimb(0,2);
					A_StartSound("patch/apply");
					A_StartSound("battery/charge");
				} else 
					A_StartSound("patch/apply");
				actor a=spawn(invoker.injecttype,pos,ALLOW_REPLACE);
				a.accuracy=40;a.target=self;
				A_TakeInventory(invoker.inventorytype,1);
				invoker.inventorytype="";
			}
			TNT1 A 4 A_MuzzleClimb(0,-0.5,0,-0.5,0,-0.5,0,-0.5);
			TNT1 A 6;
			TNT1 A 0{
				actor a=spawn(invoker.spentinjecttype,pos+(0,0,height-8),ALLOW_REPLACE);
				a.angle=angle;a.vel=vel;a.A_ChangeVelocity(3,1,2,CVF_RELATIVE);
				a.A_StartSound("weapons/grenopen",CHAN_WEAPON,CHANF_OVERLAP);
			}
			goto nope;
		pullpin:
			TNT1 A 3 A_JumpIf(health<HDCONST_MINSTANDHEALTH&&!random(0,4),"readyend");
			TNT1 A 0{
				if(!countinv(invoker.inventorytype))return;
				invoker.weaponstatus[0]|=INCF_PINOUT;
				A_StartSound("weapons/fragpinout",CHAN_WEAPON,CHANF_OVERLAP);
				A_TakeInventory(invoker.inventorytype,1);
			}
			//fallthrough
		holdfrag:
			TNT1 A 2 A_ClearRefire();
			TNT1 A 0{
				int buttons=player.cmd.buttons;
				if(buttons&BT_RELOAD)setweaponstate("pinbackin");
				else if(buttons&BT_ALTFIRE)setweaponstate("holdfrag");
			}
			TNT1 A 10;
			TNT1 A 0{invoker.DropFrag();}
			goto readyend;
		pinbackin:
			TNT1 A 10;
			TNT1 A 0 A_JumpIf(health<HDCONST_MINSTANDHEALTH&&!random(0,2),"holdfrag");
			TNT1 A 20{
				A_StartSound("weapons/fragpinout",CHAN_WEAPON);
				invoker.weaponstatus[0]&=~INCF_PINOUT;
				A_GiveInventory("HDFragGrenadeAmmo",1);
			}
			goto nope;
	}
}
