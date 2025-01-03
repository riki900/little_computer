local lib_output = {}

local ASM_FILE_SUFFIX_PATTERN = ".asm$"
local NO_VALUE = ""
local LIST_HEADING_1 = "ADDR  OP  OPERANDS           LINE: SOURCE"
local LIST_HEADING_2 = "---- ---- ------------------ ----- ------------------------------"
local SYMBOLS_HEADING_1 = ""
local SYMBOLS_HEADING_2 = "SYMBOL    ADDR"
local SYMBOLS_HEADING_3 = "--------- -----"

local function format_obj_code(obj_code)
	local formatted_operands = ""
	for _, operand in ipairs({ "op1", "op2", "op3" }) do
		local operand_value = obj_code[operand]
		if operand_value == nil then
			break
		end
		if type(operand_value) == "number" then
			operand_value = string.format("%04X", operand_value)
		end
		formatted_operands = formatted_operands .. string.format("%s ", obj_code[operand])
	end
	local formatted_obj_code = string.format("%04X %4s %s", obj_code.address, obj_code.op_code, formatted_operands)
	return formatted_obj_code
end

function lib_output.run(src_file_name, _statements, _symbols)
	-- write out source listing and symbols
	local my_base_name = string.gsub(src_file_name, ASM_FILE_SUFFIX_PATTERN, NO_VALUE)

	local lst_file_name = string.format("%s.lst", my_base_name)
	local lst_file = assert(io.open(lst_file_name, "w"))
	lst_file:write(string.format("%s\n", LIST_HEADING_1))
	lst_file:write(string.format("%s\n", LIST_HEADING_2))

	-- write out object code
	local obj_file_name = string.format("%s.obj", my_base_name)
	local obj_file = assert(io.open(obj_file_name, "w"))

	for _, statement in ipairs(_statements) do
		-- write out object code
		local formatted_obj_code = format_obj_code(statement.obj_code)
		obj_file:write(string.format("%s\n", formatted_obj_code))
		-- truncate obj_code for the listing
		local listing_obj_code = string.sub(formatted_obj_code, 1, 28)
		-- write listing line with obj and source
		local print_line = string.format("%-30s%03d: %s", listing_obj_code, statement.line, statement.source)
		lst_file:write(string.format("%s\n", print_line))
	end
	lst_file:write(string.format("%s\n", SYMBOLS_HEADING_1))
	lst_file:write(string.format("%s\n", SYMBOLS_HEADING_2))
	lst_file:write(string.format("%s\n", SYMBOLS_HEADING_3))
	local sorted_symbols = {}
	for symbol in pairs(_symbols) do
		table.insert(sorted_symbols, symbol)
	end
	table.sort(sorted_symbols)
	for _, symbol in ipairs(sorted_symbols) do
		lst_file:write(string.format("%-10s %s\n", symbol, _symbols[symbol]))
	end

	lst_file:close()
	obj_file:close()
end

return lib_output
