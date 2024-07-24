local lib_pass2 = {}

local OPERAND_TYPES = {
	REGISTER = "REGISTER",
	HEX_LITERAL = "HEX_LITERAL",
	STR_LITERAL = "STR_LITERAL",
	LABEL = "LABEL",
	UNKNOWN = "UNKNOWN",
}

function lib_pass2.run(_statements, _symbols)
	local my_statements = {}
	for _, statement in ipairs(_statements) do
		local ir_code = statement.ir_code
		local op_code = ir_code.op_code
		local op1 = ir_code.op1
		local op2 = ir_code.op2
		local op3 = ir_code.op3
		-- replace symbols with address
		if op1 ~= nil then
			if op1.type == OPERAND_TYPES.LABEL and _symbols[op1.value] ~= nil then
				op1 = _symbols[op1.value]
			else
				op1 = op1.value
			end
		end
		if op2 ~= nil then
			if op2.type == OPERAND_TYPES.LABEL and _symbols[op2.value] ~= nil then
				op2 = _symbols[op2.value]
			else
				op2 = op2.value
			end
		end
		if op3 ~= nil then
			if op3.type == OPERAND_TYPES.LABEL and _symbols[op3.value] ~= nil then
				op3 = _symbols[op3.value]
			else
				op3 = op3.value
			end
		end

		local obj_code = { address = ir_code.address, op_code = op_code, op1 = op1, op2 = op2, op3 = op3 }
		statement.obj_code = obj_code
		table.insert(my_statements, statement)
	end
	return my_statements
end

return lib_pass2
