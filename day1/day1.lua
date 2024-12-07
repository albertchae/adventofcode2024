-- require("debug")

local inspect = require("inspect")
local pl = require("pl.utils")

local filename = arg[1]
print("Reading file: " .. filename)

local lines = {}
for line in io.lines(filename) do
	table.insert(lines, line)
end

print(inspect(lines))

return lines
