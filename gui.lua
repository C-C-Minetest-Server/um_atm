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
        local currency_name = enabled_count[t]
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

        local currency_name = enabled_count[t]
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

local function handle_currency_action(t, amount)
    if amount < 0 then
        return handle_currency_add(t, -amount)
    end
    return handle_currency_take(t, amount)
end

local function handle_deposit_all(t)
    return function(player, ctx)
        local name = player:get_player_name()
        local inv = player:get_inventory()
        local currency_name = enabled_count[t]

        local stack = inv:remove_item("main", currency_name .. " 65535")
        local amount = stack:get_count() * enabled_key[currency_name]

        unified_money.add_balance(name, amount)
        return true
    end
end

local function handle_withdraw_all(t)
    return function(player, ctx)
        local name = player:get_player_name()
        local inv = player:get_inventory()
        local balance = unified_money.get_balance_safe(name)

        local take = math.floor(balance / t)
        balance = balance % t

        local stack = ItemStack(enabled_count[t])
        stack:set_count(take)
        stack = inv:add_item("main", stack)
        balance = balance + (stack:get_count() * t)

        unified_money.set_balance_safe(name, balance)

        return true
    end
end

local function count_item(player, t)
    local itemname = enabled_count[t]
    local inv = player:get_inventory()
    local count = 0

    for _, stack in ipairs(inv:get_list("main")) do
        if stack:get_name() == itemname then
            count = count + stack:get_count()
        end
    end
    return count
end

local function signed(num)
    return (num < 0 and "-" or "+") .. tostring(math.abs(num))
end

local columns_lvl = {
    [1] = { -1, 1 },
    [2] = { -10, -1, 1, 10, },
    [3] = { false, -100, -10, -1, 1, 10, 100, true }
}

local insert = table.insert

um_atm.gui = flow.make_gui(function(player, ctx)
    local name = player:get_player_name()
    local balance = unified_money.get_balance_safe(name)
    ctx.lvl = ctx.lvl or 1

    local columns = columns_lvl[ctx.lvl] or columns_lvl[1]
    local body = {} -- VBox

    insert(body, gui.Stack {
        gui.Label {
            align_h = "center", expand = true,
            label = S("Deposit / Withdraw"),
        },
        gui.ButtonExit {
            align_h = "right", expand = true,
            w = 0.7, h = 0.7, label = "x"
        }
    })

    for _, money in ipairs(enabled_currency) do
        if ctx.lvl > 1 or money <= 10 then
            local row = {} -- HBox
            insert(row, gui.ItemImage {
                w = 1, h = 1,
                item_name = (money ~= 1) and ("currency:minegeld_" .. str(money)) or "currency:minegeld"
            })
            for _, amount in ipairs(columns) do
                if type(amount) == "boolean" then
                    insert(row, gui.Button {
                        w = 1, h = 1,
                        label = (amount and "+" or "-") .. S("ALL"),
                        on_event = (amount and handle_withdraw_all or handle_deposit_all)(money)
                    })
                else
                    insert(row, gui.Button {
                        w = 1, h = 1,
                        label = signed(amount),
                        on_event = handle_currency_action(money, amount)
                    })
                end
            end

            insert(row, gui.Label {
                w = 1, h = 1,
                label = S("You have:@n@1", count_item(player, money))
            })

            insert(body, gui.HBox(row))
        end
    end

    insert(body, (ctx.lvl == 1 and gui.VBox or gui.HBox) {
        gui.Label {
            label = um_translate_common.balance_show(balance),
            expand = true,
        },
        gui.Label {
            label = S("-: Deposit / +: Withdraw"),
            expand = true,
        },
    })

    return gui.VBox(body)
end)
