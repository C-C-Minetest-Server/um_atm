um_atm = {}

um_atm.settings = {
    types = {
        enable_model1 = minetest.settings:get_bool("um_atm.types.enable_model1",true),
        enable_model2 = minetest.settings:get_bool("um_atm.types.enable_model2",true),
        enable_model3 = minetest.settings:get_bool("um_atm.types.enable_model3",true),
    },
    currency = {
        enable_1 = minetest.settings:get_bool("um_atm.currency.enable_1",true),
        enable_5 = minetest.settings:get_bool("um_atm.currency.enable_5",true),
        enable_10 = minetest.settings:get_bool("um_atm.currency.enable_10",true),
        enable_50 = minetest.settings:get_bool("um_atm.currency.enable_50",true),
        enable_100 = minetest.settings:get_bool("um_atm.currency.enable_100",true),
    }
}

local MP = minetest.get_modpath("um_atm")
dofile(MP .. "/gui.lua")
dofile(MP .. "/blocks.lua")
dofile(MP .. "/craft.lua")