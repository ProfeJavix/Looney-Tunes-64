local nps = gNetworkPlayers
local states = gMarioStates
local playerTable = gPlayerSyncTable

local acts = {}

---@param m MarioState
function acts.act_bugs_lola_hover(m)
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

---@param m MarioState
function acts.act_bugs_ground_dive_pound(m)
    m.flags = m.flags | MARIO_UNKNOWN_18
    set_character_animation(m, CHAR_ANIM_DIVE)
    play_character_sound_if_no_flag(m, CHAR_SOUND_GROUND_POUND_WAH, MARIO_MARIO_SOUND_PLAYED)
    play_sound_if_no_flag(m, SOUND_ACTION_THROW, MARIO_ACTION_SOUND_PLAYED)

    if m.actionState == 0 then
        m.vel.y = -1
        m.faceAngle.x = approach_s16_symmetric(m.faceAngle.x, 0x3555, 0x800)

        if m.faceAngle.x == 0x3555 then
            m.vel.y = -55
            m.actionState = 1
        end
    end

    update_air_without_turn(m)
    if perform_air_step(m, 0) == AIR_STEP_LANDED then
        play_sound(SOUND_OBJ2_MONTY_MOLE_APPEAR, m.marioObj.header.gfx.cameraToObject)
        spawn_non_sync_object(id_bhvBugsDirtHole, E_MODEL_BUGS_DIRT_HOLE, m.pos.x, m.pos.y, m.pos.z, function(o)
            o.oOwner = m.playerIndex
        end)
        m.vel.y = 0
        return set_mario_action(m, ACT_BUGS_MOVE_UNDERGROUND, m.actionArg)
    end

    m.marioObj.header.gfx.angle.x = m.faceAngle.x
end

---@param m MarioState
function acts.act_bugs_move_underground(m)
    m.squishTimer = 0xFF
    m.invincTimer = -1
    cur_obj_scale(0)

    if m.input & INPUT_UNKNOWN_10 ~= 0 then
        return set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if m.forwardVel > 5 and get_global_timer() % 5 == 0 then
        play_sound(SOUND_MOVING_TERRAIN_SLIDE, m.marioObj.header.gfx.cameraToObject)
        for _ = 1, 3 do
            local pos = {
                x = m.pos.x + random_sign() * math.random(0, 60),
                y = m.pos.y,
                z = m.pos.z + random_sign() * math.random(0, 60)
            }
            spawn_non_sync_object(id_bhvDirtParticleSpawner, E_MODEL_DIRT_ANIMATION, pos.x, pos.y, pos.z, function() end)
        end
    end

    m.forwardVel = approach_f32_symmetric(m.forwardVel, 60 * m.intendedMag / 8, 3)
    m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x600)
    mario_set_forward_vel(m, m.forwardVel)

    local step = perform_ground_step(m)
    if step == GROUND_STEP_LEFT_GROUND then
        mario_set_forward_vel(m, math.min(m.forwardVel, 20))
        return set_mario_action(m, ACT_FREEFALL, 0)
    elseif m.controller.buttonPressed & A_BUTTON ~= 0 then
        return set_mario_action(m, ACT_JUMP, 0)
    elseif step == GROUND_STEP_HIT_WALL then
        mario_set_forward_vel(m, 0)
    end
end

