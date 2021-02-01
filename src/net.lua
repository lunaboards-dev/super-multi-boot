do
	local inet = clist("internet")()
	local prox
	if inet then
		prox = cproxy(inet)
	end
	addboot(8, function()
	end, function(data)
		local req = establish_connection(prox, data)
		load_data(getdata(req))
	end)

	addboot(9, function(addr)
		local req = establish_connection(prox, addr)
		load(getdata(req), "="..addr)()
	end, function(data)
		return data
	end)
end