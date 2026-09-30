local nps = gNetworkPlayers
local states = gMarioStates

---@param m MarioState
---@param pPos Vec3f
---@param range integer
---@param minDist? number
---@return Object|nil, integer
function getAutoTarget(m, pPos, range, minDist)
    local targetBhvs = {
        id_bhvMario,
        id_bhvBalconyBigBoo,
        id_bhvBigBully,
        id_bhvBigChillBully,
        id_bhvBobomb,
        id_bhvBoo,
        id_bhvBooWithCage,
        id_bhvBowser,
        id_bhvBulletBill,
        id_bhvChainChomp,
        id_bhvChuckya,
        id_bhvEnemyLakitu,
        id_bhvFlyGuy,
        id_bhvFlyingBookend,
        id_bhvGhostHuntBigBoo,
        id_bhvGhostHuntBoo,
        id_bhvGoomba,
        id_bhvHauntedChair,
        id_bhvKoopa,
        id_bhvMerryGoRoundBigBoo,
        id_bhvMerryGoRoundBoo,
        id_bhvMips,
        id_bhvMoneybag,
        id_bhvMontyMole,
        id_bhvPiranhaPlant,
        id_bhvPokey,
        id_bhvScuttlebug,
        id_bhvSkeeter,
        id_bhvSmallBully,
        id_bhvSmallChillBully,
        id_bhvSmallPenguin,
        id_bhvSnufit,
        id_bhvSpindrift,
        id_bhvSpiny,
        id_bhvToadMessage,
        id_bhvTuxiesMother,
        id_bhvWigglerBody,
        id_bhvWigglerHead,
        id_bhvMarvinTNT
    }

    minDist = minDist or 2000
    local target = nil
    local pitch = 0

    for _, id in ipairs(targetBhvs) do
        local curO = obj_get_first_with_behavior_id(id)
        while curO do
            if curO.activeFlags ~= ACTIVE_FLAG_DEACTIVATED and (id ~= id_bhvMario or
            (curO.oBehParams - 1 ~= m.playerIndex and is_player_active(states[curO.oBehParams - 1]) ~= 0)) then
                local dist = dist_between_objects(m.marioObj, curO)
                if dist < minDist and
                math.abs(obj_pitch_to_object(m.marioObj, curO)) < 0x2200 and
                abs_angle_diff(obj_angle_to_object(m.marioObj, curO), m.faceAngle.y) < range then
                    minDist = dist
                    target = curO
                end
            end

            curO = obj_get_next_with_same_behavior_id(curO)
        end
    end

    if target then
        local mPos = gVec3fZero()
        object_pos_to_vec3f(mPos, m.marioObj)
        target.oPosY = target.oPosY + target.hitboxHeight / 2

        vec3f_to_object_pos(m.marioObj, pPos)
        pitch = obj_pitch_to_object(m.marioObj, target)

        vec3f_to_object_pos(m.marioObj, mPos)
        target.oPosY = target.oPosY - target.hitboxHeight / 2
    end

    return target, pitch
end

local validAffectLists = {
    OBJ_LIST_PLAYER,
    OBJ_LIST_PUSHABLE,
    OBJ_LIST_GENACTOR,
    OBJ_LIST_DESTRUCTIVE,
    OBJ_LIST_SURFACE
}