---@param m MarioState
function acts.act_daffy_pound(m)
    set_character_animation(m, CHAR_ANIM_GROUND_POUND)

    if m.actionState == 0 then
        m.peakHeight = m.pos.y
        m.vel.y = -60

        if is_anim_at_end(m) ~= 0 then
            m.actionState = 1
        end
    else
        update_air_with_turn(m)
        if perform_air_step(m, 0) == AIR_STEP_LANDED then
            if check_fall_damage_or_get_stuck(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
                if m.playerIndex == 0 then
                    set_camera_shake_from_hit(SHAKE_GROUND_POUND)
                end
            elseif m.action ~= ACT_HARD_BACKWARD_GROUND_KB then
                queue_rumble_data_mario(m, 5, 80)
                set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
                play_character_sound(m, CHAR_SOUND_OOOF2)
                return set_mario_action(m, ACT_BUTT_STUCK_IN_GROUND, 0)
            end

            play_mario_heavy_landing_sound(m, SOUND_ACTION_TERRAIN_HEAVY_LANDING)
            if m.action ~= ACT_HARD_BACKWARD_GROUND_KB then
                set_mario_particle_flags(m, (PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR), 0)
                return set_mario_action(m, ACT_DAFFY_POUND_LAND, m.actionArg)
            end
        end
    end
end

---@param m MarioState
function acts.act_daffy_pound_land(m)
    if m.input & INPUT_UNKNOWN_10 ~= 0 then
        return set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if m.input & INPUT_ABOVE_SLIDE ~= 0 then
        return set_mario_action(m, ACT_BUTT_SLIDE, 0)
    end

    if m.actionTimer > 3 and m.actionArg == 0 then
        m.vel.y = 50
        return set_mario_action(m, ACT_DAFFY_POUND_BOUNCE, 0)
    end
    m.actionTimer = m.actionTimer + 1

    local fVel = m.forwardVel
    landing_step(m, CHAR_ANIM_GROUND_POUND_LANDING, ACT_BUTT_SLIDE_STOP)
    m.forwardVel = fVel
end

---@param m MarioState
function acts.act_daffy_pound_bounce(m)
    play_character_sound_if_no_flag(m, CHAR_SOUND_GROUND_POUND_WAH, MARIO_MARIO_SOUND_PLAYED)

    if m.vel.y < 30 and m.controller.buttonDown & Z_TRIG ~= 0 then
        m.actionArg = 1
    end

    if m.vel.y < 10 and m.actionArg == 1 then
        return set_mario_action(m, ACT_DAFFY_POUND, 0)
    end

    update_air_with_turn(m)
    common_air_action_step(m, ACT_DOUBLE_JUMP_LAND, CHAR_ANIM_DOUBLE_JUMP_RISE, AIR_STEP_CHECK_LEDGE_GRAB | AIR_STEP_CHECK_HANG)
end

---@param m MarioState
function acts.act_daffy_mallet_swing(m)

    if should_begin_sliding(m) ~= 0 then
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
    end

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if mario_check_object_grab(m) ~= 0 then
        set_character_animation(m, CHAR_ANIM_FIRST_PUNCH)
        set_anim_to_frame(m, 0)
        return 1
    end

    play_character_sound_if_no_flag(m, CHAR_SOUND_PUNCH_WAH, MARIO_MARIO_SOUND_PLAYED)
    set_character_anim_with_accel(m, CHAR_ANIM_FIRST_PUNCH_FAST, 0x10000 * 2.9)

    local frame = m.marioObj.header.gfx.animInfo.animFrame

    if frame > 3 then
        affectAllObjects(m.marioObj, function(att, vic)
            if dist_between_objects(att, vic) < 220 and vic.oInteractType ~= INTERACT_GRABBABLE then
                local angleToVic = obj_angle_to_object(att, vic)
                local startAngle = m.faceAngle.y

                if frame < 12 then
                    startAngle = math.s16(startAngle + 0x71C)
                elseif frame < 22 then
                    startAngle = math.s16(startAngle - 0x1C71)
                else
                    startAngle = math.s16(startAngle - 0x4000)
                end

                local angleDiff = abs_angle_diff(angleToVic, startAngle)

                if angleDiff <= 0x38E3 and math.s16(startAngle + angleDiff) == angleToVic then
                    play_sound(SOUND_ACTION_HIT, vic.header.gfx.cameraToObject)

                    if obj_has_behavior_id(vic, id_bhvMario) ~= 0 then
                        local nm = states[vic.oBehParams - 1]
                        local act = 0
                        if abs_angle_diff(angleToVic, nm.faceAngle.y) > 0x4000 then
                            act = ternary(nm.floorHeight == nm.pos.y, ACT_HARD_BACKWARD_GROUND_KB,
                                ACT_HARD_BACKWARD_AIR_KB)
                            nm.faceAngle.y = math.s16(angleToVic - 0x8000)
                        else
                            act = ternary(nm.floorHeight == nm.pos.y, ACT_HARD_FORWARD_GROUND_KB, ACT_HARD_FORWARD_AIR_KB)
                            nm.faceAngle.y = angleToVic
                        end

                        hurt_and_set_mario_action(nm, act, 0, 8)
                        nm.invincTimer = 20
                    else
                        return true
                    end
                end
            end
            return false
        end)

        if frame > 15 and m.controller.buttonPressed & B_BUTTON ~= 0 then
            m.actionArg = 1
        end
    end

    mario_set_forward_vel(m, approach_f32_symmetric(m.forwardVel, 0, 1))
    perform_ground_step(m)

    if is_anim_at_end(m) ~= 0 then
        return set_mario_action(m, ternary(m.actionArg == 0, ACT_IDLE, ACT_DAFFY_MALLET_POUND), 0)
    end
end

---@param m MarioState
function acts.act_daffy_mallet_pound(m)
    play_character_sound_if_no_flag(m, CHAR_SOUND_HERE_WE_GO, MARIO_MARIO_SOUND_PLAYED)
    set_character_anim_with_accel(m, CHAR_ANIM_SECOND_PUNCH, 0x10000 * ternary(m.marioObj.header.gfx.animInfo.animFrame < 12, 1, 1.6))

    if m.actionState == 0 then
        m.vel.y = 30
        m.actionState = 1
    end

    update_air_with_turn(m)

    local frame = m.marioObj.header.gfx.animInfo.animFrame

    local poundPos = {
        x = m.pos.x + 130 * sins(m.faceAngle.y),
        y = m.pos.y,
        z = m.pos.z + 130 * coss(m.faceAngle.y)
    }

    if frame >= 15 then
        affectAllObjects(m.marioObj, function(att, vic)
            if dist_between_object_and_point(vic, poundPos.x, vic.oPosY, poundPos.z) < 300 and
            math.abs(poundPos.y - vic.oPosY) < 80 then
                play_sound(SOUND_ACTION_HIT_3, vic.header.gfx.cameraToObject)
                if obj_has_behavior_id(vic, id_bhvMario) ~= 0 then
                    local nm = states[vic.oBehParams - 1]
                    local act = ternary(nm.pos.y == nm.floorHeight, ACT_HARD_BACKWARD_GROUND_KB, ACT_HARD_BACKWARD_AIR_KB)
                    hurt_and_set_mario_action(nm, act, 0, 12)
                elseif vic.oInteractType == INTERACT_BOUNCE_TOP or
                    vic.oInteractType == INTERACT_BOUNCE_TOP2 or
                    vic.oInteractType == INTERACT_KOOPA or
                    vic.oInteractType == INTERACT_BULLY then
                    vic.oInteractStatus = (ATTACK_GROUND_POUND_OR_TWIRL | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED)
                else
                    return true
                end
            end
            return false
        end)
        if frame > 20 then
            m.vel.y = -55
        end
    end

    if perform_air_step(m, 0) == AIR_STEP_LANDED then
        play_sound(SOUND_OBJ_POUNDING_LOUD, m.marioObj.header.gfx.cameraToObject)

        spawn_non_sync_object(id_bhvHorStarParticleSpawner, E_MODEL_NONE, poundPos.x, poundPos.y, poundPos.z, function() end)
        spawn_non_sync_object(id_bhvMistCircParticleSpawner, E_MODEL_NONE, poundPos.x, poundPos.y, poundPos.z, function() end)

        if m.playerIndex == 0 then
            set_camera_shake_from_hit(SHAKE_GROUND_POUND)
        end

        return set_mario_action(m, ACT_DAFFY_MALLET_POUND_LAND, 0)
    end
end

---@param m MarioState
function acts.act_daffy_mallet_pound_land(m)
    if m.input & INPUT_UNKNOWN_10 ~= 0 then
        return set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if m.input & INPUT_ABOVE_SLIDE ~= 0 then
        return set_mario_action(m, ACT_BUTT_SLIDE, 0)
    end

    set_character_animation(m, CHAR_ANIM_SECOND_PUNCH)
    stationary_ground_step(m)

    if m.actionTimer > 5 then
        return set_mario_action(m, ACT_STOP_CROUCHING, 0)
    end
    m.actionTimer = m.actionTimer + 1
end

---@param m MarioState
function acts.act_elmer_shoot_shotgun(m)
    playerTable[m.playerIndex].blockCTActsTimer = 3

    local frame = m.marioObj.header.gfx.animInfo.animFrame
    local animID = m.marioObj.header.gfx.animInfo.animID
    local endAct = 0
    local swapAnim = false

    if animID ~= CHAR_ANIM_FIRST_PUNCH_FAST and animID ~= CHAR_ANIM_AIR_KICK then
        set_anim_to_frame(m, 0)
        frame = 0
    end

    if m.action == ACT_ELMER_SHOOT_SHOTGUN then
        if should_begin_sliding(m) ~= 0 then
            return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
        end

        if mario_check_object_grab(m) ~= 0 then
            set_character_animation(m, CHAR_ANIM_FIRST_PUNCH)
            set_anim_to_frame(m, 0)
            return 1
        end

        animID = CHAR_ANIM_FIRST_PUNCH_FAST
        if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_AIR_KICK then
            swapAnim = true
        end
        endAct = ACT_IDLE

        if m.forwardVel >= 0 then
            apply_slope_decel(m, 0.5)
        else
            m.forwardVel = approach_f32_symmetric(m.forwardVel, 0, 8)
            apply_slope_accel(m)
        end

        local step = perform_ground_step(m)
        if step == GROUND_STEP_LEFT_GROUND then
            set_mario_action(m, ACT_ELMER_AIR_SHOOT_SHOTGUN, m.actionArg)
            set_anim_to_frame(m, frame)
            return 1
        elseif step == GROUND_STEP_NONE and m.forwardVel ~= 0 then
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
        end
    else
        animID = CHAR_ANIM_AIR_KICK
        if m.marioObj.header.gfx.animInfo.animID == CHAR_ANIM_FIRST_PUNCH_FAST then
            swapAnim = true
        end
        endAct = ACT_FREEFALL

        update_air_without_turn(m)

        local step = perform_air_step(m, 0)
        if step == AIR_STEP_LANDED then
            if check_fall_damage_or_get_stuck(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
                set_mario_action(m, ACT_ELMER_SHOOT_SHOTGUN, m.actionArg)
                set_anim_to_frame(m, frame)
                return 1
            end
        end
    end

    if swapAnim then
        set_character_animation(m, animID)
        set_anim_to_frame(m, frame)
    else
        set_character_animation(m, animID)
    end

    m.marioBodyState.eyeState = ternary(frame > 6 and frame < 15, MARIO_EYES_CLOSED, MARIO_EYES_HALF_CLOSED)

    if frame == 8 then
        local bulletPos = {
            x = get_hand_foot_pos_x(m, 0) + 70 * sins(m.faceAngle.y),
            y = get_hand_foot_pos_y(m, 0),
            z = get_hand_foot_pos_z(m, 0) + 70 * coss(m.faceAngle.y)
        }
        play_sound(SOUND_OBJ_CANNON4, m.marioObj.header.gfx.cameraToObject)
        play_character_sound(m, CHAR_SOUND_UH2_2)
        spawn_non_sync_object(id_bhvSmoke, E_MODEL_SMOKE, bulletPos.x, bulletPos.y, bulletPos.z, function() end)

        if m.playerIndex == 0 and m.actionArg == 0 then
            local target, pitch = getAutoTarget(m, bulletPos, 0x1000, 1500)

            set_camera_shake_from_hit(SHAKE_FOV_UNUSED)
            spawn_sync_object(id_bhvCommonBullet, E_MODEL_BOWLING_BALL, bulletPos.x, bulletPos.y, bulletPos.z, function(o)
                o.oOwner = nps[0].globalIndex
                o.oBehParams2ndByte = 10

                if target then
                    o.oSubAction = 1
                    o.oMoveAnglePitch = pitch
                    o.oMoveAngleYaw = math.s16(obj_angle_to_point(target, bulletPos.x, bulletPos.z) - 0x8000)
                else
                    o.oMoveAnglePitch = 0
                    o.oMoveAngleYaw = m.faceAngle.y
                end
            end)

            m.actionArg = 1
        end
    end

    if is_anim_at_end(m) ~= 0 then
        return set_mario_action(m, endAct, 0)
    end
end

---@param m MarioState
function acts.act_sylvester_tweety_glide(m)

    if m.actionState == 0 then
        play_character_sound_if_no_flag(m, CHAR_SOUND_YAHOO, MARIO_MARIO_SOUND_PLAYED)
        set_character_animation(m, CHAR_ANIM_DOUBLE_JUMP_RISE)

        if m.vel.y < 20 then
            if m.controller.buttonDown & A_BUTTON == 0 then
                return set_mario_action(m, ACT_FREEFALL, 0)
            else
                m.actionState = 1
            end
        end
    else
        set_character_animation(m, CHAR_ANIM_HANG_ON_OWL)
        if m.controller.buttonDown & A_BUTTON == 0 then
            play_character_sound(m, CHAR_SOUND_UH)
            return set_mario_action(m, ACT_FREEFALL, 0)
        else
            m.peakHeight = m.pos.y
        end

        m.vel.y = m.vel.y + ternary(m.actionTimer > 90, 2, 4)
        m.actionTimer = m.actionTimer + 1
    end

    update_air_with_turn(m)
    local step = perform_air_step(m, 0)
    if m.actionState == 1 then
        if step == AIR_STEP_LANDED then
            return set_mario_action(m, ACT_WALKING, 0)
        elseif step == AIR_STEP_HIT_WALL then
            return set_mario_action(m, ACT_AIR_HIT_WALL, 0)
        end
    end
end

---@param m MarioState
function acts.act_sylvester_tweety_fight(m)

    local tweety = obj_get_first_with_behavior_id(id_bhvTweety)
    while tweety do
        if tweety.oOwner == m.playerIndex then
            break
        end

        tweety = obj_get_next_with_same_behavior_id(tweety)
    end

    if not tweety then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if m.actionState ~= 2 then
        play_character_sound_if_no_flag(m, CHAR_SOUND_PUNCH_HOO, MARIO_MARIO_SOUND_PLAYED)
        set_character_animation(m, CHAR_ANIM_DIVE)

        if m.actionState == 0 then
            local target = getAutoTarget(m, { x = tweety.oPosX, y = tweety.oPosY, z = tweety.oPosZ }, 0x10000, 1000)
            if target then
                m.usedObj = target
            end
            m.actionState = 1
        end

        if not m.usedObj or m.usedObj.activeFlags == ACTIVE_FLAG_DEACTIVATED then
            return set_mario_action(m, ACT_FREEFALL, 0)
        end

        m.faceAngle.x = obj_pitch_to_object(m.marioObj, m.usedObj)
        m.faceAngle.y = obj_angle_to_object(m.marioObj, m.usedObj)

        m.pos.y = math.max(m.floorHeight + 10, m.pos.y)

        m.forwardVel = 80
        m.vel.x = m.forwardVel * sins(m.faceAngle.y) * coss(m.faceAngle.x)
        m.vel.y = m.forwardVel * -sins(m.faceAngle.x)
        m.vel.z = m.forwardVel * coss(m.faceAngle.y) * coss(m.faceAngle.x)

        local step = perform_air_step(m, 0)
        if step == AIR_STEP_HIT_WALL then
            return set_mario_action(m, ACT_AIR_HIT_WALL, 0)
        end

        if dist_between_objects(m.marioObj, m.usedObj) < m.usedObj.hitboxRadius + 10 then
            play_character_sound(m, CHAR_SOUND_PUNCH_YAH)
            mario_set_forward_vel(m, 0)
            m.actionState = 2
        end
    else
        m.usedObj = nil
        if m.actionTimer > 20 then
            return set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        end
        m.actionTimer = m.actionTimer + 1

        m.squishTimer = 0xFF
        cur_obj_scale(0)

        affectAllObjects(m.marioObj, function (att, vic)
            if dist_between_objects(att, vic) < 300 then
                if obj_has_behavior_id(vic, id_bhvMario) ~= 0 then
                    local nm = states[vic.oBehParams - 1]
                    att.oDamageOrCoinValue = 3
                    nm.interactObj = att
                    take_damage_and_knock_back(nm, att)
                else
                    return true
                end
            end

            return false
        end)

        if m.actionTimer % 4 == 0 then
            play_sound(SOUND_ACTION_HIT, m.marioObj.header.gfx.cameraToObject)
        end

        for _ = 1, 10 do
            spawn_non_sync_object(id_bhvSylvesterFightDust, E_MODEL_MIST, m.pos.x, m.pos.y, m.pos.z, function() end)
        end
    end
end

---@param m MarioState
function acts.act_sylvester_wall_crawl(m)
    playerTable[m.playerIndex].blockCTActsTimer = 3
    m.peakHeight = m.pos.y

    if not m.wall then
        if m.actionTimer > 3 then
            m.vel.y = 20
            mario_set_forward_vel(m, 20)
            return set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        end

        m.actionTimer = m.actionTimer + 1
        mario_set_forward_vel(m, 10)
        perform_air_step(m, 0)
        m.marioObj.header.gfx.angle.x = -0x4000

        return
    end
    m.actionTimer = 0

    local curVel = m.forwardVel
    mario_set_forward_vel(m, 6)

    m.faceAngle.y = math.s16(atan2s(m.wall.normal.z, m.wall.normal.x) - 0x8000)

    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        m.faceAngle.y = m.faceAngle.y + 0x8000
        return set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    elseif m.controller.buttonPressed & Z_TRIG ~= 0 then
        m.pos.x = m.pos.x - 30 * sins(m.faceAngle.y)
        m.pos.z = m.pos.z - 30 * coss(m.faceAngle.y)
        mario_set_forward_vel(m, -20)
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    vec3f_copy(m.vel, gVec3fZero())

    if m.intendedMag > 0 then
        curVel = approach_f32_symmetric(curVel, 45 * (m.intendedMag / 64), 2)

        if math.abs(m.controller.stickX) > 0 then
            local yaw = m.faceAngle.y
            local hVel = curVel * math.abs(m.controller.stickX / 64)

            if m.controller.stickX > 0 then
                yaw = yaw - 0x3999
            elseif m.controller.stickX < 0 then
                yaw = yaw + 0x3999
            end
            yaw = math.s16(yaw)

            m.vel.x = hVel * sins(yaw)
            m.vel.z = hVel * coss(yaw)
        end

        if math.abs(m.controller.stickY) > 0 then
            m.vel.y = curVel * (m.controller.stickY / 64)
        end
    else
        curVel = 0
    end

    set_character_anim_with_accel(m, CHAR_ANIM_CRAWLING, math.clamp(curVel, 5, 20) * 0x10000)
    if curVel > 0 and m.vel ~= gVec3fZero() then
        play_step_sound(m, 26, 79)
    else
        m.marioObj.header.gfx.animInfo.animAccel = 1
        set_anim_to_frame(m, 25)
    end

    local step = perform_air_step(m, AIR_STEP_CHECK_LEDGE_GRAB)
    m.forwardVel = curVel

    if step == AIR_STEP_GRABBED_LEDGE then
        return
    elseif step == AIR_STEP_LANDED then
        return set_mario_action(m, ACT_IDLE, 0)
    end

    m.marioObj.header.gfx.pos.x = m.marioObj.header.gfx.pos.x + 55 * sins(m.faceAngle.y)
    m.marioObj.header.gfx.pos.z = m.marioObj.header.gfx.pos.z + 55 * coss(m.faceAngle.y)

    m.marioObj.header.gfx.angle.x = -0x4000
end

---@param m MarioState
function acts.act_marvin_shoot_laser(m)
    playerTable[m.playerIndex].blockCTActsTimer = 3
    set_character_animation(m, CHAR_ANIM_FIRST_PUNCH_FAST)

    local frame = m.marioObj.header.gfx.animInfo.animFrame

    if frame == 12 and m.actionArg == 0 then
        local laserPos = {
            x = get_hand_foot_pos_x(m, 0) + 35 * sins(m.faceAngle.y),
            y = get_hand_foot_pos_y(m, 0) + 5,
            z = get_hand_foot_pos_z(m, 0) + 35 * coss(m.faceAngle.y)
        }
        spawn_non_sync_object(id_bhvSmoke, E_MODEL_SMOKE, laserPos.x, laserPos.y - 20, laserPos.z, function() end)

        if m.playerIndex == 0 then
            local target, pitch = getAutoTarget(m, laserPos, 0x1200, 2000)

            spawn_sync_object(id_bhvMarvinLaser, E_MODEL_MARVIN_LASER, laserPos.x, laserPos.y, laserPos.z, function(o)
                o.oOwner = nps[0].globalIndex

                if target then
                    o.oSubAction = 1
                    o.oMoveAnglePitch = pitch
                    o.oMoveAngleYaw = math.s16(obj_angle_to_point(target, laserPos.x, laserPos.z) - 0x8000)
                else
                    o.oMoveAnglePitch = 0
                    o.oMoveAngleYaw = m.faceAngle.y
                end
            end)
            m.actionArg = 1
        end
    end

    if m.action == ACT_MARVIN_SHOOT_LASER then
        if should_begin_sliding(m) ~= 0 then
            return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
        end

        if mario_check_object_grab(m) ~= 0 then
            set_character_animation(m, CHAR_ANIM_FIRST_PUNCH)
            set_anim_to_frame(m, 0)
            return 1
        end

        if m.forwardVel >= 0 then
            apply_slope_decel(m, 0.7)
        else
            m.forwardVel = approach_f32_symmetric(m.forwardVel, 0, 8)
            apply_slope_accel(m)
        end

        local step = perform_ground_step(m)
        if step == GROUND_STEP_LEFT_GROUND then
            set_mario_action(m, ACT_MARVIN_AIR_SHOOT_LASER, m.actionArg)
            set_anim_to_frame(m, frame)
            return 1
        elseif step == GROUND_STEP_NONE and m.forwardVel ~= 0 then
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
        end
    else
        update_air_without_turn(m)

        local step = perform_air_step(m, 0)
        if step == AIR_STEP_LANDED then
            if check_fall_damage_or_get_stuck(m, ACT_HARD_BACKWARD_GROUND_KB) == 0 then
                set_mario_action(m, ACT_MARVIN_SHOOT_LASER, m.actionArg)
                set_anim_to_frame(m, frame)
                return 1
            end
        end
    end

    if m.controller.buttonPressed & B_BUTTON ~= 0 and frame >= 20 and frame <= 25 then
        set_anim_to_frame(m, 8)
        m.actionState = m.actionState + 1
        m.actionArg = 0
    elseif frame < 6 and m.action == ACT_MARVIN_AIR_SHOOT_LASER then
        set_anim_to_frame(m, 6)
    end

    if is_anim_at_end(m) ~= 0 then
        return set_mario_action(m, ACT_IDLE, 0)
    end
end

---@param m MarioState
function acts.act_marvin_grab_tnt(m)
    playerTable[m.playerIndex].blockCTActsTimer = 5

    if should_begin_sliding(m) ~= 0 then
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
    end

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    play_character_sound_if_no_flag(m, CHAR_SOUND_WAH2, MARIO_MARIO_SOUND_PLAYED)
    mario_set_forward_vel(m, 0)
    stationary_ground_step(m)

    local frame = m.marioObj.header.gfx.animInfo.animFrame
    if frame == 10 and m.playerIndex == 0 then
        m.usedObj = spawn_sync_object(id_bhvMarvinTNT, E_MODEL_MARVIN_TNT, m.pos.x, m.pos.y, m.pos.z, function(o)
            o.oOwner = nps[0].globalIndex
        end)
        network_send_object(m.usedObj, true)
    elseif frame == 11 then
        mario_grab_used_object(m)
    elseif frame == 20 then
        mario_throw_held_object(m)
    end

    set_character_animation(m, CHAR_ANIM_PICK_UP_LIGHT_OBJ)
    if is_anim_at_end(m) ~= 0 then
        return set_mario_action(m, ACT_IDLE, 0)
    end
end

---@param m MarioState
function acts.act_taz_tornado(m)

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    play_character_sound_if_no_flag(m, CHAR_SOUND_WAH2, MARIO_MARIO_SOUND_PLAYED)

    if mario_check_object_grab(m) ~= 0 then
        set_character_animation(m, CHAR_ANIM_FIRST_PUNCH)
        set_anim_to_frame(m, 0)
        return 1
    end

    if m.action == ACT_TAZ_TORNADO_START then
        if m.input & INPUT_UNKNOWN_10 ~= 0 then
            return set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
        end

        if m.input & INPUT_ABOVE_SLIDE ~= 0 then
            return set_mario_action(m, ACT_BUTT_SLIDE, 0)
        end

        mario_set_forward_vel(m, 0)

        set_character_animation(m, CHAR_ANIM_FIRST_PUNCH_FAST)
        if is_anim_at_end(m) ~= 0 then
            mario_set_forward_vel(m, 30)
            set_mario_action(m, ACT_TAZ_TORNADO_ATTACK, 0)
            m.flags = m.flags | MARIO_MARIO_SOUND_PLAYED
            return 1
        end
        perform_ground_step(m)
    else
        set_character_animation(m, CHAR_ANIM_A_POSE)
        m.invincTimer = -1

        mario_set_forward_vel(m, approach_f32_symmetric(m.forwardVel, math.max(m.intendedMag / 32 * 40, 10), 0.7))
        m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x400)

        m.actionTimer = m.actionTimer + 1

        if m.actionTimer % 3 == 0 then
            play_sound(SOUND_ACTION_SPIN, m.pos)
        end
        set_mario_particle_flags(m, PARTICLE_DIRT | PARTICLE_DUST, 0)

        affectAllObjects(m.marioObj, function (att, vic)
            if dist_between_objects(att, vic) < 250 then
                local bhvId = get_id_from_behavior(vic.behavior)
                if bhvId == id_bhvMario then
                    local nm = states[vic.oBehParams - 1]
                    if is_player_active(nm) ~= 0 and
                    nm.action & PREVENT_ACT_FLAGS == 0 and
                    not PREVENT_ACT_GROUPS[nm.action & ACT_GROUP_MASK] then
                        hurt_and_set_mario_action(nm, ACT_CAUGHT_IN_TAZ_TORNADO, nps[m.playerIndex].globalIndex, 0)
                    end
                elseif get_object_list_from_behavior(vic.behavior) ~= OBJ_LIST_SURFACE and
                bhvId ~= id_bhvChainChomp and bhvId ~= id_bhvBigBully and bhvId ~= id_bhvBigChillBully and bhvId ~= id_bhvKlepto then

                    if vic.oInteractType == INTERACT_GRABBABLE and m.actionTimer <= 10 then
                        return false
                    end

                    spawn_sync_object(id_bhvTazCaughtObj, obj_get_model_id_extended(vic), m.pos.x, m.pos.y, m.pos.z, function(o)
                        o.oOwner = nps[m.playerIndex].globalIndex
                        o.oSubAction = bhvId

                        o.oBehParams = vic.oBehParams
                        o.oBehParams2ndByte = vic.oBehParams2ndByte

                        o.oHealth = vic.oHealth
                        o.oNumLootCoins = vic.oNumLootCoins
                        o.oOpacity = vic.oOpacity
                        o.oAnimState = vic.oAnimState
                        o.oDeathSound = vic.oDeathSound

                        o.oGraphYOffset = vic.oGraphYOffset
                        o.hitboxDownOffset = vic.hitboxDownOffset
                        o.hitboxRadius = vic.hitboxRadius
                        o.hitboxHeight = vic.hitboxHeight
                        o.hurtboxRadius = vic.hurtboxRadius
                        o.hurtboxHeight = vic.hurtboxHeight
                        vec3f_copy(o.header.gfx.scale, vic.header.gfx.scale)

                        o.oKoopaMovementType = vic.oKoopaMovementType
                        o.oScuttlebugUnkF4 = vic.oScuttlebugUnkF4
                        o.oBullySubtype = vic.oBullySubtype
                    end)
                    vic.oSyncDeath = 1
                    network_send_object(vic, true)
                    obj_mark_for_deletion(vic)
                elseif obj_check_hitbox_overlap(att, vic) then
                    return true
                end
            end
            return false
        end)

        local step = perform_ground_step(m)
        if m.actionTimer > 90 then
            return set_mario_action(m, ACT_WALKING, 0)
        elseif step == GROUND_STEP_HIT_WALL and m.wall then
            local doors = {
                [id_bhvDoor] = true,
                [id_bhvStarDoor] = true
            }
            if m.wall.object and doors[get_id_from_behavior(m.wall.object.behavior)] and isDoorUnlocked(m.wall.object) then
                spawn_triangle_break_particles(20, 138, 0.7, 3)
                cur_obj_play_sound_1(SOUND_GENERAL_BREAK_BOX)
                obj_mark_for_deletion(m.wall.object)
            else
                m.marioObj.oWallAngle = atan2s(m.wall.normal.z, m.wall.normal.x)
                m.faceAngle.y = cur_obj_reflect_move_angle_off_wall()
                play_sound(SOUND_ACTION_HIT_2, m.marioObj.header.gfx.cameraToObject)
            end
        end

        m.marioObj.header.gfx.angle.y = m.twirlYaw
        m.twirlYaw = math.s16(m.twirlYaw + 0x2100)
    end
end

---@param m MarioState
function acts.act_caught_in_taz_tornado(m)
    if m.actionState ~= 2 then
        local tornadoM = states[getLocalFromGlobalIdx(m.actionArg)]
        if is_player_active(tornadoM) == 0 or tornadoM.action ~= ACT_TAZ_TORNADO_ATTACK then
            if m.playerIndex == 0 then
                m.faceAngle.y = math.random(-0x7FFF, 0x8000)
                mario_set_forward_vel(m, math.random(30, 60))
                m.vel.y = math.random(20, 80)
                m.flags = m.flags & ~MARIO_MARIO_SOUND_PLAYED
                m.actionState = 2
            end
            return
        end

        if m.playerIndex == 0 and m.actionState == 0 then
            m.vel.y = 0
            m.twirlYaw = math.random(-0x7FFF, 0x8000)
            m.angleVel.x = math.random(0x300, 0x1000)
            m.angleVel.y = math.random(170, 220)
            m.angleVel.z = math.random(50, 150)
            m.actionState = 1
        end

        m.faceAngle.y = m.faceAngle.y - math.s16(m.angleVel.x)

        set_character_animation(m, CHAR_ANIM_BEING_GRABBED)
        play_character_sound_if_no_flag(m, CHAR_SOUND_WHOA, MARIO_MARIO_SOUND_PLAYED)

        m.vel.y = math.min(m.vel.y + 10, m.angleVel.y)

        m.pos.x = tornadoM.pos.x + m.angleVel.z * sins(m.twirlYaw)
        m.pos.y = tornadoM.pos.y + m.vel.y
        m.pos.z = tornadoM.pos.z + m.angleVel.z * coss(m.twirlYaw)

        vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
        vec3s_copy(m.marioObj.header.gfx.angle, m.faceAngle)

        m.twirlYaw = m.twirlYaw + 0x500
    else
        set_character_animation(m, CHAR_ANIM_AIR_FORWARD_KB)
        play_character_sound_if_no_flag(m, CHAR_SOUND_WAAAOOOW, MARIO_MARIO_SOUND_PLAYED)

        local step = perform_air_step(m, 0)
        if step == AIR_STEP_LANDED then
            return set_mario_action(m, ACT_FORWARD_GROUND_KB, 0)
        elseif step == AIR_STEP_HIT_WALL then
            return set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        end
    end
end

---@param m MarioState
function acts.act_foghorn_slap(m)
    if should_begin_sliding(m) ~= 0 then
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
    end

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if mario_check_object_grab(m) ~= 0 then
        set_character_animation(m, CHAR_ANIM_FIRST_PUNCH)
        set_anim_to_frame(m, 0)
        return 1
    end

    if m.action == ACT_FOGHORN_SLAP_CHARGE then
        if m.actionState == 0 then
            m.marioBodyState.handState = MARIO_HAND_RIGHT_OPEN
            set_character_animation(m, CHAR_ANIM_FIRST_PUNCH_FAST)
            play_character_sound_if_no_flag(m, CHAR_SOUND_HOOHOO, MARIO_MARIO_SOUND_PLAYED)
            if is_anim_at_end(m) ~= 0 then
                m.actionState = 1
            end
        else
            if m.intendedMag ~= 0 then

                if m.actionState ~= 2 then
                    play_character_sound(m, CHAR_SOUND_HELLO)
                    m.actionState = 2
                end

                m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x800)
                play_step_sound(m, 28, 84)
                if m.marioObj.header.gfx.animInfo.animFrame == 0 then
                    m.forwardVel = 10 * m.intendedMag / 32
                end
            else
                m.forwardVel = approach_f32_symmetric(m.forwardVel, 0, 1)
                if m.forwardVel == 0 then
                    m.marioBodyState.handState = MARIO_HAND_RIGHT_OPEN

                    if m.actionState == 2 then
                        m.flags = m.flags & ~MARIO_MARIO_SOUND_PLAYED
                        m.actionState = 0
                    end
                end
            end
            mario_set_forward_vel(m, m.forwardVel)

            if m.controller.buttonDown & B_BUTTON == 0 then
                return set_mario_action(m, ACT_FOGHORN_SLAP_RELEASE, m.actionTimer)
            end

            m.actionTimer = math.min(m.actionTimer + 5, 150)

            local accel = ternary(m.forwardVel == 0, (1 + m.actionTimer / 50), 3 * (m.forwardVel / 15))
            set_character_anim_with_accel(m, CHAR_ANIM_SECOND_PUNCH, math.max(0x1000, 0x10000 * accel))
        end
        perform_ground_step(m)
    else
        m.marioBodyState.handState = MARIO_HAND_RIGHT_OPEN
        set_character_animation(m, CHAR_ANIM_SECOND_PUNCH_FAST)
        play_character_sound_if_no_flag(m, CHAR_SOUND_PUNCH_HOO, MARIO_MARIO_SOUND_PLAYED)
        mario_set_forward_vel(m, 0)
        stationary_ground_step(m)

        if m.marioObj.header.gfx.animInfo.animFrame < 8 then
            local power = m.actionArg / 150

            affectAllObjects(m.marioObj, function (att, vic)
                local angleToO = mario_obj_angle_to_object(m, vic)
                if dist_between_objects(att, vic) < vic.hitboxRadius + 100 and
                abs_angle_diff(angleToO, m.faceAngle.y) <= 0x2AAA then

                    if obj_has_behavior_id(vic, id_bhvMario) ~= 0 then

                        if m.actionState == 0 then
                            m.actionState = 1
                        end

                        local nm = states[vic.oBehParams - 1]
                        nm.faceAngle.y = obj_angle_to_object(nm.marioObj, m.marioObj)
                        hurt_and_set_mario_action(nm, ACT_SLAPPED_BY_FOGHORN, m.actionArg, 4 * (2 + 2 * power))
                    elseif vic.oInteractType == INTERACT_BOUNCE_TOP or
                    vic.oInteractType == INTERACT_BOUNCE_TOP2 or
                    vic.oInteractType == INTERACT_KOOPA or
                    vic.oInteractType == INTERACT_BULLY then

                        if m.actionState == 0 then
                            m.actionState = 1
                        end

                        vic.oAction = OBJ_ACT_HORIZONTAL_KNOCKBACK
                        vic.oIntangibleTimer = 5
                        vic.oForwardVel = 40 + 80 * power
                        vic.oVelY = 25 + 45 * power
                        vic.oFlags = vic.oFlags & ~OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW
                        vic.oMoveFlags = 0
                        vic.oMoveAngleYaw = angleToO

                        if vic.oSyncID ~= 0 then
                            network_send_object(vic, true)
                        end
                    end
                end

                return false
            end)

            if m.actionState == 1 then
                if m.actionState == 1 and is_anim_past_frame(m, 3) ~= 0 then
                    m.actionState = 2
                    spawn_non_sync_object(id_bhvTriangleParticleSpawner, E_MODEL_NONE, m.pos.x, m.pos.y + 50, m.pos.z, function() end)
                end
                if m.playerIndex == 0 and power >= 0.2 then
                    play_sound(SOUND_ACTION_HIT_3, m.marioObj.header.gfx.cameraToObject)
                    set_camera_shake_from_point(ternary(power <= 0.6, SHAKE_POS_SMALL, SHAKE_POS_MEDIUM), m.pos.x, m.pos.y, m.pos.z)
                end
            end
        end

        if is_anim_at_end(m) ~= 0 then
            return set_mario_action(m, ACT_IDLE, 0)
        end
    end
