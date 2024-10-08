--// vars

local players = workspace.Players
local camera = workspace.CurrentCamera

--// services

local run_service = game:GetService("RunService")
local teams = game:GetService("Teams")
local plr_service = game:GetService("Players")
local user_input_service = game:GetService("UserInputService")

--// tables

local features = {
    chams = {enabled = true, color = {fill = Color3.fromRGB(255, 0, 0), 
    outline = Color3.fromRGB(255, 0, 0)}, 
    transparency = {fill = 1, outline = 0.2}},
}

--// instances

local crosshair_dot = Drawing.new("Circle")
crosshair_dot.Radius = 2
crosshair_dot.Color = Color3.fromRGB(255, 0, 0) -- Red dot
crosshair_dot.Thickness = 2
crosshair_dot.Filled = true
crosshair_dot.Visible = true

--// functions

function is_ally(player)
    if not player then
        return false
    end

    local helmet = player:FindFirstChildWhichIsA("Folder") and player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
    if not helmet then
        return false
    end

    if helmet.BrickColor == BrickColor.new("Black") then
        return teams.Phantoms == plr_service.LocalPlayer.Team
    end

    return teams.Ghosts == plr_service.LocalPlayer.Team
end

function get_players()
    local entity_list = {}

    for _, team in players:GetChildren() do
        for _, player in team:GetChildren() do
            if player:IsA("Model") and not is_ally(player) then
                entity_list[#entity_list+1] = player
            end
        end
    end

    return entity_list
end

function add_chams(adornee)
    local highlight = Instance.new("Highlight", adornee)
    highlight.FillColor = features.chams.color.fill
    highlight.OutlineColor = features.chams.color.outline
    highlight.FillTransparency = features.chams.transparency.fill
    highlight.OutlineTransparency = features.chams.transparency.outline
end

function get_character(player)
    local char = {
        head = nil,
        torso = nil,
    }

    for _, bodypart in player:GetChildren() do
        if bodypart:IsA("BasePart") or bodypart:IsA("MeshPart") then
            if bodypart.Size == Vector3.new(1, 1, 1) then
                char.head = bodypart
            elseif bodypart.Size == Vector3.new(2, 2, 1) then
                char.torso = bodypart
            end
        end
    end

    return char
end

--// logic

run_service.RenderStepped:Connect(function()
    for _, player in get_players() do
        if player and player:FindFirstChildWhichIsA("Model") and not player:FindFirstChildWhichIsA("Highlight") then
            if features.chams.enabled then
                add_chams(player)
            end
        end
    end

    crosshair_dot.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end)
