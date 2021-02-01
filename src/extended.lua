local loaded_menus = {}

local function load_smbmenu(drive)
	if loaded_menus[drive] then return end
	local fs = cproxy(drive)
	local hand = lassert(fs.open(".smbmenu", "r"))
	load_data(readfile(fs, hand))
	loaded_menus[drive] = true
end

local function loadall()
	for fs in clist("filesystem") do
		if cinvoke(fs, "exists", ".smbmenu") then
			load_smbmenu(fs)
		end
	end
end

addconfig("loadall", function(v)
	if (v ~= "0") then
		loadall()
	end
end)

addconfig(0x0000, function(v)
	if (sbyte(v) > 0) then
		loadall()
	end
end)

addboot(0, function(drive)
	load_smbmenu(drive)
end, function(data)
	return
end)