end

---@param m MarioState
function acts.act_slapped_by_foghorn(m)
    if m.actionState == 0 then
        local power = m.actionArg / 150
        mario_set_forward_vel(m, -(15 + 45 * power))
        m.vel.y = 10 + 40 * power
        m.actionState = 1
    end

    play_character_sound_if_no_flag(m, CHAR_SOUND_UH, MARIO_MARIO_SOUND_PLAYED)
    common_air_knockback_step(m, ACT_BACKWARD_GROUND_KB, ACT_BACKWARD_GROUND_KB, 0x0002, m.forwardVel)
end

---@param m MarioState
function acts.act_lola_slam_dunk(m)
    if m.actionState == 0 then
        play_character_sound_if_no_flag(m, CHAR_SOUND_YAH_WAH_HOO, MARIO_MARIO_SOUND_PLAYED)
        set_character_animation(m, CHAR_ANIM_JUMP_WITH_LIGHT_OBJ)
        update_air_with_turn(m)
        
        if m.playerIndex == 0 and m.actionArg == 0 then
            spawn_sync_object(id_bhvBasketBall, E_MODEL_BASKET_BALL, m.pos.x, m.pos.y, m.pos.z, function (o)
                o.oOwner = nps[0].globalIndex
            end)
            m.actionArg = 1
        end

        if m.vel.y < 20 then
            m.actionState = 1
        end
    else
        set_character_anim_with_accel(m, CHAR_ANIM_FALL_WITH_LIGHT_OBJ, 0x10000 * 1.2)

        if m.actionState == 1 then
            update_air_with_turn(m)
            if is_anim_past_frame(m, 18) ~= 0 then
                play_character_sound(m, CHAR_SOUND_PUNCH_YAH)
                m.actionState = 2
            end
        end

        if m.actionState == 1 then
            m.vel.y = math.max(5, m.vel.y)
        end
    end

    if m.actionState == 2 then
        mario_set_forward_vel(m, approach_f32_symmetric(m.forwardVel, 0, 1))
    else
        mario_set_forward_vel(m, math.min(m.forwardVel, 10))
    end

    if perform_air_step(m, 0) == AIR_STEP_LANDED then
        return set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end
