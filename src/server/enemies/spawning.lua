module = {}

--services--

local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

--defining enemies in server storage--

local zombieEnemy = ServerStorage.enemies.zombie
local hellHoundEnemy = ServerStorage.enemies.hellHound

--functions--

--pass the spawn function an array of spawners of the same type i.e. zombie spawner
function module.spawn(spawners: Array)
    if CollectionService:HasTag(spawners[1],"zombie") then
        local newZombie = zombieEnemy:Clone()
        newZombie.HumanoidRootPart.Position = spawners[math.random(#spawners)].Position

        for _,part in pairs(newZombie:GetDescendants()) do
            if part:IsA("BasePart") and part:CanSetNetworkOwnership() then
                part:SetNetworkOwner(nil)
            end
        end

        newZombie.Parent = workspace
    end
    if CollectionService:HasTag(spawners[1],"hellHound") then
        local newHellHound = hellHoundEnemy:Clone()
        newHellHound.Dog.Position = spawners[math.random(#spawners)].Position
        newHellHound.Parent = workspace
    end

end


return module