--#by @Solivion 10/18/2024
--#Simple modesty layer thing, Put under an actor, recommended to be in ServerScriptService
--###Disclaimer: Lots of assets will be loaded within the script, it might defer the other assets from loading, be warned. if you want to remove or lower the loading assets, you may edit the script's ID table(defaultshirts, defaultpants)
--####The Script Will Apply BodyColor if there is no current existing Default Clothing IDs

-->{Setting}<--
local Debug = false -- You get it, It prints throughout the process
local ApplyDefaultClothingAnyway = false -- will skip any checks for valid clothing, and apply the default modesty layer, not recommended because it will just be default clothing which you can just set at game setting
local ApplyColourAnyway = false -- will apply body colour even if there is already shirt/pant in that section
local OnlyApplyColour = false --  will apply colour and skip default clothing if there is any
local DontCheckDefaultClothing = false -- let the default clothing through without preload
local PreloadAssets = true -- preload the characters' shirts and pants assets, it might be required because GetAssetFetchStatus Returns Enum.AssetFetchStatus.None when not using PreloadAsync For Some Reason(according to my studio testing)

--<{CORE}>--
--<<Services>>--
local Players = game:GetService("Players")
local ContentProvider = game:FindFirstChildOfClass('ContentProvider')

--<<Variables>>--
local defaultshirts = {}
local defaultpants = {}
local DEFAULT_ID = "rbxassetid://"  -- Replace with actual asset ID
local defaultshirts = {855759986, 855766170, 855768337, 855773572, 855776101, 855777285, 855778082}
local defaultpants = {867818313, 867822311, 867830078, 867838635, 867813066, 867826313, 867842477, 867833254}
local defaultstringshirt = {}
local defaultstringpants = {}

--To create a valid Template IDs
if not DontCheckDefaultClothing then
	for i,v in defaultshirts do
		table.insert(defaultstringshirt, DEFAULT_ID.. tostring(v))
	end
	for i,v in defaultpants do
		table.insert(defaultstringpants, DEFAULT_ID.. tostring(v))
	end
end

--<<Functions>>--
function DEBUG(...)
	if Debug then
		print(...)
	end
end

--function to check the stats
function isabletobeloaded(STAT: Enum.AssetFetchStatus): boolean
	if not STAT or typeof(STAT) ~= typeof(Enum.AssetFetchStatus.None) then return false end
	return STAT == Enum.AssetFetchStatus.Success or STAT == Enum.AssetFetchStatus.Loading
end

--functions about colour
local function invertColor(color: Color3): Color3
	return Color3.new(1 - color.R, 1 - color.G, 1 - color.B)
end
function StarkestOutlineColour(Colour)
	local brightness = (0.299 * Colour.R + 0.587 * Colour.G + 0.114 * Colour.B)

	local STARK
	if brightness > 0.5 then
		STARK = Color3.fromRGB(0, 0, 0)
	else
		STARK = Color3.fromRGB(1, 1, 1)
	end

	return STARK
end

--coroute the Preload to check if any can be loaded, might cause assets to not load in game. Disable as needed
if not DontCheckDefaultClothing then
	coroutine.resume(coroutine.create(function()
		defaultshirts = {}
		defaultpants = {}
		if #defaultstringshirt > 0 then
			ContentProvider:PreloadAsync(defaultstringshirt, function(a, stat)
				if stat ~= Enum.AssetFetchStatus.Failure and stat ~= Enum.AssetFetchStatus.TimedOut then
					table.insert(defaultshirts,tonumber(a))
				end
			end)
		end
		if #defaultstringpants > 0 then
			ContentProvider:PreloadAsync(defaultstringpants, function(a, stat)
				if stat ~= Enum.AssetFetchStatus.Failure and stat ~= Enum.AssetFetchStatus.TimedOut then
					table.insert(defaultpants,tonumber(a))
				end
			end)
		end
	end))
end

