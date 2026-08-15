const GeoLayout bugs_ears_EarsSwitch_opt1[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ASM(0, geo_update_layer_transparency),
		GEO_ANIMATED_PART(LAYER_TRANSPARENT, 0, 0, 0, bugs_ears_Bone_mesh_layer_1),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout bugs_ears_EarsSwitch_opt2[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ANIMATED_PART(LAYER_OPAQUE, 0, 0, 0, bugs_ears_Bone_mesh_layer_1_mat_override_Metal__METAL__0),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout bugs_ears_EarsSwitch_opt3[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ASM(0, geo_update_layer_transparency),
		GEO_ANIMATED_PART(LAYER_TRANSPARENT, 0, 0, 0, bugs_ears_Bone_mesh_layer_1_mat_override_Metal__METAL__1),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout bugs_ears_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_SWITCH_CASE(0, geo_switch_ears_state),
		GEO_OPEN_NODE(),
			GEO_NODE_START(),
			GEO_OPEN_NODE(),
				GEO_ANIMATED_PART(LAYER_OPAQUE, 0, 0, 0, bugs_ears_Bone_mesh_layer_1),
			GEO_CLOSE_NODE(),
			GEO_BRANCH(1, bugs_ears_EarsSwitch_opt1),
			GEO_BRANCH(1, bugs_ears_EarsSwitch_opt2),
			GEO_BRANCH(1, bugs_ears_EarsSwitch_opt3),
		GEO_CLOSE_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, bugs_ears_material_revert_render_settings),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, bugs_ears_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
