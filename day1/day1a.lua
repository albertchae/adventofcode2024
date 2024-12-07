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

table.sort(list1)
table.sort(list2)

print(inspect(list1))
print(inspect(list2))

local sum_of_differences = fun.zip(list1, list2):reduce(function(acc, x, y)
	return acc + math.abs(x - y)
end, 0)

print(sum_of_differences)
