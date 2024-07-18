local RAM = {}
local RAM_SIZE = 512
local function init_RAM()
	for i = 0, RAM_SIZE-1 do
		RAM[i] = 0
	end
end

local function byte_to_char(value)
    local display_value = string.char(value)
    if display_value:match("%w") then
        return display_value
    end
    if display_value:match("%p") then
        return display_value
    end
    return "."
end

local function dump_RAM()
	local address = 0
	local segment_size = 16
    while address < #RAM do
		io.write(string.format("%04X: ", address))
		local chars = ""
		for _ = 1, segment_size do
			io.write(string.format("%02X ", RAM[address]))
			chars = chars .. byte_to_char(RAM[address])
			address = address + 1
		end
		print(string.format(" %s", chars))
	end
end

local function set_RAM()
   for _ = 0,128 do
    RAM[math.random(0,RAM_SIZE)] = math.random(1,255)
   end

end

init_RAM()
set_RAM()
dump_RAM()
print()
