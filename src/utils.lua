local nps = gNetworkPlayers

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