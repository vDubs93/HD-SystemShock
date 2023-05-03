Class Map01 : Actor {
	Default {
		Radius 13;
		Height 112;
		
		
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