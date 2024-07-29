--[[
   assembler for little computer
--]]

-- put in global space to avoid adding require
-- when debugging libraries
pt = require("print_table")

local init_step = require("libs.asm_lib_init")
local pass1_step = require("libs.asm_lib_pass1")
local pass2_step = require("libs.asm_lib_pass2")
local output_step = require("libs.asm_lib_output")

local USAGE = "Usage: lua asm.lua <source file name>"

local statements, symbols

local function run(src_file_name)
	statements = init_step.run(src_file_name)
	-- convert source to ir_code and symbols
	symbols, statements = pass1_step.run(statements)
	-- convert ir_code to obj_code
	statements = pass2_step.run(statements, symbols)
	-- write out source listing and obj_code
	output_step.run(src_file_name, statements, symbols)
end

-- source file name required on command line
if #arg ~= 1 then
	print(USAGE)
	os.exit(1)
end

-- go assemble the source
run(arg[1])
pt(symbols)
