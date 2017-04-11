
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

function Timer.new(fn, data)
	local self = setmetatable({}, Timer)

	assert(type(fn) == "function")
	self.fn = fn

	if data.storage and data.key then
		self.storage = data.storage
		self.key = data.key
		local stored_data = data.storage:get_string(data.key)
		if stored_data == "" then
			-- initialize from default values
			self.interval = data.interval
			self.repeats = data.repeats == nil or data.repeats == true
			self.elapsed = 0.0
		else
			local meta = minetest.parse_json(stored_data)
			-- initialize from saved state
			self.interval = meta.interval
			self.repeats = meta.repeats == nil or meta.repeats == true
			self.active = meta.active
			if self.active then
				self.elapsed = meta.elapsed or 0.0
			else
				self.elapsed = 0.0
			end
		end
	elseif data.interval then
		-- initialize from default state since no storageref present
		self.interval = data.interval
		self.repeats = data.repeats == nil or data.repeats

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
	assert(type(interval) == "number")
	assert(interval > 0.0)
	self.interval = interval
end

function Timer:set_repeats(repeats)
	assert(type(repeats) == "boolean")
	self.repeats = repeats
end

function Timer:get_repeats()
	return self.repeats
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

function Timer:save()
	self.storage:set_string(self.key, minetest.write_json(self:to_table()))
end

---
--- our globalstep function - step all active timers
---

minetest.register_globalstep(function(dtime)
	for k, _ in pairs(timers) do
		k(dtime)
	end
end)
