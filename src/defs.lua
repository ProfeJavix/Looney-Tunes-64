---@class _G
---@field charSelect? table
---@field charSelectExists? boolean

---@class Object
---@field oOwner integer

---@class LTData
---@field id string
---@field name string
---@field description string
---@field author? string
---@field menuColor string
---@field model ModelExtendedId
---@field charType? CharacterType
---@field camScale? number
---@field palettes? PaletteData[]
---@field animData? AnimData
---@field voices? table
---@field replaceActs? ReplaceActInfo
---@field hasPowerMeter? boolean

---@class PaletteData
---@field palette table
---@field name? string

---@class AnimData
---@field animTable? table
---@field eyeTable? table
---@field handTable? table

---@class ReplaceActInfo
---@field acts integer[]
---@field actsSet? table
---@field param? fun(m: MarioState, incAct: integer): integer
---@field canGrab? fun(m: MarioState): boolean

local playerTable = gPlayerSyncTable

for i = 0, MAX_PLAYERS - 1 do
    playerTable[i].blockCTActsTimer = 0
end

PREVENT_ACT_FLAGS = (
	ACT_FLAG_INVULNERABLE |
	ACT_FLAG_THROWING |
	ACT_FLAG_RIDING_SHELL |
	ACT_FLAG_SWIMMING_OR_FLYING |
	ACT_FLAG_BUTT_OR_STOMACH_SLIDE
)

PREVENT_ACT_GROUPS = {
    [ACT_GROUP_CUTSCENE] = true,
    [ACT_GROUP_SUBMERGED] = true,
	[ACT_GROUP_AUTOMATIC] = true
}

ACT_BUGS_LOLA_HOVER = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)
ACT_BUGS_DIVE_POUND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_BUGS_MOVE_UNDERGROUND = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_INTANGIBLE)
ACT_DAFFY_POUND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_DAFFY_POUND_LAND = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY | ACT_FLAG_ATTACKING)
ACT_DAFFY_POUND_BOUNCE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_DAFFY_MALLET_SWING = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)
ACT_DAFFY_MALLET_POUND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_DAFFY_MALLET_POUND_LAND = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY | ACT_FLAG_ATTACKING)
ACT_ELMER_SHOOT_SHOTGUN = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ACT_ELMER_AIR_SHOOT_SHOTGUN = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
ACT_SYLVESTER_TWEETY_GLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)
ACT_SYLVESTER_TWEETY_FIGHT = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_INTANGIBLE)
ACT_SYLVESTER_WALL_CRAWL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)
ACT_MARVIN_SHOOT_LASER = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ACT_MARVIN_AIR_SHOOT_LASER = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
ACT_MARVIN_GRAB_TNT = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY)
ACT_TAZ_TORNADO_START = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY)
ACT_TAZ_TORNADO_ATTACK = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)
ACT_CAUGHT_IN_TAZ_TORNADO = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_INVULNERABLE)
ACT_FOGHORN_SLAP_CHARGE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ACT_FOGHORN_SLAP_RELEASE = allocate_mario_action(ACT_GROUP_STATIONARY | ACT_FLAG_STATIONARY)
ACT_SLAPPED_BY_FOGHORN = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_INVULNERABLE | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_SAM_SHOOT_PISTOL = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)
ACT_SAM_AIR_SHOOT_PISTOL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
ACT_SAM_SHOULDER_BASH = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ATTACKING)
ACT_WILE_AIR_WALK = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_WILE_ROCKET_EXPLODE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_INVULNERABLE | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_WILE_ROCKET_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)

E_MODEL_BUGS_DIRT_HOLE = smlua_model_util_get_id('bugs_dirt_hole_geo')
E_MODEL_TWEETY = smlua_model_util_get_id('sylvester_tweety_geo')
E_MODEL_MARVIN_LASER = smlua_model_util_get_id('marvin_laser_geo')
E_MODEL_MARVIN_TNT = smlua_model_util_get_id('marvin_tnt_geo')
E_MODEL_EXPLOSION_KABOOM = smlua_model_util_get_id('explosion_kaboom_geo')
E_MODEL_BASKET_BALL = smlua_model_util_get_id('basket_ball_geo')

