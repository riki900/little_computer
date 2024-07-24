--[[
  modules for little computer assembler
--]]

local asm_lib_init = {}

local NO_VALUE = ""

function asm_lib_init.run(src_file_name)
    local my_statements = {}
    local src_file = assert(io.open(src_file_name, "r"))
    local src_line = src_file:read("*l")
    local line_num = 1
    while src_line do
        local statement = { line = line_num, source = src_line, errors = {}, ir_code = {}, obj_code = NO_VALUE }
        table.insert(my_statements, statement)
        src_line = src_file:read("*l")
        line_num = line_num + 1
    end
    src_file:close()
    return my_statements
end

return asm_lib_init
