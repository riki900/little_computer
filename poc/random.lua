
local threshold = 0.2
local count = 0
local cells = 100
local max_fill = cells * threshold
for _ = 1,cells do
    local current = math.random()
    if current < threshold then
        count = count + 1
        print(threshold,current)
    end
    if count >= max_fill then
        break
    end
end
print(count)