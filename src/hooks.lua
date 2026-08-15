local hooks = {}

---@param player integer
---@param seqId SeqId
function hooks.on_seq_load(player, seqId)

    audio_stream_stop(STREAM_CREDITS)

    if seqId == SEQ_EVENT_CUTSCENE_ENDING then
        audio_stream_set_looping(STREAM_CREDITS, true)
        audio_stream_play(STREAM_CREDITS, true, 1)
        return 0
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
function hooks.bugs_before_set_mario_action(m, incAct)

    if m.action == ACT_BUGS_HOVER then
        m.marioBodyState.allowPartRotation = 0
    end

    if incAct == ACT_TRIPLE_JUMP then
        set_mario_y_vel_based_on_fspeed(m, 69, 0)
        m.forwardVel = m.forwardVel * 0.8
        return set_mario_action(m, ACT_BUGS_HOVER, 0)
    end
end

---@param m MarioState
function hooks.bugs_on_set_mario_action(m)
    if JUMP_ACTIONS[m.action] then
        m.vel.y = m.vel.y * 1.5
    end
end

return hooks