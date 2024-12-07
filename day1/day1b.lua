-- require("debug")

local inspect = require("inspect")
local pl = require("pl.utils")
local fun = require("fun")

local filename = arg[1]
print("Reading file: " .. filename)

local list1 = {}
local list2 = {}

for line in io.lines(filename) do
	local split_line = pl.split(line)
	table.insert(list1, split_line[1])
	table.insert(list2, split_line[2])
end

print(inspect(list1))
print(inspect(list2))

local tally = {}
local defaultmt = {
	__index = function()
		return 0
	end,
}
setmetatable(tally, defaultmt)
for _, x in ipairs(list2) do
	tally[x] = tally[x] + 1
end

print(inspect(tally))

local sum = fun.reduce(function(acc, x)
	return acc + x * tally[x]
end, 0, list1)

print(sum)
