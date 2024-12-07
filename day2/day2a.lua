-- require("debug")

local inspect = require("inspect")
local pl = require("pl.utils")
local fun = require("fun")

local filename = arg[1]
print("Reading file: " .. filename)

local reports = {}

local function is_safe(list)
	-- print(inspect(list))
	local zipped = fun.zip(table.pack(table.unpack(list, 1, #list - 1)), table.pack(table.unpack(list, 2, #list)))

	local decreasing = list[1] > list[#list]
	-- print("decreasing:" .. tostring(decreasing))

	return fun.all(function(x, y)
		-- print(x, y)
		if decreasing then
			return y - x < 0 and y - x >= -3
		else
			return y - x > 0 and y - x <= 3
		end
	end, zipped)
end

for line in io.lines(filename) do
	local levels = fun.map(tonumber, pl.split(line)):totable()
	table.insert(reports, levels)
end

local safe_count = fun.reduce(function(acc, report)
	if is_safe(report) then
		return acc + 1
	else
		print(false)
		return acc
	end
end, 0, reports)

print(safe_count)

-- print(is_safe(fun.map(tonumber, { "2", "5", "8", "11", "13", "14", "15" }):totable()))
