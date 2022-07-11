local bequilleModel = -1035084591
local clipSet = "move_lester_CaneUp"
local pickupAnim = {
	dict = "pickup_object",
	name = "pickup_low"
}

local localization = {
	['ragdoll'] = "Vous ne pouvez pas utiliser de béquille pendant que vous êtes en ragdoll!",
	['falling'] = "Vous ne pouvez pas utiliser une béquille pendant que vous tombez!",
	['combat'] = "Vous ne pouvez pas utiliser de béquille pendant que vous êtes au combat!",
	['dead'] = "Vous ne pouvez pas utiliser une béquille quand vous êtes mort!",
	['vehicle'] = "Vous ne pouvez pas utiliser de béquille lorsque vous êtes dans un véhicule!",
	['weapon'] = "Vous ne pouvez pas utiliser une béquille tout en ayant une arme!",
	['pickup'] = "Appuyez sur ~INPUT_PICKUP~ pour prendre une béquille!"
}


local isUsingBequille = false
local bequilleObject = nil
local walkStyle = nil

local function LoadClipSet(set)
	RequestClipSet(set)
	while not HasClipSetLoaded(set) do
		Citizen.Wait(10)
	end
end

local function LoadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
	end
end

local function DisplayNotification(msg)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostTicker(false, false)
end

local function DisplayHelpText(msg)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, 0, 1, 50)
end

local function CreateBequille()
	if not HasModelLoaded(bequilleModel) then
		RequestModel(bequilleModel)
		while not HasModelLoaded(bequilleModel) do
			Citizen.Wait(10)
		end
	end
	local playerPed = GetPlayerPed(-1)
	bequilleObject = CreateObject(bequilleModel, GetEntityCoords(playerPed), true, false, false)
	AttachEntityToEntity(bequilleObject, playerPed, 70, 1.18, -0.36, -0.20, -20.0, -87.0, -20.0, true, true, false, true, 1, true)
end

local function CanPlayerEquipBequille()
	local playerPed = GetPlayerPed(-1)
	local hasWeapon, weaponHash = GetCurrentPedWeapon(playerPed)

	if hasWeapon then
		return false, localization['weapon']
	elseif IsPedInAnyVehicle(playerPed, false) then
		return false, localization['vehicle']
	elseif IsEntityDead(playerPed) then
		return false, localization['dead']
	elseif IsPedInMeleeCombat(playerPed) then
		return false, localization['combat']
	elseif IsPedFalling(playerPed) then
		return false, localization['falling']
	elseif IsPedRagdoll(playerPed) then
		return false, localization['ragdoll']
	end
	return true
end

local function UnequipBequille()
	if DoesEntityExist(bequilleObject) then
		DeleteEntity(bequilleObject)
	end

	isUsingBequille = false
	local playerPed = GetPlayerPed(-1)
	
	if walkStyle then
		LoadClipSet(walkStyle)
		SetPedMovementClipset(playerPed, walkStyle, 1.0)
		RemoveClipSet(walkStyle)
	else
		ResetPedMovementClipset(playerPed)
	end
end

local function EquipBequille()
	local playerPed = GetPlayerPed(-1)
	local canEquip, msg = CanPlayerEquipBequille()
	if not canEquip then
		DisplayNotification(msg)
		return
	end

	LoadClipSet(clipSet)
	SetPedMovementClipset(playerPed, clipSet, 1.0)
	RemoveClipSet(clipSet)

	CreateBequille()
	isUsingBequille = true

	Citizen.CreateThread(function()
		local fallCount = 0

		while true do
			Citizen.Wait(250)
			if not isUsingBequille then
				break
			end

			local playerPed = GetPlayerPed(-1)
			local isBequilleHidden = false
			local hasWeapon, weaponHash = GetCurrentPedWeapon(playerPed)

			if IsPedInAnyVehicle(playerPed, true) or hasWeapon then
				if not isBequilleHidden then
					isBequilleHidden = true
					if DoesEntityExist(bequilleObject) then
						DeleteEntity(bequilleObject)
					end
				end
			elseif not DoesEntityExist(bequilleObject) then
				Citizen.Wait(750)
				CreateBequille()
				isBequilleHidden = false
			elseif not IsEntityAttachedToEntity(bequilleObject, playerPed) then
				local traceObject = true
				while traceObject do
					local wait = 0
					if DoesEntityExist(bequilleObject) then
						playerPed = GetPlayerPed(-1)
						if not IsPedFalling(playerPed) and not IsPedRagdoll(playerPed) then
							local dist = #(GetEntityCoords(playerPed)-GetEntityCoords(bequilleObject))
							if dist < 2.0 then
								DisplayHelpText(localization['pickup'])
								if IsControlJustReleased(0, 38) then
									LoadAnimDict(pickupAnim.dict)
									TaskPlayAnim(playerPed, pickupAnim.dict, pickupAnim.name, 2.0, 2.0, -1, 0, 0, false, false, false)

									local failCount = 0
									while not IsEntityPlayingAnim(playerPed, pickupAnim.dict, pickupAnim.name, 3) and failCount < 25 do
										failCount = failCount + 1
										Citizen.Wait(50)
									end
									if failCount >= 25 then
										ClearPedTasks(playerPed)
									else
										Citizen.Wait(800)
									end

									RemoveAnimDict(pickupAnim.dict)
									DeleteEntity(bequilleObject)
									Citizen.Wait(900)
									CreateBequille()
									traceObject = false
								end
							elseif dist < 200.0 then
								wait = dist * 10
							else
								traceObject = false
							end
						else
							wait = 250
						end
					else
						traceObject = false
					end
					Citizen.Wait(wait)
				end
			elseif IsPedRagdoll(playerPed) or IsEntityDead(playerPed) then
				DetachEntity(bequilleObject, true, true)
			elseif IsPedInMeleeCombat(playerPed) then
				Citizen.Wait(400)
				DetachEntity(bequilleObject, true, true)
			elseif IsPedFalling(playerPed) then
				fallCount = fallCount + 1
				if fallCount > 3 then
					DetachEntity(bequilleObject, true, true)
					fallCount = 0
				end
			elseif fallCount > 0 then
				fallCount = fallCount - 1
			end
		end
	end)
end

local function ToggleBequille()
	if isUsingBequille then
		UnequipBequille()
	else
		EquipBequille()
	end
end

-- Exports --
exports('SetWalkStyle', function(walk)
	walkStyle = walk
end)

-- Commands --
RegisterCommand("bequille", function(source, args, rawCommand)
	ToggleBequille()
end, false)