end

---@param m MarioState
function acts.act_sam_shoot_pistol(m)

    if m.input & INPUT_UNKNOWN_10 ~= 0 then
        return set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if should_begin_sliding(m) ~= 0 then
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
    end

    if m.input & INPUT_ABOVE_SLIDE ~= 0 then
        return set_mario_action(m, ACT_BUTT_SLIDE, 0)
    end

    if m.actionArg == 0 then

        if mario_check_object_grab(m) ~= 0 then
            set_character_animation(m, CHAR_ANIM_FIRST_PUNCH)
            set_anim_to_frame(m, 0)
            return 1
        end

        set_character_anim_with_accel(m, CHAR_ANIM_CROUCHING, 0x10000 * 3.4)
        if is_anim_at_end(m) ~= 0 then
            play_character_sound(m, CHAR_SOUND_SO_LONGA_BOWSER)
            m.actionArg = 1
        end
    elseif m.actionArg == 3 then
        set_character_anim_with_accel(m, CHAR_ANIM_STOP_CROUCHING, 0x10000 * 3)
        if is_anim_at_end(m) ~= 0 then
            return set_mario_action(m, ACT_IDLE, 0)
        end
    else
        set_character_anim_with_accel(m, ternary(m.actionArg == 1, CHAR_ANIM_FIRST_PUNCH_FAST, CHAR_ANIM_SECOND_PUNCH_FAST), 0x10000 * 1.9)

        if m.marioObj.header.gfx.animInfo.animFrame > 3 and m.controller.buttonPressed & B_BUTTON ~= 0 then
            m.actionTimer = 1
        end

        if is_anim_at_end(m) ~= 0 then
            if m.actionTimer == 1 then
                m.actionArg = 3 - m.actionArg
            else
                m.actionArg = 3
            end
            m.actionTimer = 0
        end

        if is_anim_past_frame(m, 12) ~= 0 then
            local bulletPos = {
                x = get_hand_foot_pos_x(m, 2 - m.actionArg) + 50 * sins(m.faceAngle.y),
                y = get_hand_foot_pos_y(m, 2 - m.actionArg),
                z = get_hand_foot_pos_z(m, 2 - m.actionArg) + 50 * coss(m.faceAngle.y)
            }
            play_sound(SOUND_OBJ_CANNON4, m.marioObj.header.gfx.cameraToObject)
            spawn_non_sync_object(id_bhvSmoke, E_MODEL_SMOKE, bulletPos.x, bulletPos.y - 20, bulletPos.z, function() end)

            if m.playerIndex == 0 then
                local target, pitch = getAutoTarget(m, bulletPos, 0x1000, 1500)
                set_environmental_camera_shake(SHAKE_ENV_EXPLOSION)

                spawn_sync_object(id_bhvCommonBullet, E_MODEL_BOWLING_BALL, bulletPos.x, bulletPos.y, bulletPos.z, function(o)
                    o.oOwner = nps[0].globalIndex
                    o.oBehParams2ndByte = 5

                    if target then
                        o.oSubAction = 1
                        o.oMoveAnglePitch = pitch
                        o.oMoveAngleYaw = math.s16(obj_angle_to_point(target, bulletPos.x, bulletPos.z) - 0x8000)
                    else
                        o.oMoveAnglePitch = 0
                        o.oMoveAngleYaw = m.faceAngle.y
                    end
                end)
            end
        end
    end

    if m.forwardVel >= 0 then
        apply_slope_decel(m, 0.5)
        if m.forwardVel ~= 0 then
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
            play_sound(SOUND_MOVING_TERRAIN_SLIDE, m.marioObj.header.gfx.cameraToObject)
        end
    else
        m.forwardVel = approach_f32_symmetric(m.forwardVel, 0, 8)
        apply_slope_accel(m)
    end
    perform_ground_step(m)
