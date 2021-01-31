addboot(1, function(drive)
	local fs = cproxy(drive)
	local hand = lassert(fs.open("init.lua", "r"))
	function comp.getBootAddress()
		return drive
	end
	function comp.setBootAddress()end
	assert(lload(lassert(readfile(fs, hand))))()
end, function(data)
	return b2a(data)
end)