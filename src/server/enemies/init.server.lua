local CollectionService = game:GetService("CollectionService")
--local zombieScript = require(script.zombie)
local spawning = require(script.spawning)

--gathering spawners--

local spawners = {}
spawners.zombie = {}
spawners.hellHound = {}


for _, thing in pairs(CollectionService:GetTagged("spawner")) do
    if CollectionService:HasTag(thing, "zombie") then
        table.insert(spawners.zombie, thing)
    
    elseif CollectionService:HasTag(thing, "hellHound") then
        table.insert(spawners.hellHound, thing)
    end
end

--spawning zombies--

spawning.spawn(spawners.zombie)
wait(3)
spawning.spawn(spawners.zombie)
wait(3)
spawning.spawn(spawners.zombie)


--test1