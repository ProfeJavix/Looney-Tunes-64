local nps = gNetworkPlayers
local states = gMarioStates

local bhvs = {}

---@param o Object
function bhvs.bhv_bugs_helicopter_ears_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

---@param o Object
function bhvs.bhv_bugs_helicopter_ears_loop(o)
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
function bhvs.bhv_bugs_dirt_hole_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_SET_FACE_ANGLE_TO_MOVE_ANGLE)
    cur_obj_scale(0)
    o.oMoveAnglePitch = 0
end

---@param o Object
function bhvs.bhv_bugs_dirt_hole_loop(o)
    if not nps[o.oOwner].connected then
        obj_mark_for_deletion(o)
        return
    end

    if o.oAction == 2 then
        o.oForwardVel = 0
        cur_obj_scale(approach_f32_symmetric(o.header.gfx.scale.x, 0, 0.3))
        cur_obj_play_sound_2(SOUND_MOVING_TERRAIN_SLIDE)
        if o.header.gfx.scale.x == 0 then
            obj_mark_for_deletion(o)
        end
    else
        local m = states[o.oOwner]

        if o.oAction == 0 then
            cur_obj_scale(approach_f32_symmetric(o.header.gfx.scale.x, 1, 0.2))
            if o.header.gfx.scale.x == 1 then
                o.oAction = 1
            end
        elseif o.oAction == 1 then
            o.oForwardVel = m.forwardVel
            if m.action ~= ACT_BUGS_MOVE_UNDERGROUND then
                o.oAction = 2
                return
            end
        end

        obj_copy_pos(o, m.marioObj)
        o.oPosY = find_floor_height(o.oPosX, o.oPosY, o.oPosZ)
        o.oMoveAngleYaw = m.faceAngle.y
    end

    cur_obj_align_gfx_with_floor()
end

---@param o Object
function bhvs.bhv_elmer_bullet_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE

    o.oGraphYOffset = 10
    o.oWallHitboxRadius = 10
    o.oDragStrength = 10
    o.oFriction = 10

    cur_obj_set_hitbox_radius_and_height(10, 20)
    o.hitboxDownOffset = 10

    obj_set_billboard(o)
    cur_obj_scale(0.1)

    network_init_object(o, true, { 'oTimer', 'oAction' })
end

---@param o Object
function bhvs.bhv_elmer_bullet_loop(o)

    if o.oAction == 1 then
        cur_obj_disable()
        if o.oTimer < 3 then
            spawn_non_sync_object(id_bhvSmoke, E_MODEL_SMOKE, o.oPosX, o.oPosY, o.oPosZ, function() end)
            return
        else
            o.oTimer = 300
        end
    end

    if o.oTimer >= 300 then
        obj_mark_for_deletion(o)
        return
    end

    local result = moveProjectile(o, 120, OBJ_MOVE_HIT_WALL | OBJ_MOVE_MASK_ON_GROUND, function (projectile)
        return affectAllObjects(
            projectile,
            function(att, vic)
                return obj_check_hitbox_overlap(att, vic)
            end,
            true
        )
    end)

    if result ~= 0 then
        o.oTimer = 0
        o.oAction = 1
        cur_obj_play_sound_2(ternary(result == 1, SOUND_ACTION_HIT_2, SOUND_GENERAL_VOLCANO_EXPLOSION))
    end
end

---@param o Object
function bhvs.bhv_tweety_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW)
    smlua_anim_util_set_animation(o, ANIM_SYLVESTER_TWEETY_FLYING)
    o.oFaceAnglePitch = 0
end

