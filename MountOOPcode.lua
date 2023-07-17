local RunService = game:GetService("RunService")
local repStore = game:GetService("ReplicatedStorage")

local Mount = {}
Mount.__index = Mount

function Mount.new(Player, MountName : string) 
	if not repStore.Objects:FindFirstChild(MountName) then return end
	local self = setmetatable({}, Mount)
	self.Owner = Player
	self.LastLoop = tick()
	self.Mount = repStore.Objects[MountName]:Clone()
	self.Mount.Parent = Player.Character
	local MountWeld = Instance.new("Motor6D", Player.Character.HumanoidRootPart)
	MountWeld.Name = "Mount"
	MountWeld.Part0 = Player.Character.HumanoidRootPart
	MountWeld.Part1 = self.Mount.Main
	MountWeld.C0 = self.Mount.Configuration:GetAttribute("Offset")
	Player.Character.Humanoid.HipHeight = self.Mount.Configuration:GetAttribute("HipHeight")
	return self
end

function Mount:Destroy(bool)
	if bool == false or bool == nil then
		local hum : Humanoid = self.Owner.Character:WaitForChild("Humanoid")
		hum.HipHeight = 0
		if self.Owner.Character.HumanoidRootPart:FindFirstChild("Mount") then
			self.Owner.Character.HumanoidRootPart:FindFirstChild("Mount"):Destroy()
		end
	end
	self.Mount:Destroy()
	self = nil
end

return Mount
