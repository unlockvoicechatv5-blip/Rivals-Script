-- Rivals Script - Mobile + PC
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local enabled = false
local settings = {
    fovRadius = 300,
    checkWall = true,
    checkTeam = true
}

local function getClosestEnemy()
    local closest, shortest = nil, settings.fovRadius
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Team ~= player.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            local humanoid = v.Character:FindFirstChild("Humanoid")
            
            if hrp and humanoid and humanoid.Health > 0 then
                local pos, onScreen = camera:WorldToScreenPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = v
                    end
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        enabled = not enabled
        print(enabled and "🔴 ON" or "⚪ OFF")
    end
end)

local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1
frame.Parent = screenGui
screenGui.Parent = player.PlayerGui

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        enabled = not enabled
        print(enabled and "🔴 ON (Mobile)" or "⚪ OFF (Mobile)")
    end
end)

RunService.RenderStepped:Connect(function()
    if not enabled then return end
    local target = getClosestEnemy()
    if not target then return end
    
    local hrp = target.Character.HumanoidRootPart
    local screenPos = camera:WorldToScreenPoint(hrp.Position)
    
    if screenPos then
        mousemove(screenPos.X - camera.ViewportSize.X / 2, screenPos.Y - camera.ViewportSize.Y / 2)
        mousebutton1down()
        task.wait(0.03)
        mousebutton1up()
    end
end)

print("✅ Script Loaded! PC: F | Mobile: Tap")
