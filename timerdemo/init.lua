
--[[

    Timer class demonstration code.

--]]

-- use mod storage API to store the timer data
local s = minetest.get_mod_storage()
assert(s)

-- our timer function
local mytimerfunc = function(elapsed)
	print("fn: ", elapsed)
end

-- our timer
local t

-- load, or, initialize our timer
local mytimerdata = s:get_string("mytimerdata2")
if mytimerdata == "" then
	-- make a new timer, and start it
	t = Timer(mytimerfunc, 2.0)
	t:start()
else
	-- load the timer data from saved data
	t = Timer(mytimerfunc, minetest.parse_json(mytimerdata))
end

-- on shutdown, save our timer data
minetest.register_on_shutdown(function()
	s:set_string("mytimerdata2", minetest.write_json(t:to_table()))
end)