---@param o Object
function bhvs.bhv_tweety_loop(o)
    local m = states[o.oOwner]
    if is_player_active(m) == 0 or
    m.flags & MARIO_CAP_ON_HEAD == 0 or
    _G.charSelect.character_get_current_number(o.oOwner) ~= CT_SYLVESTER then
        obj_mark_for_deletion(o)
        return
    end

    if m.action == ACT_SYLVESTER_TWEETY_GLIDE and m.actionState == 1 then
        o.oMoveAngleYaw = m.faceAngle.y
        o.oPosX = m.pos.x - 10 * sins(m.faceAngle.y) + 10 * sins(math.s16(m.faceAngle.y + 0x4000))
        o.oPosY = m.pos.y + 125
        o.oPosZ = m.pos.z - 10 * coss(m.faceAngle.y) + 10 * coss(math.s16(m.faceAngle.y + 0x4000))
        obj_set_gfx_pos_from_pos(o)
        return
    end

    local target = nil
    local yOffset = 0

    if m.action & PREVENT_ACT_FLAGS == 0 and
    not PREVENT_ACT_GROUPS[m.action & ACT_GROUP_MASK] and
    not _G.charSelect.gCSPlayers[m.playerIndex].inMenu then
        target = getAutoTarget(m, { x = o.oPosX, y = o.oPosY, z = o.oPosZ }, 0x10000, 1000)
    else
        yOffset = 170
    end

    local targetFVel = 0
    local targetYVel = 0
    local canAttack = true

    if not target then
        target = m.marioObj
        targetFVel = m.forwardVel
        targetYVel = m.vel.y
        canAttack = false
    end

    if yOffset == 0 then
        yOffset = target.hitboxHeight + 20 + target.oVelY
    end

    local targetPos = { x = target.oPosX, y = target.oPosY + yOffset, z = target.oPosZ }

    local dist = dist_between_object_and_point(o, targetPos.x, targetPos.y, targetPos.z)
    if dist < 2000 then
        if targetFVel == 0 and targetYVel == 0 and dist < 150 then

            if dist <= target.hitboxRadius + 30 then
                o.oAngleVelYaw = math.s16(o.oAngleVelYaw + 0x300)
                o.oForwardVel = 100
                targetPos.y = targetPos.y + coss(0x400 * o.oFlyGuyOscTimer) * 10

                if canAttack and m.playerIndex == 0 and m.controller.buttonPressed & X_BUTTON ~= 0 and
                m.action ~= ACT_SYLVESTER_TWEETY_FIGHT and m.action & PREVENT_ACT_FLAGS == 0 and
                not PREVENT_ACT_GROUPS[m.action & ACT_GROUP_MASK] then
                    m.vel.y = 20
                    set_mario_action(m, ACT_SYLVESTER_TWEETY_FIGHT, 0)
                end
            else
                o.oAngleVelYaw = math.s16(obj_angle_to_object(target, o) + 0x300)
                o.oForwardVel = approach_f32_symmetric(o.oForwardVel, 20, 1)
            end

            targetPos.x = targetPos.x + 80 * sins(o.oAngleVelYaw)
            targetPos.z = targetPos.z + 80 * coss(o.oAngleVelYaw)
            o.oMoveAngleYaw = obj_angle_to_point(o, targetPos.x, targetPos.z)
        else
            if dist < 100 then
                o.oMoveAngleYaw = approach_s16_symmetric(o.oMoveAngleYaw, target.oFaceAngleYaw, 0x800)
                o.oForwardVel = 25
            else
                o.oMoveAngleYaw = obj_angle_to_object(o, target)
                o.oForwardVel = 35
            end

            if targetFVel ~= 0 then
                o.oForwardVel = math.min(o.oForwardVel, math.abs(targetFVel) - 5)
            elseif dist < 100 then
                o.oForwardVel = approach_f32_symmetric(o.oForwardVel, 10, 1)
            end
        end

        if m.action == ACT_SYLVESTER_TWEETY_FIGHT and m.actionState == 2 then
            targetPos.y = m.pos.y + 500
        end

        cur_obj_compute_vel_xz()

        targetPos.x = approach_f32_symmetric(o.oPosX, targetPos.x, math.abs(o.oVelX))
        targetPos.y = approach_f32_symmetric(o.oPosY, targetPos.y, math.abs(target.oVelY) + 10)
        targetPos.z = approach_f32_symmetric(o.oPosZ, targetPos.z, math.abs(o.oVelZ))
    end

    cur_obj_update_floor()
    obj_set_pos(o, targetPos.x, math.max(targetPos.y, o.oFloorHeight), targetPos.z)

    o.oFlyGuyOscTimer = o.oFlyGuyOscTimer + 1
end

---@param o Object
function bhvs.bhv_sylvester_fight_dust_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(o)
    o.oOpacity = 200
    cur_obj_scale(6)

    obj_translate_xz_random(o, 300)
    o.oPosY = o.oPosY + math.random(0, 300)
end

