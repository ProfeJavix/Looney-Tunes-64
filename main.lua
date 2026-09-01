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
local bhvs = require('src/behaviors')
local actions = require('src/actions')
local hooks = require('src/hooks')

id_bhvHelicopterEars = hook_behavior(nil, OBJ_LIST_EXT, true, bhvs.bhv_helicopter_ears_init, bhvs.bhv_helicopter_ears_loop)
id_bhvElmerBullet = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, bhvs.bhv_elmer_bullet_init, bhvs.bhv_elmer_bullet_loop)
id_bhvMarvinLaser = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, bhvs.bhv_marvin_laser_init, bhvs.bhv_marvin_laser_loop)
id_bhvMarvinTNT = hook_behavior(nil, OBJ_LIST_GENACTOR, true, bhvs.bhv_marvin_tnt_init, bhvs.bhv_marvin_tnt_loop)
id_bhvMarvinTNTSmoke = hook_behavior(nil, OBJ_LIST_DEFAULT, true, bhvs.bhv_marvin_tnt_smoke_init, bhvs.bhv_marvin_tnt_smoke_loop)
id_bhvLTExplosion = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, bhvs.bhv_lt_explosion_init, bhvs.bhv_lt_explosion_loop)

hook_mario_action(ACT_BUGS_HOVER, actions.act_bugs_hover)
hook_mario_action(ACT_ELMER_SHOOT_SHOTGUN, actions.act_elmer_shoot_shotgun)
hook_mario_action(ACT_ELMER_AIR_SHOOT_SHOTGUN, actions.act_elmer_shoot_shotgun)
hook_mario_action(ACT_MARVIN_SHOOT_LASER, actions.act_marvin_shoot_laser)
hook_mario_action(ACT_MARVIN_AIR_SHOOT_LASER, actions.act_marvin_shoot_laser)
hook_mario_action(ACT_MARVIN_GRAB_TNT, actions.act_marvin_grab_tnt)

hook_event(HOOK_UPDATE, hooks.update)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, hooks.before_set_mario_action)
hook_event(HOOK_ON_INTERACT, hooks.on_interact)
hook_event(HOOK_ON_SEQ_LOAD, hooks.on_seq_load)
hook_event(HOOK_ON_PLAY_SOUND, hooks.on_play_sound)

_G.charSelect.character_hook_moveset(CT_BUGS, HOOK_BEFORE_SET_MARIO_ACTION, hooks.bugs_before_set_mario_action)
_G.charSelect.character_hook_moveset(CT_BUGS, HOOK_ON_SET_MARIO_ACTION, hooks.bugs_on_set_mario_action)
_G.charSelect.character_hook_moveset(CT_MARVIN, HOOK_MARIO_UPDATE, hooks.marvin_mario_update)