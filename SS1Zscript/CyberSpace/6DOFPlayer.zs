class SixDoFPlayer : PlayerPawn
{
    Property UpMove : upMove;


    Default
    {
        Speed 320 / ticRate;
        SixDoFPlayer.UpMove 1.0;

        +NoGravity
        +RollSprite
    }


    const maxYaw = 65536.0;
    const maxPitch = 65536.0;
    const maxRoll = 65536.0;
    const maxForwardMove = 12800;
    const maxSideMove = 10240;
    const maxUpMove = 768;
    const stopFlying = -32768;

    const trichordingCVar = "G_Trichording";


    double upMove;
    Quaternion targetRotation;


    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        bFly = true;
        targetRotation.FromEulerAngle(angle, pitch, roll);
    }


    override void HandleMovement()
    {
        if (reactionTime) --reactionTime;   // Player is frozen
        else
        {
            CheckQuickTurn();
            RotatePlayer();
            MovePlayer();
        }
    }


    override void CheckCrouch(bool totallyFrozen) {}
    override void CheckPitch() {}


    override void MovePlayer()
    {
        UserCmd cmd = player.cmd;

        if (IsPressed(BT_Jump)) cmd.upMove = maxUpMove;
        if (IsPressed(BT_Crouch)) cmd.upMove = -maxUpMove;
        if (cmd.upMove == stopFlying) cmd.upMove = 0;   // Can't stop flying

        if (cmd.forwardMove || cmd.sideMove || cmd.upMove)
        {
            double scale = CmdScale();
            double fm = scale * cmd.forwardMove / maxForwardMove;
            double sm = scale * cmd.sideMove / maxSideMove;
            double um = scale * cmd.upMove / maxUpMove;

            [fm, sm, um] = TweakSpeeds3(fm, sm, um);

            Vector3 forward, right, up;
            [forward, right, up] = GetAxes();

            Vector3 wishVel = fm * forward + sm * right + um * up;

            Accelerate(wishVel.Unit(), wishVel.Length(), 4.0);
            BobAccelerate(wishVel.Unit(), wishVel.Length(), 4.0);

            if (!(player.cheats & CF_PREDICTING)) PlayRunning();

			if (player.cheats & CF_REVERTPLEASE)
			{
				player.cheats &= ~CF_REVERTPLEASE;
				player.camera = player.mo;
			}
        }
    }


    virtual void CheckQuickTurn()
    {
        UserCmd cmd = player.cmd;

		if (JustPressed(BT_Turn180)) player.turnticks = turn180_ticks;

        if (player.turnTicks)
        {
            --player.turnTicks;
            cmd.yaw = round(0.5 * maxYaw / turn180_ticks);
        }
    }


    virtual void RotatePlayer()
    {
        // Find target rotation
        UserCmd cmd = player.cmd;
        double cmdYaw = cmd.yaw * 360 / maxYaw;
        double cmdPitch = -cmd.pitch * 360 / maxPitch;
        double cmdRoll = cmd.roll * 360 / maxRoll;

        Quaternion input;
        input.FromEulerAngle(cmdYaw, cmdPitch, cmdRoll);
        Quaternion.Multiply(targetRotation, targetRotation, input);

        // Interpolate to it
        Quaternion r;
        r.FromEulerAngle(angle, pitch, roll);

        Quaternion.Slerp(r, r, targetRotation, 0.2);

        double newAngle, newPitch, newRoll;
        [newAngle, newPitch, newRoll] = r.ToEulerAngle();

        A_SetAngle(newAngle, SPF_Interpolate);
        A_SetPitch(newPitch, SPF_Interpolate);
        A_SetRoll(newRoll, SPF_Interpolate);
    }


    virtual double, double, double TweakSpeeds3(double forward, double side, double up)
    {
        [forward, side] = TweakSpeeds(forward, side);

        up *= upMove;

        return forward, side, up;
    }


    virtual double CmdScale()
    {
        //bool canStraferun = CVar.FindCVar(trichordingCVar).GetBool();
        //if (canStraferun) return speed;

		UserCmd cmd = player.cmd;
        double fm = double(cmd.forwardMove) / maxForwardMove;
        double sm = double(cmd.sideMove) / maxSideMove;
        double um = double(cmd.upMove) / maxUpMove;

        double maxCmd = Max(Abs(fm), Abs(sm), Abs(um));
        double total = (fm, sm, um).Length();

        double scale = total ? speed * maxCmd / total : 0;

        return scale;
    }


    virtual void Accelerate(Vector3 wishDir, double wishSpeed, double accel)
    {
        double currentSpeed = vel dot wishDir;

        double addSpeed = wishSpeed - currentSpeed;
        if (addSpeed <= 0) return;

        double accelSpeed = Min(accel * wishSpeed, addSpeed);

        vel += accelSpeed * wishDir;
    }


    virtual void BobAccelerate(Vector3 wishDir, double wishSpeed, double accel)
    {
        double currentSpeed = player.vel dot wishDir.xy;

        double addSpeed = wishSpeed - currentSpeed;
        if (addSpeed <= 0) return;

        double accelSpeed = Clamp(accel * wishSpeed, 0, addSpeed);

        player.vel += accelSpeed * wishDir.xy;
    }


    Vector3, Vector3, Vector3 GetAxes()
    {
        Quaternion r;
        r.FromEulerAngle(angle, pitch, roll);

        Vector3 forward = (1, 0, 0);
        forward = r.Rotate(forward);

        Vector3 right = (0, -1, 0);
        right = r.Rotate(right);

        Vector3 up = (0, 0, 1);
        up = r.Rotate(up);

        return forward, right, up;
    }


    bool IsPressed(int bt)
    {
        return player.cmd.buttons & bt;
    }

    bool JustPressed(int bt)
    {
        return (player.cmd.buttons & bt) && !(player.oldButtons & bt);
    }
}
