#!/usr/bin/env lua

require "ubus"
require "uloop"

uloop.init()

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

local my_method = {
	test_0 = {
		hello = {
			function(req, msg)
				conn:reply(req, {message="foo"});
				print("Call to function 'hello'")
				for k, v in pairs(msg) do
					print("key=" .. k .. " value=" .. tostring(v))
				end
			end, {id = ubus.INT32, msg = ubus.STRING }
		},
	}
}

for i=1,2000 do
	my_method["test_" .. tostring(i)] = my_method["test_0"]
end

conn:add(my_method)

uloop.timer(
	function()
		-- running "ubus list" to make sure ubus contexts are isolated
		os.execute("ubus list")
		conn:close()
		uloop.cancel()
	end,
	2000
)

uloop.run()