ANIM_BUGS_CS_MENU = 'bugs_cs_menu'
ANIM_DAFFY_CS_MENU = 'daffy_cs_menu'
ANIM_DAFFY_MALLET_SWING = 'daffy_mallet_swing'
ANIM_DAFFY_MALLET_POUND = 'daffy_mallet_pound'
ANIM_PORKY_CS_MENU = 'porky_cs_menu'
ANIM_ELMER_CS_MENU = 'elmer_cs_menu'
ANIM_ELMER_SHOOT_SHOTGUN = 'elmer_shoot_shotgun'
ANIM_ELMER_SHOOT_SHOTGUN_AIR = 'elmer_shoot_shotgun_air'
ANIM_ELMER_SHOOT_SHOTGUN_SLIDE = 'elmer_shoot_shotgun_slide'
ANIM_SYLVESTER_CS_MENU = 'sylvester_cs_menu'
ANIM_SYLVESTER_TWEETY_FLYING = 'tweety_flying'
ANIM_MARVIN_CS_MENU = 'marvin_cs_menu'
ANIM_MARVIN_GRAB_TNT = 'marvin_grab_tnt'
ANIM_MARVIN_SHOOT_LASER = 'marvin_shoot_laser'
ANIM_MARVIN_SHOOT_LASER_AIR = 'marvin_shoot_laser_air'
ANIM_TAZ_CS_MENU = 'taz_cs_menu'
ANIM_TAZ_TORNADO_START = 'taz_tornado_start'
ANIM_FOGHORN_CS_MENU = 'foghorn_cs_menu'
ANIM_FOGHORN_SLAP_CHARGE = 'foghorn_slap_charge'
ANIM_FOGHORN_SLAP_CHARGE_TIPTOE = 'foghorn_slap_charge_tiptoe'
ANIM_FOGHORN_SLAP_RELEASE = 'foghorn_slap_release'
ANIM_FOGHORN_SLAP_START = 'foghorn_slap_start'
ANIM_LOLA_CS_MENU = 'lola_cs_menu'
ANIM_SAM_CS_MENU = 'sam_cs_menu'
ANIM_SAM_UNHOLSTER = 'sam_unholster'
ANIM_SAM_HOLSTER = 'sam_holster'
ANIM_SAM_SHOOT_LEFT = 'sam_shoot_left'
ANIM_SAM_SHOOT_RIGHT = 'sam_shoot_right'
ANIM_SAM_SHOOT_DOWN = 'sam_shoot_down'
ANIM_SAM_BASH_START = 'sam_bash_start'
ANIM_SAM_BASH_RUN = 'sam_bash_run'
ANIM_WILE_CS_MENU = 'wile_cs_menu'
ANIM_WILE_ROCKET_JUMP_START = 'wile_rocket_jump_start'
ANIM_WILE_IN_AIR_REALIZATION = 'wile_in_air_realization'

define_custom_obj_fields({
    oOwner = "s32"
})

function geo_switch_lt_common(node)
    local gn = cast_graph_node(node)
    local curM = geo_get_mario_state()

    local caseFuncs = {
        [CT_DAFFY] = function (m, _, _)
            if m.action == ACT_DAFFY_MALLET_SWING or
            m.action == ACT_DAFFY_MALLET_POUND or
            m.action == ACT_DAFFY_MALLET_POUND_LAND then
                return 1
            end
        end,
        [CT_ELMER] = function (m, _, _)
            if m.action == ACT_ELMER_SHOOT_SHOTGUN or m.action == ACT_ELMER_AIR_SHOOT_SHOTGUN then
                return 1
            end
        end,
        [CT_MARVIN] = function (m, _, _)
            if m.action == ACT_MARVIN_SHOOT_LASER or m.action == ACT_MARVIN_AIR_SHOOT_LASER then
                return 1
            end
        end,
        [CT_SAM] = function (m, param, frame)
            if (m.action == ACT_SAM_SHOOT_PISTOL and (m.actionArg ~= 0 or frame > 15)) or m.action == ACT_SAM_AIR_SHOOT_PISTOL then
                return 1
            end
        end,
        [CT_WILE] = function (m, _, _)
            if m.action == ACT_WILE_ROCKET_JUMP then
                return 1
            end
        end
    }

    local ctFunc = caseFuncs[_G.charSelect.character_get_current_number(curM.playerIndex)]
    if ctFunc then
        gn.selectedCase = ctFunc(curM, gn.parameter, curM.marioObj.header.gfx.animInfo.animFrame) or 0
    else
        gn.selectedCase = 0
    end
end

function geo_rotate_ears(node)
    local gn = cast_graph_node(node)
    local rot = cast_graph_node(node.next)
    local m = geo_get_mario_state()

    if m.action == ACT_BUGS_LOLA_HOVER and m.actionState == 1 then
        if gn.parameter == 1 then
            rot.rotation.x = 0x2500
        end
        rot.rotation.y = rot.rotation.y + 0x4000
    else
        rot.rotation.x = 0
        rot.rotation.y = ternary(gn.parameter == 0, 0x8000, 0)
    end
end

---@param node GraphNode
function geo_switch_bugs_dirt(node)
    local gn = cast_graph_node(node)
    local o = geo_get_current_object()

    gn.selectedCase = ternary(o.oForwardVel == 0, 0, 1)
end

function geo_tornado_switch(node)
    local gn = cast_graph_node(node)
    local m = geo_get_mario_state()
    if m.action == ACT_TAZ_TORNADO_ATTACK then
        gn.selectedCase = ternary(m.marioBodyState.modelState & MODEL_STATE_METAL ~= 0, 5, 4)
    else
        gn.selectedCase = m.marioBodyState.modelState >> 8
    end
end