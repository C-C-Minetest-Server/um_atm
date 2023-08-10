local steel = nil
local mese = nil
local glass = nil
local cheap = nil

if minetest.get_modpath("mcl_core") then
    steel = "mcl_core:iron_ingot"
    mese = "mcl_core:emerald"
    glass = "mcl_core:glass"
    cheap = "mcl_core:iron_ingot"
    if minetest.get_modpath("mcl_copper") then
        cheap = "mcl_copper:copper_ingot"
    end
elseif minetest.get_modpath("default") then
    steel = "default:steel_ingot"
    mese = "default:mese_crystal"
    glass = "default:glass"
    cheap = "default:copper_ingot"
else
    if minetest.get_modpath("zr_iron") then
        steel = "zr_iron:ingot"
    end
    if minetest.get_modpath("zr_mese") then
        mese = "zr_mese:crystal"
    end
    if minetest.get_modpath("zr_glass") then
        glass = "zr_glass:glass"
    end
    if minetest.get_modpath("zr_copper") then
        cheap = "zr_copper:ingot"
    end
end
if minetest.get_modpath("mesecons_wires") then
    cheap = "mesecons:wire_00000000_off"
end

if not(steel and mese and glass and cheap) then
    minetest.log("warning","[um_atm] No valid craft items found, giving up.")
    return
end

if um_atm.settings.types.enable_model1 then
    minetest.register_craft({
        output = "um_atm:atm_1",
        recipe = {
            {steel, cheap, steel},
            {glass, "currency:minegeld", steel},
            {steel, cheap, steel}
        }
    })
end

if um_atm.settings.types.enable_model2 then
    minetest.register_craft({
        output = "um_atm:atm_2",
        recipe = {
            {steel, mese, steel},
            {glass, "currency:minegeld_5", steel},
            {steel, mese, steel}
        }
    })
end

if um_atm.settings.types.enable_model3 then
    minetest.register_craft({
        output = "um_atm:atm_3",
        recipe = {
            {steel, mese, steel},
            {glass, "currency:minegeld_10", steel},
            {steel, mese, steel}
        }
    })
end