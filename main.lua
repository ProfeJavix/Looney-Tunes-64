-- name: [CS] Looney Tunes 64
-- incompatible: cs

if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n[CS] Looney Tunes 64\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return
end

require('src/utils')
require('src/defs')
require('src/animations')
require('src/cs-setup')
local loops = require('src/loops')
local hooks = require('src/hooks')

id_bhvHelicopterEars = hook_behavior(nil, OBJ_LIST_GENACTOR, true, loops.bhv_helicopter_ears_init, loops.bhv_helicopter_ears_loop)
id_bhvMarvinLaser = hook_behavior(nil, OBJ_LIST_GENACTOR, true, loops.bhv_marvin_laser_init, loops.bhv_marvin_laser_loop)

hook_mario_action(ACT_BUGS_HOVER, loops.act_bugs_hover)

hook_event(HOOK_MARIO_UPDATE, function (m)
    if m.controller.buttonPressed == X_BUTTON then
        debugLog('a')
        spawn_sync_object(id_bhvMarvinLaser, E_MODEL_MARVIN_LASER, m.pos.x, m.pos.y, m.pos.z, nil)
    end
end)

hook_event(HOOK_ON_SEQ_LOAD, hooks.on_seq_load)
_G.charSelect.character_hook_moveset(CT_BUGS, HOOK_BEFORE_SET_MARIO_ACTION, hooks.bugs_before_set_mario_action)
_G.charSelect.character_hook_moveset(CT_BUGS, HOOK_ON_SET_MARIO_ACTION, hooks.bugs_on_set_mario_action)