-- require("debug")

local inspect = require("inspect")
local pl = require("pl.utils")
local fun = require("fun")
local rex = require("rex_pcre2")

local filename = arg[1]
print("Reading file: " .. filename)

local mul_pattern = "mul\\((\\d{1,3}),(\\d{1,3})\\)"
local do_pattern = "do\\(\\)"
local dont_pattern = "don't\\(\\)"
local enabled = true

local function multiply_line(line)
	local search_index = 1
	local sum = 0

	while search_index ~= nil do
		if enabled == false then
			-- skip over until the next do
			local _, do_end = rex.find(line, do_pattern, search_index)
			if do_end == nil then -- mul never gets reenabled in this line, exit but save enabled false for next line
				enabled = false
				return sum
			end
			enabled = true
			search_index = do_end
		else
			local dont_start, dont_end = rex.find(line, dont_pattern, search_index)
			local mul_start, mul_end, a, b = rex.find(line, mul_pattern, search_index)

			-- no more muls, no more processing needed
			if mul_end == nil and dont_end == nil then
				return sum
			end

			if dont_start == nil or mul_start < dont_start then
				sum = sum + a * b
				search_index = mul_end
			else
				enabled = false
				search_index = dont_end
			end
		end

		--print(sum)
		--print(a, b)
		--print(dont_start, mul_start)
	end
end

local lines = {}
for line in io.lines(filename) do
	table.insert(lines, line)
end

local total_sum = fun.reduce(function(acc, line)
	return acc + multiply_line(line)
end, 0, lines)

print(total_sum)
