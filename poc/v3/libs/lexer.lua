local lexer = {}

local CR = "\n"
local TOKEN_TYPES = {
	NUMBER = "NUMBER",
	STRING = "STRING",
	EOF = "EOF",
	REGISTER = "REGISTER",
	SYMBOL = "SYMBOL",
	OP_CODE = "OP_CODE",
	COMMENT = "COMMENT",
	WHITE_SPACE = "WHITE_SPACE",
}

local pos = 1
local source, line_number
local tokens = {}

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
local function at()
	--	return lex.source[lex.pos]
	return string.sub(source, pos, pos)
end
--[[

local function advance()
	-- lex.pos += 1
	pos = pos + 1
end
--]]

local function advanceN(n)
	n = n or string.len(source)
	pos = pos + n
	if at() == CR then
		line_number = line_number + 1
		pos = pos + 1
	end
end

local function new_token(token_type, value)
	return {
		token_type,
		value,
		line_number,
		pos,
	}
end

local function remainder()
	return string.sub(source, pos)
end

local function at_eof()
	return pos >= string.len(source)
end

local function commentHandler(pattern)
	local match_begin, _ = string.find(remainder(), pattern.pattern)
	if match_begin ~= nil then
		local end_of_line = string.find(remainder(), CR)
		advanceN(end_of_line)
		line_number = line_number + 1
	end
end

local function skipHandler(pattern)
	local _, match_end = string.find(remainder(), pattern.pattern)
	advanceN(match_end)
end

local function numberHandler(pattern)
	local value = string.match(remainder(), pattern.pattern)
	table.insert(tokens, new_token(TOKEN_TYPES.NUMBER, tonumber(value)))
	advanceN(string.len(value))
end

local function stringHandler(pattern)
	local value = string.match(remainder(), pattern.pattern)
	value = string.gsub(value, '"', "")
	table.insert(tokens, new_token(pattern.token_type, value))
	advanceN(string.len(value) + 2)
end

local function registerHandler(pattern)
	local value = string.match(remainder(), pattern.pattern)
	value = string.gsub(value, "R", "")
	table.insert(tokens, new_token(pattern.token_type, tonumber(value)))
	advanceN(string.len(value) + 1)
end

local function symbolHandler(pattern)
	local value = string.match(remainder(), pattern.pattern)
	local token_type = pattern.token_type
	if VALID_OP_CODES[value] ~= nil then
		token_type = TOKEN_TYPES.OP_CODE
	end
	table.insert(tokens, new_token(token_type, value))
	advanceN(string.len(value) + 1)
end

local patterns = {
	{ pattern = "#.*", handler = commentHandler, token_type = TOKEN_TYPES.COMMENT },
	{ pattern = "%s+", handler = skipHandler, token_type = TOKEN_TYPES.WHITE_SPACE },
	{ pattern = ",", handler = skipHandler, token_type = TOKEN_TYPES.WHITE_SPACE },
	{ pattern = "R%d", handler = registerHandler, token_type = TOKEN_TYPES.REGISTER },
	{ pattern = "[0]x%d+", handler = numberHandler, token_type = TOKEN_TYPES.NUMBER },
	{ pattern = "[a-zA-Z_][a-zA-Z0-9_]*", handler = symbolHandler, token_type = TOKEN_TYPES.SYMBOL },
	{ pattern = '"[^"]*"', handler = stringHandler, token_type = TOKEN_TYPES.STRING },
}

function lexer.tokenize(_source)
	source = _source
	line_number = 1
	while not at_eof() do
		local matched = false
		for _, pattern in ipairs(patterns) do
			local loc = string.find(remainder(), pattern.pattern)
			if loc ~= nil and loc == 1 then
				pattern.handler(pattern)
				matched = true
				goto continue
			end
		end
		::continue::
		if not matched then
			error(string.format("lexer error: unrecognized token near '%s'", remainder()))
		end
	end

	table.insert(tokens, new_token(TOKEN_TYPES.EOF, TOKEN_TYPES.EOF))
	return tokens
end

return lexer
