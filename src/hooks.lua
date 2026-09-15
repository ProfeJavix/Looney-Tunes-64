local nps = gNetworkPlayers
local playerTable = gPlayerSyncTable

local hooks = {}

function hooks.update()
    if playerTable[0].blockCTActsTimer > 0 then
        playerTable[0].blockCTActsTimer = playerTable[0].blockCTActsTimer - 1
    end
end

---@param m MarioState
---@param incAct integer
function hooks.before_set_mario_action(m, incAct)

    if not _G.charSelect.gCSPlayers[m.playerIndex].movesetToggle then return end

    local repData = CT_REPLACE_ACTS[_G.charSelect.character_get_current_number(m.playerIndex)]

    if repData then
        local param = 1
        if repData.param then
            param = repData.param(m, incAct)
        end

        if repData.acts[param] then
            if playerTable[m.playerIndex].blockCTActsTimer == 0 then
                return set_mario_action(m, repData.acts[param], 0)
            end
            return 1
        end
    end
end

---@param m MarioState
---@param o Object
---@param intType InteractionType
---@param interacted boolean
function hooks.on_interact(m, o, intType, interacted)

    if not _G.charSelect.gCSPlayers[m.playerIndex].movesetToggle then return end

    local repData = CT_REPLACE_ACTS[_G.charSelect.character_get_current_number(m.playerIndex)]

    if not repData or not repData.actsSet[m.action] then return end

    if intType == INTERACT_GRABBABLE and
    not interacted and
    o.oInteractionSubtype & INT_SUBTYPE_NOT_GRABBABLE == 0 and
    repData.canGrab(m) then
        m.interactObj = o
        m.input = m.input | INPUT_INTERACT_OBJ_GRABBABLE

        if o.oSyncID ~= 0 then
            network_send_object(o, true)
        end
    end
end

---@param seqId SeqId
function hooks.on_seq_load(_, seqId)

    audio_stream_stop(STREAM_CREDITS)

    if seqId == SEQ_EVENT_CUTSCENE_CREDITS then
        audio_stream_set_looping(STREAM_CREDITS, true)
        audio_stream_play(STREAM_CREDITS, true, 1)
        return 0
    end
end

---@param soundId integer
---@param pos Vec3f
function hooks.on_play_sound(soundId, pos)

    if soundId == SOUND_MENU_THANK_YOU_PLAYING_MY_GAME then
        local clip = CT_THANKS_FOR_PLAYING_CLIPS[_G.charSelect.character_get_current_number()]

        if clip then
            audio_sample_play(clip, pos, 5)
            return 0
        end
    end
end

local JUMP_ACTIONS = {
    [ACT_JUMP] = true,
    [ACT_HOLD_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_LONG_JUMP] = true,
    [ACT_STEEP_JUMP] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_BURNING_JUMP] = true,
    [ACT_WATER_JUMP] = true,
    [ACT_HOLD_WATER_JUMP] = true,
    [ACT_METAL_WATER_JUMP] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_SPECIAL_TRIPLE_JUMP] = true,
    [ACT_RIDING_SHELL_JUMP] = true,
    [ACT_WALL_KICK_AIR] = true
}

---@param m MarioState
function hooks.bugs_on_set_mario_action(m)
    if JUMP_ACTIONS[m.action] then
        m.vel.y = m.vel.y * 1.5
    end
end

---@param m MarioState
function hooks.daffy_before_phys_step(m)
    if m.action & ACT_FLAG_SWIMMING ~= 0 and
    m.action & ACT_FLAG_INVULNERABLE == 0 and
    m.action ~= ACT_WATER_PLUNGE then
        vec3f_mul(m.vel, 3)
    end
end

---@param m MarioState
function hooks.marvin_mario_update(m)
    if m.controller.buttonPressed == X_BUTTON and
    playerTable[m.playerIndex].blockCTActsTimer == 0 and
    m.floorHeight == m.pos.y and
    m.action & (PREVENT_ACT_FLAGS) == 0 and
    not PREVENT_ACT_GROUPS[m.action & ACT_GROUP_MASK] and
    m.action ~= ACT_MARVIN_SHOOT_LASER and m.action ~= ACT_MARVIN_GRAB_TNT then
        set_mario_action(m, ACT_MARVIN_GRAB_TNT, 0)
    end
end

return hooks