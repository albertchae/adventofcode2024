-- require("debug")

local inspect = require("inspect")
local pl = require("pl.utils")
local fun = require("fun")

local filename = arg[1]
print("Reading file: " .. filename)

local function split_string_to_chars(string)
	return fun.totable(fun.take_while(function(_)
		return true
	end, string))
end

local function parse_file_to_grid(filename)
	local grid = {}
	for line in io.lines(filename) do
		local chars = split_string_to_chars(line)
		table.insert(grid, chars)
	end

	return grid
end

local grid = parse_file_to_grid(filename)

print(inspect(grid))

local function valid_coordinates(grid, i, j)
	if i < 1 or j < 1 or i > #grid or j > #grid[1] then
		return false
	else
		return true
	end
end

local function enumerate_words(grid, i, j, length)
	local directions = { { -1, -1 }, { -1, 0 }, { -1, 1 }, { 0, -1 }, { 0, 1 }, { 1, -1 }, { 1, 0 }, { 1, 1 } }

	return fun.reduce(function(acc, direction)
		local x, y = i, j
		local chars = {}
		for _ in fun.range(length) do
			if not valid_coordinates(grid, x, y) then
				return acc
			end
			table.insert(chars, grid[x][y])
			x = x + direction[1]
			y = y + direction[2]
		end
		table.insert(acc, table.concat(chars))
		return acc
	end, {}, directions)
end

-- print(inspect(enumerate_words(grid, 1, 1, 3)))

-- assumes square grid
local function count_search(grid, target)
	local sum = 0
	for i in fun.range(#grid) do
		for j in fun.range(#grid[i]) do
			for _, word in ipairs(enumerate_words(grid, i, j, #target)) do
				if word == target then
					sum = sum + 1
				end
			end
		end
	end
	return sum

	-- loop over all i,j
	--   gather all possible words of the same length as target in every direction
	--   check if any match target, add to count
end

print(count_search(grid, "XMAS"))