end

---@param m MarioState
function acts.act_sam_air_shoot_pistol(m)

    m.peakHeight = m.pos.y
    play_character_sound_if_no_flag(m, CHAR_SOUND_SO_LONGA_BOWSER, MARIO_MARIO_SOUND_PLAYED)

    if m.actionState == 0 then
        set_character_anim_with_accel(m, CHAR_ANIM_AIR_KICK, 0x10000 * 2)

        mario_set_forward_vel(m, 0)
        m.vel.y = -7

        if is_anim_past_frame(m, 12) ~= 0 then
            for i = 0, 1 do
                local bulletPos = {
                    x = get_hand_foot_pos_x(m, i),
                    y = get_hand_foot_pos_y(m, i) - 80,
                    z = get_hand_foot_pos_z(m, i)
                }

                play_sound(SOUND_OBJ_CANNON4, m.marioObj.header.gfx.cameraToObject)
                spawn_non_sync_object(id_bhvSmoke, E_MODEL_SMOKE, bulletPos.x, bulletPos.y, bulletPos.z, function() end)

                if m.playerIndex == 0 then
                    local target, pitch = getAutoTarget(m, bulletPos, 0x10000, 5000)
                    set_environmental_camera_shake(SHAKE_ENV_EXPLOSION)

                    spawn_sync_object(id_bhvCommonBullet, E_MODEL_BOWLING_BALL, bulletPos.x, bulletPos.y, bulletPos.z, function(o)
                        o.oOwner = nps[0].globalIndex
                        o.oBehParams2ndByte = 5
                        if target and pitch <= 0x4000 and pitch > 0x1000 then
                            o.oSubAction = 1
                            o.oMoveAnglePitch = pitch
                            o.oMoveAngleYaw = math.s16(obj_angle_to_point(target, bulletPos.x, bulletPos.z) - 0x8000)
                        else
                            o.oMoveAnglePitch = 0x4000
                            o.oMoveAngleYaw = m.faceAngle.y
                        end
                    end)
                end
            end
        end

        if is_anim_at_end(m) ~= 0 then
            mario_set_forward_vel(m, 30)
            m.vel.y = 80
            m.actionState = 1
        end
    else
        if set_character_animation(m, CHAR_ANIM_FORWARD_SPINNING) == 0 then
            play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
        end

        update_air_without_turn(m)
    end

    local step = perform_air_step(m, AIR_STEP_CHECK_LEDGE_GRAB)
    if step == AIR_STEP_LANDED then
        return set_mario_action(m, ACT_JUMP_LAND, 0)
    elseif step == AIR_STEP_GRABBED_LEDGE then
        mario_set_forward_vel(m, 0)
        set_character_animation(m, CHAR_ANIM_IDLE_ON_LEDGE)
        return drop_and_set_mario_action(m, ACT_LEDGE_GRAB, 0)
    elseif step == AIR_STEP_HIT_WALL then
        mario_set_forward_vel(m, 0)
    end
