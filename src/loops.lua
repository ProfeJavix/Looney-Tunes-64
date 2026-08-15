local nps = gNetworkPlayers
local states = gMarioStates

local loops = {}

---@param o Object
function loops.bhv_helicopter_ears_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

---@param o Object
function loops.bhv_helicopter_ears_loop(o)
    local m = states[getLocalFromGlobalIdx(o.oOwner)]

    if not m or m.action ~= ACT_BUGS_HOVER then
        obj_mark_for_deletion(o)
        return
    end

    o.oAction = m.marioBodyState.modelState >> 8
    o.oOpacity = ternary(m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA ~= 0, 100, 255)

    o.oPosX = m.pos.x
    o.oPosY = m.pos.y + 132
    o.oPosZ = m.pos.z
    obj_set_gfx_pos_from_pos(o)

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x2000
end

---@param o Object
function loops.bhv_marvin_laser_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

---@param o Object
function loops.bhv_marvin_laser_loop(o)
    cur_obj_scale(5)
end

---@param m MarioState
function loops.act_bugs_hover(m)

    if m.input & INPUT_B_PRESSED ~= 0 then
        return set_mario_action(m, ACT_DIVE, 0)
    end

    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0)
    end

    play_mario_sound(m, SOUND_ACTION_TERRAIN_JUMP, CHAR_SOUND_YAHOO)

    common_air_action_step(m, ACT_TRIPLE_JUMP_LAND, ternary(m.actionState == 0, CHAR_ANIM_TRIPLE_JUMP, CHAR_ANIM_GENERAL_FALL), 0)

    if m.action == ACT_TRIPLE_JUMP_LAND then
        queue_rumble_data_mario(m, 5, 40)
        return 1
    end

    if m.actionState == 0 then
        if m.vel.y <= -20 then
            m.actionState = 1
        end

        play_flip_sounds(m, 2, 8, 20)
    elseif m.actionState == 1 then
        if m.playerIndex == 0 and m.actionArg == 0 then
            spawn_sync_object(id_bhvHelicopterEars, E_MODEL_BUGS_EARS, m.pos.x, m.pos.y, m.pos.z, function(o)
                o.oOwner = nps[0].globalIndex
            end)
            m.actionArg = 1
        end

        m.marioBodyState.allowPartRotation = 1
        m.marioBodyState.headAngle.x = -0x2000

        m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x200)
        m.vel.y = -8
        m.peakHeight = m.pos.y

        if m.actionTimer > 15 and m.controller.buttonDown & A_BUTTON == 0 then
            return set_mario_action(m, ACT_FREEFALL, 0)
        end
        m.actionTimer = m.actionTimer + 1

        if m.actionTimer % 3 ~= 0 then
            play_sound(SOUND_ACTION_BRUSH_HAIR, m.marioObj.header.gfx.cameraToObject)
        end
    end
end

return loops