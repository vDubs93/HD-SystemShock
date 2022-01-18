void main()
{
	vec4 c = texture(InputTexture, TexCoord);

	vec2 U = c.xy / textureSize(InputTexture, 0);
	vec2 z = TexCoord /textureSize(InputTexture, 0);                                // normalized coordinates
         U = (U+U - z) / z.y;
    
	z = U - vec2(-1,0);  U.x += .2; U.y += .2;                        // Moebius transform
    U *= mat2(z,-z.y,z.x) / dot(U,U);
    length(U+=.5);  // offset. not included as length(U+=.5) because of an ATI bug
    
                     //  spiral, zoom       phase     // spiraling
    U =   log(length(U))*vec2(.5, -.5) + timer/8
        + atan(U.y, U.x)/6.3 * vec2(5, 1);        
	                                 // n  
  //c += length(fract(U*3.)) -c;
  //c  = texture(InputTexture, fract(U*3.));  // U*1. is also nice
  //c += length(sin(U*30.)) -c;
   c = .5+.5*sin(6.*3.14159*U.y+vec4(0,2.1,-2.1,0));
	c += abs(sin(timer));
	
	FragColor = c;
}

