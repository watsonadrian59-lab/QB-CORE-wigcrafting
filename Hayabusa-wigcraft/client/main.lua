local QBCore = exports['qb-core']:GetCoreObject()

-- =====================================
-- RADIAL MENU: WIG SELLING OPTION
-- =====================================
CreateThread(function()
    exports['qb-radialmenu']:AddOption({
        id = 'wig_selling',
        title = 'Wig Selling',
        icon = 'user',
        type = 'client',
        event = 'wigcraft:toggleWigSelling',
        shouldClose = true,
        enabled = true
    })
end)


local placedTable = nil
local wigSelling = false
local uiOpen = false

-- OPEN SHOP
RegisterNetEvent('wigcraft:openShop', function()
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "wigshop", {
        label = "Wig Ingredient Shop",
        items = Config.IngredientShop.items
    })
end)

-- CORNER SELL TOGGLE
RegisterNetEvent('wigcraft:toggleWigSelling', function()
    if not QBCore.Functions.HasItem('basic_wig') and
               not QBCore.Functions.HasItem('premium_wig') and
               not QBCore.Functions.HasItem('dyed_wig') and
               not QBCore.Functions.HasItem('lace_wig') and
               not QBCore.Functions.HasItem('full_wig') and
               not QBCore.Functions.HasItem('synth_wig') then

        QBCore.Functions.Notify("You have no wigs to sell", "error")
        return
    end

    -- toggle selling
    wigSelling = not wigSelling

    if wigSelling then
        QBCore.Functions.Notify("Wig selling enabled", "success")
        TriggerEvent('wigcraft:startWigSellingLoop')
    else
        QBCore.Functions.Notify("Wig selling disabled", "error")
    end
end)

