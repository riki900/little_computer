local lib_pass1 = {}

local LABEL_PATTERN = "(%g+:)"
local LABELED_LINE_PATTERN = string.format("^%s", LABEL_PATTERN)
local HEX_LITERAL_PATTERN = "0x%x%x%x%x"
local STR_LITERAL_PATTERN = '".*"'
local OP_CODE_PATTERN = "^%s*(%g+)%s*"
local REGISTER_PATTERN = "R%d"
local LEADING_SPACES_PATTERN = "^%s*"
local TRAILING_SPACES_PATTERN = "%s*$"
local OPERAND_DELIMITER_PATTERN = ",%s*"
local CAPTURE_OPERAND_PATTERN = "([^%s]+)"
local SINGLE_SPACE = " "
local NO_VALUE = ""

local VALID_OP_CODES = {
    -- opcode = operand definition
    ADDI = "RRI",
    ADDR = "RRR",
    ANDI = "RRI",
    ADD = "RRL",
    AND = "RRL",
    ANDR = "RRR",
    BR = "L",
    BRnp = "L",
    BRnz = "L",
    BRnzp = "L",
    BRp = "L",
    BRz = "L",
    BRzp = "L",
    DC = "LIT",
    DIVI = "RRI",
    DIV = "RRL",
    DIVR = "RRR",
    GETC = "NO_ARGS",
    HALT = "NO_ARGS",
    IN = "NO_ARGS",
    JMP = "R",
    JSR = "L",
    JSRR = "R",
    LDI = "RI",
    LD = "RL",
    LDR = "RR",
    LEA = "RL",
    MULI = "RRI",
    MUL = "RRL",
    MULR = "RRR",
    NOP = "NO_ARGS",
    NOTR = "RRR",
    ORI = "RRI",
    OR = "RRL",
    ORR = "RRR",
    OUT = "NO_ARGS",
    PUTS = "L",
    RET = "NO_ARGS",
    SUBI = "RRI",
    SUB = "RRL",
    SUBR = "RRR",
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

function lib_pass1.run(_statements)
    local my_symbols = {}
    local my_statements = {}
    local address = 1
    local op1, op2, op3
    for _, statement in ipairs(_statements) do
        local label, op_code, operands = tokenize_statement(statement.source)
        local checks
        local ir_code
        local type_check = VALID_OP_CODES[op_code]
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
            my_symbols[label] = address
        end
        op1, op2, op3 = table.unpack(operands)
        ir_code = { address = address, label = label, op_code = op_code, op1 = op1, op2 = op2, op3 = op3 }
        statement.ir_code = ir_code
        address = address + 1

        ::continue::
        table.insert(my_statements, statement)
    end

    return my_symbols, my_statements
end

return lib_pass1
