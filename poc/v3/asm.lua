--[[
  little computer assembler based on PRATT parsing
--]]

pt = require("print_table")

local lexer = require("libs.lexer")

if #arg ~= 1 then
    print("Usage: lua asm.lua <assembler source.asm>")
    os.exit(1)
end

local src_file = assert(io.open(arg[1],"r"),"cannot open source file")
local source = src_file:read("*a")
src_file:close()

local tokens = lexer.tokenize(source)
pt(tokens)
