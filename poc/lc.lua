--[[
  little computer inspired by LC-3
  runs obj code created by assembler.lua
--]]

local pt = require("print_table")

-- instruction decoder and execution
local alu = require("alu")

local ram = {}
local PC

local function obj_2_instr(obj_line)
	local instruction = {}
	for token in string.gmatch(obj_line, "[^%s]+") do
		table.insert(instruction, token)
	end

	return instruction[1], instruction
end

local function load_obj(obj_file_name)
	local obj_file = assert(io.open(obj_file_name, "r"))
	local obj_line = obj_file:read("*l")
	while obj_line do
		local address, instruction = obj_2_instr(obj_line)
		table.insert(ram, address, instruction)
		obj_line = obj_file:read("*l")
	end
end

local function initialize()
	if #arg == 0 then
		print("Usage: lua lc.lua <.obj file>")
		os.exit(1)
	end
	load_obj(arg[1])
	alu.initialize(ram)
	PC = 1
end

local function run()
	print("RUN: START")
	print()
	while true do
		local instruction = ram[PC]
		--pt(instruction)
		local op_code = instruction[2]
		if alu[op_code] == nil then
			error("PANIC: INVALID OP_CODE " .. op_code)
		end
		if op_code == "HALT" then
			break
		end
		alu[op_code](instruction)
		PC = PC + 1
	end
	print()
	print("RUN: HALT")
end

initialize()
run()
print(alu.state())
