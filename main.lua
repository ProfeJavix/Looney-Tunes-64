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

id_bhvHelicopterEars = hook_behavior(nil, OBJ_LIST_EXT, true, loops.bhv_helicopter_ears_init, loops.bhv_helicopter_ears_loop)
id_bhvElmerBullet = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, loops.bhv_elmer_bullet_init, loops.bhv_elmer_bullet_loop)
id_bhvMarvinLaser = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, loops.bhv_marvin_laser_init, loops.bhv_marvin_laser_loop)

hook_mario_action(ACT_BUGS_HOVER, loops.act_bugs_hover)
hook_mario_action(ACT_ELMER_SHOOT_SHOTGUN, loops.act_elmer_shoot_shotgun)
hook_mario_action(ACT_ELMER_AIR_SHOOT_SHOTGUN, loops.act_elmer_shoot_shotgun)

hook_event(HOOK_UPDATE, hooks.update)
hook_event(HOOK_ON_SEQ_LOAD, hooks.on_seq_load)
hook_event(HOOK_ON_PLAY_SOUND, hooks.on_play_sound)

_G.charSelect.character_hook_moveset(CT_BUGS, HOOK_BEFORE_SET_MARIO_ACTION, hooks.bugs_before_set_mario_action)
_G.charSelect.character_hook_moveset(CT_BUGS, HOOK_ON_SET_MARIO_ACTION, hooks.bugs_on_set_mario_action)
_G.charSelect.character_hook_moveset(CT_ELMER, HOOK_BEFORE_SET_MARIO_ACTION, hooks.elmer_before_set_mario_action)
_G.charSelect.character_hook_moveset(CT_ELMER, HOOK_ON_INTERACT, hooks.elmer_on_interact)