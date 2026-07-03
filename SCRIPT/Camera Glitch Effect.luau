--made this dumb script a while back
-- By Solivion

local ChanceMultiplier = 50 -- this is 10% maximum(Health Reaches 0)

local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
camera:ClearAllChildren()
local math = math
local tick = tick
local wait = wait
local function generateKeyCode()
	local code = ""
	local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:',.<>/?"
	local numCharacters = #characters

	for i = 1, 20 do -- You can adjust the length of the keycode as needed
		local charIndex = math.random(1, numCharacters)
		code = code .. characters:sub(charIndex, charIndex)
	end
	return code
end
-- Define parameters for the camera effects
local glitchChance = 5 -- Adjust this to control how often glitches occur (lower values mean less frequent)
local glitchDuration = math.random(1,5)/20 -- How long the glitch effect lasts (in seconds)
local glitchIntensity = 1 -- How intense the glitch effect is (adjust as needed)
local saturationIntensity = 0.5 -- Intensity of the saturation effect (0 to 1)

local function applyCameraGlitch()
	local originalCFrame = camera.CFrame
	local startTime = tick()
	local duration = glitchDuration

	--while tick() - startTime < duration do
		local glitchOffset = CFrame.new(
			math.random() * glitchIntensity - glitchIntensity / 2,
			math.random() * glitchIntensity - glitchIntensity / 2,
			math.random() * glitchIntensity - glitchIntensity / 2
	)
	task.synchronize()
		camera.CFrame = originalCFrame * glitchOffset
	task.delay(glitchDuration, function()
		--end

	-- Restore the camera to its original position
		task.synchronize() camera.CFrame = originalCFrame
		
	end)
	
end

local function UnattCam()
	local cam
	task.synchronize()
	cam = {Enum.CameraType.Scriptable, Enum.CameraType.Fixed}
	task.synchronize()
	camera.CameraType = cam[math.random(#cam)]
	task.delay(glitchDuration, function()
		camera.CameraType = Enum.CameraType.Custom
	end)
	
end


local function applySaturationEffect()
	task.synchronize()
	local newlag = Instance.new("Highlight", workspace)
	newlag.FillTransparency = math.random(5,10)/10
	newlag.OutlineTransparency = math.random(5,10)/10
	game:FindFirstChildOfClass('Debris'):AddItem(newlag, 5/10)
	task.delay(math.random(1,5)/10, function()
	newlag:Destroy()	end) -- Adjust the duration of the saturation effect
	
end
function dark()
	task.synchronize()
	local newCC = Instance.new("ColorCorrectionEffect", workspace.CurrentCamera)
	newCC.Brightness = math.random(-10,10)/10
	newCC.TintColor = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
	newCC.Saturation = 1
	newCC.Contrast = 1
	game:FindFirstChildOfClass('Debris'):AddItem(newCC, 5/10)
	task.delay(math.random(1,5)/10, function()
		task.synchronize()
		newCC:Destroy()
		end) -- Adjust the duration of the saturation effect
	
	
end
while task.wait(.01) do
	task.desynchronize()
	if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
		local Chance = ((player.Character:FindFirstChildOfClass('Humanoid').MaxHealth - player.Character:FindFirstChildOfClass('Humanoid').Health)/player.Character:FindFirstChildOfClass('Humanoid').MaxHealth) * ChanceMultiplier
		if math.random(1, 500) < Chance then
			applyCameraGlitch()
		end
		-- Add more random camera effects here if desired
		if math.random(1, 500) < Chance then
			applySaturationEffect()
		end
		if  math.random(1, 500) < Chance then
			dark()
		end
		if  math.random(1, 500) < Chance then
			UnattCam()
		end
	end
end

