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
	local defaultmt = {
		__index = function()
			return {}
		end,
	}
	setmetatable(grid, defaultmt)

	for line in io.lines(filename) do
		local chars = split_string_to_chars(line)
		table.insert(grid, chars)
	end

	return grid
end

local grid = parse_file_to_grid(filename)

print(inspect(grid))

local function is_xmas_center(grid, i, j)
	if grid[i][j] ~= "A" then
		return false
	end

	-- look for m on one side and s on the other
	local sides =
		{ { { -1, -1 }, { -1, 1 } }, { { 1, -1 }, { 1, 1 } }, { { -1, -1 }, { 1, -1 } }, { { -1, 1 }, { 1, 1 } } }

	return fun.any(function(side)
		return fun.all(function(corner)
			local x, y = i, j
			local a, b = i, j
			x = x + corner[1]
			y = y + corner[2]
			a = a - corner[1]
			b = b - corner[2]

			-- relies on lua out of bounds access returning nil and metatable returning default empty table
			return grid[x][y] == "M" and grid[a][b] == "S"
		end, side)
	end, sides)
end

-- print(inspect(enumerate_words(grid, 1, 1, 3)))

-- assumes square grid
local function count_search(grid)
	local sum = 0
	for i in fun.range(#grid) do
		for j in fun.range(#grid[i]) do
			if is_xmas_center(grid, i, j) then
				sum = sum + 1
			end
		end
	end
	return sum
end

--is_xmas_center(grid, 2, 3)

print(count_search(grid))