end

---@param m MarioState
function acts.act_sam_shoulder_bash(m)

    if m.input & INPUT_UNKNOWN_10 ~= 0 then
        return set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    local shake = false

    if m.actionState == 0 then
        play_character_sound_if_no_flag(m, CHAR_SOUND_LETS_A_GO, MARIO_MARIO_SOUND_PLAYED)
        set_character_anim_with_accel(m, CHAR_ANIM_CROUCH_FROM_SLIDE_KICK, 0x10000 * 2.6)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)

        mario_set_forward_vel(m, 0)

        if is_anim_at_end(m) ~= 0 then
            shake = true
            if m.actionTimer > 10 then
                mario_set_forward_vel(m, 40)
                m.actionTimer = 0
                m.actionState = 1
            else
                m.actionTimer = m.actionTimer + 1
            end
        end
    else
        if m.forwardVel < 0 then
            m.forwardVel = 40
        end

        set_character_anim_with_accel(m, CHAR_ANIM_SLIDE_KICK, 0x10000 * 4.2)
        mario_set_forward_vel(m, approach_f32_symmetric(m.forwardVel, 40 + 20 * m.intendedMag / 32, 2))
        m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x200)

        local pFlags = PARTICLE_DIRT
        if m.actionTimer % 2 == 0 then
            pFlags = pFlags | PARTICLE_MIST_CIRCLE
        end
        set_mario_particle_flags(m, pFlags, 0)
        play_step_sound(m, 1, 21)

        if m.actionTimer > 60 then
            return set_mario_action(m, ACT_BRAKING, 0)
        end
        m.actionTimer = m.actionTimer + 1
    end

    if perform_ground_step(m) == GROUND_STEP_HIT_WALL then
        local bonk = true
        if m.wall and m.wall.object then
            local intType = m.wall.object.oInteractType
            if intType ~= 0 and intType ~= INTERACT_WARP_DOOR then
                if intType ~= INTERACT_DOOR or isDoorUnlocked(m.wall.object) then
                    bonk = false

                    if intType == INTERACT_DOOR then
                        spawn_triangle_break_particles(20, 138, 0.7, 3)
                        cur_obj_play_sound_1(SOUND_GENERAL_BREAK_BOX)
                        obj_mark_for_deletion(m.wall.object)
                    end
                end
            end
        end

        if bonk then
            play_sound(SOUND_ACTION_BONK, m.marioObj.header.gfx.cameraToObject)
            set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
            mario_set_forward_vel(m, -20)
            return set_mario_action(m, ACT_GROUND_BONK, 0)
        end
    end
    if shake then
        m.marioObj.header.gfx.pos.x = m.pos.x + random_sign() * math.random(3)
        m.marioObj.header.gfx.pos.z = m.pos.z + random_sign() * math.random(3)
    end
