local RunService = game:GetService("RunService")
local repStore = game:GetService("ReplicatedStorage")
local https = game:GetService("HttpService")
local Ts = game:GetService("TweenService")

local function Check(Player, Row)
	local choice = nil
	for _,Pet in pairs(workspace.Pets[Player.UserId]:GetChildren()) do
		for i,v in Row do
			if Pet:GetAttribute("Offset") == v then
				Row[i] = nil
			end
		end
	end

	for i,v in Row do
		if v ~= nil and choice == nil then
			choice = v
		end
	end
	return choice
end

local Pet = {}
Pet.__index = Pet

function Pet.new(Player, PetName : string, Key) 
	if not repStore.Objects.Pets:FindFirstChild(PetName) then return end
	local self = setmetatable({}, Pet)
	self.Owner = Player
	self.LastLoop = tick()
	self.Pet = repStore.Objects.Pets[PetName]:Clone()
	self.Pet:SetAttribute("Key", Key)
	self.Pet.Parent = workspace.Pets[Player.UserId]
	self.Key = Key
	local EquippedPetTable = https:JSONDecode(self.Owner.Hidden.EquippedPets.Value)
	
	local options = {
		Row1 = {
			place1 = Vector3.new(-5,0,5),
			place2 = Vector3.new(0,0,5),
			place3 = Vector3.new(5,0,5),
		},
		Row2 = {
			place1 = Vector3.new(-2.5,0,10),
			place2 = Vector3.new(2.5,0,10),
			place3 = Vector3.new(0,0,15),
		}
	}
	

	
	local ChosenOffset = Check(Player, options.Row1)
	if ChosenOffset == nil then
		ChosenOffset = Check(Player, options.Row2)
	end
	
	self.Pet:SetAttribute("Offset", ChosenOffset)
	self.PetPosInTable = #EquippedPetTable
	
	for _,v in pairs(self.Pet:GetChildren()) do
		if not v:IsA("BasePart") then return end
		v.CanCollide = false
		v.Anchored = false
	end
	self.Pet:PivotTo(self.Owner.Character.HumanoidRootPart.CFrame)
	
	local CharAttachment = Instance.new("Attachment", self.Owner.Character.HumanoidRootPart)
	CharAttachment.Name = Key
	local PetAttachment = Instance.new("Attachment", self.Pet.PrimaryPart)
	CharAttachment.Position = ChosenOffset
	
	local oritationAlign = Instance.new("AlignOrientation", self.Pet.PrimaryPart)
	oritationAlign.Attachment0 = PetAttachment
		oritationAlign.Attachment1 = CharAttachment
	oritationAlign.Responsiveness = 0
	
	local positionAlign = Instance.new("AlignPosition", self.Pet.PrimaryPart)
	positionAlign.Attachment0 = PetAttachment
	positionAlign.Attachment1 = CharAttachment
	positionAlign.ApplyAtCenterOfMass = true
	positionAlign.Responsiveness = 0
	
	return self
end

function Pet:Destroy()
	if self.Owner.Character.HumanoidRootPart:FindFirstChild(self.Key) then
		self.Owner.Character.HumanoidRootPart[self.Key]:Destroy()
	end
	self.Pet:Destroy()
	self = nil
end

return Pet
