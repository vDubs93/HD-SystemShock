
vec3 brightnessContrast(vec3 value, float brightness, float contrast)
{
    return (value - 0.5) * contrast + 0.5 + brightness;
}

void main() {
	vec4 c = texture(InputTexture, TexCoord);
	c.xyz = brightnessContrast(c.xyz, .0025 * multiplier, .75 * multiplier);
	FragColor = c;
}
