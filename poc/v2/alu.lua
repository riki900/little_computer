local alu = {}

local ram = {}

local REMAINDER_REGISTER = "R0"
local RETURN_REGISTER = "R7"

local registers = {
	[0] = 0x0000,
	[1] = 0x0000,
	[2] = 0x0000,
	[3] = 0x0000,
	[4] = 0x0000,
	[5] = 0x0000,
	[6] = 0x0000,
	[7] = 0x0000,
}

local CC = 0

local CC_FLAGS = {
	negative = 1 << 2,
	zero = 1 << 1,
	positive = 1,
}
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

alu[0x0000] = function() --  DC and NOP
end

-- DR <- SRC1 && LABEL
alu[0x0010] = function(instruction) -- AND
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) & tonumber(fetch_ram(address))
	set_cc(registers[dest])
end

-- DR <- SRC1 && 0x0000
alu[0x0011] = function(instruction) -- ANDI
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) & tonumber(src2)
	set_cc(registers[dest])
end

-- DR <- SRC1 && SRC2
alu[0x0012] = function(instruction) -- ANDR
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) & tonumber(registers[src2])
	set_cc(registers[dest])
end

-- DR -SR
alu[0x0013] = function(instruction) -- NOTR
	local _, _, dest, src = table.unpack(instruction)
	registers[dest] = ~tonumber(registers[src])
	set_cc(registers[dest])
end

-- DR <- SRC1 || LABEL
alu[0x0014] = function(instruction) -- OR
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) | tonumber(fetch_ram(address))
	set_cc(registers[dest])
end

-- DR <- SRC1 || 0x0000
alu[0x0015] = function(instruction) -- ORI
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) | tonumber(src2)
	set_cc(registers[dest])
end

-- DR <- SRC1 || SRC2
alu[0x0016] = function(instruction) -- ORR
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = tonumber(registers[src1]) | tonumber(registers[src2])
	set_cc(registers[dest])
end

-- branch to label
alu[0x0030] = function(instruction) -- BR
	local _, _, address = table.unpack(instruction)
	return tonumber(address)
end

-- conditional branch when NP flags are set
alu[0x0031] = function(instruction) -- BRnp
	local _, _, address = table.unpack(instruction)
	if
		((CC & CC_FLAGS.negative) == CC_FLAGS.negative or (CC & CC_FLAGS.positive) == CC_FLAGS.positive)
		and (CC & CC_FLAGS.zero) ~= CC_FLAGS.zero
	then
		return tonumber(address)
	end
end

-- conditional branch when Z flags are set
alu[0x0032] = function(instruction) -- BRnz
	local _, _, address = table.unpack(instruction)
	if
		((CC & CC_FLAGS.negative) ~= CC_FLAGS.negative or (CC & CC_FLAGS.positive) ~= CC_FLAGS.positive)
		and (CC & CC_FLAGS.zero) == CC_FLAGS.zero
	then
		return tonumber(address)
	end
end

-- conditional branch when NZP flags are set
alu[0x0033] = function(instruction) -- BRnzp
	local _, _, address = table.unpack(instruction)
	return tonumber(address)
end

-- conditional branch when P flags are set
alu[0x0034] = function(instruction) -- BRp
	local _, _, address = table.unpack(instruction)
	if
		((CC & CC_FLAGS.zero) ~= CC_FLAGS.zero or (CC & CC_FLAGS.negative) ~= CC_FLAGS.negative)
		and (CC & CC_FLAGS.positive) == CC_FLAGS.positive
	then
		return tonumber(address)
	end
end

-- conditional branch when Z flags are set
alu[0x0035] = function(instruction) -- BRz
	local _, _, address = table.unpack(instruction)
	if
		((CC & CC_FLAGS.negative) ~= CC_FLAGS.negative or (CC & CC_FLAGS.positive) ~= CC_FLAGS.positive)
		and (CC & CC_FLAGS.zero) == CC_FLAGS.zero
	then
		return tonumber(address)
	end
end

-- conditional branch when ZP flags are set
alu[0x0036] = function(instruction) -- BRzp
	local _, _, address = table.unpack(instruction)
	if
		((CC & CC_FLAGS.zero) == CC_FLAGS.zero or (CC & CC_FLAGS.positive) == CC_FLAGS.positive)
		and (CC & CC_FLAGS.negative) ~= CC_FLAGS.negative
	then
		return tonumber(address)
	end
end

-- JMP SR (jump to location in loaded into the source register)
alu[0x0037] = function(instruction) -- JMP
	local _, _, jmp_to_register = table.unpack(instruction)
	return tonumber(registers[jmp_to_register])
end

-- JSR LABEL (jump to LABEL loc and set R7 to next PC)
alu[0x0038] = function(instruction) -- JSR
	local PC, _, address = table.unpack(instruction)
	registers[RETURN_REGISTER] = PC + 1
	return tonumber(address)
end
-- JSRR SR (jump to loc in SR and set R7 to next PC)
alu[0x0039] = function(instruction) -- JSRR
	local PC, _, jmp_to_register = table.unpack(instruction)
	registers[RETURN_REGISTER] = PC + 1
	return tonumber(registers[jmp_to_register])
end

