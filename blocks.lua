local S = minetest.get_translator("um_atm")
local str = tostring

local sound = nil
if minetest.global_exists("zr_stone") then
    sound = zr_stone.sounds
elseif minetest.global_exists("default") then
    sound = default.node_sound_stone_defaults()
elseif minetest.global_exists("mcl_sounds") then
    sound = mcl_sounds.node_sound_stone_defaults()
end

local function register_atm(lvl)
    minetest.register_node("um_atm:atm_" .. str(lvl), {
        description = S("ATM model @1", lvl),
        tiles = {
            "atm" .. ((lvl == 1) and "" or str(lvl)) .. "_top.png", "atm" ..
        ((lvl == 1) and "" or str(lvl)) .. "_top.png",
            "atm" .. ((lvl == 1) and "" or str(lvl)) .. "_side.png", "atm" ..
        ((lvl == 1) and "" or str(lvl)) .. "_side.png",
            "atm" .. ((lvl == 1) and "" or str(lvl)) .. "_side.png", "atm" ..
        ((lvl == 1) and "" or str(lvl)) .. "_front.png"
        },
        paramtype2 = "facedir",
        groups = {
            cracky = 2,
            pickaxey = 1,
            bank_equipment = 1,
            um_atm = 1,
        },
        legacy_facedir_simple = true,
        is_ground_content = false,
        _mcl_blast_resistance = 6,
        _mcl_hardness = 1.5,
        stack_max = minetest.global_exists("mcl_core") and 64 or 99,
        sounds = sound,
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            um_atm.gui:show(player, { lvl = lvl })
        end
    })
end

if um_atm.settings.types.enable_model1 then
    register_atm(1)
end

if um_atm.settings.types.enable_model2 then
    register_atm(2)
end

if um_atm.settings.types.enable_model3 then
    register_atm(3)
end
