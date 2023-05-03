class SS1FlatPickup : HDPickup
{	
	int currRoll;
	default
	{
		scale 0.3;
		+FLATSPRITE
	}

	override void postbeginplay()
	{
		currRoll = random(0, 360);
		AlignToPlane(self, currRoll);
	}
	
	override void OnDrop(Actor dropper)
	{
		//AlignToPlane(self);
		angle = 0;
		currRoll = dropper.angle;
		roll = dropper.angle;
		pitch = 0;
		super.OnDrop(dropper);
	}
	
	override void tick()
	{
		
		if (pos.z == GetZAt())
			AlignToPlane(self, currRoll);
		super.tick();
	}
	static void AlignToPlane(Actor self, int roll){
		if (!self)
			return;
		Vector3 fnormal = self.CurSector.FloorPlane.Normal;
		Vector2 fnormalp1 = ((fnormal.x, fnormal.y).Length(), fnormal.z);
		double fang = atan2(fnormal.y, fnormal.x);
		double fpitch = atan2(fnormalp1.x, fnormalp1.y);
		self.pitch = fpitch;
		self.angle = fang;
		self.roll = roll - fang;
	}
}