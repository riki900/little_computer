local lib_output = {}

local function format_obj_code(obj_code)
    local formatted_operands = ""
    for _, operand in ipairs({ "op1", "op2", "op3" }) do
        if obj_code[operand] ~= nil then
            formatted_operands = formatted_operands .. string.format("%s ", obj_code[operand])
        end
    end
    local formatted_obj_code = string.format("%03d %4s %-20s", obj_code.address, obj_code.op_code, formatted_operands)
    return formatted_obj_code
end

function lib_output.run(_base_name, _statements, _symbols)
    -- write out source listing and symbols
    local lst_file_name = string.format("%s.lst", _base_name)
    local lst_file = assert(io.open(lst_file_name, "w"))

    -- write out object code
    local obj_file_name = string.format("%s.obj", _base_name)
    local obj_file = assert(io.open(obj_file_name, "w"))

    for _, statement in ipairs(_statements) do
        -- write out object code
        local formatted_obj_code = format_obj_code(statement.obj_code)
        obj_file:write(string.format("%s\n", formatted_obj_code))
        -- write listing line with obj and source
        local print_line = string.format("%-30s%s", formatted_obj_code, statement.source)
        lst_file:write(string.format("%s\n", print_line))
    end
    lst_file:write(string.format("\n%s\n", "SYMBOL TABLE"))
    for address, symbol in pairs(_symbols) do
        lst_file:write(string.format("%s %s\n", address, symbol))
    end

    lst_file:close()
    obj_file:close()
end

return lib_output