-- RET (return from subroutine - jump to location in R7.)
alu[0x003A] = function(instruction) -- RET
	local _ = table.unpack(instruction)
	return tonumber(registers[RETURN_REGISTER])
end

-- GETC - get single char from STDIN (no echo), store in R0
alu[0x0050] = function(instruction) -- GETC
	local _, _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- GETC - get single char from STDIN (echo), store in R0
alu[0x0051] = function(instruction) -- IN
	local _, _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- OUT - print char in R0 on STDOUT
alu[0x0052] = function(instruction) -- OUT
	local _, _, dest, src1, src2 = table.unpack(instruction)
	_ = dest + src1 + src2 -- remove when implemented
	return true
end

-- PUTS LABEL - print string at LABEL to STDOUT
alu[0x0053] = function(instruction) -- PUTS
	local _, _, address = table.unpack(instruction)
	print(fetch_ram(address))
end

-- DR <- LABEL ( LD value at address of LABEL)
alu[0x0070] = function(instruction) -- LD
	local _, _, dest, address = table.unpack(instruction)
	registers[dest] = fetch_ram(address)
	set_cc(registers[dest])
end

-- DR <- 0x0000
alu[0x0071] = function(instruction) -- LDI
	local _, _, dest, src = table.unpack(instruction)
	registers[dest] = src
	set_cc(registers[dest])
end

-- DR <- SR
alu[0x0072] = function(instruction) -- LDR
	local _, _, dest, src = table.unpack(instruction)
	registers[dest] = registers[src]
	set_cc(registers[dest])
end

-- DR <- LABEL (load address of label)
alu[0x0073] = function(instruction) -- LEA
	local _, _, dest, src1 = table.unpack(instruction)
	registers[dest] = src1
end

-- DR <- SRC1 + LABEL
alu[0x0090] = function(instruction) -- ADD
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = registers[src1] + fetch_ram(address)
	set_cc(registers[dest])
end

-- DR <- SRC1 + 0x0000
alu[0x0091] = function(instruction) -- ADDI
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] + src2
	set_cc(registers[dest])
end

-- DR <- SRC1 + SRC2
alu[0x0092] = function(instruction) -- ADDR
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] + registers[src2]
	set_cc(registers[dest])
end

-- integer division result in DR remainder in R0.
-- DIV DR <- SRC1 / LABEL
alu[0x0093] = function(instruction) -- DIV
	local _, _, dest, src1, address = table.unpack(instruction)
	local dividend = registers[src1]
	registers[dest] = dividend // fetch_ram(address)
	registers[REMAINDER_REGISTER] = dividend % fetch_ram(address)
	set_cc(registers[dest])
end

-- integer division result in DR remainder in R0.
-- DR <- SRC1 / 0x0000
alu[0x0094] = function(instruction) -- DIVI
	local _, _, dest, src1, src2 = table.unpack(instruction)
	local dividend = registers[src1]
	registers[dest] = dividend // src2
	registers[REMAINDER_REGISTER] = dividend % src2
	set_cc(registers[dest])
end

-- integer division result in DR remainder in R0.
-- DR <- SRC1 / SRC2
alu[0x0095] = function(instruction) -- DIVR
	local _, _, dest, src1, src2 = table.unpack(instruction)
	local dividend = registers[src1]
	registers[dest] = dividend // registers[src2]
	registers[REMAINDER_REGISTER] = dividend % registers[src2]
	set_cc(registers[dest])
end

-- DR <- SRC1 + LABEL
alu[0x0096] = function(instruction) -- MUL
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = registers[src1] * fetch_ram(address)
	set_cc(registers[dest])
end

-- DR <- SRC1 + 0x0000
alu[0x0097] = function(instruction) -- MULI
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] * src2
	set_cc(registers[dest])
end

-- DR <- SRC1 + SRC2
alu[0x0098] = function(instruction) -- MULR
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] * registers[src2]
	set_cc(registers[dest])
end

-- DR <- SRC1 - LABEL
alu[0x0099] = function(instruction) -- SUB
	local _, _, dest, src1, address = table.unpack(instruction)
	registers[dest] = registers[src1] - fetch_ram(address)
	set_cc(registers[dest])
end

-- DR <- SRC1 - 0x0000
alu[0x009A] = function(instruction) -- SUBI
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] - src2
	set_cc(registers[dest])
end

-- DR <- SRC1 - SRC2
alu[0x009B] = function(instruction) -- SUBR
	local _, _, dest, src1, src2 = table.unpack(instruction)
	registers[dest] = registers[src1] - registers[src2]
	set_cc(registers[dest])
end

-- HALT (stop execution)
alu[0x00B0] = function() -- HALT
end

local function display_as_16_bit(value)
	return string.sub(string.format("%04X", value), -4)
end

function alu.state()
	-- display only the right most 4 hex digits
	local print_line = ""
	for register = 0, 7 do
		local value = display_as_16_bit(registers[register])
		print_line = print_line .. string.format("%d: %s ", register, value)
	end
	return print_line
end

function alu.initialize(_ram)
	ram = _ram
end

--[[
TODO: use to convert strings in obj file to hex numbers
used by the alu to lookup operations
local to_hex = tonumber("0x"..number)
--]]
return alu