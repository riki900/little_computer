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

-- LOAD DR <- SR
-- LOAD DR <- 0x0000
alu.LOAD = function(instruction)
	local _, dest, src = table.unpack(instruction)
	if type(src) == "number" then
		registers[dest] = src
	else
		registers[dest] = registers[src]
	end
	set_cc(registers[dest])
end

-- LEA DR <- LABEL (load address of LABEL)
alu.LEA = true

-- LD DR <- LABEL ( load value at address of LABEL)
alu.LD = true

-- ADD DR <- SRC1 + SRC2
-- ADD DR <- SRC1 + 0x0000
alu.AND = true

-- NOT DR <- SR
alu.NOT = function(instruction)
	local _, dest, src = table.unpack(instruction)
	registers[dest] = ~registers[src]
	set_cc(registers[dest])
end

-- ADD DR <- SRC1 + SRC2
-- ADD DR <- SRC1 + 0x0000
alu.ADD = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	if type(src2) == "number" then
		registers[dest] = registers[src1] + src2
	else
		registers[dest] = registers[src1] + registers[src2]
	end
	set_cc(registers[dest])
end

-- SUB DR <- SRC1 + SRC2
-- SUB DR <- SRC1 + 0x0000
alu.SUB = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	if type(src2) == "number" then
		registers[dest] = registers[src1] - src2
	else
		registers[dest] = registers[src1] - registers[src2]
	end
	set_cc(registers[dest])
end

-- MUL DR <- SRC1 + SRC2
-- MUL DR <- SRC1 + 0x0000
alu.MUL = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	if type(src2) == "number" then
		registers[dest] = registers[src1] * src2
	else
		registers[dest] = registers[src1] * registers[src2]
	end
	set_cc(registers[dest])
end

-- integer division using a pair of registers.
-- DR is the quotient register, the remainder is stored in R0.
-- DIV DR1 <- SRC1 / SRC2
-- DIV DR1 <- SRC1 / 0x0000
alu.DIV = function(instruction)
	local _, dest, src1, src2 = table.unpack(instruction)
	if type(src2) == "number" then
		registers[dest] = registers[src1] // src2
	else
		registers[dest] = registers[src1] // registers[src2]
	end
	set_cc(registers[dest])
end

-- HALT (stop execution)
alu.HALT = true

-- branch instructions
-- BRxxx LABEL
-- unconditional branch
alu.BR = true

-- conditional branch when NZP flags are set
alu.BRnzp = true

-- conditional branch when NZ flags are set
alu.BRnz = true

-- conditional branch when NP flags are set
alu.BRnp = true

-- conditional branch when Z flags are set
alu.BRz = true

-- conditional branch when ZP flags are set
alu.BRzp = true

-- conditional branch when P flags are set
alu.BRp = true

-- JMP SR (jump to location in loaded into the source register)
alu.JMP = true

-- JSR LABEL (jump to LABEL loc and set R7 to next PC)
alu.JSR = true

-- JSRR SR (jump to loc in SR and set R7 to next PC)
alu.JSRR = true

-- RET (return from subroutine - jump to location in R7.)
alu.RET = true

--[[
   TRAP instructions
--]]

-- GETC - get single char from STDIN (no echo), store in R0
alu.GETC = true

-- OUT - print char in R0 on STDOUT
alu.OUT = true

-- OUT - print char in R0 on STDOUT
alu.OUT = true

-- IN - get single char from STDIN (with echo), store in R0
alu.GETC = true

-- PUTS LABEL - print string at LABEL to STDOUT 
alu.PUTS = true






return alu