---@param o Object
function bhvs.bhv_sylvester_fight_dust_loop(o)
    cur_obj_move_using_fvel_and_gravity()
    if o.oTimer > 4 then
        obj_mark_for_deletion(o)
    end
end

---@param o Object
function bhvs.bhv_marvin_laser_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_SET_FACE_ANGLE_TO_MOVE_ANGLE)
    o.header.gfx.scale.z = 0
    cur_obj_play_sound_2(SOUND_OBJ_SNOWMAN_BOUNCE)
    network_init_object(o, true, { 'oTimer', 'oAction', 'oSubAction' })
end

---@param o Object
function bhvs.bhv_marvin_laser_loop(o)

    local t = math.min(1, o.oTimer / 4)

    if o.oAction == 0 then
        o.header.gfx.scale.z = math.lerp(0, 1, t)

        local m = states[getLocalFromGlobalIdx(o.oOwner)]

        if m and o.oSubAction == 0 then
            o.oMoveAngleYaw = m.faceAngle.y
            o.oHomeX = get_hand_foot_pos_x(m, 0) + 40 * sins(o.oMoveAngleYaw)
            o.oHomeZ = get_hand_foot_pos_z(m, 0) + 40 * coss(o.oMoveAngleYaw)
            o.oPosY = get_hand_foot_pos_y(m, 0)
        end

        o.oPosX = o.oHomeX + 80 * o.header.gfx.scale.z * sins(o.oMoveAngleYaw)
        o.oPosZ = o.oHomeZ + 80 * o.header.gfx.scale.z * coss(o.oMoveAngleYaw)

        obj_set_gfx_pos_from_pos(o)

        if o.header.gfx.scale.z == 1 then
            o.oAction = 1
        end
    elseif o.oAction == 1 then
        local result = moveProjectile(o, 120, OBJ_MOVE_HIT_WALL | OBJ_MOVE_MASK_ON_GROUND, function(projectile)
            return affectAllObjects(projectile, obj_check_hitbox_overlap, true)
        end)

        if result ~= 0 then
            o.oTimer = 0
            o.oAction = 2
            cur_obj_play_sound_2(SOUND_OBJ2_SWOOP)
        end
    else
        spawn_non_sync_object(id_bhvSmoke, E_MODEL_SMOKE, o.oPosX, o.oPosY, o.oPosZ, function() end)
        o.header.gfx.scale.z = math.lerp(1, 0, t)
        if o.header.gfx.scale.z == 0 then
            obj_mark_for_deletion(o)
        end
    end
end

---@param o Object
function bhvs.bhv_marvin_tnt_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_HOLDABLE | OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW)
    o.oInteractType = INTERACT_GRABBABLE

    o.oGravity = -2
    o.oWallHitboxRadius = 40

    cur_obj_set_hitbox_radius_and_height(40, 80)
    cur_obj_scale(0.4)
    cur_obj_hide()

    network_init_object(o, true, { 'oAction', 'oTimer', 'oHeldState' })
end

---@param o Object
function bhvs.bhv_marvin_tnt_loop(o)

    if o.oAction == 2 then
        spawn_non_sync_object(id_bhvLTExplosion, E_MODEL_EXPLOSION_KABOOM, o.oPosX, o.oPosY, o.oPosZ, function(exp)
            exp.oOwner = -1
        end)
        obj_mark_for_deletion(o)
        return
    end

    if o.oHeldState == HELD_FREE then
        if o.oAction == 0 and o.oTimer < 5 then return end

        o.oInteractType = INTERACT_BOUNCE_TOP
        cur_obj_become_tangible()
        cur_obj_scale(approach_f32_symmetric(o.header.gfx.scale.x, 0.6, 0.03))

        if o.oMoveFlags & OBJ_MOVE_MASK_ON_GROUND ~= 0 then
            obj_forward_vel_approach(0, 2)
            cur_obj_play_sound_2(SOUND_MOVING_TERRAIN_SLIDE)
        end

        cur_obj_update_floor_and_walls()
        cur_obj_move_standard(-78)

        spawn_non_sync_object(id_bhvMarvinTNTSmoke, E_MODEL_SMOKE, o.oPosX, o.oPosY, o.oPosZ, function()end)
        cur_obj_play_sound_1(SOUND_AIR_BOBOMB_LIT_FUSE)

        if o.oInteractStatus & INT_STATUS_INTERACTED ~= 0 or o.oTimer > 45 then
            o.oAction = 2
            return
        end

        if o.oMoveFlags & OBJ_MOVE_HIT_WALL ~= 0 then
            o.oMoveAngleYaw = cur_obj_reflect_move_angle_off_wall()
        end
    elseif o.oHeldState == HELD_HELD then
        cur_obj_become_intangible()
        cur_obj_hide()
        o.oAction = 0
        o.oTimer = 5
    else
        cur_obj_unhide()
        o.oAction = 1

        if o.oHeldState == HELD_THROWN then
            o.oForwardVel = 30
            o.oVelY = 20
        end
        o.oHeldState = HELD_FREE
    end
