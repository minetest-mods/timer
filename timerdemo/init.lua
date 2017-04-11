
--[[

    Timer class demonstration code.

--]]

-- use mod storage API to store the timer data
local s = minetest.get_mod_storage()
assert(s)

-- our timer functions
local mytimerfunc1 = function(elapsed)
	print("fn1: ", elapsed)
end

local mytimerfunc2 = function(elapsed)
	print("fn2: ", elapsed)
end

-- our timers
-- t1 - persistent, saved in storage
local t1 = Timer(mytimerfunc1, {
	storage = s,
	key = "timer_data",
	interval = 2.0,
	repeats = true,
})

-- t2, not persistent
local t2 = Timer(mytimerfunc2, {
	interval = 2.2,
	repeats = true,
})

-- t3, does not repeat, anonymous function, not persistent.
local t3 = Timer(function(elapsed)
		print("fn3: ", elapsed)
	end
	, {
	interval = 5.3,
	repeats = false,
})

-- a restored timer that was already running will get started
-- automatically, but a new timer will not. So, start it.
--
-- you don't need to check `is_active()`. It's safe to always
-- `start()` your timer in any case.
if not t1:is_active() then
	t1:start()
end

-- timer 2 & 3 always needs starting manually
t2:start()

t3:start()

-- on shutdown, save our timer data
minetest.register_on_shutdown(function()
	t1:save()
end)

-- change timer interval for t2 to some other value, to demonstrate
-- that it isn't saved.
minetest.after(5.5, function()
	t2:set_interval(0.5)
end)
