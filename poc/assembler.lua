--[[
   assembler for my little computer
--]]

local OP_CODES = {

	-- math operations
	ADD = true,
	ADDI = true,
	ADDR = true,
	DIV = true,
	DIVI = true,
	DIVR = true,
	MUL = true,
	MULI = true,
	MULR = true,
	SUB = true,
	SUBI = true,
	SUBR = true,

	-- bit operations
	AND = true,
	ANDI = true,
	ANDR = true,
	NOTR = true,
	OR = true,
	ORI = true,
	ORR = true,

	-- branch/jump operations
	BR = true,
	BRnp = true,
	BRnzp = true,
	BRnz = true,
	BRp = true,
	BRzp = true,
	BRz = true,
	JMP = true,
	RET = true,
	JSRR = true,
	JSR = true,

	-- trap instructions
	--[[ TODO: implement
	GETC = true,
	OUT = true,
	IN = true,
	--]]
	PUTS = true,

	-- misc instructions
	HALT = true,
	NOP = true,

	-- load resisters
	LEA = true,
	LD = true,
	LDI = true,
	LDR = true,
}

local pt = require("print_table")

local CR = "\n"

local function initialize()
	if #arg == 0 then
		print("Usage: lua assembler.lua <.asm source file>")
		os.exit(1)
	end

	local src_file_name = arg[1]
	local src_file = assert(io.open(src_file_name, "r"))
	local base_name = string.sub(src_file_name, 1, string.find(src_file_name, "%p") - 1)
	local lst_file_name = base_name .. ".lst"
	local lst_file = assert(io.open(lst_file_name, "w"))
	local obj_file_name = base_name .. ".obj"
	local obj_file = assert(io.open(obj_file_name, "w"))

	return src_file, lst_file, obj_file
end

local function tokenize(src_line)
	local tokens = {}
	for token in string.gmatch(src_line, "[^%s+,]+") do
		table.insert(tokens, token)
	end
	local label
	if string.match(tokens[1], "%:$") then
		label = table.remove(tokens, 1)
	end
	local op_code_pos = 1
	return {
		label = label,
		op_code = tokens[op_code_pos],
		op1 = tokens[op_code_pos + 1],
		op2 = tokens[op_code_pos + 2],
		op3 = tokens[op_code_pos + 3],
	}
end

local function lex(src_file, lst_file)
	local tokens = {}
	local src_line = src_file:read("*l")
	while src_line do
		lst_file:write(src_line .. CR)
		-- ignore blank and comment lines
		if string.match(src_line, "^%s*$") then
			goto continue
		end
		if string.match(src_line, "^%s*#") then
			goto continue
		end
		-- end ignore

		table.insert(tokens, tokenize(src_line))

		::continue::
		src_line = src_file:read("*l")
	end

	io.close(src_file)
	io.close(lst_file)

	return tokens
end

local function pass1(tokens)
	local ir_code = {}
	local symbols = {}
	local address = 1

	for _, statement in ipairs(tokens) do
		table.insert(ir_code, {
			label = statement.label,
			op_code = statement.op_code,
			op1 = statement.op1,
			op2 = statement.op2,
			op3 = statement.op3,
			address = address,
		})
		if statement.label ~= nil then
			symbols[statement.label] = address
		end
		address = address + 1
	end

	return symbols, ir_code
end

local function pass2(symbols, ir_code, obj_file)
	for _, statement in ipairs(ir_code) do
		local op_code = statement.op_code
		local op1 = statement.op1
		local op2 = statement.op2
		local op3 = statement.op3
		-- replace symbols with address
		if symbols[op1] ~= nil then
			op1 = symbols[op1]
		end
		if symbols[op2] ~= nil then
			op2 = symbols[op2]
		end
		if symbols[op3] ~= nil then
			op3 = symbols[op3]
		end
		local statement_details = { statement.address, op_code, op1, op2, op3 }
		local obj_statement = ""
		for _, detail in ipairs(statement_details) do
			obj_statement = obj_statement .. detail .. " "
		end
		obj_file:write(obj_statement .. CR)
	end

	obj_file:close()
end

local src_file, lst_file, obj_file = initialize()
local tokens = lex(src_file, lst_file)
local symbols, ir_code = pass1(tokens)
pass2(symbols, ir_code, obj_file)
