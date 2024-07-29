local pt = require("print_table")

local lib_pass1 = {}

local LABEL_PATTERN = "(%g+:)"
local LABELED_LINE_PATTERN = string.format("^%s", LABEL_PATTERN)
local HEX_LITERAL_PATTERN = "0x%x%x%x%x"
local STR_LITERAL_PATTERN = '^".*"$'
local OP_CODE_PATTERN = "^%s*(%g+)%s*"
local REGISTER_PATTERN = "R%d"
local LEADING_SPACES_PATTERN = "^%s*"
local TRAILING_SPACES_PATTERN = "%s*$"
local OPERAND_DELIMITER_PATTERN = ",%s*"
local CAPTURE_OPERAND_PATTERN = "([^%s]+)"
local SINGLE_SPACE = " "
local NO_VALUE = ""

local VALID_OP_CODES = {
	ADDI = { type = "RRI", op_code = "0091" },
	ADDR = { type = "RRR", op_code = "0092" },
	ADD = { type = "RRL", op_code = "0090" },
	ANDI = { type = "RRI", op_code = "0011" },
	ANDR = { type = "RRR", op_code = "0012" },
	AND = { type = "RRL", op_code = "0010" },
	BRnp = { type = "L", op_code = "0031" },
	BRnzp = { type = "L", op_code = "0033" },
	BRnz = { type = "L", op_code = "0032" },
	BRp = { type = "L", op_code = "0034" },
	BR = { type = "L", op_code = "0030" },
	BRzp = { type = "L", op_code = "0036" },
	BRz = { type = "L", op_code = "0035" },
	DC = { type = "LIT", op_code = "0000" },
	DIVI = { type = "RRI", op_code = "0094" },
	DIVR = { type = "RRR", op_code = "0095" },
	DIV = { type = "RRL", op_code = "0093" },
	GETC = { type = "NO_ARGS", op_code = "0050" },
	HALT = { type = "NO_ARGS", op_code = "00B0" },
	IN = { type = "NO_ARGS", op_code = "0051" },
	JMP = { type = "R", op_code = "0037" },
	JSRR = { type = "R", op_code = "0039" },
	JSR = { type = "L", op_code = "0038" },
	LDI = { type = "RI", op_code = "0071" },
	LDR = { type = "RR", op_code = "0072" },
	LD = { type = "RL", op_code = "0070" },
	LEA = { type = "RL", op_code = "0073" },
	MULI = { type = "RRI", op_code = "0097" },
	MULR = { type = "RRR", op_code = "0098" },
	MUL = { type = "RRL", op_code = "0096" },
	NOP = { type = "NO_ARGS", op_code = "0000" },
	NOTR = { type = "RRR", op_code = "0013" },
	ORI = { type = "RRI", op_code = "0015" },
	ORR = { type = "RRR", op_code = "0016" },
	OR = { type = "RRL", op_code = "0014" },
	OUT = { type = "NO_ARGS", op_code = "0052" },
	PUTS = { type = "L", op_code = "0053" },
	RET = { type = "NO_ARGS", op_code = "003A" },
	SUBI = { type = "RRI", op_code = "009A" },
	SUBR = { type = "RRR", op_code = "009B" },
	SUB = { type = "RRL", op_code = "0099" },
}
local OPERAND_TYPES = {
    REGISTER = "REGISTER",
    HEX_LITERAL = "HEX_LITERAL",
    STR_LITERAL = "STR_LITERAL",
    LABEL = "LABEL",
    UNKNOWN = "UNKNOWN",
}

local OPERAND_CHECKS = {

    -- 1 operand (register)
    R = { OPERAND_TYPES.REGISTER },
    -- 2 operand (register, immediate)
    RI = { OPERAND_TYPES.REGISTER, OPERAND_TYPES.HEX_LITERAL },
    -- 2 operand (register, label)
    RL = { OPERAND_TYPES.REGISTER, OPERAND_TYPES.LABEL },
    -- 3 operand (register,register, register)
    RR = { OPERAND_TYPES.REGISTER, OPERAND_TYPES.REGISTER },
    -- 3 operand (register,register, immediate)
    RRI = { OPERAND_TYPES.REGISTER, OPERAND_TYPES.REGISTER, OPERAND_TYPES.HEX_LITERAL },
    -- 3 operand (register,register, label)
    RRL = { OPERAND_TYPES.REGISTER, OPERAND_TYPES.REGISTER, OPERAND_TYPES.LABEL },
    -- 3 operand (register,register, register)
    RRR = { OPERAND_TYPES.REGISTER, OPERAND_TYPES.REGISTER, OPERAND_TYPES.REGISTER },
    -- special case for DC (label: DC literal)
    LIT = {},
    -- 1 operand (label)
    L = { OPERAND_TYPES.LABEL },
    -- no operands
    NO_ARGS = {},
}


