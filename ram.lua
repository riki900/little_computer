local Ram = {}
Ram.__index = Ram

local DEFAULT_SIZE = 1024

local function init_RAM(self)
	for i = 0, self.size - 1 do
		self.ram[i] = 0
	end
end

function Ram.new(ram_size)
	local self = setmetatable({}, Ram)
	self.ram = {}
	self.size = ram_size or DEFAULT_SIZE
    init_RAM(self)
	return self
end

return Ram