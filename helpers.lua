local helpers = {}

function helpers.byte_to_char(value)
	local display_value = string.char(value)
	if display_value:match("%w") then
		return display_value
	end
	if display_value:match("%p") then
		return display_value
	end
	return "."
end

function helpers.dump_RAM(RAM)
	local address = 0
	local segment_size = 16
	while address < #RAM do
		io.write(string.format("%04X: ", address))
		local chars = ""
		for _ = 1, segment_size do
			io.write(string.format("%02X ", RAM[address]))
			chars = chars .. helpers.byte_to_char(RAM[address])
			address = address + 1
		end
		print(string.format(" %s", chars))
	end
end

return helpers