local coordsVisible = false

noClip = false
noClipSpeed = 1
noClipLabel = nil
noClipSpeeds = {
	"Very Slow",
	"Slow",
	"Normal",
	"Fast",
	"Very Fast",
	"Extremely Fast",
	"Extremely Fast v2.0",
	"Max Speed"
}

Citizen.CreateThread(function()
    while true do
		local sleepThread = 250
		
		if coordsVisible then
			sleepThread = 5

			local playerPed = PlayerPedId()
			local playerX, playerY, playerZ = table.unpack(GetEntityCoords(playerPed))
			local playerH = GetEntityHeading(playerPed)

			DrawGenericText(("~".DevConfig.XYZColors."~X~w~: %s ~".DevConfig.XYZColors."~Y~w~: %s ~".DevConfig.XYZColors."~Z~w~: %s ~r~H~w~: %s"):format(FormatCoord(playerX), FormatCoord(playerY), FormatCoord(playerZ), FormatCoord(playerH)))
		end

		Citizen.Wait(sleepThread)
	end
end)

Citizen.CreateThread(function()
	while true do
		if noClip then
			local noclipEntity = PlayerPedId()
			if IsPedInAnyVehicle(noclipEntity, false) then
				local vehicle = GetVehiclePedIsIn(noclipEntity, false)
				if GetPedInVehicleSeat(vehicle, -1) == noclipEntity then
					noclipEntity = vehicle
				else
					noclipEntity = nil
				end
			end

			FreezeEntityPosition(noclipEntity, true)
			SetEntityInvincible(noclipEntity, true)

			DisableControlAction(0, 31, true)
			DisableControlAction(0, 30, true)
			DisableControlAction(0, 44, true)
			DisableControlAction(0, 20, true)
			DisableControlAction(0, 32, true)
			DisableControlAction(0, 33, true)
			DisableControlAction(0, 34, true)
			DisableControlAction(0, 35, true)

			local yoff = 0.0
			local zoff = 0.0
			if IsControlJustPressed(0, 21) then
				noClipSpeed = noClipSpeed + 1
				if noClipSpeed > #noClipSpeeds then
					noClipSpeed = 1
				end

			end

			if IsDisabledControlPressed(0, 32) then
				yoff = 0.25;
			end

			if IsDisabledControlPressed(0, 33) then
				yoff = -0.25;
			end

			if IsDisabledControlPressed(0, 34) then
				SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + 2.0)
			end

			if IsDisabledControlPressed(0, 35) then
				SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) - 2.0)
			end

			if IsDisabledControlPressed(0, 44) then
				zoff = 0.1;
			end

			if IsDisabledControlPressed(0, 20) then
				zoff = -0.1;
			end

			local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (noClipSpeed + 0.3), zoff * (noClipSpeed + 0.3))

			local heading = GetEntityHeading(noclipEntity)
			SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
			SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
			SetEntityHeading(noclipEntity, heading)

			SetEntityCollision(noclipEntity, false, false)
			SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)
			Citizen.Wait(0)

			FreezeEntityPosition(noclipEntity, false)
			SetEntityInvincible(noclipEntity, false)
			SetEntityCollision(noclipEntity, true, true)
		else
			Citizen.Wait(200)
		end
	end
end)


AddEventHandler("EasyAdmin:BuildMainMenuOptions", function() 
	trainerMenu = _menuPool:AddSubMenu(mainMenu, "Devtools","",true)
	trainerMenu:SetMenuWidthOffset(menuWidth)	

	

	if permissions["devtools_coords"] and DevConfig.coords then
		local thisItem = NativeUI.CreateCheckboxItem("Coords","") -- create our new item
		trainerMenu:AddItem(thisItem) -- thisPlayer is global.
		thisItem.CheckboxEvent = function(sender, item, checked_)
			if item == thisItem then
				ToggleCoords()
			end
		end
	end

	if permissions["devtools_noclip"] and DevConfig.noclip then
		local thisItem = NativeUI.CreateCheckboxItem('Noclip', noClip, "")
		trainerMenu:AddItem(thisItem)
		thisItem.CheckboxEvent = function(sender, item, status)
			if item == thisItem then
				noClip = not noClip
				if not noClip then
				noClipSpeed = 1
				end
			end
		end
	end

	if permissions["devtools_vanish"] and DevConfig.vanish then
		local thisItem = NativeUI.CreateCheckboxItem('Vanish', not IsEntityVisible(PlayerPedId()), "")
		trainerMenu:AddItem(thisItem)
		thisItem.CheckboxEvent = function(sender, item, status)
			if item == thisItem then
				local playerPed = PlayerPedId()
				SetEntityVisible(playerPed, not IsEntityVisible(playerPed))
			end
		end
	end

	if permissions["devtools_tpm"] and DevConfig.tpm then
		local thisItem = NativeUI.CreateItem('TPM', "")
		trainerMenu:AddItem(thisItem)
		thisItem.Activated = function(ParentMenu,SelectedItem)
			TriggerEvent('esx:tpm', source)
		end
	end

end)

function DrawGenericText(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(7)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.40, 0.00)
end

FormatCoord = function(coord)
	if coord == nil then
		return "unknown"
	end

	return tonumber(string.format("%.2f", coord))
end

ToggleCoords = function()
	coordsVisible = not coordsVisible
end

RegisterNetEvent('esx:tpm')
AddEventHandler('esx:tpm', function()
    
    local WaypointHandle = GetFirstBlipInfoId(8)
    
    if DoesBlipExist(WaypointHandle) then
        
        local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
        
        for height = 1, 1000 do
            
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
            
            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)
            
            if foundGround then
                
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
                
                break
            
            end
            Citizen.Wait(5)
        end

    else

    end
end)