end

---@param o Object
function bhvs.bhv_marvin_tnt_smoke_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(o)
    o.oAnimState = -1

    o.oPosX = o.oPosX + (math.random() * 40) - 20
    o.oPosY = o.oPosY + (math.random() * 40) + 40
    o.oPosZ = o.oPosZ + (math.random() * 40) - 20
    cur_obj_scale(0.5)
end

---@param o Object
function bhvs.bhv_marvin_tnt_smoke_loop(o)
    o.oAnimState = o.oAnimState + 1
    bhv_dust_smoke_loop()
end

---@param o Object
function bhvs.bhv_taz_caught_obj_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oWallHitboxRadius = 40
    o.oFaceAnglePitch = 0

    o.oGravity = -2

    local animData = {
        [id_bhvGoomba] = function (obj)
            obj.oAnimations = gObjectAnimations.goomba_seg8_anims_0801DA4C
            cur_obj_init_animation(0)
        end,
        [id_bhvKoopa] = function (obj)
            obj.oAnimations = gObjectAnimations.koopa_seg6_anims_06011364
            cur_obj_init_animation(1)
        end,
        [id_bhvBobomb] = function (obj)
            obj.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
            cur_obj_init_animation(0)
        end,
        [id_bhvPiranhaPlant] = function (obj)
            obj.oAnimations = gObjectAnimations.piranha_plant_seg6_anims_0601C31C
            cur_obj_init_animation(0)
        end,
        [id_bhvSpindrift] = function (obj)
            obj.oAnimations = gObjectAnimations.spindrift_seg5_anims_05002D68
            cur_obj_init_animation(0)
        end,
        [id_bhvScuttlebug] = function (obj)
            obj.oAnimations = gObjectAnimations.scuttlebug_seg6_anims_06015064
            cur_obj_init_animation(0)
        end,
        [id_bhvHauntedChair] = function (obj)
            obj.oAnimations = gObjectAnimations.chair_seg5_anims_05005784
            cur_obj_init_animation(0)
        end,
        [id_bhvFlyingBookend] = function (obj)
            obj.oAnimations = gObjectAnimations.bookend_seg5_anims_05002540
            cur_obj_init_animation(1)
        end,
        [id_bhvFlyGuy] = function (obj)
            obj.oAnimations = gObjectAnimations.flyguy_seg8_anims_08011A64
            cur_obj_init_animation(0)
        end,
        [id_bhvSwoop] = function (obj)
            obj.oAnimations = gObjectAnimations.swoop_seg6_anims_060070D0
            cur_obj_init_animation(0)
        end,
        [id_bhvMontyMole] = function (obj)
            obj.oAnimations = gObjectAnimations.monty_mole_seg5_anims_05007248
            cur_obj_init_animation(1)
        end,
        [id_bhvSmallBully] = function (obj)
            obj.oAnimations = gObjectAnimations.bully_seg5_anims_0500470C
            cur_obj_init_animation(0)
        end,
        [id_bhvMoneybag] = function (obj)
            obj.oAnimations = gObjectAnimations.moneybag_seg6_anims_06005E5C
            cur_obj_init_animation(0)
            o.oOpacity = 255
        end,
        [id_bhvSkeeter] = function (obj)
            obj.oAnimations = gObjectAnimations.skeeter_seg6_anims_06007DE0
            cur_obj_init_animation(0)
        end,
        [id_bhvSpiny] = function (obj)
            obj.oAnimations = gObjectAnimations.spiny_seg5_anims_05016EAC
            cur_obj_init_animation(0)
        end,
        [id_bhvFirePiranhaPlant] = function (obj)
            obj.oAnimations = gObjectAnimations.piranha_plant_seg6_anims_0601C31C
            cur_obj_init_animation(0)
        end
    }

    if animData[o.oSubAction] then
        animData[o.oSubAction](o)
    end

    if nearest_mario_state_to_object(o).playerIndex == 0 then
        o.oMoveAngleYaw = math.random(-0x7FFF, 0x8000)
        o.oFaceAnglePitch = math.random(-0x7FFF, 0x8000)
        o.oSnufitYOffset = math.random(170, 220)
        o.oSnufitZOffset = math.random(50, 150)
        o.oBirdTargetYaw = math.random(0x300, 0x1000)
    end

    network_init_object(o, true, {
        'oAction',
        'oMoveAngleYaw',
        'oFaceAngleYaw',
        'oFaceAnglePitch',
        'oForwardVel',
        'oVelY',
        'oSnufitYOffset',
        'oSnufitZOffset',
        'oBirdTargetYaw',
        'oOwner'
    })