local function validate_DC(statement, label, operands)
    local my_statement = statement

    if label == NO_VALUE then
        local error = string.format("REQUIRED LABEL MISSING")
        table.insert(my_statement.errors, error)
    end

    if #operands ~= 1 then
        local error = string.format("NUM OF OPERANDS INVALID: %d required, found %d", 1, #operands)
        table.insert(my_statement.errors, error)
    end

    if operands[1].type ~= OPERAND_TYPES.HEX_LITERAL and operands[1].type ~= OPERAND_TYPES.STR_LITERAL then
        local error = string.format("OPERAND DATA TYPE NOT STRING or HEX")
        table.insert(my_statement.errors, error)
    end

    return my_statement
end

local function tokenize_operands(operands)

    -- trim the opeands string & replace , with space
    operands = string.gsub(operands, OPERAND_DELIMITER_PATTERN, SINGLE_SPACE)
    operands = string.gsub(operands, LEADING_SPACES_PATTERN, NO_VALUE)
    operands = string.gsub(operands, TRAILING_SPACES_PATTERN, NO_VALUE)

    local tokens = {}
    local operand_type
    -- strings operans are special case - only one allowed
    if string.match(operands, STR_LITERAL_PATTERN) ~= nil then
        operand_type = OPERAND_TYPES.STR_LITERAL
        local tokenized = { type = operand_type, value = operands }
        table.insert(tokens,tokenized)
        return tokens
    end
    for operand in string.gmatch(operands, CAPTURE_OPERAND_PATTERN) do
        if string.match(operand, REGISTER_PATTERN) ~= nil then
            operand_type = OPERAND_TYPES.REGISTER
        elseif string.match(operand, HEX_LITERAL_PATTERN) ~= nil then
            operand_type = OPERAND_TYPES.HEX_LITERAL
        elseif string.match(operand, STR_LITERAL_PATTERN) ~= nil then
            operand_type = OPERAND_TYPES.STR_LITERAL
        elseif string.match(operand, LABEL_PATTERN) ~= nil then
            operand_type = OPERAND_TYPES.LABEL
        elseif string.match(operand, LABEL_PATTERN) ~= nil then
            operand_type = OPERAND_TYPES.LABEL
        else
            operand_type = OPERAND_TYPES.UNKNOWN
        end
        local tokenized = { type = operand_type, value = operand }
        table.insert(tokens, tokenized)
    end

    return tokens
end

local function tokenize_statement(source_line)
    local label = NO_VALUE
    if string.match(source_line, LABELED_LINE_PATTERN) then
        label = string.match(source_line, LABELED_LINE_PATTERN)
        source_line = string.gsub(source_line, LABELED_LINE_PATTERN, NO_VALUE)
    end

    local op_code = string.match(source_line, OP_CODE_PATTERN)
    if VALID_OP_CODES[op_code] == nil then
        print(string.format("ERROR: invalid op code: %s", op_code))
    end
    local src_operands = string.gsub(source_line, OP_CODE_PATTERN, NO_VALUE)

    local operands = tokenize_operands(src_operands)

    return label, op_code, operands
end

local function src_operand_to_ir_code(operand)
     if operand == nil then
        return operand
     end
     if operand.type == OPERAND_TYPES.REGISTER then
        operand.value = "000" .. string.gsub(operand.value,"R","")
        return operand
    end
    if operand.type == OPERAND_TYPES.HEX_LITERAL then
        operand.value = string.gsub(operand.value,"0x","")
        return operand
    end
    if operand.type == OPERAND_TYPES.STR_LITERAL then
        operand.value = string.gsub(operand.value,'"',"")
        return operand
    end
    return operand
end

function lib_pass1.run(_statements)
    local my_symbols = {}
    local my_statements = {}
    local address = 1
    local op1, op2, op3, ir_op_code
    for _, statement in ipairs(_statements) do
        local label, op_code, operands = tokenize_statement(statement.source)
        local checks
        local ir_code
        local type_check = VALID_OP_CODES[op_code].type
        if type_check == nil then
            local error = string.format("ERROR: INVALID OP_CODE: '%s'", op_code)
            table.insert(statement.errors, error)
            goto continue
        end

        -- dc is a special case
        if op_code == "DC" then
            statement = validate_DC(statement, label, operands)
            goto gen_ir_code
        end
        -- required number of operands
        checks = OPERAND_CHECKS[type_check]
        if #checks ~= #operands then
            local error = string.format("NUM OF OPERANDS INVALID: %d required, found %d", #checks, #operands)
            table.insert(statement.errors, error)
            goto continue
        end
        -- check operand types
        for idx, check in ipairs(checks) do
            local op_type = operands[idx].type
            local param = operands[idx].value
            if op_type ~= check then
                local error = string.format("ERROR: parm %s not of type %s", param, check)
                table.insert(statement.errors, error)
                goto continue
            end
        end
        ::gen_ir_code::
        if label ~= NO_VALUE then
            my_symbols[label] = string.format("%04X",address)
        end
        op1, op2, op3 = table.unpack(operands)
        op1 = src_operand_to_ir_code(op1)
        op2 = src_operand_to_ir_code(op2)
        op3 = src_operand_to_ir_code(op3)
        ir_op_code = VALID_OP_CODES[op_code].op_code
        ir_code = { address = address, label = label, op_code = ir_op_code, op1 = op1, op2 = op2, op3 = op3 }
        statement.ir_code = ir_code
        address = address + 1

        ::continue::
        table.insert(my_statements, statement)
    end

    return my_symbols, my_statements
end

return lib_pass1
