-- require("debug")

local inspect = require("inspect")
local pl = require("pl.utils")
local fun = require("fun")
local rex = require("rex_pcre2")

local filename = arg[1]
print("Reading file: " .. filename)

local mul_pattern = "mul\\((\\d{1,3}),(\\d{1,3})\\)"

local function multiply_line(line)
	local search_index = 1
	local sum = 0
	while search_index ~= nil do
		local _, end_index, a, b = rex.find(line, mul_pattern, search_index)
		search_index = end_index
		if end_index ~= nil then
			sum = sum + a * b
		end
	end
	return sum
end

local lines = {}
for line in io.lines(filename) do
	table.insert(lines, line)
end

local total_sum = fun.reduce(function(acc, line)
	return acc + multiply_line(line)
end, 0, lines)

print(total_sum)
