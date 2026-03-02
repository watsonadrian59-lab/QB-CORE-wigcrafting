local QBCore = exports['qb-core']:GetCoreObject()

-- USEABLE TABLE ITEM
QBCore.Functions.CreateUseableItem("wig_crafting_table", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    TriggerClientEvent("wigcraft:placeTable", source)

    Player.Functions.RemoveItem("wig_crafting_table", 1)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["wig_crafting_table"], "remove")
end)

-- RETURN TABLE
RegisterNetEvent('wigcraft:returnTableItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        Player.Functions.AddItem("wig_crafting_table", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["wig_crafting_table"], "add")
    end
end)

-- CRAFT WIG
RegisterNetEvent('wigcraft:finishCraft', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = data.item

    local recipe = Config.Recipes[item]
    if not recipe then return end

    for mat, amount in pairs(recipe.materials) do
        if not Player.Functions.RemoveItem(mat, amount) then
            TriggerClientEvent('QBCore:Notify', src, "Missing materials", "error")
            return
        end
    end

    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
    TriggerClientEvent('QBCore:Notify', src, "Wig crafted!", "success")
end)

-- SELL WIGS
RegisterNetEvent('wigcraft:sellToNPC', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local payout = 0

    local sellRules = {
        basic_wig  = { amount = 5 },
        premium_wig = { amount = 3 },
        dyed_wig    = { amount = 1 },
        lace_wig      = { amount = 1 },
        full_lace_wig  = { amount = 1 },
        synth_wig     = { amount = 2 }
    }

    for item, rule in pairs(sellRules) do
        local wig = Player.Functions.GetItemByName(item)

        if wig and wig.amount >= rule.amount then
            Player.Functions.RemoveItem(item, rule.amount)

            local price = Config.WigSell.payout[item] or 0
            payout = payout + (price * rule.amount)
        end
    end

    if payout > 0 then
        Player.Functions.AddMoney("cash", payout)
        TriggerClientEvent('QBCore:Notify', src, "Sold wigs for $" .. payout, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Not enough wigs to sell", "error")
    end
end)

-- NETWORK PROP HANDOFF SYNC
RegisterNetEvent('wigcraft:syncBagHandoff', function(dealerNetId)
    TriggerClientEvent('wigcraft:clientBagHandoff', -1, dealerNetId)
end)

-- REQUEST MODEL FALLBACK (optional)
RegisterNetEvent('wigcraft:requestBagModel', function()
    local src = source
    TriggerClientEvent('wigcraft:provideBagModel', src)
end)