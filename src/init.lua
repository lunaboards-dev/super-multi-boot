local dev, com, str, _x, empty, tru, space, ourname = component, computer, string, "%.2x", "", true, " ", "Super Multi Boot"
local cproxy, clist, cinvoke, lassert, lload, lsetmetatable, spack, sunpack, sfind, sbyte, srep, sformat, sgsub, ssub, lerror =
      dev.proxy, dev.list, dev.invoke, assert, load, setmetatable, str.pack, str.unpack, str.find, str.byte, str.rep,
      str.format, str.gsub, str.sub, error
_BOOT=ourname
_BIOS=ourname -- both like classic zorya and zorya neo
-- our basic info
_SMB = {
	version = "0.1-alpha",
	git = "$[[git rev-parse --short HEAD]]"
}
local function a2b(addr)
	addr = sgsub(addr, "%-", empty)
	local baddr = empty
	for i=1, #addr, 2 do
		baddr = baddr .. str.char(tonumber(ssub(addr, i, i+1), 16))
	end
	return baddr
end

local function b2a(addr)
	return sformat(sformat("%s-%s%s", srep(_x, 4), srep(_x.._x.."-", 3),srep(_x, 6)), sbyte(addr, 1, #addr))
end

local function readfile(fs, hand)
	local buffer = empty
	local data, reason
	repeat
		data = fs.read(hand, math.huge)
		if not data and reason then
			lerror(reason)
		end
		buffer = buffer .. (data or empty)
	until not data or data == ""
	return buffer
end

local function getdata(req)
	local data = empty
	while tru do
		local chunk, reason = req.read()
		if not chunk then req.close() if reason then lerror(reason, 0) end break end
		data = data .. chunk
	end
	return data
end

local function establish_connection(dev, ...)
	for i=1, 3 do
		local req, err = dev.request(...)
		if dev then return req end
	end
	lerror("couldn't connect", 0)
end

local handlers = {}

local function addboot(id, boot, read)
	handlers[id] = {boot, read}
end

local btable = {}

local function load_data(cdat)
	local pos = 1
	while sbyte(cdat, pos) do
		local handler, namesize, size = sbyte(cdat, pos, pos+2)
		local name, bdat = ssub(cdat, pos+3, pos+2+namesize), table.pack(handlers[handler][2](ssub(cdat, pos+3+namesize, pos+2+namesize+size)))
		if (bdat.n > 0) then
			btable[#btable+1] = {name,bdat}
		end
	end
end

-- insert handlers here

--#include "extended.lua"
--#incldue "bios.lua"

-- all handlers inserted
load_data(cinvoke(clist("ee")(), "getData"))

-- display menu
local gpu = cproxy(clist("gpu")())
local screen = clist("scre")()
gpu.bind(screen)
local w, h = gpu.getResolution()
gpu.setBackground(0)
gpu.setForefround(0xFFFFFF)
gpu.fill(1, 1, w, h, space)
local function cls()gpu.fill(1,1,w,h,space)end
local upper_left, horizontal, upper_right, vertical, lower_left, lower_right = "┌", "─", "┐", "│", "└", "┘"
gpu.set((w-ourname)//2, 1, ourname)
gpu.set(1, 2, upper_left)
gpu.set(2, 2, srep(horizontal, w-2))
gpu.set(w, 2, upper_right)
for i=1, h-6 do
	gpu.set(1, i+2, vertical)
	gpu.set(w, i+2, vertical)
end
gpu.set(1, h-3, lower_left)
gpu.set(w, h-3, srep(horizontal, w-2))
gpu.set(w, h-3, lower_right)
gpu.set(1, h-1, "Use ↑ and ↓ keys to select which entry is highlighted.")
gpu.set(1, h, "Use ENTER to boot the selected entry.")