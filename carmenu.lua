-- seats
local function GetAvailableSeats(vehicle)
    local availableSeats = {}

    for i = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        if IsVehicleSeatFree(vehicle, i) then
            table.insert(availableSeats, i)
        end
    end

    return availableSeats
end

local function SwitchSeat(seatIndex)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) and IsPedInAnyVehicle(playerPed, false) then
        TaskWarpPedIntoVehicle(playerPed, vehicle, seatIndex)
    else
        lib.notify({
            title = 'Car Menu',
            description = 'You are not in a vehicle.',
            type = 'error'
        })
    end
end

RegisterNetEvent('mira_utility:changeseat', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) then
        local seats = GetAvailableSeats(vehicle)
        local options = {}

        table.insert(options, {
            title = 'Back to main menu',
            arrow = true,
            event = 'open_car_menu'
        })

        for _, seat in ipairs(seats) do
            local seatLabel = 'Seat '

            if seat == -1 then
                seatLabel = 'Driver seat'
            elseif seat == 0 then
                seatLabel = 'Front passenger seat'
            elseif seat == 1 then
                seatLabel = 'Rear left seat'
            elseif seat == 2 then
                seatLabel = 'Rear right seat'
            end

            table.insert(options, {
                title = seatLabel,
                event = 'switch_seat',
                args = seat
            })
        end

        if #options > 0 then
            lib.registerContext({
                id = 'vehicle_seat_switch',
                title = 'Car Menu',
                options = options
            })

            lib.showContext('vehicle_seat_switch')
        else
            lib.notify({
                title = 'Car Menu',
                description = 'No available seats to switch to.',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Car Menu',
            description = 'You are not in any vehicle.',
            type = 'error'
        })
    end
end)

RegisterNetEvent('switch_seat', function(seat)
    SwitchSeat(seat)
end)

-- doors
local function GetAvailableDoors(vehicle)
    local doors = {}

    if GetNumberOfVehicleDoors(vehicle) > 0 then
        if GetNumberOfVehicleDoors(vehicle) >= 2 then
            table.insert(doors, { index = 0, label = "Front left door" })
            table.insert(doors, { index = 1, label = "Front right door" })
        end
        if GetNumberOfVehicleDoors(vehicle) >= 4 then
            table.insert(doors, { index = 2, label = "Rear left door" })
            table.insert(doors, { index = 3, label = "Rear right door" })
        end
        if DoesVehicleHaveDoor(vehicle, 4) then
            table.insert(doors, { index = 4, label = "Hood" })
        end
        if DoesVehicleHaveDoor(vehicle, 5) then
            table.insert(doors, { index = 5, label = "Trunk" })
        end
    end

    return doors
end

local function ToggleDoor(vehicle, doorIndex)
    if GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0 then
        SetVehicleDoorShut(vehicle, doorIndex, false)
    else
        SetVehicleDoorOpen(vehicle, doorIndex, false, false)
    end
end

RegisterNetEvent('mira_utility:opendoor', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) then
        local doors = GetAvailableDoors(vehicle)
        local options = {}

        table.insert(options, {
            title = 'Back to main menu',
            arrow = true,
            event = 'open_car_menu'
        })

        for _, door in ipairs(doors) do
            if IsVehicleDoorDamaged(vehicle, door.index) then
                lib.notify({
                    title = 'Doors',
                    description = door.label .. ' are damaged and cannot be opened/closed.',
                    type = 'error'
                })
            else
                table.insert(options, {
                    title = door.label,
                    event = 'toggle_door',
                    args = door.index
                })
            end
        end

        if #options > 0 then
            lib.registerContext({
                id = 'vehicle_door_menu',
                title = 'Car Menu',
                options = options
            })

            lib.showContext('vehicle_door_menu')
        else
            lib.notify({
                title = 'Car Menu',
                description = 'No available doors to open/close.',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Car Menu',
            description = 'You are not in any vehicle.',
            type = 'error'
        })
    end
end)