---@param attacker Object
---@param checkFunc fun(att: Object, vic: Object): boolean
---@param onlyFirst? boolean
---@return boolean
function affectAllObjects(attacker, checkFunc, onlyFirst)
    for _, list in ipairs(validAffectLists) do
        local curO = nil
        if list == OBJ_LIST_SURFACE then
            local colData = collision_get_temp_wall_collision_data()
            colData.x = attacker.oPosX
            colData.y = attacker.oPosY
            colData.z = attacker.oPosZ
            colData.radius = attacker.hitboxRadius
            colData.offsetY = attacker.hitboxDownOffset
            if find_wall_collisions(colData) ~= 0 then
                if colData.walls[colData.numWalls].object then
                    curO = colData.walls[colData.numWalls].object
                end
            end
        else
            curO = obj_get_first(list)
        end

        while curO do
            local hit = false

            if curO ~= attacker then
                if list == OBJ_LIST_PLAYER then
                    local m = states[curO.oBehParams - 1]
                    if is_player_active(m) ~= 0 and m.invincTimer == 0 and
                    (obj_has_behavior_id(attacker, id_bhvMario) ~= 0 or nps[m.playerIndex].globalIndex ~= attacker.oOwner) and
                    m.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE and m.action & (ACT_FLAG_INVULNERABLE | ACT_FLAG_INTANGIBLE) == 0 then
                        hit = checkFunc(attacker, curO)
                        if hit then
                            interact_damage(m, 0, attacker)
                        end
                    end
                elseif list == OBJ_LIST_SURFACE then
                    hit = true
                    curO.oInteractStatus = curO.oInteractStatus | (INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED)
                else
                    if obj_is_attackable(curO) or (obj_has_behavior_id(curO, id_bhvChainChomp) ~= 0 and obj_is_valid_for_interaction(curO)) then
                        hit = checkFunc(attacker, curO)
                        if hit then
                            curO.oInteractStatus = (ATTACK_PUNCH | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED | INT_STATUS_TOUCHED_BOB_OMB)
                        end
                    elseif (obj_is_bully(curO) or obj_has_behavior_id(curO, id_bhvBobomb) ~= 0) and obj_is_valid_for_interaction(curO) then
                        hit = checkFunc(attacker, curO)
                        if hit then
                            curO.oInteractStatus = (ATTACK_KICK_OR_TRIP | INT_STATUS_MARIO_UNK1 | INT_STATUS_INTERACTED)
                        end
                    end
                end
            end

            if list ~= OBJ_LIST_SURFACE then
                curO = obj_get_next(curO)
                if hit and onlyFirst then
                    return true
                end
            elseif hit then
                return true
            end
        end
    end
    return false
end

---@param o Object
---@param speed number
---@param stopFlags integer
---@param hitFunc? fun(projectile: Object): boolean
---@return integer
function moveProjectile(o, speed, stopFlags, hitFunc)
    for i = 1, math.ceil(speed / 40) do
        local fVel = ternary(i * 40 <= speed, 40, speed - (40 * (i - 1)))
        cur_obj_update_floor_and_walls()

        obj_compute_vel_from_move_pitch(fVel)
        cur_obj_compute_vel_xz()

        if hitFunc and hitFunc(o) then
            return 1
        elseif o.oMoveFlags & stopFlags ~= 0 then
            return 2
        end

        o.oPosX = o.oPosX + o.oVelX
        o.oPosY = o.oPosY + o.oVelY
        o.oPosZ = o.oPosZ + o.oVelZ
    end

    return 0
end

---@param localIdx? integer
---@return boolean
function isLT64Char(localIdx)
    return LT_64_CHARS[_G.charSelect.character_get_current_number(localIdx)]
end

---@param o Object
---@return boolean
function isDoorUnlocked(o)

    local behParamsValue = o.oBehParams >> 24

    if o.oInteractType == INTERACT_WARP_DOOR then

        if behParamsValue ~= 1 and behParamsValue ~= 2 then
            return true
        end

        local saveFlags = save_file_get_flags()
        local cond1 = saveFlags & (SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR | SAVE_FLAG_HAVE_KEY_2) ~= 0
        local cond2 = saveFlags & (SAVE_FLAG_UNLOCKED_BASEMENT_DOOR | SAVE_FLAG_HAVE_KEY_1) ~= 0

        return (behParamsValue == 1 and cond1) or (behParamsValue == 2 and cond2)
    end

    return save_file_get_total_star_count(get_current_save_file_num() - 1, COURSE_MIN - 1, COURSE_MAX - 1) >= behParamsValue or
    behParamsValue == 70
end

---@param globalIdx integer
---@return integer
function getLocalFromGlobalIdx(globalIdx)
    if globalIdx < 0 or globalIdx >= MAX_PLAYERS then return -1 end

    for i = 0, MAX_PLAYERS - 1 do
        if nps[i].connected and nps[i].globalIndex == globalIdx then
            return i
        end
    end
    return -1
end

---@param cond? boolean
---@param ifTrue any
---@param ifFalse any
function ternary(cond, ifTrue, ifFalse)
    if cond then
        return ifTrue
    else
        return ifFalse
    end
end

function debugLog(msg, ...)
    local parts = { tostring(msg) }

    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        table.insert(parts, tostring(arg))
    end

    djui_chat_message_create(table.concat(parts, " "))
end

return {}
