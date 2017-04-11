
--[[

  Timer - a high precision, saveable timer class

  Copyright (C) 2017 - Auke Kok <sofar@foo-projects.org

  "timer" is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation; either version 2.1
  of the license, or (at your option) any later version.

]]--


---
--- static data: active timer table
---

local timers = {}


---
--- Timer class
---

Timer = {}
Timer.__index = Timer

setmetatable(Timer, {
	__call = function(c, ...)
		return c.new(...)
	end,
})

local function register(self)
	-- step fuction, instanced for this timer, guarantees
	-- the index is unique and we can find it quickly for
	-- removal later
	self.registration = function(dtime)
		if self.active then
			self.elapsed = self.elapsed + dtime
			if self.elapsed > self.interval then
				self:expire()
			end
		end
	end
	timers[self.registration] = true
end

function Timer.new(fn, param1, param2)
	local self = setmetatable({}, Timer)

	assert(type(fn) == "function")
	self.fn = fn

	if type(param1) == "table" then
		self.interval = param1.interval
		self.repeats = param1.repeats
		self.active = param1.active
		if self.active then
			self.elapsed = param1.elapsed or 0.0
		end

	elseif type(param1) == "number" then
		self.interval = param1
		self.repeats = param2 or true

		self.active = false
		self.elapsed = 0.0

	else
		minetest.log("error", "Unable to create Timer: Invalid parameters")
		return nil
	end

	if self.active then
		register(self)
	end

	return self
end

function Timer:start()
	if self.active ~= true then
		register(self)
		self.active = true
	end
end

function Timer:stop()
	if self.active then
		self.active = false
		timers[self.registration] = nil
		self.registration = nil
	end
end

function Timer:set_interval(interval)
	self.interval = interval
end

function Timer:get_interval()
	return self.interval
end

function Timer:get_elapsed()
	return self.elapsed
end

function Timer:is_active()
	return self.active == true
end

function Timer:expire(elapsed)
	self.fn(self.elapsed)
	if self.elapsed and self.elapsed > 0.0 then
		-- we could set it here to 0.0, but it's nice
		-- to account for the slippage and be a little
		-- bit more accurate
		self.elapsed = 0.0 + (self.interval - self.elapsed)
	end
	if not self.repeats then
		self:stop()
	end
end

function Timer:to_table()
	return {
		name = self.name,
		interval = self.interval,
		repeats = self.repeats,
		active = self.active,
		elapsed = self.elapsed,
	}
end

---
--- our globalstep function - step all active timers
---

minetest.register_globalstep(function(dtime)
	for k, _ in pairs(timers) do
		k(dtime)
	end
end)
