class HackerStatusBar : HDStatusBar
{	
	int heartBeat[140][2];
	int energyUsage[140];
	float counters[4];
	DynamicValueInterpolator pCharge;
	DynamicValueInterpolator phealth;
	DynamicValueInterpolator pMaxHealth;
	override void init()
	{
		phealth = DynamicValueInterpolator.Create(0,0.01,1,4);
		pCharge = DynamicValueInterpolator.Create(0,0.01,1,4);
		for (int i=0; i< 140; i++)
		{
			energyUsage[i] = 0;
		}
		super.init();
		
	}
	void DrawPuzzle(int puzzleType)
	{
		if (puzzleType == 1) {
			let hpl = Hacker(cplayer.mo);
			DrawImage("NumPad", (6, -6), DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM, 255, (320, 200),(0.5, 0.5));
			DrawImage("NPInput", (6, -70), DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM, 255, (320, 200),(0.5, 0.5));
			DrawImage(gametic % 10 < 5 ? "NPCursor" : "", ((hpl.cursorX * 16) + 6, -((hpl.cursorY * 16) + 6)), DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM, 255,
			(320, 200),(0.5, 0.5));
			Font myfont = "NUMPADF";
			HUDFont font = HUDFont.Create(myfont, 16, false);
			DrawString(font,numPadPuzzle(hpl.currPuzz).getInput(), (10,-84), scale:(0.5, 0.5));
			
		} else if (puzzleType == 2) {
			let hpl = Hacker(cplayer.mo);
			DrawImage("APanel", (6, -6), DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM, 255, (320, 200));
			DrawImage(gametic % 10 < 5 ? "APCursor" : "", ((hpl.cursorX *19) + 12, -(((4-hpl.cursorY) * 17.25) + 12)), DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM, 255, (320, 200));
			AccessPanelPuzzle puzz = AccessPanelPuzzle(hpl.currPuzz);
			
			for (int y = 0; y < 5; y++) {
				for (int x = 0; x < 7; x++) {
					String imgToDraw = "";
					int space[2];
					space[0] = puzz.getGridSpaceFlipped(x, y);
					space[1] = puzz.getGridSpaceStatus(x, y);
					
					if (space[0] == 1){
						if (space[1] == 0)
							imgToDraw = "APSP1OFF";
						else
							imgToDraw = "APSP1ON";
					} else if (space[0] == 0)
						imgToDraw = "APSP2OFF";
					DrawImage(imgToDraw, ((x *19) + 12, -(((4-y) * 17.25) + 12)), DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM, 255, (320, 200));
				}
			}
		} else if (puzzleType == 3) {
			let hpl = Hacker(cplayer.mo);
			elevatorPanel panel = elevatorPanel(hpl.currPuzz);
			DrawImage("EPAD"..(panel.user_elev_number+1), (6, -6), DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM, 255, (320, 200), (0.5, 0.5));
			DrawImage(gametic % 10 < 5 ? "NPCursor" : "", ((hpl.cursorX * 16) + 6, -((hpl.cursorY * 16) + 6)), DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM, 255,
			(320, 200),(0.5, 0.5));
		}
	}
	
	
	void drawEKG(Hacker hpl)
	{
		DrawImage("EKGOUTLN", (-30,26),DI_SCREEN_LEFT_TOP | DI_ITEM_LEFT_BOTTOM);
		int spike = 10;
		
		if (hpl.health > 0){
			if (hpl.beatCount%hpl.beatmax > hpl.beatmax - 2) {
				spike = 0;
			}else if (hpl.beatCount%hpl.beatmax > hpl.beatmax-3){
				spike = 20;
			}
		}
		
		float beatPos = hpl.gameTime%140;
		heartBeat[hpl.gameTime%140][1] = hpl.gameTime%140;
		float nPos = (hpl.gameTime*.9)%140;
		float chiPos = (hpl.gameTime/2)%140;
		heartBeat[hpl.gameTime%140][0] = spike;
		energyUsage[(hpl.gameTime%140)] = hpl.energyUse;
		
		counters[2] += counters[2] < 20 && hpl.health < 1?0.1 : 0;
		counters[0] = beatPos%140;
		counters[1] = (counters[1]+.5)%360;
		for (int i=0; i < 140; i++){
			int hx1 =  heartBeat[i][1];
			int hy1 = heartBeat[i][0];
			int hx2,hy2;
			if ((heartBeat[i][0] == heartBeat[i > 0 ? i - 1 : 139][0])|| (heartBeat[i][0] != 10) || heartBeat[i > 0 ? i - 1 : 139][0] != 10) {
				hx2 = heartBeat[i > 0 ? i - 1 : 139][1];
				hy2 = heartBeat[i > 0 ? i - 1 : 139][0];
			} else {
				hx2 = 0;
				hy2 = 0;
			}
			float halpha = (((i-counters[0])%140)/140.) * 255;
			float alpha = ((i)%71)/70.;
			hx1 += 10;
			hy1 += 10;
			hx2 += 10;
			hy2 += 10;
			int cx1 = (chiPos - i)%141;
			int cy1 = sin(5*((chiPos-i)%141)) * (20-counters[2]);
			int cx2 = (chiPos - (i + 1))%141;
			int cy2 = sin(5*((chiPos-(i+1))%141)) * (20-counters[2]);
			int ex1 = (nPos - i)%140;
			int ey1 = 30 - energyUsage[i];
			int ex2 = (nPos - (i + 1))%140;
			int ey2 = 30 - energyUsage[i > 0 ? i - 1 : 139];
			if (abs(ex1-ex2) < 10 && i < 70)
				screen.drawThickLine(3 * ex1 + 30, 3*ey1, 3 * ex2 + 30, 3*ey2,4,Color(255,0,128,255), (1-alpha) * 255);
			if (abs(cx1-cx2) < 10 && i < 70)
				screen.drawThickLine(3 * cx1 + 30, cy1 + 60, 3* cx2 + 30, cy2 + 60,4,Color(255,220,0,255), (1-alpha) * 255);
			if (abs(hx1-hx2) < 10 && (beatPos - i)%140 <70)
				screen.drawThickLine(3 * hx1, 3*hy1, 3 * hx2,3* hy2,4,Color(255,255,0,0), halpha);
				
		}
	}
	override void Draw(int state,double TicFrac){
		let hpl=Hacker(cplayer.mo);
		if (level.LevelNum<20){
		pCharge.Update(hpl.InternalCharge);
		phealth.Update(hpl.health);	
		if (hd_debug) {
			HUDFont patchfont = HUDFont.Create(smallfont, 1, false, 2, 2);
			DrawString(patchfont, string.format("Patch Amounts: %03d %03d %03d %03d", hpl.medPatchCount, hpl.Bpatch, hpl.sightPatch, hpl.staminaPatch), (0, 32));
		}
		beginHud(forcescaled:true);
		
		
		
			if(!automapactive){
				if (hpl.doPuzzle){
					DrawPuzzle(hpl.doPuzzle);
				}
				drawbar(
						"ChargeBar","EmptyBar",
						phealth.getValue(),100,
						(120,32),-1,
						0,self.DI_SCREEN_CENTER_TOP, true
					);
				drawbar(
						"ChargeBar","EmptyBar",
						pCharge.getValue(),255,
						(140,51),-1,
						0,self.DI_SCREEN_CENTER_TOP, true
					);
				drawEKG(hpl);
				
				DrawImage("ChargeIcon1",(83, 54),DI_SCREEN_CENTER_TOP);
				DrawImage("ChargeOutline",(165,37),DI_SCREEN_CENTER_TOP);
				DrawImage("ChargeOutline",(185,56),DI_SCREEN_CENTER_TOP);
				}
			}
		if(
			!cplayer
			||!hpl
		)return;
		cplayer.inventorytics=0;


		if(automapactive){
			DrawAutomapHUD(ticfrac);
			DrawAutomapStuff();
		}else if(cplayer.mo==cplayer.camera){
			DrawAlwaysStuff();
			if(hpl.health>0){
				BeginHUD(forcescaled:false);

				bool usemughud=(
					hd_hudstyle.getint()==1
					||(
						state==HUD_Fullscreen
						&&!hd_hudstyle.getint()
					)
				);

				if(
					state<=HUD_Fullscreen
					&&hudlevel>0
				)DrawCommonStuff(usemughud);
				else{
					let www=hdweapon(cplayer.readyweapon);
					if(www&&www.balwaysshowstatus)drawweaponstatus(www);
				}
			}
		}

		//blacking out
		if(hpl.blackout>0)fill(
			color(hpl.blackout,6,2,0),0,0,screen.getwidth(),screen.getheight()
		);


		if(hpl.health<1)drawtip();
		if(idmypos)drawmypos();
	}
	void DrawAutomapStuff(){
		SetSize(0,480,300);
		BeginHUD();

		//KEYS!
		if(hpl.countinv("BlueCard"))drawimage("BKEYB0",(10,24),DI_TOPLEFT);
		if(hpl.countinv("YellowCard"))drawimage("YKEYB0",(10,44),DI_TOPLEFT);
		if(hpl.countinv("RedCard"))drawimage("RKEYB0",(10,64),DI_TOPLEFT);
		if(hpl.countinv("BlueSkull"))drawimage("BSKUA0",(6,30),DI_TOPLEFT);
		if(hpl.countinv("YellowSkull"))drawimage("YSKUA0",(6,50),DI_TOPLEFT);
		if(hpl.countinv("RedSkull"))drawimage("RSKUB0",(6,70),DI_TOPLEFT);

		//frags
		if(deathmatch||fraglimit>0)drawstring(
			mHUDFont,FormatNumber(CPlayer.fragcount),
			(30,24),DI_TOPLEFT|DI_TEXT_ALIGN_LEFT,
			Font.CR_RED
		);

		//mugshot
		DrawTexture(GetMugShot(5,Mugshot.CUSTOM,getmug(hpl.mugshot)),(6,-14),DI_BOTTOMLEFT,alpha:blurred?0.2:1.);

		/*heartbeat/playercolour tracker
		if(hpl && hpl.beatmax){
			float cpb=hpl.beatcount*1./hpl.beatmax;
			float ysc=-(4+hpl.bloodpressure*0.05);
			if(!hud_aspectscale.getbool())ysc*=1.2;
			fill(
				color(int(cpb*255),sbcolour.r,sbcolour.g,sbcolour.b),
				32,-24-cpb*3,
				4,ysc,
				DI_BOTTOMLEFT
			);
		}*/
		//health
		if(hd_debug)drawstring(
			pnewsmallfont,formatnumber(hpl.health),
			(34,-24),DI_BOTTOMLEFT|DI_TEXT_ALIGN_CENTER,
			hpl.health>70?Font.CR_OLIVE:(hpl.health>33?Font.CR_GOLD:Font.CR_RED),scale:(0.5,0.5)
		);

		//items
		DrawItemHUDAdditions(HDSB_AUTOMAP,DI_TOPLEFT);

		//inventory selector
		DrawInvSel(6,100,10,109,DI_TOPLEFT);


		//guns
		drawselectedweapon(-80,-60,DI_BOTTOMRIGHT);

		drawammocounters(-18);
		drawweaponstash(true,-48);

		drawmypos(10);
	}

