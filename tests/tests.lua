--[[
  test programs for lc
--]]
-- make requires work during tests
--package.path = package.path .. ";../?.lua"
--local luaunit = require("luaunit")
-- end boilerplate

local tests = {}

tests.test_LOAD = {
	description = "test LOAD instruction",
	instructions = {
		{ "LOAD", "R0", 0x0000 },
		{ "LOAD", "R1", "R0" },
		{ "LOAD", "R2", 0x0002 },
		{ "LOAD", "R3", 0x0003 },
		{ "LOAD", "R4", 0x0044 },
		{ "LOAD", "R5", 0x0555 },
		{ "LOAD", "R6", 0x0606 },
		{ "LOAD", "R7", 0x7777 },
	},
}

tests.test_ADD = {
	description = "test ADD instruction",
	instructions = {
		{ "LOAD", "R0", 0x0002 },
		{ "LOAD", "R1", 0x0002 },
		{ "ADD", "R2", "R0", "R1" },
		{ "LOAD", "R3", 0x0003 },
		{ "ADD", "R3", "R3", "R3" },
		{ "LOAD", "R4", 0x0044 },
		{ "ADD", "R4", "R4", 0x0044 },
		{ "ADD", "R5", "R4", 0x0011 },
	},
}

tests.test_SUB = {
	description = "test SUB instruction",
	instructions = {
		{ "LOAD", "R0", 0x0033 },
		{ "LOAD", "R1", 0x0031 },
		{ "SUB", "R2", "R0", "R1" },
		{ "LOAD", "R3", 0x0003 },
		{ "SUB", "R3", "R3", "R3" },
		{ "LOAD", "R4", 0x0005 },
		{ "SUB", "R4", "R4", 0x0001 },
		{ "SUB", "R5", "R4", 0x0002 },
		{ "LOAD", "R6", 0x0002 },
		{ "SUB", "R7", "R6", 0x0004 },
	},
}

tests.test_MUL = {
	description = "test MUL instruction",
	instructions = {
		{ "LOAD", "R0", 0x0002},
		{ "LOAD", "R1", 0x0003 },
		{ "MUL", "R2", "R0", "R1" },
		{ "LOAD", "R3", 0x0003 },
		{ "MUL", "R3", "R3", "R3" },
		{ "LOAD", "R4", 0x0004 },
		{ "MUL", "R4", "R4", 0x0002 },
		{ "MUL", "R5", "R4", 0x0002 },
	},
}

tests.test_DIV = {
	description = "test DIV instruction",
	instructions = {
		{ "LOAD", "R0", 0x0008},
		{ "LOAD", "R1", 0x0004 },
		{ "DIV", "R2", "R0", "R1" },
		{ "LOAD", "R3", 0x0003 },
		{ "DIV", "R3", "R3", "R3" },
		{ "LOAD", "R4", 0x000e },
		{ "DIV", "R4", "R4", 0x0002 },
		{ "DIV", "R5", "R4", 0x0002 },
	},
}

tests.test_NOT = {
	description = "test NOT instruction",
	instructions = {
		{ "LOAD", "R0", 0x0002 },
		{ "NOT", "R1", "R0" },
		{ "LOAD", "R3", 0x0005 },
		{ "NOT", "R3", "R3" },
		{ "LOAD", "R4", -0x000A },
		{ "NOT", "R4", "R4" },
	},
}

return tests
