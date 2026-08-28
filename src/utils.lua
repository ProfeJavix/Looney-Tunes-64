local nps = gNetworkPlayers
local states = gMarioStates

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
	id_bhvWigglerHead
}

---@param m MarioState
---@param range integer
---@param minDist? number
---@return Object|nil
function getAutoTarget(m, range, minDist)
	minDist = minDist or 2000
	local target = nil

	for _, id in ipairs(targetBhvs) do
		local curO = obj_get_first_with_behavior_id(id)
		while curO do
			if id ~= id_bhvMario or (curO ~= m.marioObj and is_player_active(states[curO.oBehParams - 1]) ~= 0) then
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

	return target
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
            if list == OBJ_LIST_PLAYER then
                local m = states[curO.oBehParams - 1]
                if is_player_active(m) ~= 0 and nps[m.playerIndex].globalIndex ~= attacker.oOwner and
                m.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE and
                m.action & (ACT_FLAG_INVULNERABLE | ACT_FLAG_INTANGIBLE) == 0 and m.invincTimer == 0 then
                    hit = checkFunc(attacker, curO)
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