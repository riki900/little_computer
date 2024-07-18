
local conds = { "nzp", 
'nz',
'np',
'z',
'zp',
'p' }

for _, cond in ipairs(conds) do
    print()
    print(string.format("-- conditional branch when %s flags are set",string.upper(cond)))
    print(string.format("alu.BR%s = true",cond))

end