	void DrawMyPos(int downpos=(STB_COMPRAD<<2)){
		//permanent mypos
		drawstring(
			psmallfont,string.format("%i  x",hpl.pos.x),
			(-4,downpos+10),DI_TEXT_ALIGN_RIGHT|DI_SCREEN_RIGHT_TOP,
			Font.CR_OLIVE
		);
		drawstring(
			psmallfont,string.format("%i  y",hpl.pos.y),
			(-4,downpos+18),DI_TEXT_ALIGN_RIGHT|DI_SCREEN_RIGHT_TOP,
			Font.CR_OLIVE
		);
		drawstring(
			psmallfont,string.format("%i  z",hpl.pos.z),
			(-4,downpos+26),DI_TEXT_ALIGN_RIGHT|DI_SCREEN_RIGHT_TOP,
			Font.CR_OLIVE
		);
	}
	string getmug(string mugshot){
		if(mugshot==HDMUGSHOT_DEFAULT)switch(cplayer.getgender()){
			case 0:return "STF";
			case 1:return "SFF";
			default:return "STC";
		}else return mugshot;
	}
	void DrawAlwaysStuff(){
		if(
			hpl.health>0&&(
				hpl.binvisible
				||hpl.alpha<=0
			)
		)return;

		//reads hd_setweapondefault and updates accordingly
		if(hd_setweapondefault.getstring()!=""){
			string wpdefs=cvar.getcvar("hd_weapondefaults",cplayer).getstring().makelower();
			string wpdlastchar=wpdefs.mid(wpdefs.length()-1,1);
			while(
				wpdlastchar==" "
				||wpdlastchar==","
			){
				wpdefs=wpdefs.left(wpdefs.length()-1);
				wpdlastchar=wpdefs.mid(wpdefs.length()-1,1);
			}
			string newdef=hd_setweapondefault.getstring().makelower();
			newdef.replace(",","");
			string newdefwep=newdef.left(3);
			newdefwep.replace(" ","");
			newdefwep.replace(",","");
			if(newdefwep.length()==3){
				int whereisold=wpdefs.rightindexof(newdefwep);
				if(whereisold<0){
					wpdefs=wpdefs..","..newdef;
				}else{
					string leftofdef=wpdefs.left(whereisold);
					wpdefs=wpdefs.mid(whereisold);
					int whereiscomma=wpdefs.indexof(",");
					if(whereiscomma<0){
						if(newdef==newdefwep)wpdefs="";
						else wpdefs=newdef;
					}else{
						if(newdef==newdefwep)wpdefs=wpdefs.mid(whereiscomma);
						else wpdefs=newdef..wpdefs.mid(whereiscomma);
					}
					if(leftofdef!=""){
						wpdlastchar=leftofdef.mid(leftofdef.length()-1,1);
						while(
							wpdlastchar==" "
							||wpdlastchar==","
						){
							leftofdef=leftofdef.left(leftofdef.length()-1);
							wpdlastchar=leftofdef.mid(leftofdef.length()-1,1);
						}
						wpdefs=leftofdef..","..wpdefs;
					}
				}
				wpdefs.replace(",,",",");
				wpdlastchar=wpdefs.mid(wpdefs.length()-1,1);
				while(
					wpdlastchar==" "
					||wpdlastchar==","
				){
					wpdefs=wpdefs.left(wpdefs.length()-1);
					wpdlastchar=wpdefs.mid(wpdefs.length()-1,1);
				}

				hd_setweapondefault.setstring("");
				cvar.findcvar("hd_weapondefaults").setstring(wpdefs);
			}
		}


		//update loadout1 based on old custom
		//delete once old custom is gone!
		let lomt=LoadoutMenuHackToken(ThinkerFlag.Find(cplayer.mo,"LoadoutMenuHackToken"));
		if(lomt)cvar.findcvar("hd_loadout1").setstring(lomt.loadout);



		//draw the crosshair
		if(
			!blurred
			&&hpl.health>0
		)DrawHDXHair(hpl);



		//draw item overlays
		for(int i=0;i<hpl.OverlayGivers.size();i++){
			let ppp=hpl.OverlayGivers[i];
			if(
				ppp
				&&ppp.owner==hpl
			)ppp.DisplayOverlay(self,hpl);
		}


		//draw information text for selected weapon
		SetSize(0,320,200);
		BeginHUD(forcescaled:true);
		let hdw=HDWeapon(cplayer.readyweapon);
		if(hdw&&hdw.msgtimer>0)DrawString(
			psmallfont,hdw.wepmsg,(0,48),
			DI_SCREEN_HCENTER|DI_TEXT_ALIGN_CENTER,
			translation:Font.CR_DARKGRAY,
			wrapwidth:smallfont.StringWidth("m")*80
		);

	}
	void DrawCommonStuff(bool usemughud){
		let cp=HDPlayerPawn(CPlayer.mo);
		if(!cp)return;

		int mxht=-4-mIndexFont.mFont.GetHeight();
		int mhht=-4-mHUDFont.mFont.getheight();

		//inventory
		DrawSurroundingInv(25,-4,42,mxht,DI_SCREEN_CENTER_BOTTOM);
		DrawInvSel(25,-14,42,mxht,DI_SCREEN_CENTER_BOTTOM);

		//keys
		string keytype="";
		if(hpl.countinv("BlueCard"))keytype="STKEYS0";
		if(hpl.countinv("BlueSkull")){
			if(keytype=="")keytype="STKEYS3";
			else keytype="STKEYS6";
		}
		if(keytype!="")drawimage(
			keytype,
			(50,-16),
			DI_SCREEN_CENTER_BOTTOM
		);
		keytype="";
		if(hpl.countinv("YellowCard"))keytype="STKEYS1";
		if(hpl.countinv("YellowSkull")){
			if(keytype=="")keytype="STKEYS4";
			else keytype="STKEYS7";
		}
		if(keytype!="")drawimage(
			keytype,
			(50,-10),
			DI_SCREEN_CENTER_BOTTOM
		);
		keytype="";
		if(hpl.countinv("RedCard"))keytype="STKEYS2";
		if(hpl.countinv("RedSkull")){
			if(keytype=="")keytype="STKEYS5";
			else keytype="STKEYS8";
		}
		if(keytype!="")drawimage(
			keytype,
			(50,-4),
			DI_SCREEN_CENTER_BOTTOM
		);


		//health
		if(hd_debug)drawstring(
			pnewsmallfont,FormatNumber(hpl.health),
			(0,mxht),DI_TEXT_ALIGN_CENTER|DI_SCREEN_CENTER_BOTTOM,
			hpl.health>70?Font.CR_OLIVE:(hpl.health>33?Font.CR_GOLD:Font.CR_RED),scale:(0.5,0.5)
		);


		//frags
		if(deathmatch||fraglimit>0)drawstring(
			mHUDFont,FormatNumber(CPlayer.fragcount),
			(74,mhht),DI_TEXT_ALIGN_LEFT|DI_SCREEN_CENTER_BOTTOM,
			Font.CR_RED
		);


		/*heartbeat/playercolour tracker
		if(hpl.beatmax){
			float cpb=hpl.beatcount*1./hpl.beatmax;
			float ysc=-(3+hpl.bloodpressure*0.05);
			if(!hud_aspectscale.getbool())ysc*=1.2;
			fill(
				color(int(cpb*255),sbcolour.r,sbcolour.g,sbcolour.b),
				-12,-6-cpb*2,3,ysc, DI_SCREEN_CENTER_BOTTOM
			);
		}
		*/
		//items
		DrawItemHUDAdditions(
			usemughud?HDSB_MUGSHOT:0
			,DI_SCREEN_CENTER_BOTTOM
		);

		//weapon readouts!
		if(cplayer.readyweapon&&cplayer.readyweapon!=WP_NOCHANGE)
			drawweaponstatus(cplayer.readyweapon);

		//weapon sprite
		if(
			hudlevel==2
			||cvar.getcvar("hd_hudsprite",cplayer).getbool()
			||!cvar.getcvar("r_drawplayersprites",cplayer).getbool()
		)
		drawselectedweapon(58,-6,DI_SCREEN_CENTER_BOTTOM|DI_ITEM_LEFT_BOTTOM);

		//full hud consequences
		if(hudlevel==2){
			drawweaponstash();
			drawammocounters(mxht);

			//encumbrance
			if(hpl.enc){
				double pocketenc=hpl.pocketenc;
				drawstring(
					pnewsmallfont,formatnumber(int(hpl.enc)),
					(8,mxht),DI_TEXT_ALIGN_LEFT|DI_SCREEN_LEFT_BOTTOM,
					hpl.overloaded<0.8?Font.CR_OLIVE:hpl.overloaded>1.6?Font.CR_RED:Font.CR_GOLD,scale:(0.5,0.5)
				);
				int encbarheight=mxht+5;
				fill(
					color(128,96,96,96),
					4,encbarheight,1,-1,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
				fill(
					color(128,96,96,96),
					5,encbarheight,1,-20,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
				fill(
					color(128,96,96,96),
					3,encbarheight,1,-20,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
				encbarheight--;
				drawrect(
					4,encbarheight,1,
					-min(hpl.maxpocketspace,pocketenc)*19/hpl.maxpocketspace,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
				bool overenc=hpl.flip&&pocketenc>hpl.maxpocketspace;
				fill(
					overenc?color(255,216,194,42):color(128,96,96,96),
					4,encbarheight-19,1,overenc?3:1,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
			}

			int wephelpheight=NewSmallFont.GetHeight()*5;

			//compass
			int STB_COMPRAD=12;vector2 compos=(-STB_COMPRAD,STB_COMPRAD)*2;
			double compangle=hpl.angle;

			double compangle2=hpl.deltaangle(0,compangle);
			if(abs(compangle2)<120)screen.DrawText(NewSmallFont,
				font.CR_GOLD,
				600+compangle2*32/cplayer.fov,
				wephelpheight,
				"E",
				DTA_VirtualWidth,640,DTA_VirtualHeight,480
			);
			compangle2=hpl.deltaangle(-90,compangle);
			if(abs(compangle2)<120)screen.DrawText(NewSmallFont,
				font.CR_BLACK,
				600+compangle2*32/cplayer.fov,
				wephelpheight,
				"S",
				DTA_VirtualWidth,640,DTA_VirtualHeight,480
			);
			compangle2=hpl.deltaangle(180,compangle);
			if(abs(compangle2)<120)screen.DrawText(NewSmallFont,
				font.CR_RED,
				600+compangle2*32/cplayer.fov,
				wephelpheight,
				"W",
				DTA_VirtualWidth,640,DTA_VirtualHeight,480
			);
			compangle2=hpl.deltaangle(90,compangle);
			if(abs(compangle2)<120)screen.DrawText(NewSmallFont,
				font.CR_WHITE,
				600+compangle2*32/cplayer.fov,
				wephelpheight,
				"N",
				DTA_VirtualWidth,640,DTA_VirtualHeight,480
			);

			string s=hpl.wephelptext;
			if(s!="")screen.DrawText(NewSmallFont,OptionMenuSettings.mFontColorValue,
				8,
				wephelpheight,
				s,
				DTA_VirtualWidth,640,
				DTA_VirtualHeight,480,
				DTA_Alpha,0.8
			);

			wephelpheight+=NewSmallFont.GetHeight();
			screen.DrawText(NewSmallFont,
				font.CR_OLIVE,
				600,
				wephelpheight,
				"^",
				DTA_VirtualWidth,640,DTA_VirtualHeight,480
			);
			string postxt=string.format("%i,%i,%i",hpl.pos.x,hpl.pos.y,hpl.pos.z);
			screen.DrawText(NewSmallFont,
				font.CR_OLIVE,
				600-(NewSmallFont.StringWidth(postxt)>>1),
				wephelpheight+6,
				postxt,
				DTA_VirtualWidth,640,DTA_VirtualHeight,480
			);

		}

		if(hd_debug>=3){
			double velspd=hpl.vel.length();
			string velspdout=velspd.."   "..(velspd*HDCONST_MPSTODUPT).."mps   "..(velspd*HDCONST_MPSTODUPT*HDCONST_MPSTOKPH).."km/h";
			screen.DrawText(NewSmallFont,
				font.CR_GRAY,
				600-(NewSmallFont.StringWidth(velspdout)>>1),
				NewSmallFont.GetHeight(),
				velspdout,
				DTA_VirtualWidth,640,DTA_VirtualHeight,480
			);
		}


		if(usemughud)DrawTexture(
			GetMugShot(5,Mugshot.CUSTOM,getmug(hpl.mugshot)),(0,-14),
			DI_ITEM_CENTER_BOTTOM|DI_SCREEN_CENTER_BOTTOM,
			alpha:blurred?0.2:1.
		);


		//object description
		drawstring(
			pnewsmallfont,hpl.viewstring,
			(0,20),DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER,
			Font.CR_GREY,0.4,scale:(1,1)
		);


		drawtip();

		//debug centre line
		if(hd_debug)fill(color(96,24,96,18),-0.3,0,0.6,100, DI_SCREEN_CENTER);

	}
}