shader_type canvas_item;

void vertex() {
	
}

void fragment() {
  vec2 dist = abs(UV - 0.5);
  
	COLOR = vec4(1.0, 0.0, 0.0, max(dist.x,dist.y)*0.3);
}