RegisterNetEvent('toggle_door', function(doorIndex)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) then
        ToggleDoor(vehicle, doorIndex)
    end
end)

-- windows
local function GetAvailableWindows(vehicle)
    local windows = {}

    if GetNumberOfVehicleDoors(vehicle) >= 2 then
        table.insert(windows, { index = 0, label = "Front left window" })
        table.insert(windows, { index = 1, label = "Front right window" })
    end
    if GetNumberOfVehicleDoors(vehicle) >= 4 then
        table.insert(windows, { index = 2, label = "Rear left window" })
        table.insert(windows, { index = 3, label = "Rear right window" })
    end

    return windows
end

local function ToggleWindow(vehicle, windowIndex)
    if IsVehicleWindowIntact(vehicle, windowIndex) then
        RollDownWindow(vehicle, windowIndex)
    else
        RollUpWindow(vehicle, windowIndex)
    end
end

RegisterNetEvent('mira_utility:openwindow', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) then
        local windows = GetAvailableWindows(vehicle)
        local options = {}

        table.insert(options, {
            title = 'Back to main menu',
            arrow = true,
            event = 'open_car_menu'
        })

        for _, window in ipairs(windows) do
            table.insert(options, {
                title = window.label,
                event = 'toggle_window',
                args = window.index
            })
        end

        if #options > 0 then
            lib.registerContext({
                id = 'vehicle_window_menu',
                title = 'Car Menu',
                options = options
            })

            lib.showContext('vehicle_window_menu')
        else
            lib.notify({
                title = 'Car Menu',
                description = 'No available windows to open/close.',
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Car Menu',
            description = 'You are not in any vehicle.',
            type = 'error'
        })
    end
end)

RegisterNetEvent('toggle_window', function(windowIndex)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) then
        ToggleWindow(vehicle, windowIndex)
    end
end)

-- main table
function OpenCarMenu()
    lib.registerContext({
        id = 'carmenu_open',
        title = 'Car Menu',
        onExit = function() end,
        options = {
            {
                title = 'Engine - Start/Stop',
                icon = 'fa-solid fa-gauge',
                event = 'mira_utility:carmenu:turnengineoff'
            },
            {
                title = 'Seats - Change Seat',
                icon = 'fa-solid fa-chair',
                arrow = true,
                event = 'mira_utility:changeseat'
            },
            {
                title = 'Doors - Open/Close',
                icon = 'fa-solid fa-car-side',
                arrow = true,
                event = 'mira_utility:opendoor'
            },
            {
                title = 'Windows - Open/Close',
                icon = 'fa-solid fa-window-maximize',
                arrow = true,
                event = 'mira_utility:openwindow'
            },
            {
                title = 'Neons - Toggle Neons',
                icon = 'fa-solid fa-lightbulb',
                arrow = true,
                event = 'mira_utility:ToggleNeons'
            },
        }
    })
    lib.showContext('carmenu_open')
end

RegisterNetEvent('open_car_menu', function()
    OpenCarMenu()
end)

RegisterCommand("carmenu", function()
    local user = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(user, false)
    if IsPedInAnyVehicle(user) then
        OpenCarMenu()
    else
        lib.notify({
            title = 'Car Menu',
            description = 'You must be seated in a vehicle.',
            type = 'error'
        })
    end
end)

-- engine
RegisterNetEvent("mira_utility:carmenu:turnengineoff", function()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)

    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= player then 
        lib.notify({
            title = 'Car Menu',
            description = 'You must be in the driver seat.',
            type = 'error'
        })
        return
    end

    local engineRunning = GetIsVehicleEngineRunning(vehicle)
    
    if engineRunning then
        SetVehicleEngineOn(vehicle, false, false, true)
        lib.notify({
            title = 'Car Menu',
            description = 'Engine has been turned off!',
            type = 'success'
        })
    else
        SetVehicleEngineOn(vehicle, true, false, true)
        lib.notify({
            title = 'Car Menu',
            description = 'Engine has been turned on!',
            type = 'success'
        })
    end
end)
