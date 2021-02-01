-- only supports OSDI version 2+
local osdi_header = "<IIc8I3c13"

local function is_osdi(data)
	local blksize, version, zero, magic, uuid = sunpack("<BI3Ic8c16", data)
	if (magic ~= "osdiPLUS" or version ~= 2 or zero ~= 0 or 1 << blksize ~= 512) then return false end
	return b2a(uuid)
end

local osdi_map = {}

local function parse_osdi(data, part)
	local offset = (spacksize(osdi_header)*drive)+1
	return sunpack(osdi_header, ssub(data, offset, offset+spacksize(osdi_header)-1))
end

for drv in clist("drive") do
	local prx = cproxy(drv)
	local first = prox.readSector(1)
	local addr = is_osdi(first)
	if addr then
		local parts = {}
		osdi_map[addr] = parts
		parts.proxy = prx
		for i=1, 15 do
			local start, size, ptype, flags, name = parse_osdi(first, i)
			parts[i] = {start,size,ptype,flags,name}
		end
	end
end

local function get_osdi_drive(addr)
	return osdi_map[addr].proxy
end

local function load_part(addr, part)
	local pdat, proxy = osdi_map[addr][part], osdi_map[addr].proxy
	local start, size = pdat[1], pdat[2]
	local data = empty
	for i=1, size do
		data = data .. proxy.readSector(start+i-1)
	end
	return data
end

local function psub(data)
	return ssub(data, 2, 1+sunpack(leshort, data))
end

local function osdi_scan()
	for k, v in pairs(osdi_map) do
		for i=1, #v do
			local ent = v[i]
			if ent[3] == "$SMBMENU" then
				load_data(psub(load_part(k, i)))
			end
		end
	end
end

addconfig("osdiscan", function(v)
	if (v ~= "0") then
		osdi_scan()
	end
end)

addconfig(0x0600, function(dat)
	if (sbyte(v) > 0) then
		osdi_scan()
	end
end)

addboot(5, function(drive, partition)
	load_data(psub(load_part(drive, partition)))
end, function(data)
	return b2a(data), ssub(data, 17)
end)

addboot(6, function(drive, partition)
	load(psub(load_part(drive, partition)), sformat("osdi(%s..., %i)", drive:sub(1, 3), partition))()
end, function(data)
	return b2a(data), ssub(data, 17)
end)