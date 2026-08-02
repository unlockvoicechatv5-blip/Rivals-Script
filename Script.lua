-- Rivals Script - Mobile + PC (No Keys)
-- PC: Press F | Mobile: Tap screen to toggle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local settings = {
    aimAssist = true,
    autoShoot = true,
    silentAim = true,
    fovRadius = 300,
    checkWall = true,
    checkTeam = true,
    toggleKey = Enum.KeyCode.F
}

local enabled = false
local target = nil

-- Check if target is behind wall
local function isBehindWall(targetPos)
    if not settings.checkWall then return false end
    
    local origin = camera.CFrame.Position
    local direction = (targetPos - origin).Unit * (targetPos - origin).Magnitude
    
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRay(ray, player.Character)
    
    if hit then
        local distanceToTarget = (targetPos - origin).Magnitude
        local distanceToHit = (position - origin).Magnitude
        if distanceToHit < distanceToTarget - 1 then
            return true
        end
    end
    return false
end

-- Find nearest enemy
local function getClosestEnemy()
    local closest = nil
    local shortest = settings.fovRadius
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player then
            
            -- Team Check
            if settings.checkTeam and v.Team == player.Team then
                continue
            end
            
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                local humanoid = v.Character:FindFirstChild("Humanoid")
                
                if hrp and humanoid and humanoid.Health > 0 then
                    
                    -- Wall Check
                    if settings.checkWall and isBehindWall(hrp.Position) then
                        continue
                    end
                    
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
    end
    return closest
end

-- PC Toggle (F key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == settings.toggleKey then
        enabled = not enabled
        print(enabled and "🔴 Rivals Script ON" or "⚪ Rivals Script OFF")
        if enabled then
            print("✅ Wall Check: ON | Team Check: ON")
        end
    end
end)

-- Mobile Toggle (Tap screen - FIXED)
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1
frame.Parent = screenGui
screenGui.Parent = player.PlayerGui

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        enabled = not enabled
        print(enabled and "🔴 Rivals Script ON (Mobile)" or "⚪ Rivals Script OFF (Mobile)")
        if enabled then
            print("✅ Wall Check: ON | Team Check: ON")
        end
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    if not enabled then return end
    
    target = getClosestEnemy()
    if not target then return end
    
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local screenPos, onScreen = camera:WorldToScreenPoint(hrp.Position)
    if not onScreen then return end
    
    -- Silent Aim
    if settings.silentAim then
        local deltaX = screenPos.X - camera.ViewportSize.X / 2
        local deltaY = screenPos.Y - camera.ViewportSize.Y / 2
        mousemove(deltaX, deltaY)
    end
    
    -- Auto Shoot
    if settings.autoShoot then
        mousebutton1down()
        task.wait(0.03)
        mousebutton1up()
    end
end)

print("✅ Rivals Script Loaded!")
print("🖥️ PC: Press F | 📱 Mobile: Tap screen")
print("🧱 Wall Check: ON")
print("👥 Team Check: ON")
