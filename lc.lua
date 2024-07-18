local tests = require("tests/tests")

local registers = {
	R0 = 0x0000,
	R1 = 0x0000,
	R2 = 0x0000,
	R3 = 0x0000,
	R4 = 0x0000,
	R5 = 0x0000,
	R6 = 0x0000,
	R7 = 0x0000,
}

local clear_registers = {
	{ "LOAD", "R0", 0x0000 },
	{ "LOAD", "R1", 0x0000 },
	{ "LOAD", "R2", 0x0000 },
	{ "LOAD", "R3", 0x0000 },
	{ "LOAD", "R4", 0x0000 },
	{ "LOAD", "R5", 0x0000 },
	{ "LOAD", "R6", 0x0000 },
	{ "LOAD", "R7", 0x0000 },
}

local function display_as_16_bit(value)
	return string.sub(string.format("%04X", value), -4)
end

local cc = {
	N = false,
	Z = false,
	P = false,
}

local function set_cc(value)
	cc.N = (value < 0)
	cc.Z = (value == 0)
	cc.P = (value > 0)
end

local alu = {
	-- instructions follow

	-- LOAD DR <- SRC
	-- LOAD RR <- 0x0000
	LOAD = function(instruction)
		local _, dest, src = table.unpack(instruction)
		if type(src) == "number" then
			registers[dest] = src
		else
			registers[dest] = registers[src]
		end
		set_cc(registers[dest])
	end,

	-- ADD DR <- SRC1 + SRC2
	-- ADD DR <- SRC1 + 0x0000
	ADD = function(instruction)
		local _, dest, src1, src2 = table.unpack(instruction)
		if type(src2) == "number" then
			registers[dest] = registers[src1] + src2
		else
			registers[dest] = registers[src1] + registers[src2]
		end
		set_cc(registers[dest])
	end,
	-- ADD DR <- SRC1 + SRC2
	-- ADD DR <- SRC1 + 0x0000
	SUB = function(instruction)
		local _, dest, src1, src2 = table.unpack(instruction)
		if type(src2) == "number" then
			registers[dest] = registers[src1] - src2
		else
			registers[dest] = registers[src1] - registers[src2]
		end
		set_cc(registers[dest])
	end,
	-- MUL DR <- SRC1 + SRC2
	-- MUL DR <- SRC1 + 0x0000
	MUL = function(instruction)
		local _, dest, src1, src2 = table.unpack(instruction)
		if type(src2) == "number" then
			registers[dest] = registers[src1] * src2
		else
			registers[dest] = registers[src1] * registers[src2]
		end
		set_cc(registers[dest])
	end,
	-- integer division using a pair of registers.
	-- DR is the quotient register, the remainder is stored in the next register.
	-- DIV R3, R5, R6 divides r5 by r6 storing dividend in R3 and remainder in R4
	-- MUL DR1 <- SRC1 / SRC2
	-- MUL DR1 <- SRC1 / 0x0000
	DIV = function(instruction)
		local _, dest, src1, src2 = table.unpack(instruction)
		if type(src2) == "number" then
			registers[dest] = registers[src1] // src2
		else
			registers[dest] = registers[src1] // registers[src2]
		end
		set_cc(registers[dest])
	end,
	-- DR <- SR
	NOT = function(instruction)
		local _, dest, src = table.unpack(instruction)
		registers[dest] = ~registers[src]
		set_cc(registers[dest])
	end,
}

local function print_registers()
	-- display only the right most 4 hex digits
	local print_line = ""
	for r = 0, 7 do
		local register = string.format("R%d", r)
		local value = display_as_16_bit(registers[register])
		print_line = print_line .. string.format("%3s: %s", register, value)
	end
	return print_line
end

local function run(_program)
	for _, instruction in ipairs(_program) do
		local op_code = table.unpack(instruction)
		alu[op_code](instruction)
	end
end

for key, _ in pairs(alu) do
	print(key)
end

--[[
for _, test in pairs(tests) do
	print()
	run(clear_registers)
	print(test.description)
	run(test.instructions)
	print(print_registers())
end
--]]