end

---@param m MarioState
function acts.act_wile_air_walk(m)
    m.marioBodyState.handState = MARIO_HAND_FISTS

    if m.actionState == 0 then
        m.vel.y = 0

        if m.intendedMag ~= 0 then
            m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x80)
        end

        local step = perform_air_step(m, AIR_STEP_CHECK_LEDGE_GRAB)
        if step == AIR_STEP_LANDED then
            return set_mario_action(m, ACT_WALKING, 0)
        elseif step == AIR_STEP_NONE then
            if m.pos.y <= m.floorHeight + 200 then
                return set_mario_action(m, ACT_FREEFALL, 0)
            elseif m.forwardVel == 0 and is_anim_past_end(m) ~= 0 then
                m.actionState = 1
            end
        elseif step == AIR_STEP_GRABBED_LEDGE then
            set_character_animation(m, CHAR_ANIM_IDLE_ON_LEDGE)
            return set_mario_action(m, ACT_LEDGE_GRAB, 0)
        elseif step == AIR_STEP_HIT_WALL then
            m.wallKickTimer = 5
            return set_mario_action(m, ACT_AIR_HIT_WALL, 0)
        elseif step == AIR_STEP_HIT_LAVA_WALL then
            return lava_boost_on_wall(m)
        end

        m.forwardVel = approach_f32_symmetric(m.forwardVel, 0, 0.4)
        set_character_anim_with_accel(m, CHAR_ANIM_RUNNING, 0x10000 * math.max(m.forwardVel / 3, 1.5))
    elseif m.actionState == 1 then

        if cur_obj_check_anim_frame_in_range(50, 70) ~= 0 then
            m.marioBodyState.handState = MARIO_HAND_RIGHT_OPEN
        end
        set_character_animation(m, CHAR_ANIM_IDLE_HEAD_CENTER)
        if is_anim_at_end(m) ~= 0 then
            play_character_sound(m, CHAR_SOUND_WAAAOOOW)
            m.actionState = 2
        end
    else
        set_character_anim_with_accel(m, CHAR_ANIM_RUNNING, 0x10000 * 10)
        m.actionTimer = m.actionTimer + 1

        m.vel.y = 1
        if perform_air_step(m, 0) == AIR_STEP_LANDED then
            return set_mario_action(m, ACT_FREEFALL_LAND, 0)
        end

        if m.actionTimer > 30 then
            return set_mario_action(m, ACT_FREEFALL, 0)
        end
    end

    mario_set_forward_vel(m, m.forwardVel)
