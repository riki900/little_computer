--[[
   little computer implemented instructions
--]]

local cc = {
	N = false,
	Z = false,
	P = false,
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

local function set_cc(value)
	cc.N = (value < 0)
	cc.Z = (value == 0)
	cc.P = (value > 0)
end

local alu = {}
-- instructions follow

-- DR <- SRC1 + SRC2
alu.ADDR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] + registers[src2]
	set_cc(registers[dest])
end

-- DR <- SRC1 + 0x0000
alu.ADDI = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] + src2
	set_cc(registers[dest])
end

-- DR <- SRC1 + LABEL
alu.ADD = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- SRC1 && LABEL
alu.AND = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- SRC1 && 0x0000
alu.ANDI = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- SRC1 && SRC2
alu.ANDR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- branch instructions
-- BRxxx LABEL
-- unconditional branch
alu.BR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- conditional branch when NZP flags are set
alu.BRnzp = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- conditional branch when NZ flags are set
alu.BRnz = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- conditional branch when NP flags are set
alu.BRnp = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- conditional branch when Z flags are set
alu.BRz = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- conditional branch when ZP flags are set
alu.BRzp = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- conditional branch when P flags are set
alu.BRp = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- integer division result in DR remainder in R0.
-- DIV DR <- SRC1 / LABEL
alu.DIV = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- integer division result in DR remainder in R0.
-- DR <- SRC1 / 0x0000
alu.DIVI = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] // src2
	set_cc(registers[dest])
end

-- integer division result in DR remainder in R0.
-- DR <- SRC1 / SRC2
alu.DIVR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] // registers[src2]
	set_cc(registers[dest])
end

-- GETC - get single char from STDIN (no echo), store in R0
alu.GETC = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- HALT (stop execution)
alu.HALT = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- GETC - get single char from STDIN (echo), store in R0
alu.IN = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- JMP SR (jump to location in loaded into the source register)
alu.JMP = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- JSR LABEL (jump to LABEL loc and set R7 to next PC)
alu.JSR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- JSRR SR (jump to loc in SR and set R7 to next PC)
alu.JSRR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- LABEL ( LD value at address of LABEL)
alu.LD = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	set_cc(registers[dest])
	return true
end
-- DR <- 0x0000
alu.LDI = function(instruction)
	local _, dest, src = table.unpack(instruction)
		registers[dest] = src
	set_cc(registers[dest])
end

-- LD DR <- SR
alu.LDR = function(instruction)
	local _, dest, src = table.unpack(instruction)
	if type(src) == "number" then
		registers[dest] = src
	else
		registers[dest] = registers[src]
	end
	set_cc(registers[dest])
end

-- DR <- LABEL (load address of label)
alu.LEA = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- SRC1 + LABEL
alu.MUL = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- SRC1 + 0x0000
alu.MULI = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] * src2
	set_cc(registers[dest])
end

-- DR <- SRC1 + SRC2
alu.MULR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] * registers[src2]
	set_cc(registers[dest])
end

-- DR -SR
alu.NOTR = function(instruction)
	local _, dest, src = table.unpack(instruction)
	registers[dest] = ~registers[src]
	set_cc(registers[dest])
end

-- DR <- SRC1 || LABEL
alu.OR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- SRC1 || 0x0000
alu.ORI = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- SRC1 || SRC2
alu.ORR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- OUT - print char in R0 on STDOUT
alu.OUT = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- PUTS LABEL - print string at LABEL to STDOUT
alu.PUTS = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- RET (return from subroutine - jump to location in R7.)
alu.RET = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- DR <- SRC1 - LABEL
alu.SUB = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- SUB DR <- SRC1 - 0x0000
alu.SUBI = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] - src2
	set_cc(registers[dest])
end

-- SUB DR <- SRC1 - SRC2
alu.SUBR = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] - registers[src2]
	set_cc(registers[dest])
end

return alu
