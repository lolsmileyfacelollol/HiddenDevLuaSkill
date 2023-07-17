local RunService = game:GetService("RunService")
local repStore = game:GetService("ReplicatedStorage")
local Https = game:GetService("HttpService")
local MarketPlaceService = game:GetService("MarketplaceService")
local Eggs = require(script:WaitForChild("Eggs"))

local Egg = {}
Egg.__index = Egg

local function ownsgamepass(userid,gamepassid)
	local s,res = pcall(MarketPlaceService.UserOwnsGamePassAsync,MarketPlaceService,userid,gamepassid)
	if not s then
		res = false
	end
	return res
end

function Egg.new(EggModel, EggName : string) 
	local self = setmetatable({}, Egg)
	if not Eggs[EggName] or Eggs[EggName] == nil then
		print("NO EGG FOUND IN EGGS MODULE BY THE NAME OF ".. EggName, "| MODEL: ".. EggModel)
		return
	end

	self.Egg = EggName
	self.Price = Eggs[EggName].Price
	self.CostType = Eggs[EggName].CostType
	self.Options = Eggs[EggName].Pets
	self.Color = Eggs[EggName].Color
	self.Activator = Instance.new("ProximityPrompt", EggModel.Epart) -- replace with invisible prompt later (add client side gui to pop up when near to display winnable pets)

	EggModel.cost.CostGui.Cost.Text = self.Price

	self.Activator.ActionText = "Open for $".. self.Price
	self.Activator.ObjectText = EggName
	self.Activator.Triggered:Connect(function(player)
		if player:GetAttribute("OpeningEgg") or player:GetAttribute("Busy") then 
			repStore.Remotes.ClientSounds:FireClient(player, repStore.Audio.Fail)
			return 
		end
		local PetsTable = Https:JSONDecode(player.Hidden.Pets.Value)
		local NumOwned = 0
		for i in PetsTable do
			NumOwned += 1
		end

		local MaxStorage
		if ownsgamepass(player.UserId, 201469579) then
			MaxStorage = 20
		else
			MaxStorage = 10
		end
		local CashType = player.leaderstats:FindFirstChild(self.CostType)
		if CashType then
			if NumOwned <= MaxStorage and NumOwned < MaxStorage then
				if CashType.Value < self.Price then
					repStore.Remotes.ClientSounds:FireClient(player, repStore.Audio.Fail)
				elseif CashType.Value >= self.Price then
					repStore.Remotes.ClientSounds:FireClient(player, repStore.Audio.Success)
					self:Open(player, CashType)
				end
			else
				repStore.Remotes.ClientSounds:FireClient(player, repStore.Audio.Fail)
				return
			end
		end
	end)

	return self
end

function Egg:Destroy(bool)
	self = nil
end