-- NPC DEAL LOOP
RegisterNetEvent('wigcraft:startWigSellingLoop', function()
    CreateThread(function()

        while true do
            Wait(1000)

            -- STOP IF SELLING TURNED OFF
            if not wigSelling then
                return
            end

            -- STOP IF NO WIGS TO SELL
            if not QBCore.Functions.HasItem('basic_wig') and
               not QBCore.Functions.HasItem('premium_wig') and
               not QBCore.Functions.HasItem('dyed_wig') and
               not QBCore.Functions.HasItem('lace_wig') and
               not QBCore.Functions.HasItem('full_lace_wig') and
               not QBCore.Functions.HasItem('synth_wig') then

                wigSelling = false
                QBCore.Functions.Notify("No wigs left — selling disabled", "error")
                return
            end

            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

            local femaleModels = {
                "a_f_m_business_02",
                "a_f_y_business_01",
                "a_f_y_business_02",
                "a_f_y_business_03"
            }

            local model = GetHashKey(femaleModels[math.random(#femaleModels)])
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(10) end

            local spawnPos = coords + vector3(math.random(12, 25), math.random(12, 25), 0)
            local dealer = CreatePed(4, model, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, true)

            SetEntityAsMissionEntity(dealer, true, true)
            SetBlockingOfNonTemporaryEvents(dealer, true)
            SetPedCanRagdoll(dealer, false)

            TaskGoToEntity(dealer, playerPed, -1, 1.2, 1.0, 0, 0)

            -- DISTANCE CHECK
            local timeout = 0
            while true do
                Wait(250)

                if not DoesEntityExist(dealer) then
                    break
                end

                local dist = #(GetEntityCoords(dealer) - GetEntityCoords(playerPed))

                if dist <= 3.5 then
                    break
                end

                TaskGoToEntity(dealer, playerPed, -1, 1.2, 1.0, 0, 0)

                timeout = timeout + 1
                if timeout > 160 then
                    ClearPedTasksImmediately(dealer)
                    DeleteEntity(dealer)
                    break
                end
            end

            if not DoesEntityExist(dealer) then
                goto continue
            end

            -- HANDOFF ANIMATION
            ClearPedTasksImmediately(dealer)
            ClearPedTasksImmediately(playerPed)

            RequestAnimDict("mp_common")
            while not HasAnimDictLoaded("mp_common") do Wait(10) end

            local bagModel = GetHashKey("shearlingshopperbag")
            if not IsModelValid(bagModel) then
                bagModel = GetHashKey("prop_shopping_bags01")
            end

            RequestModel(bagModel)
            while not HasModelLoaded(bagModel) do Wait(10) end

            local bag = CreateObject(bagModel, 0.0, 0.0, 0.0, true, true, false)

            AttachEntityToEntity(
                bag,
                playerPed,
                GetPedBoneIndex(playerPed, 57005),
                0.15, 0.0, -0.05,
                0.0, 270.0, 0.0,
                true, true, false, true, 1, true
            )

            TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, 2500, 49, 0, false, false, false)
            TaskPlayAnim(dealer, "mp_common", "givetake1_b", 8.0, -8.0, 2500, 49, 0, false, false, false)

            Wait(2000)

            DetachEntity(bag, true, true)

            AttachEntityToEntity(
                bag,
                dealer,
                GetPedBoneIndex(dealer, 57005),
                0.15, 0.0, -0.05,
                0.0, 270.0, 0.0,
                true, true, false, true, 1, true
            )

            Wait(1500)

            TaskWanderStandard(dealer, 10.0, 10)

            Wait(2500)

            DeleteEntity(bag)
            DeleteEntity(dealer)

            TriggerServerEvent('wigcraft:sellToNPC')

            ::continue::
        end
    end)
end)

-- PLACE TABLE WITH THIRD EYE
RegisterNetEvent('wigcraft:placeTable', function()
    if placedTable then
        QBCore.Functions.Notify("You already placed a crafting table", "error")
        return
    end

    local playerPed = PlayerPedId()
    local model = GetHashKey(Config.Crafting.tableModel)

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local forward = GetEntityForwardVector(playerPed)
    local coords = GetEntityCoords(playerPed) + (forward * 1.5)

    placedTable = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    PlaceObjectOnGroundProperly(placedTable)
    FreezeEntityPosition(placedTable, true)

    exports['qb-target']:AddTargetEntity(placedTable, {
        options = {
            {
                type = "client",
                event = "wigcraft:openTabletUI",
                icon = "fas fa-cut",
                label = "Drip City Wig Crafting"
            },
            {
                type = "client",
                event = "wigcraft:pickupTable",
                icon = "fas fa-box",
                label = "Pick Up Table"
            }
        },
        distance = 2.0
    })

    TriggerServerEvent('wigcraft:removeTableItem')
    QBCore.Functions.Notify("Crafting table placed", "success")
end)

RegisterNetEvent('wigcraft:pickupTable', function()
    if not placedTable then return end

    exports['qb-target']:RemoveTargetEntity(placedTable)
    DeleteEntity(placedTable)
    placedTable = nil

    TriggerServerEvent('wigcraft:returnTableItem')
    QBCore.Functions.Notify("Crafting table picked up", "success")
end)

-- OPEN UI
RegisterNetEvent('wigcraft:openTabletUI', function()
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "open",
        recipes = Config.Recipes
    })
end)

-- CLOSE UI
RegisterNUICallback('close', function()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end)

-- CRAFT REQUEST (progress handled server side)
RegisterNUICallback('craft', function(data)
    local item = data.item

    -- close UI before crafting starts
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })

    -- start progressbar animation
    exports['progressbar']:Progress({
        name = "craft_wig",
        duration = Config.Crafting.progressTime,
        label = "Crafting Wig...",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        },
        animation = {
            animDict = "mp_common",
            anim = "givetake1_a"
        }
    }, function(cancelled)
        if not cancelled then
            -- server handles material removal + item grant
            TriggerServerEvent('wigcraft:finishCraft', { item = item })
        else
            QBCore.Functions.Notify("Crafting cancelled", "error")
        end
    end)
end)