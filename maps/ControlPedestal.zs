Class ControlPedestal : Actor {
	Default {
		Radius 32;
		Height 144;
		
		
		+SOLID
		+INVULNERABLE
		+NODAMAGE
		+SHOOTABLE
		+NOTAUTOAIMED
		+NEVERTARGET
		+DONTTHRUST
	}

	States {
		Spawn:
			PLAY A -1;
			Stop;
	}
}