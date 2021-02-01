local function a2b(addr)
	addr = string.gsub(addr, "%-", "")
	local baddr = ""
	for i=1, #addr, 2 do
		baddr = baddr .. string.char(tonumber(string.sub(addr, i, i+1), 16))
	end
	return baddr
end

local options = {

}

local types = {
	extended=0,
	bios=1,
	file=2,
	text=3,
	option=4,
	osdi=5,
	osdibootcode=6,
	config=7,
	netcfg=8,
	netboot=9
}

local sertypes = {
	uuid=function(v)
		return a2b(v)
	end,
	raw = function(v)
		return v
	end,
	string = function(v)
		return string.byte(#v)..v
	end,
	int = function(v)
		return string.pack("<I", v)
	end,
	bool = function(v)
		return string.char(v and 1 or 0)
	end,
	byte = function(v)
		return string.char(v)
	end,
	short = function(v)
		return string.pack("<H", v)
	end,
	float = function(v)
		return string.pack("f", v)
	end
}

local f = io.open(arg[1], "r")
local t = assert(load("return "..f:read("*a")))()
local f2 = io.open(arg[2], "wb")
for i=1, #t do
	local ent = t[i]
	ent.name = ent.name or ""
	local d = ""
	print("type: "..ent.type.."; args: "..#ent.."; name: "..ent.name)
	for i=1, #ent do
		local k, v = next(ent[i])
		--print(k, v)
		d = d .. sertypes[k](v)
	end
	f2:write(string.char(types[ent.type], #ent.name, #d)..ent.name..d)
end