--Check assets and apply things to simulate clothing
function applyDefaultClothing(character: Model)
	task.synchronize()
	local start = 0
	task.wait(.5)
	local loading = {}
	local loaded = {}
	local function ISLOADED(ASSET: string)
		if table.find(loaded, ASSET) or isabletobeloaded(ContentProvider:GetAssetFetchStatus(ASSET)) then
			return true
		end
		return false
	end
	DEBUG(character:GetFullName()..'_LAUNCHED')
	local function LOADED(ASSET: string, STATUS: Enum.AssetFetchStatus)
		if STATUS == Enum.AssetFetchStatus.Success then
			DEBUG(ASSET..'_LOAD_SUCCESS')
			if not table.find(loaded, ASSET) then table.insert(loaded, ASSET) end
		else
			DEBUG(ASSET..'_LOAD_'..STATUS.Name:upper())
		end
	end
	--check if there are clothing objects are if any is successfully fetched, incase roblox did them services dirty
	if not ApplyDefaultClothingAnyway then
		while start < 5 and not ApplyDefaultClothingAnyway and character and not ((character:FindFirstChildOfClass('Pants') and ISLOADED(character:FindFirstChildOfClass('Pants').PantsTemplate)) and (character:FindFirstChildOfClass('Shirt') and ISLOADED(character:FindFirstChildOfClass('Shirt').ShirtTemplate)))  do
			local dt = task.wait(1)
			if PreloadAssets then
				if character:FindFirstChildOfClass('Pants') and not table.find(loading, character:FindFirstChildOfClass('Pants').PantsTemplate) then
					DEBUG('LOADING_'..character:FindFirstChildOfClass('Pants').PantsTemplate)
					table.insert(loading, character:FindFirstChildOfClass('Pants').PantsTemplate)
					local succes = pcall(function() ContentProvider:PreloadAsync({character:FindFirstChildOfClass('Pants').PantsTemplate},LOADED) end)
					if not succes and table.find(loading, character:FindFirstChildOfClass('Pants').PantsTemplate) then table.remove(loading, table.find(loading, character:FindFirstChildOfClass('Pants').PantsTemplate)) end
				end
				if character:FindFirstChildOfClass('Shirt') and not table.find(loading, character:FindFirstChildOfClass('Shirt').ShirtTemplate) then
					DEBUG('LOADING_'..character:FindFirstChildOfClass('Shirt').ShirtTemplate)
					table.insert(loading, character:FindFirstChildOfClass('Shirt').ShirtTemplate)
					local succes = pcall(function() ContentProvider:PreloadAsync({character:FindFirstChildOfClass('Shirt').ShirtTemplate},LOADED) end)
					if not succes and table.find(loading, character:FindFirstChildOfClass('Shirt').ShirtTemplate) then table.remove(loading, table.find(loading, character:FindFirstChildOfClass('Shirt').ShirtTemplate)) end
				end
			end
			DEBUG('LOOPED_'..character:GetFullName())
			start += dt
		end
	end
	--either timed out or got valid clothing
	DEBUG(character:GetFullName()..'_LOOP_DONE')
	if not character or not ApplyDefaultClothingAnyway and (#loaded >= 2 or #loading > 4 or ((character:FindFirstChildOfClass('Pants') and ISLOADED(character:FindFirstChildOfClass('Pants').PantsTemplate)) and (character:FindFirstChildOfClass('Shirt') and ISLOADED(character:FindFirstChildOfClass('Shirt').ShirtTemplate)))) then DEBUG(character:GetFullName()..'_CLOTHING_IS_VALID') return end
	task.desynchronize()
	DEBUG(character:GetFullName()..'_PASSED_REQUIREMENT'..(ApplyDefaultClothingAnyway and '(APPLY ANYWAY)' or ''))
	loading = {}
	local samecolor = true
	local lastcolor
	--check if the colors are too similar or the same
	local howmuchleft = character and character:FindFirstChildOfClass('Humanoid') and  character:FindFirstChildOfClass('Humanoid').RigType == Enum.HumanoidRigType.R15 and 8 or 3
	if howmuchleft and character then
		for i,v in character:GetChildren() do
			if v:IsA('BasePart') then
				if not lastcolor then lastcolor = v.Color end
				if math.abs(v.Color.R - lastcolor.R) > .25 or math.abs(v.Color.G - lastcolor.G) > .25 or math.abs(v.Color.B - lastcolor.B) > .25 then
					howmuchleft -= 1
					if howmuchleft <= 0 then
						samecolor = false
						break
					end
				end
			end
		end
	end
	--get some clothes
	if samecolor then
		DEBUG(character:GetFullName()..'_SAMECOLOUR')
		local function ChangeColor(v:BasePart, Colour:Color3)
			if math.abs(v.Color.R - lastcolor.R) < .25 and math.abs(v.Color.G - lastcolor.G) < .25 and math.abs(v.Color.B - lastcolor.B) < .25 then	v.Color = Colour or Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255)) end
		end
		task.synchronize()
		--not registered until needed
		local shirtcolorsave
		local pantscolorsave
		if not lastcolor then return end
		if not character:FindFirstChildOfClass("Shirt") or not ISLOADED(character:FindFirstChildOfClass('Shirt').ShirtTemplate) then
			if #defaultshirts > 0 and not OnlyApplyColour then
				local shirt = Instance.new("Shirt")
				shirt.ShirtTemplate = DEFAULT_ID..tostring(defaultshirts[math.random(1,#defaultshirts)])
				shirt.Parent = character
			else
				local shirtcolor = BrickColor.random().Color
				if math.abs(shirtcolor.R - lastcolor.R) < .25 or math.abs(shirtcolor.G - lastcolor.G) < .25 or math.abs(shirtcolor.B - lastcolor.B) < .25 then
					shirtcolor = invertColor(shirtcolor)
				end
				if character:FindFirstChild('Torso') then
					for i,v in character:GetChildren() do
						if v:IsA('BasePart') and (v.Name:upper():match('TORSO')) then
							ChangeColor(v, shirtcolor)
						end
					end
				elseif character:FindFirstChild('UpperTorso') then
					for i,v in character:GetChildren() do
						if v:IsA('BasePart') and (v.Name:upper():match('ARM') and v.Name:upper():match('UPPER') or v.Name:upper():match('TORSO')) then
							ChangeColor(v, shirtcolor)
						end
					end
				else
					for i,v in character:GetChildren() do
						if v:IsA('BasePart') and (v.Name:upper():match('ARM') or v.Name:upper():match('TORSO')) then
							ChangeColor(v, shirtcolor)
						end
					end
				end
				shirtcolorsave = shirtcolor
			end
		end
		if not character:FindFirstChildOfClass("Pants") or not ISLOADED(character:FindFirstChildOfClass('Pants').PantsTemplate) then
			if #defaultpants > 0 and not OnlyApplyColour then
				local pants = Instance.new("Pants")
				pants.PantsTemplate = DEFAULT_ID..tostring(defaultpants[math.random(1,#defaultpants)])
				pants.Parent = character
			else
				local pantscolor = BrickColor.random().Color
				if math.abs(pantscolor.R - lastcolor.R) < .25 or math.abs(pantscolor.G - lastcolor.G) < .25 or math.abs(pantscolor.B - lastcolor.B) < .25 then
					pantscolor = invertColor(pantscolor)
				end
				if character:FindFirstChild('Torso') then
					for i,v in character:GetChildren() do
						if v:IsA('BasePart') and (v.Name:upper():match('LEG')) then
							ChangeColor(v, pantscolor)
						end
					end
				elseif character:FindFirstChild('UpperTorso') then
					for i,v in character:GetChildren() do
						if v:IsA('BasePart') and (v.Name:upper():match('LEG') and v.Name:upper():match('UPPER') or v.Name:upper():match('TORSO')) then
							ChangeColor(v, pantscolor)
						end
					end
				else
					for i,v in character:GetChildren() do
						if v:IsA('BasePart') and (v.Name:upper():match('LEG') or v.Name:upper():match('TORSO')) then
							ChangeColor(v, pantscolor)
						end
					end
				end
				pantscolorsave = pantscolor
			end
		end

		if shirtcolorsave or pantscolorsave then
			local shirtcolor = shirtcolorsave
			local pantscolor = pantscolorsave
			--incase 'BodyColors' just appeared to change the colour back, check if any modification is needed
			local function applycolor(OBJECT: BodyColors)
				if not OBJECT or not character then return end
				if shirtcolor and (ApplyColourAnyway or (not character:FindFirstChildOfClass("Shirt") or not ISLOADED(character:FindFirstChildOfClass('Shirt').ShirtTemplate))) then
					OBJECT.TorsoColor3 = shirtcolor
				end
				if pantscolor and (ApplyColourAnyway or (not character:FindFirstChildOfClass("Pants") or not ISLOADED(character:FindFirstChildOfClass('Pants').PantsTemplate))) then
					OBJECT.LeftLegColor3 = pantscolor
					OBJECT.RightLegColor3 = pantscolor
				end
			end

			--functions to get the 'BodyColors' object
			if character then
				if character:FindFirstChildOfClass('BodyColors') then
					-- it is there
					if applycolor then applycolor(character:FindFirstChildOfClass('BodyColors')) end
				end
				-- wait for it until the character got destroyed or maxed out registeration limit
				local waitforit
				local limit = 100
				local Instancelimit = 5
				waitforit = character.ChildAdded:Connect(function(a)
					limit -= 1
					if a:IsA('BodyColors') then
						Instancelimit -= 1
						if applycolor then applycolor(a) end
						if waitforit then
							waitforit:Disconnect()
						end
					end
					if limit <= 0 or Instancelimit <= 0 then
						if waitforit then
							waitforit:Disconnect()
						end
						if character then
							character:Destroy() -- too many children added, abnormal humanoid behavior detected. might be exploit
						end
						if applycolor then applycolor = nil end
					end
				end)
			end
		end
	else
		DEBUG(character:GetFullName()..'_DIFFERENTCOLOR')
	end
end

--<<Script Connections>>--
--default method that is used as a way to register characters for the application
task.synchronize()
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		coroutine.resume(coroutine.create(function() task.wait(1) applyDefaultClothing(character) end))
	end)
end)

for _, char in workspace:FindFirstChild('Map'):GetChildren() do
	if char:IsA('Model') and char:FindFirstChildOfClass('Humanoid') then
		coroutine.resume(coroutine.create(function() applyDefaultClothing(char) end))
	end
end