function Egg:ChoosePet(Player, stat) -- logisitical Side of opening
	local function ChooseRarity()
		local RandomNumber = math.random(0,100)
		local ChosenRarity

		local Chance = math.random(0,100)
		if Chance <= 2 then
			ChosenRarity = "Legendary"
		elseif Chance > 2 and Chance <= 13 then
			ChosenRarity = "Rare"
		elseif Chance > 13 and Chance <= 25 then
			ChosenRarity = "Uncommon"
		elseif Chance > 25 then
			ChosenRarity = "Common"
		end
		return ChosenRarity
	end	

	stat.Value -= self.Price

	local Rarity
	local ChosenPet

	repeat
		task.wait()
		Rarity = ChooseRarity()
	until #self.Options[Rarity] >= 1
	ChosenPet = self.Options[Rarity][math.random(1,#self.Options[Rarity])]
	local Data = Https:JSONDecode(Player.Hidden.Pets.Value)

	local keyId = Https:GenerateGUID(false)
	Data[keyId] = ChosenPet
	
	Player.Hidden.Pets.Value = Https:JSONEncode(Data)
	return ChosenPet, Rarity
end

function Egg:DisplayEgg(Player, Pet, Rarity) -- displaying egg to the client
	local plrGui = Player.PlayerGui
	local OpenGui = plrGui.OpeningGui
	local Frame = OpenGui:WaitForChild("Frame")
	local petDisplay = Frame:WaitForChild("PetDisplay")
	local EggDisplay = Frame:WaitForChild("Egg")
	local CloseButton : TextButton = Frame:WaitForChild("Button")
	--change with raritys
	local MagicCircle = Frame:WaitForChild("MagicCircle")
	local Light = Frame:WaitForChild("Light")
	local Ambience = Frame:WaitForChild("Ambience")
	local orginalColors = {
		Ambience = Ambience.ImageColor3,
		Light = Light.ImageColor3,
		MagicCircle = MagicCircle.ImageColor3,
		EggDisplay = EggDisplay.ImageColor3,
	}

	Ambience.ImageColor3 = self.Color
	Light.ImageColor3 = self.Color
	MagicCircle.ImageColor3 = self.Color
	EggDisplay.ImageColor3 = self.Color
	
	OpenGui.Enabled = true
	
	if not ownsgamepass(Player.UserId,203981222) then
		--Egg open code start
		for i = 0, 25, 1 do
			task.wait()
			EggDisplay.Rotation += 1
		end
		task.wait(0.1)
		repStore.Remotes.ClientSounds:FireClient(Player, repStore.Audio.EggTick)
		for i = 0, 25, 1 do
			task.wait()
			EggDisplay.Rotation -= 1
		end
		task.wait(0.1)
		repStore.Remotes.ClientSounds:FireClient(Player, repStore.Audio.EggTick)
		for i = 0, 25, 1 do
			task.wait()
			EggDisplay.Rotation -= 1
		end
		task.wait(0.1)
		repStore.Remotes.ClientSounds:FireClient(Player, repStore.Audio.EggTick)
		for i = 0, 25, 1 do
			task.wait()
			EggDisplay.Rotation += 1
		end
		task.wait(0.1)
		repStore.Remotes.ClientSounds:FireClient(Player, repStore.Audio.EggOpened)
		MagicCircle.Visible = true
		EggDisplay.Visible = false
		CloseButton.Visible = true
		--egg open code end

		--pet display start
		local PetModel = repStore.Objects.Pets:FindFirstChild(Pet):Clone()
		PetModel.Parent = petDisplay
		local viewportCamera = Instance.new("Camera")
		petDisplay.CurrentCamera = viewportCamera
		viewportCamera.Parent = petDisplay
		local PetCF = CFrame.new(0,0,0)
		PetModel:PivotTo(PetCF)
		viewportCamera.FieldOfView = 45
		viewportCamera.CFrame = CFrame.new(Vector3.new(0, 0, 5), PetModel.PrimaryPart.Position)
		PetModel:PivotTo(CFrame.new(PetCF.Position, viewportCamera.CFrame.Position))
		local color
		local secondaryColor
		local AmbienceColor
		if Rarity == "Common" then
			color = Color3.new(1, 1, 1)
			secondaryColor = Color3.new(1, 0.901961, 0.611765)
			AmbienceColor = Color3.new(1, 1, 1)
		elseif Rarity == "Uncommon" then
			color = Color3.new(0.466667, 0.752941, 1)
			secondaryColor = Color3.new(0.439216, 0.607843, 1)
			AmbienceColor = Color3.new(0.25098, 0.862745, 1)
		elseif Rarity == "Rare" then
			color = Color3.new(0.0901961, 1, 0.317647)
			secondaryColor = Color3.new(0.376471, 1, 0.552941)
			AmbienceColor = Color3.new(0.858824, 1, 0.67451)
		elseif Rarity == "Legendary" then
			color = Color3.new(1, 0.631373, 0.117647)
			secondaryColor = Color3.new(1, 0.972549, 0.219608)
			AmbienceColor = Color3.new(1, 0.34902, 0.129412)
		end
		--display rarity color
		Ambience.ImageColor3 = AmbienceColor
		Light.ImageColor3 = color
		MagicCircle.ImageColor3 = secondaryColor
		--wait then destroy gui
		local open = true
		local Connection = CloseButton.MouseButton1Click:Once(function()
			EggDisplay.Rotation = 0
			PetModel:Destroy()
			viewportCamera:Destroy()
			EggDisplay.Visible = true
			MagicCircle.Visible = false
			CloseButton.Visible = false
			OpenGui.Enabled = false
			--reset colors
			Ambience.ImageColor3 = orginalColors.Ambience
			Light.ImageColor3 = orginalColors.Light
			MagicCircle.ImageColor3 = orginalColors.MagicCircle
			EggDisplay.ImageColor3 = orginalColors.EggDisplay
			open = false
			Player:SetAttribute("OpeningEgg", false)
		end)

		task.wait(10)
		if open then
			Connection:Disconnect()
			EggDisplay.Rotation = 0
			PetModel:Destroy()
			viewportCamera:Destroy()
			EggDisplay.Visible = true
			MagicCircle.Visible = false
			OpenGui.Enabled = false
			CloseButton.Visible = false
			--reset colors
			Ambience.ImageColor3 = orginalColors.Ambience
			Light.ImageColor3 = orginalColors.Light
			MagicCircle.ImageColor3 = orginalColors.MagicCircle
			EggDisplay.ImageColor3 = orginalColors.EggDisplay
			Player:SetAttribute("OpeningEgg", false)
		end
	else
		--pet display start
		local PetModel = repStore.Objects.Pets:FindFirstChild(Pet):Clone()
		PetModel.Parent = petDisplay
		local viewportCamera = Instance.new("Camera")
		petDisplay.CurrentCamera = viewportCamera
		viewportCamera.Parent = petDisplay
		local PetCF = CFrame.new(0,0,0)
		PetModel:PivotTo(PetCF)
		viewportCamera.FieldOfView = 45
		viewportCamera.CFrame = CFrame.new(Vector3.new(0, 0, 5), PetModel.PrimaryPart.Position)
		PetModel:PivotTo(CFrame.new(PetCF.Position, viewportCamera.CFrame.Position))
		local color
		local secondaryColor
		local AmbienceColor
		if Rarity == "Common" then
			color = Color3.new(1, 1, 1)
			secondaryColor = Color3.new(1, 0.901961, 0.611765)
			AmbienceColor = Color3.new(1, 1, 1)
		elseif Rarity == "Uncommon" then
			color = Color3.new(0.466667, 0.752941, 1)
			secondaryColor = Color3.new(0.439216, 0.607843, 1)
			AmbienceColor = Color3.new(0.25098, 0.862745, 1)
		elseif Rarity == "Rare" then
			color = Color3.new(0.0901961, 1, 0.317647)
			secondaryColor = Color3.new(0.376471, 1, 0.552941)
			AmbienceColor = Color3.new(0.858824, 1, 0.67451)
		elseif Rarity == "Legendary" then
			color = Color3.new(1, 0.631373, 0.117647)
			secondaryColor = Color3.new(1, 0.972549, 0.219608)
			AmbienceColor = Color3.new(1, 0.34902, 0.129412)
		end
		MagicCircle.Visible = true
		EggDisplay.Visible = false
		repStore.Remotes.ClientSounds:FireClient(Player, repStore.Audio.EggOpened)
		CloseButton.Visible = true
		--display rarity color
		Ambience.ImageColor3 = AmbienceColor
		Light.ImageColor3 = color
		MagicCircle.ImageColor3 = secondaryColor
		--wait then destroy gui
		local open = true
		local Connection = CloseButton.MouseButton1Click:Once(function()
			EggDisplay.Rotation = 0
			PetModel:Destroy()
			viewportCamera:Destroy()
			EggDisplay.Visible = true
			MagicCircle.Visible = false
			OpenGui.Enabled = false
			CloseButton.Visible = false
			--reset colors
			Ambience.ImageColor3 = orginalColors.Ambience
			Light.ImageColor3 = orginalColors.Light
			MagicCircle.ImageColor3 = orginalColors.MagicCircle
			EggDisplay.ImageColor3 = orginalColors.EggDisplay
			open = false
			Player:SetAttribute("OpeningEgg", false)
		end)
		task.wait(10)
		if open then
			Connection:Disconnect()
			EggDisplay.Rotation = 0
			PetModel:Destroy()
			viewportCamera:Destroy()
			EggDisplay.Visible = true
			MagicCircle.Visible = false
			CloseButton.Visible = false
			OpenGui.Enabled = false
			--reset colors
			Ambience.ImageColor3 = orginalColors.Ambience
			Light.ImageColor3 = orginalColors.Light
			MagicCircle.ImageColor3 = orginalColors.MagicCircle
			EggDisplay.ImageColor3 = orginalColors.EggDisplay
			Player:SetAttribute("OpeningEgg", false)
		end
	end
end

function Egg:Open(Player, Stat) -- open the egg (causes both the logistcal functions and the displaying functions)
	Player:SetAttribute("OpeningEgg", true)
	local Pet,Rarity = self:ChoosePet(Player, Stat)
	self:DisplayEgg(Player, Pet, Rarity)
end

return Egg
