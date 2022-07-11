-- Active le pvp
AddEventHandler("playerSpawned", function()
  Citizen.CreateThread(function()

    local player = PlayerId()
    local playerPed = GetPlayerPed(-1)

    -- Enable pvp
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(playerPed, true, true)

  end)
end)

-- Actualise la carte 
Citizen.CreateThread(function()
    SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
    SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
    SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
    SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
    SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4

    while true do
        Citizen.Wait(1)
        if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
            SetRadarZoom(1100)
        end
    end
end)

-- Supprime le contrôle d'un véhicule en l'air 
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local veh = GetVehiclePedIsIn(PlayerPedId(),false)
        if DoesEntityExist(veh) and not IsEntityDead(veh) then
            local model = GetEntityModel(veh)
            if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) and not IsThisModelABicycle(model) and not IsThisModelABike(model) and not IsThisModelAQuadbike(model) and IsEntityInAir(veh) then
                DisableControlAction(0,59)
                DisableControlAction(0,60)
                DisableControlAction(0,73)
            end
        end
    end
end)

-- Supprime le Nord indiqué sur la map
Citizen.CreateThread(function()
    while true do
    Citizen.Wait(0)
  SetBlipAlpha(GetNorthRadarBlip(), 0)
 end
end)

-- Supprime les coups de cross
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
    local ped = PlayerPedId()
        if IsPedArmed(ped, 6) then
           DisableControlAction(1, 140, true)
              DisableControlAction(1, 141, true)
           DisableControlAction(1, 142, true)
        end
    end
end)

-- Evite les attaques après un ALT TAB
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        DisableControlAction(1, 140, true)
        if not IsPlayerTargettingAnything(PlayerId()) then
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
        end
    end
end)

-- Changer de place dans la voiture avec les touches 1,2,3,4
Citizen.CreateThread(function()
while true do
local plyPed = PlayerPedId()
if IsPedSittingInAnyVehicle(plyPed) then
local plyVehicle = GetVehiclePedIsIn(plyPed, false)
CarSpeed = GetEntitySpeed(plyVehicle) * 3.6 -- On définit la vitesse du véhicule en km/h
if CarSpeed <= 300.0 then -- On ne peux pas changer de place si la vitesse du véhicule est au dessus ou égale à 300 km/h
if IsControlJustReleased(0, 157) then -- conducteur : 1
SetPedIntoVehicle(plyPed, plyVehicle, -1)
Citizen.Wait(10)
end
if IsControlJustReleased(0, 158) then -- avant droit : 2
SetPedIntoVehicle(plyPed, plyVehicle, 0)
Citizen.Wait(10)
end
if IsControlJustReleased(0, 160) then -- arriere gauche : 3
SetPedIntoVehicle(plyPed, plyVehicle, 1)
Citizen.Wait(10)
end
if IsControlJustReleased(0, 164) then -- arriere droite : 4
SetPedIntoVehicle(plyPed, plyVehicle, 2)
Citizen.Wait(10)
end
end
end
Citizen.Wait(10) -- anti crash
end
end)

-- Désactiver les sons ambiants - Scanner Police, Bruits de tir à l'ammunation 
Citizen.CreateThread(function()
    StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    SetAudioFlag("PoliceScannerDisabled", true)
end)


-- Désactiver les pompes LSPD
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        DisablePlayerVehicleRewards(PlayerId())
    end
end)

-- Désactive les aggressions des pnjs sur un joueur 
SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_LOST"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_SALVA"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_HILLBILLY"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_BALLAS"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_MEXICAN"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_FAMILY"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_MARABUNTE"), GetHashKey('PLAYER'))

SetRelationshipBetweenGroups(1, GetHashKey("GANG_1"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("GANG_2"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("GANG_9"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("GANG_10"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("FIREMAN"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("MEDIC"), GetHashKey('PLAYER'))
SetRelationshipBetweenGroups(1, GetHashKey("COP"), GetHashKey('PLAYER'))
