
script:GetPropertyChangedSignal("Parent"):Connect(function()
	if not script:FindFirstAncestorWhichIsA("Actor") or (not script:FindFirstAncestorWhichIsA("PlayerGui") and not script:FindFirstAncestorWhichIsA("StarterGui")) then
		task.synchronize()
		script.Enabled = false
		script:Destroy()
	end
end)
function FindFirstChildOfNameAndClass(Where: Instance, Name: string, Class: string)
	if script:FindFirstAncestorOfClass("Actor") then
		task.desynchronize()
	end
	local Found: boolean = false
	if Where == nil then
		return
	end
	for i,v in Where:GetChildren() do
		if not Found then
			if Where == nil then
				Found = true
				return nil
			end
			if v.Name:match(Name) and (v:IsA(Class) or v.ClassName:upper():match(Class:upper())) then
				Found = true
				return v
			end
		end
	end
end
local plr
local char
local hum
local run = game:FindFirstChildOfClass('RunService')
local rootpart,head 
local OffsetBecauseIBadAtVector3 = Vector3.new(0,0,-0.55)

task.synchronize()
game:FindFirstChildOfClass('RunService').RenderStepped:Connect(function(dt)
	task.desynchronize()
	if not workspace:GetAttribute('Pause') then
	if not script:FindFirstAncestorWhichIsA("Actor") then
		task.synchronize()
		script.Enabled = false
		script:Destroy()
		return
	end
	task.desynchronize()
	--[[if not  game:FindFirstChildOfClass("Players"):GetPlayerFromCharacter(script.Parent)   then
		game:GetService("RunService"):UnbindFromRenderStep("CameraOffset")
	end]]
	local delta = dt
	local speed = 1 - .000001 ^ delta
	plr = game:FindFirstChildOfClass("Players").LocalPlayer
		if not plr then return end
	char = plr.Character
	if not char then return end
	hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end	
	head = FindFirstChildOfNameAndClass(char,"Head","BasePart") or char.PrimaryPart
	rootpart = FindFirstChildOfNameAndClass(char,"HumanoidRootPart","BasePart") or FindFirstChildOfNameAndClass(char,"Torso","BasePart") or FindFirstChildOfNameAndClass(char,"Head","BasePart")
	if not head or not rootpart then return end	
	if workspace:FindFirstChildOfClass("Camera") and (hum or head or rootpart) and not table.find({hum , head , rootpart},workspace:FindFirstChildOfClass("Camera").CameraSubject)  then
		task.synchronize()
		workspace:FindFirstChildOfClass("Camera").CameraSubject = (hum or head or rootpart)
		task.desynchronize()
	end
	task.desynchronize()
	if char and hum and rootpart and head and hum.CameraOffset ~=  ((char:GetAttribute("InvalidCam") and (rootpart.CFrame+Vector3.new(0,1.35,0)):pointToObjectSpace(head.CFrame.p + char:GetAttribute("InvalidCam"))) or (rootpart.CFrame+Vector3.new(0,1.35,0)):pointToObjectSpace(head.CFrame.p + 0.65 * head.CFrame.LookVector)) then
		--print("CAM RAN")
		task.synchronize()
			hum.CameraOffset = hum.CameraOffset:Lerp( (char:GetAttribute("InvalidCam") and (rootpart.CFrame+Vector3.new(0,1.35,0)):pointToObjectSpace(head.CFrame.p + char:GetAttribute("InvalidCam"))) or (rootpart.CFrame+Vector3.new(0,1.35,0)):pointToObjectSpace(head.CFrame.p + Vector3.new(0.65, 0.65, 0.65) * head.CFrame.LookVector) ,speed)
	end
	end
end)