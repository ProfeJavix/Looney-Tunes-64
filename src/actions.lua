local nps = gNetworkPlayers
local states = gMarioStates
local playerTable = gPlayerSyncTable

local acts = {}

---@param m MarioState
function acts.act_bugs_hover(m)
    if m.input & INPUT_B_PRESSED ~= 0 then
        return set_mario_action(m, ACT_DIVE, 0)
    end

    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0)
    end

    play_mario_sound(m, SOUND_ACTION_TERRAIN_JUMP, CHAR_SOUND_YAHOO)

    common_air_action_step(m, ACT_TRIPLE_JUMP_LAND,
        ternary(m.actionState == 0, CHAR_ANIM_TRIPLE_JUMP, CHAR_ANIM_GENERAL_FALL), 0)

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

---@param m MarioState
function acts.act_daffy_pound(m)
    set_character_animation(m, CHAR_ANIM_GROUND_POUND)

    if m.actionState == 0 then
        m.peakHeight = m.pos.y
        m.vel.y = -60
        mario_set_forward_vel(m, 0)

        if is_anim_at_end(m) ~= 0 then
            m.actionState = 1
        end
    else
        local step = perform_air_step(m, 0)
        if step == AIR_STEP_LANDED then
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
        return drop_and_set_mario_action(m, ACT_SHOCKWAVE_BOUNCE, 0)
    end

    if m.input & INPUT_OFF_FLOOR ~= 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if m.input & INPUT_ABOVE_SLIDE ~= 0 then
        return set_mario_action(m, ACT_BUTT_SLIDE, 0)
    end

    if m.actionTimer > 3 and (m.actionArg == 0 or m.controller.buttonDown & Z_TRIG ~= 0) then
        m.vel.y = 50
        return set_mario_action(m, ACT_DAFFY_POUND_BOUNCE, m.actionArg)
    end
    m.actionTimer = m.actionTimer + 1

    landing_step(m, CHAR_ANIM_GROUND_POUND_LANDING, ACT_BUTT_SLIDE_STOP)
end

---@param m MarioState
function acts.act_daffy_pound_bounce(m)
    play_character_sound_if_no_flag(m, CHAR_SOUND_GROUND_POUND_WAH, MARIO_MARIO_SOUND_PLAYED)

    if m.vel.y < 10 and m.controller.buttonDown & Z_TRIG ~= 0 then
        return set_mario_action(m, ACT_DAFFY_POUND, 1)
    end

    update_air_with_turn(m)
    common_air_action_step(m, ACT_DOUBLE_JUMP_LAND, CHAR_ANIM_DOUBLE_JUMP_RISE,
        AIR_STEP_CHECK_LEDGE_GRAB | AIR_STEP_CHECK_HANG)
end

---@param m MarioState
function acts.act_daffy_mallet_swing(m)
    --temp, just for anim test

    set_character_animation(m, CHAR_ANIM_A_POSE)
    smlua_anim_util_set_animation(m.marioObj, 'daffy_swing_anim')

    if is_anim_at_end(m) ~= 0 then
        return set_mario_action(m, ACT_IDLE, 0)
    end
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
            spawn_sync_object(id_bhvElmerBullet, E_MODEL_BOWLING_BALL, bulletPos.x, bulletPos.y, bulletPos.z, function(o)
                o.oOwner = nps[0].globalIndex

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

local FOGHORN_SLAP_INTERACTS = {
    INTERACT_PLAYER,
    INTERACT_BOUNCE_TOP,
    INTERACT_BOUNCE_TOP2,
    INTERACT_KOOPA,
    INTERACT_BULLY
}

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

    m.marioBodyState.handState = MARIO_HAND_RIGHT_OPEN

    if m.action == ACT_FOGHORN_SLAP_CHARGE then
        if m.forwardVel >= 0 then
            apply_slope_decel(m, 0.8)
        else
            m.forwardVel = approach_f32_symmetric(m.forwardVel, 0, 8)
            apply_slope_accel(m)
        end

        local step = perform_ground_step(m)
        if step == GROUND_STEP_NONE and m.forwardVel ~= 0 then
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
        end

        if m.actionState == 0 then
            set_character_animation(m, CHAR_ANIM_FIRST_PUNCH_FAST)
            if is_anim_at_end(m) ~= 0 then
                m.actionState = 1
            end
        else
            if m.controller.buttonDown & B_BUTTON == 0 then
                return set_mario_action(m, ACT_FOGHORN_SLAP_RELEASE, m.actionTimer)
            end

            m.actionTimer = math.min(m.actionTimer + 5, 150)
            set_character_anim_with_accel(m, CHAR_ANIM_SECOND_PUNCH, 0x10000 * (1 + m.actionTimer / 50))
        end
    else
        set_character_animation(m, CHAR_ANIM_SECOND_PUNCH_FAST)
        play_character_sound_if_no_flag(m, CHAR_SOUND_PUNCH_HOO, MARIO_MARIO_SOUND_PLAYED)
        mario_set_forward_vel(m, 0)
        stationary_ground_step(m)

        if m.marioObj.header.gfx.animInfo.animFrame < 8 then
            local power = m.actionArg / 150

            for _, intType in ipairs(FOGHORN_SLAP_INTERACTS) do
                local o = mario_get_collided_object(m, intType)
                if o then
                    local angleToO = mario_obj_angle_to_object(m, o)
                    if abs_angle_diff(angleToO, m.faceAngle.y) <= 0x2AAA then
                        if intType == INTERACT_PLAYER then
                            local nm = states[o.oBehParams - 1]
                            if nm.playerIndex == 0 and
                            is_player_active(nm) ~= 0 and
                            nm.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE and
                            nm.action & (ACT_FLAG_INVULNERABLE | ACT_FLAG_INTANGIBLE) == 0 and
                            nm.invincTimer == 0 then
                                nm.faceAngle.y = obj_angle_to_object(nm.marioObj, m.marioObj)
                                hurt_and_set_mario_action(nm, ACT_SLAPPED_BY_FOGHORN, m.actionArg, 4 * (2 + 2 * power))
                            end
                        else
                            o.oAction = OBJ_ACT_HORIZONTAL_KNOCKBACK
                            o.oForwardVel = 40 + 80 * power
                            o.oVelY = 25 + 45 * power
                            o.oFlags = o.oFlags & ~OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW
                            o.oMoveFlags = 0
                            o.oMoveAngleYaw = angleToO

                            if o.oSyncID ~= 0 then
                                network_send_object(o, true)
                            end
                        end

                        if m.playerIndex == 0 then
                            local shake = 0
                            if power >= 0.2 then
                                if power <= 0.6 then
                                    shake = SHAKE_POS_SMALL
                                else
                                    shake = SHAKE_POS_MEDIUM
                                end
                            end
                            set_camera_shake_from_point(shake, m.pos.x, m.pos.y, m.pos.z)
                        end
                    end
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
