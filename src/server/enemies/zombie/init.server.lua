local CollectionService = game:GetService("CollectionService")
local pathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")
local players = game:GetService("Players")
local zombies = {}
zombies.active =  {}
zombies.inactive = {}

local CharacterSize = ServerStorage.enemies.zombie:GetExtentsSize()

pathfindingParams = {
    WaypointSpacing = math.huge,
	AgentRadius = (CharacterSize.X + CharacterSize.Z)/4,
	AgentHeight = CharacterSize.Y,
	AgentCanJump = false,
	Costs = {
		WindowBarricade = 1
	}
}

--functions--

function async(func,...)
    local co = coroutine.wrap(func)
    co(...)
end

function contains(list, thing)
    for entry in list do
        if entry == thing then
            return true
        end
    end
    return false
end

function checkDist(part1, part2)
    if typeof(part1) ~= Vector3 then part1 = part1.Position end
    if typeof(part2) ~= Vector3 then part2 = part2.Position end
    return (part1 - part2).Magnitude
end

function updateTarget()
    for _,zombie in pairs(zombies.active) do
        local target = nil
        local range = math.huge
        for _,player in pairs(players:GetPlayers()) do
            if checkDist(zombie, player) <= range then
                if player and player.Humanoid.Health > 0 then target = player.HumanoidRootPart end
            end
        end
        zombies.active.zombie.target = target
    end
end

async(function()
    wait(.10)
    updateTarget()
end)

function pathToTarget(zombie)
    path = pathfindingService:CreatePath(pathfindingParams)
    path:ComputeAsync(zombie.HumanoidRootPart.Position, zombies.active.zombie.target.Position)
    local waypoints = path:GetWaypoints()
    local currentTarget = zombies.active.zombie.target
    for i,waypoint in pairs(waypoints) do
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            zombie.Humanoid.Jump = true
        elseif waypoint.Action == "windowBarricade" then
            print("window")
        else
            zombie.Humanoid:MoveTo(waypoint.Position)
            zombie.Humanoid.MoveToFinished:wait()
            if not zombies.active.zombie.target then
                break
            elseif checkDist(currentTarget,waypoints[#waypoints]) > 10 or currentTarget ~= zombies.active.zombie.target then
                pathToTarget(zombie)
                break
            end
        end
    end
end

function moveHandler(zombie)
    while wait(1) do
        if zombie.Humanoid.Health <= 0 then
            break
        end
        if zombies.active.zombie.target then
            pathToTarget(zombie)
        end
    end
end

function onDeath(zombie)
    local zombieIndex = nil
    if contains(zombies.active, zombie) then
        if zombie.Humanoid.Health <= 0 then
            for i,Zombie in ipairs(zombies.active) do
                if Zombie == zombie then zombieIndex = i end
            end
            table.remove(zombies.active, zombieIndex)
            table.insert(zombies.inactive, zombie)
        end
    end
end

--zombie attack function--



--connections etc--

CollectionService:GetInstanceAddedSignal("enemy"):Connect(function(enemy)
    if CollectionService:HasTag(enemy, "zombie") then
        if enemy:FindFirstAncestor("Workspace") then
            if contains(zombies.active, enemy) == false then
                table.insert(zombies.active, enemy)
                async(moveHandler, enemy)
                print(zombies)
            end
        end
    end
end)

function initialize()
    for _,enemy in pairs(CollectionService:GetTagged("enemy")) do
        if CollectionService:HasTag(enemy, "zombie") then
            if enemy:FindFirstAncestor("Workspace") then
                if contains(zombies.active, enemy) == false then
                    table.insert(zombies.active, enemy)
                    async(moveHandler, enemy)
                    print(zombies)
                end
            end
        end
    end
end

initialize()

--figure out how to attach a "target" value to each zombie that contains the target players HumanoidRootPart
--maybe make a list of players and attach an id to each of them so that the zombie can store their id in it's attributes