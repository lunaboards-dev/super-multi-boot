addboot(2, function(drive, file)
	local fs = cproxy(drive)
	local hand = lassert(fs.open(file, "r"))
	function comp.getBootAddress()
		return drive
	end
	function comp.setBootAddress()end
	assert(lload(lassert(readfile(fs, hand))))()
end, function(data)
	return b2a(data), data:sub(17)
end)