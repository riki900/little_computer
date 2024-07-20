--[[
   little computer implemented instructions
--]]
local pt = require("print_table")

local REMAINDER_REGISTER = "R0"
local RETURN_REGISTER = "R7"

local CC = 0

local CC_FLAGS = {
	negative = 1 << 2,
	zero = 1 << 1,
	positive = 1,
}

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

local ram = {}

local function set_cc(value)
	CC = 0
	value = tonumber(value)
	if value < 0 then
		CC = CC + CC_FLAGS.negative
	elseif value == 0 then
		CC = CC + CC_FLAGS.zero
	else
		CC = CC + CC_FLAGS.positive
	end
end

local function fetch_ram(address)
	local value_idx = 3
	return ram[tonumber(address)][value_idx]
end

local alu = {}
-- instructions follow

-- DR <- SRC1 + SRC2
alu.ADDR = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] + registers[src2]
	set_cc(registers[dest])
end

-- DR <- SRC1 + 0x0000
alu.ADDI = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] + src2
	set_cc(registers[dest])
end

-- DR <- SRC1 + LABEL
alu.ADD = function(instruction)
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = registers[src1] + fetch_ram(address)
	set_cc(registers[dest])
end

-- DR <- SRC1 && LABEL
alu.AND = function(instruction)
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) & tonumber(fetch_ram(address))
	set_cc(registers[dest])
end

-- DR <- SRC1 && 0x0000
alu.ANDI = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) & tonumber(src2)
	set_cc(registers[dest])
end

-- DR <- SRC1 && SRC2
alu.ANDR = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) & tonumber(registers[src2])
	set_cc(registers[dest])
end

-- branch instructions
-- BRxxx LABEL
-- unconditional branch
alu.BR = function(instruction)
	local _, _, address = table.unpack(instruction)
	return tonumber(address)
end

-- conditional branch when NZP flags are set
alu.BRnzp = function(instruction)
	local _, _, address = table.unpack(instruction)
	return tonumber(address)
end

-- conditional branch when NZ flags are set
alu.BRnz = function(instruction)
	local _, _, address = table.unpack(instruction)
	if ((CC & CC_FLAGS.negative) == CC_FLAGS.negative
		or (CC & CC_FLAGS.zero) == CC_FLAGS.zero)
		and (CC & CC_FLAGS.positive) ~= CC_FLAGS.positive
	then
		return tonumber(address)
	end
end

-- conditional branch when NP flags are set
alu.BRnp = function(instruction)
	local _, _, address = table.unpack(instruction)
	if ((CC & CC_FLAGS.negative) == CC_FLAGS.negative
		or (CC & CC_FLAGS.positive) == CC_FLAGS.positive)
		and (CC & CC_FLAGS.zero) ~= CC_FLAGS.zero
	then
		return tonumber(address)
	end
end

-- conditional branch when Z flags are set
alu.BRz = function(instruction)
	local _, _, address = table.unpack(instruction)
	if ( (CC & CC_FLAGS.negative) ~= CC_FLAGS.negative
    or (CC & CC_FLAGS.positive) ~= CC_FLAGS.positive )
    and (CC & CC_FLAGS.zero) == CC_FLAGS.zero
    then
	   return tonumber(address)
	end
end

-- conditional branch when ZP flags are set
alu.BRzp = function(instruction)
	local _, _, address = table.unpack(instruction)
    if ( (CC & CC_FLAGS.zero) == CC_FLAGS.zero
    or (CC & CC_FLAGS.positive) == CC_FLAGS.positive )
    and (CC & CC_FLAGS.negative) ~= CC_FLAGS.negative
	then
	   return tonumber(address)
	end
end

-- conditional branch when P flags are set
alu.BRp = function(instruction)
	local _, _, address = table.unpack(instruction)
    if ( (CC & CC_FLAGS.zero) ~= CC_FLAGS.zero
    or (CC & CC_FLAGS.negative) ~= CC_FLAGS.negative )
    and (CC & CC_FLAGS.positive) == CC_FLAGS.positive
	then
	   return tonumber(address)
	end
end

-- pseudo code DC same as NOtokensP
alu.DC = function() end

-- integer division result in DR remainder in R0.
-- DIV DR <- SRC1 / LABEL
alu.DIV = function(instruction)
	local _, _, dest, src1, address = table.unpack(instruction)
	local dividend = registers[src1]
	registers[dest] = dividend // fetch_ram(address)
	registers[REMAINDER_REGISTER] = dividend % fetch_ram(address)
	set_cc(registers[dest])
end

