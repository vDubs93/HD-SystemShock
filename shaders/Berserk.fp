void rainbowSwirls(){
    vec4 c = texture(InputTexture, TexCoord);

	vec2 U = c.xy / textureSize(InputTexture, 0);
	vec2 z = TexCoord /textureSize(InputTexture, 0);
	U = (U + U - z) / z.y;
	//z = U - vec2(-1,0);  U.x -= .25;                         // Moebius transform
    //U *= mat2(z,-z.y,z.x) / dot(U,U);
    U+=.5;  // offset. not included as length(U+=.5) because of an ATI bug
    
                     //  spiral, zoom       phase     // spiraling
    U =   log(length(U))*vec2(.5, -.5) + mod(timer/64., 20)
        + atan(U.y, U.x)/6.3 * vec2(5, 1);
	                                 // n

  //c += length(fract(U*3.)) -O;
  //c  = texture(iChannel0, fract(U*3.));  // U*1. is also nice
  //c += length(sin(U*30.)) -O;
    c = .5+.5*sin(6.*3.14159*U.y+vec4(0,2.1,-2.1,0));
                 // try also U.x
  //c /= max(O.x,max(O.y,O.z)); // saturates the rainbow
	FragColor = c;
}

float random (vec2 st) {
    return fract(dot(st.xy,
                         vec2(12.9898,78.233))*
        43758.5453123);
}

void main() {
	vec4 c = texture(InputTexture, TexCoord);
	vec2 U = c.xy / textureSize(InputTexture, 0);
	int modParam = 50;
	if (mod(ceil(timer/64), 50) == 0)
		modParam = 51;
	float time = mod(ceil(timer/64), modParam);
	c = vec4(sin(time/c.x), sin(time/c.y), sin(time/c.z), sin(time/c.w));
	FragColor = c;
}

