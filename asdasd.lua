--// vars

local players = workspace.Players
local camera = workspace.CurrentCamera
local run_service = game:GetService("RunService")
local teams = game:GetService("Teams")
local plr_service = game:GetService("Players")
local user_input_service = game:GetService("UserInputService")

--// instances

local crosshair_dot = Drawing.new("Circle")
crosshair_dot.Size = 2
crosshair_dot.Color = Color3.fromRGB(255, 0, 0) -- Red dot
crosshair_dot.Thickness = 1
crosshair_dot.Filled = true
crosshair_dot.Visible = true

local crosshair_line = Drawing.new("Line")
crosshair_line.Color = Color3.fromRGB(255, 0, 0)
crosshair_line.Thickness = 1
crosshair_line.Visible = true

--// variables

local player = plr_service.LocalPlayer
local targetTeammates = true  -- Initially, target non-teammates or teammate
local aimbotActive = true  -- Initial state of the aimbot
local right_mouse_down = false

-- Function to check if a player is a teammate
local function isTeammate(targetPlayer)
    return targetPlayer.Team == player.Team
end

-- Function to look at a specific position
local function lookAt(targetPosition)
    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
end

-- Function to check if a target is visible (not behind walls)
local function isTargetVisible(targetPart)
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local ray = Ray.new(origin, direction * 5000)
    local part, position = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, camera})
    
    return part and part:IsDescendantOf(targetPart.Parent)
end

-- Function to get the closest player to the local player
local function getClosestPlayer(trg_part)
    local nearest = nil
    local lastDistance = math.huge
    local localPlayerPos = player.Character.PrimaryPart.Position
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild(trg_part) and v.Character:FindFirstChild("Humanoid") then
            local head = v.Character[trg_part]
            local humanoid = v.Character.Humanoid
            if head and humanoid.Health > 0 then  -- Check if the target is alive
                local distance = (localPlayerPos - head.Position).Magnitude
                
                -- Check visibility, distance, and teammate status
                if distance < lastDistance and isTargetVisible(head) then
                    if (targetTeammates and isTeammate(v)) or (not targetTeammates and not isTeammate(v)) then
                        nearest = v
                        lastDistance = distance
                    end
                end
            end
        end
    end
    
    return nearest
end

-- Toggle function to switch between targeting teammates and non-teammates
local function toggleTargetMode()
    targetTeammates = not targetTeammates
    print("Targeting", targetTeammates and "teammates" or "non-teammates")
end

-- Function to toggle aimbot activation
local function toggleAimbot()
    aimbotActive = not aimbotActive
    print("Aimbot", aimbotActive and "enabled" or "disabled")
end

-- Function to add chams
local function add_chams(adornee)
    local highlight = Instance.new("Highlight", adornee)
    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Solid red color
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Optional: same red for outline
    highlight.FillTransparency = 0 -- Solid, no transparency
    highlight.OutlineTransparency = 1 -- Optional: fully transparent outline
end

-- Input handling
user_input_service.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.T then
            toggleTargetMode()
        elseif input.KeyCode == Enum.KeyCode.Y then
            toggleAimbot()
        end
    end
end)

-- Mobile support for toggling aimbot and targeting mode
local UIS = game:GetService("UserInputService")

UIS.TouchTap:Connect(function(touchPositions, processed)
    if not processed then
        local touch = touchPositions[1]
        if touch.Position.Y < camera.ViewportSize.Y / 2 then
            toggleAimbot()
        else
            toggleTargetMode()
        end
    end
end)

-- RenderStepped connection to perform aiming
run_service.RenderStepped:Connect(function()
    crosshair_dot.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    if aimbotActive then
        local closestPlayer = getClosestPlayer("Head")
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
            lookAt(closestPlayer.Character.Head.Position)
            
            local target_pos, on_screen = camera:WorldToScreenPoint(closestPlayer.Character.Head.Position)
            if on_screen then
                crosshair_line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                crosshair_line.To = Vector2.new(target_pos.X, target_pos.Y)
            end
        end
    end
end)