-- integer division result in DR remainder in R0.
-- DR <- SRC1 / 0x0000
alu.DIVI = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	local dividend = registers[src1]
	registers[dest] = dividend // src2
	registers[REMAINDER_REGISTER] = dividend % src2
	set_cc(registers[dest])
end

-- integer division result in DR remainder in R0.
-- DR <- SRC1 / SRC2
alu.DIVR = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	local dividend = registers[src1]
	registers[dest] = dividend // registers[src2]
	registers[REMAINDER_REGISTER] = dividend % registers[src2]

	set_cc(registers[dest])
end

-- GETC - get single char from STDIN (no echo), store in R0
alu.GETC = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- HALT (stop execution)
alu.HALT = function() end

-- GETC - get single char from STDIN (echo), store in R0
alu.IN = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- JMP SR (jump to location in loaded into the source register)
alu.JMP = function(instruction)
	local _, _, jmp_to_register = table.unpack(instruction)
    return tonumber(registers[jmp_to_register])
end

-- JSR LABEL (jump to LABEL loc and set R7 to next PC)
alu.JSR = function(instruction)
	local PC, _, address = table.unpack(instruction)
	registers[RETURN_REGISTER] = PC + 1
	return tonumber(address)
end

-- JSRR SR (jump to loc in SR and set R7 to next PC)
alu.JSRR = function(instruction)
	local PC, _, jmp_to_register = table.unpack(instruction)
	registers[RETURN_REGISTER] = PC + 1
    return tonumber(registers[jmp_to_register])
end

-- DR <- LABEL ( LD value at address of LABEL)
alu.LD = function(instruction)
	local _, _, dest, address = table.unpack(instruction)
	registers[dest] = fetch_ram(address)
	set_cc(registers[dest])
end

-- DR <- 0x0000
alu.LDI = function(instruction)
	local _, _, dest, src = table.unpack(instruction)
	registers[dest] = src
	set_cc(registers[dest])
end

-- DR <- SR
alu.LDR = function(instruction)
	local _, _, dest, src = table.unpack(instruction)
	registers[dest] = registers[src]
	set_cc(registers[dest])
end

-- DR <- LABEL (load address of label)
alu.LEA = function(instruction)
	local _, _, dest, src1 = table.unpack(instruction)
	registers[dest] = src1
end

-- DR <- SRC1 + LABEL
alu.MUL = function(instruction)
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = registers[src1] * fetch_ram(address)
	set_cc(registers[dest])
end

-- DR <- SRC1 + 0x0000
alu.MULI = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] * src2
	set_cc(registers[dest])
end

-- DR <- SRC1 + SRC2
alu.MULR = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] * registers[src2]
	set_cc(registers[dest])
end

-- no operation (useful for branch labels)
alu.NOP = function() end

-- DR -SR
alu.NOTR = function(instruction)
	local _, _, dest, src = table.unpack(instruction)
	registers[dest] = ~tonumber(registers[src])
	set_cc(registers[dest])
end

-- DR <- SRC1 || LABEL
alu.OR = function(instruction)
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) | tonumber(fetch_ram(address))
	set_cc(registers[dest])
end

-- DR <- SRC1 || 0x0000
alu.ORI = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) | tonumber(src2)
	set_cc(registers[dest])
end

-- DR <- SRC1 || SRC2
alu.ORR = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) | tonumber(registers[src2])
	set_cc(registers[dest])
end

-- OUT - print char in R0 on STDOUT
alu.OUT = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- PUTS LABEL - print string at LABEL to STDOUT
alu.PUTS = function(instruction)
	local _, _, address = table.unpack(instruction)
	print(fetch_ram(address))
end

-- RET (return from subroutine - jump to location in R7.)
alu.RET = function(instruction)
	local _ = table.unpack(instruction)
    return tonumber(registers[RETURN_REGISTER])
end

-- DR <- SRC1 - LABEL
alu.SUB = function(instruction)
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = registers[src1] - fetch_ram(address)
	set_cc(registers[dest])
end

-- SUB DR <- SRC1 - 0x0000
alu.SUBI = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] - src2
	set_cc(registers[dest])
end

-- SUB DR <- SRC1 - SRC2
alu.SUBR = function(instruction)
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] - registers[src2]
	set_cc(registers[dest])
end

local function display_as_16_bit(value)
	return string.sub(string.format("%04X", value), -4)
end

function alu.state()
	-- display only the right most 4 hex digits
	local print_line = ""
	for r = 0, 7 do
		local register = string.format("R%d", r)
		local value = display_as_16_bit(registers[register])
		print_line = print_line .. string.format("%3s: %s", register, value)
	end
	return print_line
end

function alu.initialize(_ram)
	ram = _ram
end

return alu
