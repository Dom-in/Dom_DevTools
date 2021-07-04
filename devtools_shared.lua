Citizen.CreateThread(function()
	repeat
		Wait(0)
	until permissions
	permissions["devtools_coords"] = false
	permissions["devtools_noclip"] = false
	permissions["devtools_vanish"] = false
	permissions["devtools_tpm"] = false

end)
