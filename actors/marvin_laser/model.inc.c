Lights1 marvin_laser_f3dlite_material_lights = gdSPDefLights1(
	0xB2, 0xFF, 0x9E,
	0x1E, 0xFF, 0x0, 0x28, 0x28, 0x28);

Vtx marvin_laser_laserDL_mesh_layer_1_vtx_0[14] = {
	{{{-2, -7, -4}, 0, {752, 506}, {0xBA, 0x00, 0x96, 0xFF}}},
	{{{-2, -12, 4}, 0, {965, 875}, {0xBA, 0xA4, 0x35, 0xFF}}},
	{{{-2, -3, 4}, 0, {539, 875}, {0xBA, 0x5C, 0x35, 0xFF}}},
	{{{144, -12, 4}, 0, {453, 875}, {0x46, 0xA4, 0x35, 0xFF}}},
	{{{144, -7, -4}, 0, {240, 506}, {0x46, 0x00, 0x96, 0xFF}}},
	{{{144, -3, 4}, 0, {27, 875}, {0x46, 0x5C, 0x35, 0xFF}}},
	{{{-2, -7, -4}, 0, {1008, 496}, {0xBA, 0x00, 0x96, 0xFF}}},
	{{{144, -7, -4}, 0, {1008, -16}, {0x46, 0x00, 0x96, 0xFF}}},
	{{{144, -12, 4}, 0, {667, -16}, {0x46, 0xA4, 0x35, 0xFF}}},
	{{{-2, -12, 4}, 0, {667, 496}, {0xBA, 0xA4, 0x35, 0xFF}}},
	{{{144, -3, 4}, 0, {325, -16}, {0x46, 0x5C, 0x35, 0xFF}}},
	{{{-2, -3, 4}, 0, {325, 496}, {0xBA, 0x5C, 0x35, 0xFF}}},
	{{{144, -7, -4}, 0, {-16, -16}, {0x46, 0x00, 0x96, 0xFF}}},
	{{{-2, -7, -4}, 0, {-16, 496}, {0xBA, 0x00, 0x96, 0xFF}}},
};

Gfx marvin_laser_laserDL_mesh_layer_1_tri_0[] = {
	gsSPVertex(marvin_laser_laserDL_mesh_layer_1_vtx_0 + 0, 14, 0),
	gsSP2Triangles(0, 1, 2, 0, 3, 4, 5, 0),
	gsSP2Triangles(6, 7, 8, 0, 6, 8, 9, 0),
	gsSP2Triangles(9, 8, 10, 0, 9, 10, 11, 0),
	gsSP2Triangles(11, 10, 12, 0, 11, 12, 13, 0),
	gsSPEndDisplayList(),
};


Gfx mat_marvin_laser_f3dlite_material[] = {
	gsSPSetLights1(marvin_laser_f3dlite_material_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPEndDisplayList(),
};

Gfx mat_revert_marvin_laser_f3dlite_material[] = {
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx marvin_laser_laserDL_mesh_layer_1[] = {
	gsSPDisplayList(mat_marvin_laser_f3dlite_material),
	gsSPDisplayList(marvin_laser_laserDL_mesh_layer_1_tri_0),
	gsSPDisplayList(mat_revert_marvin_laser_f3dlite_material),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