end

---@param m MarioState
function acts.act_wile_rocket_jump(m)

    m.flags = m.flags | MARIO_UNKNOWN_18
    set_character_animation(m, CHAR_ANIM_STOP_CROUCHING)

    if m.actionState == 0 then

        local speed = ternary(m.actionArg ~= 0, 80, 100)
        local dir = { x = 0, y = 0.8 }
        local boost = false

        if m.actionArg == 0 then

            set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
            dir.y = 1

            local frame = m.marioObj.header.gfx.animInfo.animFrame
            if frame > 14 then
                boost = true
            elseif frame < 12 then
                m.marioObj.header.gfx.pos.x = m.pos.x + math.random(-10, 10)
                m.marioObj.header.gfx.pos.z = m.pos.z + math.random(-10, 10)
            end
        else
            if m.actionTimer > 8 then
                if m.intendedMag ~= 0 then
                    if m.intendedMag ~= 0 then
                        m.faceAngle.y = m.intendedYaw
                        dir.x = 1
                    end
                    speed = math.sqrt(dir.x * dir.x + dir.y * dir.y) * speed
                else
                    dir.y = 1
                end

                boost = true
            else
                m.actionTimer = m.actionTimer + 1
                m.marioObj.header.gfx.pos.x = m.pos.x + math.random(-10, 10)
                m.marioObj.header.gfx.pos.y = m.pos.y + math.random(-10, 10)
                m.marioObj.header.gfx.pos.z = m.pos.z + math.random(-10, 10)
            end
        end

        if boost then
            play_sound(SOUND_GENERAL_BOWSER_PLATFORM, m.marioObj.header.gfx.cameraToObject)
            mario_set_forward_vel(m, speed * dir.x)
            m.vel.y = speed * dir.y

            m.faceAngle.x = -atan2s(m.forwardVel, m.vel.y) + 0x4000

            m.actionTimer = 0
            m.actionState = 1
            play_character_sound(m, CHAR_SOUND_HOOHOO)
        end
    else
        if m.vel.y < -10 and m.controller.buttonDown & A_BUTTON ~= 0 then
            m.actionArg = m.actionArg + 1

            if m.actionArg > 2 then
                spawn_non_sync_object(id_bhvLTExplosion, E_MODEL_EXPLOSION_KABOOM, m.pos.x, m.pos.y, m.pos.z, function(o)
                    o.oOwner = nps[m.playerIndex].globalIndex
                end)
                return hurt_and_set_mario_action(m, ACT_WILE_ROCKET_EXPLODE, 0, 4)
            else
                m.actionState = 0
            end
        end

        local step = perform_air_step(m, 0)
        if step == AIR_STEP_LANDED then
            return set_mario_action(m, ACT_FREEFALL_LAND, 0)
        elseif step == AIR_STEP_HIT_WALL then
            if m.forwardVel > 20 then
                return set_mario_action(m, ACT_AIR_HIT_WALL, 0)
            else
                m.faceAngle.y = cur_obj_reflect_move_angle_off_wall()
            end
        end

        m.faceAngle.x = approach_s16_symmetric(m.faceAngle.x, -atan2s(m.forwardVel, m.vel.y) + 0x4000, 0x500)
    end

    m.marioObj.header.gfx.angle.x = m.faceAngle.x
    if m.actionState ~= 0 or m.actionArg ~= 0 then
        local off = gVec3fZero()
        local mat4 = gMat4Identity()
        mtxf_rotate_zxy_and_translate(mat4, gVec3fZero(), m.faceAngle)
        linear_mtxf_mul_vec3f(mat4, off, { x = 0, y = 10, z = -50})
        spawn_non_sync_object(id_bhvWhitePuffSmoke2, E_MODEL_SMOKE, m.pos.x + off.x, m.pos.y + off.y, m.pos.z + off.z, function() end)
    end
end

---@param m MarioState
function acts.act_wile_rocket_explode(m)
    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    play_character_sound_if_no_flag(m, CHAR_SOUND_ATTACKED, MARIO_MARIO_SOUND_PLAYED)

    set_character_animation(m, CHAR_ANIM_SHOCKED)
    set_anim_to_frame(m, 0)

    mario_set_forward_vel(m, 0)

    if m.actionState == 0 then
        m.vel.y = 0

        if m.actionTimer % 2 == 0 then
            spawn_non_sync_object(id_bhvBlackSmokeMario, E_MODEL_BURN_SMOKE, m.pos.x, m.pos.y, m.pos.z, function()end)
        end

        m.actionTimer = m.actionTimer + 1
        if m.actionTimer > 20 then
            play_sound(SOUND_OBJ_SOMETHING_LANDING, m.marioObj.header.gfx.cameraToObject)
            m.actionState = 1
        end
    else
        m.faceAngle.x = approach_s16_symmetric(m.faceAngle.x, -0x4000, 0x500)
        m.vel.y = -25
    end

    if perform_air_step(m, 0) == AIR_STEP_LANDED then
        play_mario_landing_sound(m, 0)
        return set_mario_action(m, ACT_BACKWARD_GROUND_KB, 0)
    end

    m.marioObj.header.gfx.angle.x = m.faceAngle.x

    if m.actionState ~= 0 then
        local yOffset = 100
        m.marioObj.header.gfx.pos.x = m.pos.x - yOffset * sins(m.faceAngle.x) * sins(m.faceAngle.y)
        m.marioObj.header.gfx.pos.z = m.pos.z - yOffset * sins(m.faceAngle.x) * coss(m.faceAngle.y)
        m.marioObj.header.gfx.pos.y = m.pos.y + yOffset - yOffset * coss(m.faceAngle.x)
    end
end

return acts
