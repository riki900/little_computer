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

local RAM = {}
local RAM_SIZE = 1024
local function init_RAM()
	for i = 0, RAM_SIZE - 1 do
		RAM[i] = 0
	end
end

local function byte_to_char(value)
	local display_value = string.char(value)
	if display_value:match("%w") then
		return display_value
	end
	if display_value:match("%p") then
		return display_value
	end
	return "."
end

local function dump_RAM()
	local address = 0
	local segment_size = 16
	while address < #RAM do
		io.write(string.format("%04X: ", address))
		local chars = ""
		for _ = 1, segment_size do
			io.write(string.format("%02X ", RAM[address]))
			chars = chars .. byte_to_char(RAM[address])
			address = address + 1
		end
		print(string.format(" %s", chars))
	end
end

local function display_as_16_bit(value)
	return string.sub(string.format("%04X", value), -4)
end
local CC_VALUES = {
	POSITIVE = "P",
	ZERO = "Z",
	NEGATIVE = "N",
}

local CC = CC_VALUES.P

local program = {
	{ "LOAD", "R0", 0x00ff },
	{ "LOAD", "R1", 0x0001 },
	{ "ADD", "R2", "R1", "R0" },
	{ "ADD", "R1", "R1", 0x0001 },
	{ "LR", "R1", "R0" },
	{ "NOT", "R3", "R1" },
	{ "NOT", "R1", "R1" },
	{ "HALT" },
}

local function set_cc(value)
	if value > 0 then
		CC = CC_VALUES.POSITIVE
	elseif value < 0 then
		CC = CC_VALUES.NEGATIVE
	else
		CC = CC_VALUES.ZERO
	end
end

local alu = {
	-- instructions follow

	-- R3 <- R2
	LOAD = function(instruction)
		local _, dest, src = table.unpack(instruction)
		registers[dest] = src
		set_cc(registers[dest])
	end,
	-- ADD R2 <- R3 + R4
	-- ADD R2 <- R3 + 0x0000
	ADD = function(instruction)
		local _, dest, src1, src2 = table.unpack(instruction)
		if type(src2) == "number" then
			registers[dest] = registers[src1] + src2
		else
			registers[dest] = registers[src1] + registers[src2]
		end
		set_cc(registers[dest])
	end,
	LR = function(instruction)
		local _, dest, src = table.unpack(instruction)
		registers[dest] = registers[src]
		set_cc(registers[dest])
	end,
	-- R2 <- NOT R1
	NOT = function(instruction)
		local _, dest, src = table.unpack(instruction)
		registers[dest] = ~registers[src]
		set_cc(registers[dest])
	end,
}

local function print_registers()
	-- display only the right most 4 hex digits
	for r = 0, 7 do
		local register = string.format("R%d", r)
		local value = display_as_16_bit(registers[register])
		print(string.format("%3s: %s", register, value))
	end
end

local function run()
	for _, instruction in ipairs(program) do
		local op_code = table.unpack(instruction)
		print(table.unpack(instruction))
		if op_code == "HALT" then
			break
		end
		alu[op_code](instruction)
	end
end

init_RAM()
dump_RAM()
run()
print_registers()
