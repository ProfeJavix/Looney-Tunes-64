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
---@field lifeIcon? TextureInfo
---@field camScale? number
---@field palettes? PaletteData[]
---@field animData? AnimData
---@field voices? table
---@field hasPowerMeter? boolean

---@class PaletteData
---@field palette table
---@field name? string

---@class AnimData
---@field animTable? table
---@field eyeTable? table
---@field handTable? table

ACT_BUGS_HOVER = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING)

E_MODEL_BUGS_EARS = smlua_model_util_get_id('bugs_ears_geo')
E_MODEL_MARVIN_LASER = smlua_model_util_get_id('marvin_laser_geo')

ANIM_BUGS_CS_MENU = 'ANIM_BUGS_CS_MENU'
ANIM_DAFFY_CS_MENU = 'ANIM_DAFFY_CS_MENU'
ANIM_PORKY_CS_MENU = 'ANIM_PORKY_CS_MENU'
ANIM_SYLVESTER_CS_MENU = 'ANIM_SYLVESTER_CS_MENU'
ANIM_MARVIN_CS_MENU = 'ANIM_MARVIN_CS_MENU'

STREAM_CREDITS = audio_stream_load('LT64 Credits.ogg')

define_custom_obj_fields({
    oOwner = "s32"
})

---@param node GraphNode
function geo_switch_bugs_ears(node)
    local gn = cast_graph_node(node)
    local m = geo_get_mario_state()

    if m.action == ACT_BUGS_HOVER and m.actionState == 1 then
        gn.selectedCase = 2
    else
        local capState = geo_get_body_state().capState
        local next = node.next

        gn.selectedCase = capState & 1

        while next and next ~= node do
            if next.type == GRAPH_NODE_TYPE_TRANSLATION_ROTATION then
                if capState & 2 ~= 0 then
                    next.flags = next.flags | GRAPH_RENDER_ACTIVE
                else
                    next.flags = next.flags & ~GRAPH_RENDER_ACTIVE
                end
            end
            next = next.next
        end
    end
end

---@param node GraphNode
function geo_switch_ears_state(node)
    local gn = cast_graph_node(node)
    local o = geo_get_current_object()

    gn.selectedCase = o.oAction
end

function geo_mallet_switch(node)
    local gn = cast_graph_node(node)
    gn.selectedCase = 1
end

function geo_railgun_switch(node)
    local gn = cast_graph_node(node)
    gn.selectedCase = 1
end