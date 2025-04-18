shader_type spatial;
render_mode vertex_lighting, shadows_disabled, world_vertex_coords;

uniform sampler2D text;
uniform sampler2D noise;

float quantize(float val, float steps) {
  return floor(val / (1.0 / steps)) * (1.0 / steps);
}

void vertex() {
  float timeScaled = TIME * .3;
  vec2 uv = VERTEX.xy + quantize(mod(timeScaled,300.0),15.0);
  vec4 offset = texture(noise, uv);
	VERTEX = VERTEX + vec3(offset.x,0.0,offset.z) * .05;
}

void fragment() {
	ALBEDO = texture(text,UV).rgb * COLOR.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
