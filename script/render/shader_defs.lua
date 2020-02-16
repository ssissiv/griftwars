local effects =
{
	desaturation = 
	[[
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		vec4 pixel = Texel(texture, texture_coords );
		number average = (pixel.r+pixel.b+pixel.g)/3.0;
		pixel.r = average;
		pixel.g = average;
		pixel.b = average;
  		return pixel;
	}
	]],

	maptile = 
	[[
	uniform float saturation = 1.0;
	uniform float brightness = 0.0;

	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{
		vec4 pixel = Texel( texture, texture_coords ) * color;

		pixel.rgb += brightness * 2 - 1;
		float intensity = dot( pixel.rgb, vec3( 0.299, 0.587, 0.114 ));
		pixel.rgb = mix( vec3( intensity, intensity, intensity ), pixel.rgb, saturation * 2.0 );
		return pixel;
	}
	]]
}



for k, v in pairs( effects ) do
	effects[k] = love.graphics.newShader( v )
end

strictify( effects )

return effects
