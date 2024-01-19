shader_type spatial;

////float offset = rand_from_seed(VERTEX_ID);
//float rand_from_seed(inout uint seed) {
    //int k;
    //int s = int(seed);
    //if (s == 0)
    //s = 305420679;
    //k = s / 127773;
    //s = 16807 * (s - k * 127773) - 2836 * k;
    //if (s < 0)
        //s += 2147483647;
    //seed = uint(s);
    //return float(seed % uint(65536)) / 65535.0;
//}
//
//uint hash(uint x) {
    //x = ((x >> uint(16)) ^ x) * uint(73244475);
    //x = ((x >> uint(16)) ^ x) * uint(73244475);
    //x = (x >> uint(16)) ^ x;
    //return x;
//}

void vertex() {
	//uint seed = hash(uint(abs(1000.0 * VERTEX.x + VERTEX.y + VERTEX.z)));
	//VERTEX = VERTEX * (1.0 + (pow(sin(TIME + (rand_from_seed(seed) * PI * 2.0)), 5.0) * 1.5));
	
	VERTEX = VERTEX * abs(
		sin(TIME + abs(8.0 + (VERTEX.x * 8.0))) + 
		sin(TIME + abs(8.0 + (VERTEX.y * 8.0))) + 
		sin(TIME + abs(8.0 + (VERTEX.z * 8.0))));
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(2, 2, 2);
}