end

---@param o Object
function bhvs.bhv_taz_caught_obj_loop(o)

    o.oFaceAngleYaw = o.oFaceAngleYaw - o.oBirdTargetYaw

    if o.oAction ~= 0 then
        if o.oAction == 1 then
            cur_obj_update_floor_and_walls()
            cur_obj_move_standard(78)

            if o.oMoveFlags & (OBJ_MOVE_MASK_ON_GROUND | OBJ_MOVE_UNDERWATER_ON_GROUND | OBJ_MOVE_HIT_WALL) ~= 0 then
                o.oAction = 2
                return
            end
        else
            if o.oNumLootCoins ~= 0 then
                obj_spawn_loot_yellow_coins(o, o.oNumLootCoins, 20)
            end
            spawn_mist_particles_with_sound(ternary(o.oDeathSound == 0, SOUND_ACTION_HIT, o.oDeathSound))
            obj_mark_for_deletion(o)
        end

        return
    end

    local m = states[getLocalFromGlobalIdx(o.oOwner)]
    if is_player_active(m) == 0 or m.action ~= ACT_TAZ_TORNADO_ATTACK then
        if nearest_mario_state_to_object(o).playerIndex == 0 then
            o.oAction = 1
            o.oForwardVel = math.random(30, 60)
            o.oVelY = math.random(20, 80)
            o.oMoveAngleYaw = math.random(-0x7FFF, 0x8000)
            network_send_object(o, true)
        end
        return
    end

    o.oVelY = math.min(o.oVelY + 10, o.oSnufitYOffset)

    o.oPosX = m.pos.x + o.oSnufitZOffset * sins(o.oMoveAngleYaw)
    o.oPosY = m.pos.y + o.oVelY
    o.oPosZ = m.pos.z + o.oSnufitZOffset * coss(o.oMoveAngleYaw)
    obj_set_gfx_pos_from_pos(o)

    o.oMoveAngleYaw = o.oMoveAngleYaw + 0x500
end

---@param o Object
function bhvs.bhv_lt_explosion_init(o)

    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(o)

    o.oIntangibleTimer = 0
    o.oDamageOrCoinValue = 4
    cur_obj_set_hitbox_radius_and_height(200, 150)
    o.hitboxDownOffset = 150

    bhv_explosion_init()
end

---@param o Object
function bhvs.bhv_lt_explosion_loop(o)

    if o.oOpacity == 0 then
        if find_water_level(o.oPosX, o.oPosZ) > o.oPosY then
            for _ = 1, 40 do
                spawn_non_sync_object(id_bhvBobombExplosionBubble, E_MODEL_WHITE_PARTICLE_SMALL, o.oPosX, o.oPosY, o.oPosZ, function()end)
            end
        else
            spawn_non_sync_object(id_bhvBobombBullyDeathSmoke, E_MODEL_SMOKE, o.oPosX, o.oPosY, o.oPosZ, function()end)
        end
        obj_mark_for_deletion(o)
    end

    o.oOpacity = approach_s16_symmetric(o.oOpacity, 0, 20)
    cur_obj_scale(o.oTimer / 9 + 1)

    if o.oTimer <= 9 then
        affectAllObjects(o, obj_check_hitbox_overlap)
    end
end

return bhvs