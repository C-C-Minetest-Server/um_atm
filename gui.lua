local gui = flow.widgets
local S = minetest.get_translator("um_atm")

local str = tostring

local enabled_currency = {}
for _, n in ipairs({ 1, 5, 10, 50, 100 }) do
    if um_atm.settings.currency["enable_" .. str(n)] then
        table.insert(enabled_currency, n)
    end
end

local enabled_key = {}
local enabled_count = {}
for _, t in ipairs(enabled_currency) do
    enabled_key[(t ~= 1) and ("currency:minegeld_" .. str(t)) or "currency:minegeld"] = t
    enabled_count[t] = (t ~= 1) and ("currency:minegeld_" .. str(t)) or "currency:minegeld"
end

local function handle_currency_take(t, amount)
    return function(player, ctx)
        local name = player:get_player_name()
        local balance = unified_money.get_balance_safe(name)

        local to_be_taken = t * amount
        if to_be_taken > balance then
            minetest.chat_send_player(name, S("Not enough money in your account"))
            return false
        end

        local inv = player:get_inventory()
        local currency_name = (t ~= 1) and ("currency:minegeld_" .. str(t)) or "currency:minegeld"
        local stack = ItemStack(currency_name .. " " .. str(amount))
        if not inv:room_for_item("main", stack) then
            minetest.chat_send_player(name, S("Not enough room in your inventory"))
            return false
        end

        local status = unified_money.del_balance(name, to_be_taken)
        if not status then
            minetest.chat_send_player(name, S("Transaction failed."))
            return true
        end
        inv:add_item("main", stack)
        return true
    end
end

local function handle_currency_add(t, amount)
    return function(player, ctx)
        local name = player:get_player_name()
        local inv = player:get_inventory()

        local currency_name = (t ~= 1) and ("currency:minegeld_" .. str(t)) or "currency:minegeld"
        local stack = ItemStack(currency_name .. " " .. str(amount))
        if not inv:contains_item("main", stack) then
            minetest.chat_send_player(name, S("Not enough money in your inventory"))
            return false
        end

        local to_be_taken = t * amount

        local status = unified_money.add_balance(name, to_be_taken)
        if not status then
            minetest.chat_send_player(name, S("Transaction failed."))
            return true
        end

        inv:remove_item("main", stack)
        return true
    end
end


um_atm.gui = flow.make_gui(function(player, ctx)
    local name = player:get_player_name()
    local balance = unified_money.get_balance_safe(name)
    ctx.lvl = ctx.lvl or 1

    local header = gui.Stack {
        gui.Label {
            align_h = "center", expand = true,
            label = um_translate_common.balance_show(balance),
        },
        gui.ButtonExit {
            align_h = "right", expand = true,
            w = 0.7, h = 0.7, label = "x"
        }
    }

    local amounts = { 1 }
    if ctx.lvl >= 2 then
        table.insert(amounts, 10)
        if ctx.lvl >= 3 then
            table.insert(amounts, 100)
        end
    end

    local body = {}    -- Hbox or VBox depends on lvl

    do                 -- Money input
        local lbox = { -- VBox
            gui.Label {
                align_h = "center",
                label = S("Money input"),
            },
        }
        do
            local col1 = {} -- HBox
            for _, n in ipairs(enabled_currency) do
                table.insert(col1, gui.ItemImage {
                    w = 1, h = 1,
                    item_name = (n ~= 1) and ("currency:minegeld_" .. str(n)) or "currency:minegeld"
                })
            end
            table.insert(lbox, gui.Hbox(col1))
        end
        for _, a in ipairs(amounts) do
            local col = {} -- HBox
            for _, n in ipairs(enabled_currency) do
                table.insert(col, gui.Button {
                    w = 1, h = 1,
                    label = str(a),
                    on_event = handle_currency_add(n, a)
                })
            end
            table.insert(lbox, gui.Hbox(col))
        end
        table.insert(lbox, gui.Button {
            w = 1, h = 1,
            label = S("Inventory to ATM"),
            on_event = function(player, ctx)
                local name = player:get_player_name()
                local inv = player:get_inventory()

                local main_size = inv:get_size("main")
                for i = 1, main_size do
                    local stack = inv:get_stack("main", i)
                    if enabled_key[stack:get_name()] then
                        local count = stack:get_count()
                        local amount = count * enabled_key[stack:get_name()]

                        unified_money.add_balance(name, amount)
                        inv:set_stack("main", i, ItemStack())
                    end
                end
                return true
            end
        })
        table.insert(body, gui.Vbox(lbox))
    end

    table.insert(body, gui.Box { w = 0.05, h = 0.05, color = "grey", padding = 0 })

    do                 -- Money output
        local rbox = { -- VBox
            gui.Label {
                align_h = "center",
                label = S("Money output"),
            },
        }
        do
            local col1 = {} -- HBox
            for _, n in ipairs(enabled_currency) do
                table.insert(col1, gui.ItemImage {
                    w = 1, h = 1,
                    item_name = (n ~= 1) and ("currency:minegeld_" .. str(n)) or "currency:minegeld"
                })
            end
            table.insert(rbox, gui.Hbox(col1))
        end
        for _, a in ipairs(amounts) do
            local col = {} -- HBox
            for _, n in ipairs(enabled_currency) do
                table.insert(col, gui.Button {
                    w = 1, h = 1,
                    label = str(a),
                    on_event = handle_currency_take(n, a)
                })
            end
            table.insert(rbox, gui.Hbox(col))
        end
        table.insert(rbox, gui.Button {
            w = 1, h = 1,
            label = S("ATM to Inventory"),
            on_event = function(player, ctx)
                local name = player:get_player_name()
                local inv = player:get_inventory()
                local balance = unified_money.get_balance_safe(name)

                for _, n in ipairs({ 100, 50, 10, 5, 1 }) do
                    if enabled_count[n] then
                        local take = math.floor(balance / n)
                        balance = balance % n

                        local stack = ItemStack(enabled_count[n])
                        stack:set_count(take)
                        stack = inv:add_item("main", stack)
                        balance = balance + (stack:get_count() * n)
                    end
                end

                unified_money.set_balance_safe(name, balance)

                return true
            end
        })
        table.insert(body, gui.Vbox(rbox))
    end

    return gui.VBox {
        header,
        ((ctx.lvl == 1) and gui.VBox or gui.HBox)(body)
    }
end)
