class explosion1 : HDActor
{
	default
	{
		scale 0.3;
		+FORCEXYBILLBOARD;
		-SOLID;
		-SHOOTABLE;
		+NOGRAVITY;
	}
	states
	{
		spawn:
			EXPL ABCGHI 4 bright;
			stop;
	}
}

class cpuexplosion : explosion1
{
	default
	{
		scale 0.7;
		
	}
	states
	{
		spawn:
			EXPL MNO 4 bright;
			EXPL P 4 bright;
			EXPL QR 4 bright;
			stop;
	
	}
}