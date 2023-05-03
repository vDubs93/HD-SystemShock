extend class Hacker {
	

override void MovePlayer(){
		let player = self.player;
		if(!player)return;
		UserCmd cmd = player.cmd;
		bool notpredicting = !(player.cheats & CF_PREDICTING);
		onGravLift = CheckProximity("GravLift", 32);
			if (onGravLift) {
				vel.xy = vel.xy * GetFriction();
			}
		//update lastpitch and lastangle if teleported
		if(teleported){
			lastpitch=pitch;
			lastangle=angle;
		}

		//cache cvars as necessary
		if(!hd_nozoomlean)cachecvars();


		//set up leaning
		int leanmove=0;
		double leanamt=leaned?(10./(3+overloaded)):0;
		if(notpredicting){
			if(
				hdweapon(player.readyweapon)
			){
				leanamt*=8./max(8.,hdweapon(player.readyweapon).gunmass());
			}
			if(
				cmdleanmove&HDCMD_LEFT
				&&(
					leaned<=0
					||cmdleanmove&HDCMD_RIGHT
				)
			)leanmove--;
			if(
				cmdleanmove&HDCMD_RIGHT
				&&(
					leaned>=0
					||cmdleanmove&HDCMD_LEFT
				)
			)leanmove++;
			if(
				!leanmove
				&&(
					cmdleanmove&HDCMD_STRAFE
					||(
						cmd.buttons&BT_ZOOM
						&&!hd_nozoomlean.getbool()
					)
				)
			){
				if(cmd.sidemove<0&&leaned<=0)leanmove--;
				if(cmd.sidemove>0&&leaned>=0)leanmove++;
				cmd.sidemove=0;
			}
		}


		TurnCheck(notpredicting,player.readyweapon);



		player.onground = (pos.z <= floorz) || bOnMobj || bMBFBouncer || (player.cheats & CF_NOCLIP2) || onGravLift;

		// killough 10/98:
		//
		// We must apply thrust to the player and bobbing separately, to avoid
		// anomalies. The thrust applied to bobbing is always the same strength on
		// ice, because the player still "works just as hard" to move, while the
		// thrust applied to the movement varies with 'movefactor'.

		if(
			!movehijacked
			&&(cmd.forwardmove||cmd.sidemove||leanmove)
		){
			double forwardmove=0;double sidemove=0;
			double bobfactor=0;
			double friction=0;double movefactor=0;
			double fm=0;double sm=0;

			[friction, movefactor] = GetFriction();
			bobfactor = heightmult*(friction<ORIG_FRICTION ? movefactor : ORIG_FRICTION_FACTOR);

			//bobbing adjustments
			if(stunned)bobfactor*=4.;
			else if(cansprint && runwalksprint>0)bobfactor*=1.6;
			else if(runwalksprint<0||mustwalk){
				if(player.crouchfactor==1)bobfactor*=0.4;
				else bobfactor*=0.7;
			}

			if(!player.onground && !bNoGravity && !waterlevel){
				// [RH] allow very limited movement if not on ground.
				movefactor*=level.aircontrol;
				bobfactor*=level.aircontrol;
			}

			//"override double,double TweakSpeeds()"...
			double basespeed=speed*12.;
			if(cmd.forwardmove){
				fm=basespeed;
				if(cmd.forwardmove<0)fm*=-0.8;
			}
			if(cmd.sidemove>0)sm=basespeed;
			else if(cmd.sidemove<0)sm=-basespeed;
			if(!player.morphTics){
				double factor=1.;
				for(let it=Inv;it;it=it.Inv){
					factor *= it.GetSpeedFactor();
				}
				fm*=factor;
				sm*=factor;
			}

			// When crouching, speed <s>and bobbing</s> have to be reduced
			if(CanCrouch() && player.crouchfactor != 1 && runwalksprint>=0){
				fm *= player.crouchfactor;
				sm *= player.crouchfactor;
			}

			if(fm&&sm)movefactor*=HDCONST_ONEOVERSQRTTWO;

			if(heightmult&&heightmult!=1)movefactor/=heightmult;

			//So far we'll stick with modelling people who can still walk.
			//Mobility aids may be added later.
			//What is a wheelchair but an unarmoured mech?
			if(
				strength>1.
				||runwalksprint>=0
			)movefactor*=(0.3*strength+0.7);

			if(!canmovelegs)movefactor*=0.1;

			forwardmove = fm * movefactor * (35 / TICRATE);
			sidemove = sm * movefactor * (35 / TICRATE);

			if(forwardmove){
				Bob(Angle, cmd.forwardmove * bobfactor / 256., true);
				ForwardThrust(forwardmove, Angle);
			}
			if(sidemove){
				let a = Angle - 90;
				Bob(a, cmd.sidemove * bobfactor / 256., false);
				Thrust(sidemove, a);
			}
			if(
				leanmove
				&&notpredicting
				&&!isfrozen()
			){
				bool poscmd=leanmove>0;
				bool zrk=zerk>0;
				if(zrk&&!random(0,63)){
					JumpCheck(0,poscmd?1024:-1024,true);
					leaned=0;
				}else{
					let a = Angle - 90;
					leaned=clamp(poscmd?leaned+1:leaned-1,-8,8);
					if(zrk){
						leaned=clamp(poscmd?leaned+1:leaned-1,-8,8);
						leanamt*=2;
					}
					if(!poscmd)leanamt=-leanamt;
					if(abs(leaned)<8){
						TryMove(
							pos.xy+(cos(a),sin(a))*leanamt,
							false
						);
					}
				}
			}

			if(
				notpredicting
				&&(forwardmove||sidemove)
			){
				PlayRunning();
			}

			if(player.cheats & CF_REVERTPLEASE){
				player.cheats &= ~CF_REVERTPLEASE;
				player.camera = player.mo;
			}
		}


		double toroll=-999;


		//undo leaning
		if(notpredicting){
			if(!leanmove&&leaned){
				let a=angle+90;
				if(leaned>0)leaned--;
				else if(leaned<0){
					leaned++;
					leanamt=-leanamt;
				}
				TryMove(
					pos.xy+(cos(a),sin(a))*leanamt,
					false
				);
			}
			toroll=(leaned>0?leaned:-leaned)*leanamt;
		}


		//turn view roll upside down to conform to movement roll
		double arp=abs(realpitch);
		if(
			arp<=270
			&&arp>90
		)toroll=180;
		else if(roll==180)toroll=0;

		if(toroll!=-999)A_SetRoll(toroll,SPF_INTERPOLATE);


		//if done in ticker, fails to show difference during TurnCheck
		lastvel=vel;
	}
	override void JumpCheck(double fm,double sm,bool forceslide){
		if(
			!forceslide
			&&player.cmd.buttons&BT_JUMP
		){
			int mcc=MantleCheck();
			if(
				player.crouchoffset
				&&!mcc
			){
				//roll instead of stand
				double moveangle=absangle(angle,HDMath.AngleTo((0,0),vel.xy));
				double vxysq=(vel.x*vel.x+vel.y*vel.y);
				double mshbak=maxstepheight;
				maxstepheight=heightmult*HDCONST_ROLLMAXSTEPHEIGHT;
				if(
					!(hd_noslide.getint()&2)
					&&fm
					&&!sm
					&&player.crouchfactor<0.9

					//this is just copypasted from jump below
					&&!(oldinput & BT_JUMP)
					&&fatigue<HDCONST_SPRINTFATIGUE
					&&(
						!stunned
						||(
							//sliding forwards or backwards
							vxysq>4.
							&&(
								moveangle<6
								||moveangle<(180-6)
							)
						)
					)
					&&(
						fm<=0
						||checkmove(pos.xy+(cos(angle),sin(angle))*radius,PCM_DROPOFF)
					)
				){
					maxstepheight=mshbak;
					double rollamt=0;
					if(fm>0)rollamt=20+sqrt(vxysq);
					else rollamt=-20-sqrt(vxysq);
					if(rollamt){
						ForwardRoll(int(rollamt),FROLL_VOLUNTARY);
						if(player.onground)
							A_ChangeVelocity(rollamt*0.2,0,abs(rollamt)*0.1,CVF_RELATIVE);
						return;
					}
				}else maxstepheight=mshbak;

				// jump-to-stand is in CrouchCheck not here
			}
			else if(waterlevel>=2){
				vel.z=4*speed;
			}
			else if(bnogravity){
				vel.z=3;
			}
			else if(  // HERE COMES THE JUMP
				fatigue<HDCONST_SPRINTFATIGUE
				&&!mcc
				&&canmovelegs
				&&stunned<1
				&&jumptimer<=3
				&&!(oldinput&BT_JUMP)
			){
				double jumppower=max(0,maxspeed*strength+1);
				double jz=jumppower*0.5;

				vector2 jumpdir=(0,0);
				if(!sm){
					double ppp=pitch;
					if(fm){
						//forward
						jumpdir.x=cos(angle);
						jumpdir.y=sin(angle);
					}else{
						ppp=-90;
					}

					if(fm<0)jumpdir*=-1;
					else if(ppp<0){
						double pstr=jumppower*ppp*(-1./90.);
						jz+=(pstr/1.5);
						jumppower-=pstr;
					}

				}else if(!fm){
					//side
					double rangle=angle+(sm>0?-90:90);
					jumpdir.x=cos(rangle);
					jumpdir.y=sin(rangle);
				}else{
					//diagonal
					double rangle=(sm>0?-45:45);
					if(fm<0)rangle*=3;
					rangle+=angle;
					jumpdir.x=cos(rangle);
					jumpdir.y=sin(rangle);
				}
				if(!checkmove(pos.xy+jumpdir*2,PCM_NOACTORS))jumpdir=(0,0);


				if(fm>0)jumppower*=(sm?1.2:1.4);
				vel.xy+=jumpdir*jumppower;
				vel.z+=jz;

				A_StartSound(
					landsound,CHAN_BODY,CHANF_OVERLAP,
					volume:min(1.,jumppower*0.04)
				);

				jumptimer+=18;
				fatigue+=3;

				//copied from sprint
				if(fatigue>=HDCONST_SPRINTFATIGUE){
					fatigue+=20;
					stunned+=400;
					A_StartSound(painsound,CHAN_VOICE);
				}

				if(bloodpressure<40)bloodpressure+=2;
			}
		}
		//slides, too!
		else if(
			forceslide||(
				(fm||sm)
				&&player.onground
				&&jumptimer<1
				&&player.crouchdir<0
				&&player.crouchfactor>0.5
				&&(
					runwalksprint>0
					||!(hd_noslide.getint()&1)
				)
			)
		){
			double mm=(strength*0.3+1.)*(lastheight-height)*(player.crouchfactor-0.5);
			double fmm=fm>0?mm:fm<0?-mm*0.6:0;
			double smm=sm>0?-mm:sm<0?mm:0;
			A_ChangeVelocity(fmm,smm,-0.6,CVF_RELATIVE);

			fatigue+=2;
			bloodpressure=max(bloodpressure,20);

			int stmod=int(strength*6.);
			stunned+=15-(stmod>>1);
			jumptimer+=35-stmod;

			smm*=-frandom(0.4,0.7);

			double slidemult=1.;
			let hdw=HDWeapon(player.readyweapon);
			if(hdw)slidemult=max(1.,0.1*hdw.gunmass());
			if(fmm<0){
				A_MuzzleClimb(
					(smm*1.2,-1.8)*slidemult,
					(smm,-1.3)*slidemult,
					(smm,-0.7)*slidemult,
					(smm*0.8,-0.3)*slidemult
				);
				if(slidemult>1.7)totallyblocked=true;
			}else if(fmm>0){
				A_MuzzleClimb(
					(smm*1.2,2.2)*slidemult,
					(smm,1.3)*slidemult,
					(smm,0.7)*slidemult,
					(smm*0.8,0.3)*slidemult
				);
				totallyblocked=true;
			}else{
				A_MuzzleClimb(
					(smm*0.6,-0.7)*slidemult,
					(smm,-0.3)*slidemult,
					(smm,-0.1)*slidemult,
					(smm*0.3,-0.07)*slidemult
				);
				if(slidemult>1.4)totallyblocked=true;
			}
		}
	}
	
}

	