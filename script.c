enum {
	// primitive geometry modes
	LINES,
	TRIANGLES,
	QUADS,

	// color constants
	WHITE = 0xFFFFFFFF
};

float light_move_radius;
float light_shine_radius;
float light_angle;
vec3 light_pos;

float direction;
vec3 rotation;

int dist_to_color(float dist) {
	float percentage = (1.0 - fclamp(dist / light_shine_radius, 0.0, 1.0)) * 255.0;

	int byte = percentage;
	
	return (byte << 24) | (byte << 16) | (byte << 8) | 0xFF;
}

void init() {
	light_move_radius = 1.5;
	light_shine_radius = 2.0;
	light_angle = 0.0;
	light_pos = v3(0.0, 0.0, 0.1);
	rotation = v3zero();
	direction = 1.0;
}

void update() {
	light_angle = (light_angle + 2.0) % 360.0;

	float asrad = rad(light_angle);
	light_pos.x = cos(asrad) * light_move_radius;
	light_pos.y = sin(asrad) * light_move_radius;

	rotation.y = rotation.y + direction;

	if (rotation.y < -45.0 || rotation.y > 45.0) {
		direction = -direction;
	}
}

void draw3d() {
	pushmatrix();
		translate(light_pos);
		
		meshbegin(QUADS);
			color(WHITE);
			texcoord(v2(0.1, 0.98));
			vertex(v3(0.0, 0.05, 0.0));

			texcoord(v2(0.0, 0.99));
			vertex(v3(-0.05, 0.0, 0.0));

			texcoord(v2(0.1, 1.0));
			vertex(v3(0.0, -0.05, 0.0));
			
			texcoord(v2(0.2, 0.99));
			vertex(v3(0.05, 0.0, 0.0));
		meshend();
	popmatrix();
	
	pushmatrix();
		rotate(rotation);
		
		// draw vertex-colored textured quad
		// 
		// counter-clockwise winding order
		meshbegin(QUADS);
			// top-left
			color(dist_to_color(v3dist(light_pos, v3(-1.0, 1.0, 0.0))));
			texcoord(v2(0.0, 0.0));
			vertex(v3(-1.0, 1.0, 0.0));

			// bottom-left
			color(dist_to_color(v3dist(light_pos, v3(-1.0, -1.0, 0.0))));
			texcoord(v2(0.0, 1.0));
			vertex(v3(-1.0, -1.0, 0.0));

			// bottom-right
			color(dist_to_color(v3dist(light_pos, v3(1.0, -1.0, 0.0))));
			texcoord(v2(1.0, 1.0));
			vertex(v3(1.0, -1.0, 0.0));

			// top-right
			color(dist_to_color(v3dist(light_pos, v3(1.0, 1.0, 0.0))));
			texcoord(v2(1.0, 0.0));
			vertex(v3(1.0, 1.0, 0.0));
		meshend();
	popmatrix();
}
