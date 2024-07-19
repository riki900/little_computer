
--[[
local alu = require("alu")

for key, _ in pairs(alu) do
    print(string.format("%s",key))
end
--]]

local tests = {
    "           ",
    "",
    "\n",
    "LABEL DC 0x0001"
}

for idx, str in ipairs(tests) do
    local matchStr = "^%s*$"
    print(matchStr)
    local isMatch = "NO"
    if string.match(str,matchStr) then
        isMatch = "YES"
    end
    print(string.format("%d: %s, '%s'",idx,isMatch,str))
end



