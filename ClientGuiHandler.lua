--[[
	Client Gui Handler
]]
-- Varibles
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player.PlayerGui

local PetRemote = game:GetService("ReplicatedStorage").Remotes.Pet

local PetsGui = PlayerGui:WaitForChild("Pets")
local HolderFrame =  PetsGui:WaitForChild("Frame")

local PetsEquippedTextLabel = HolderFrame:WaitForChild("Equipped")
local PetsStorageTextLabel = HolderFrame:WaitForChild("Storage")

local PetInventoryFrame = HolderFrame:WaitForChild("Inventory"):WaitForChild("InventoryFrame")
local PetSample = PetInventoryFrame:WaitForChild("Sample")

local ConfirmationFrame = HolderFrame:WaitForChild("Confirmation")
local ConfirmationCancelButton = ConfirmationFrame:WaitForChild("IconFrame"):WaitForChild("Cancel")
local ConfirmationDeleteButton = ConfirmationFrame:WaitForChild("IconFrame"):WaitForChild("Delete")

local CodesGui = PlayerGui:WaitForChild("Codes")
local MountsGui = PlayerGui:WaitForChild("Mounts")

local ShopGui = PlayerGui:WaitForChild("Shop")
local ShopGamepasses = ShopGui:WaitForChild("Frame"):WaitForChild("Purchases"):WaitForChild("Gamepasses")
local ShopDevProducts = ShopGui:WaitForChild("Frame"):WaitForChild("Purchases"):WaitForChild("Gems")
local GamepassTextLabel = ShopGui:WaitForChild("Frame"):WaitForChild("Gamepasses")
local GemsTextLabel = ShopGui:WaitForChild("Frame"):WaitForChild("Gems")

local TitleTextLabel = ShopGui:WaitForChild("Frame"):WaitForChild("Title")

local Gui = PlayerGui:WaitForChild("Gui")
local PetButton = Gui:WaitForChild("LeftFrame"):WaitForChild("lButtons"):WaitForChild("Pets")
local MountButton = Gui:WaitForChild("LeftFrame"):WaitForChild("lButtons"):WaitForChild("Mounts")
local CodesButton = Gui:WaitForChild("LeftFrame"):WaitForChild("lButtons"):WaitForChild("Codes")
local ShopButton = Gui:WaitForChild("LeftFrame"):WaitForChild("lButtons"):WaitForChild("Shop")
local GemsButton = GemsTextLabel.Button
local GamepassesButton = GamepassTextLabel.Button


local SelectedPetName, SelectedPetKey, SelectedPetDisplay --initializes the confirmation varibles

local MarketPlaceService = game:GetService("MarketplaceService")

local function ownsgamepass(gamepassid) -- checks if player owns gamepass
	local userid = Player.UserId
	local s,res = pcall(MarketPlaceService.UserOwnsGamePassAsync,MarketPlaceService,userid,gamepassid)
	if not s then
		res = false
	end
	return res
end

local function promptgamepass(gamepassid) -- prompts plr with gamepass id
	MarketPlaceService:PromptGamePassPurchase(Player, gamepassid)
end

local function promptproduct(productid) -- prompts plr with dev product id
	MarketPlaceService:PromptProductPurchase(Player, productid)
end

local function onPromptPurchaseFinished(gplayer, purchasedPassID, purchaseSuccess) -- runs when prompt is finished when buying gamepass
	if purchaseSuccess and gplayer == Player then
		task.wait(2)
		Player:Kick("Gamepass Purchase Success, Rejoin for gamepass to work!")
	end
end
MarketPlaceService.PromptGamePassPurchaseFinished:Connect(onPromptPurchaseFinished)

local function SetSelectedPet(PetName,Key,PetDisplay) --sets the selected pet when a pet button is clicked
	SelectedPetName = PetName
	SelectedPetKey = Key
	SelectedPetDisplay = PetDisplay
end

function ButtonSetup(Button, GuiToOpenOnClick, Fx, canClose) --  sets up a button to open a gui or frame on click and when clicked runs Fx(), canclose is just the option for if you want the player to beable to close it
	local canOpenOnClick = false
	if canClose == nil then
		canClose = true
	end
	if Button:GetAttribute("GamepassId") then -- checks if the button requires a gamepass to open it and if it does lock it unless the player owns it
		canOpenOnClick = false
		if ownsgamepass(Button:GetAttribute("GamepassId")) then
			canOpenOnClick = true
			Button.Lock.Visible = false
		else
			canOpenOnClick = false
			Button.Lock.Visible = true
		end
	elseif not Button:GetAttribute("GamepassId") then
		canOpenOnClick = true
		if Button:FindFirstChild("Lock") then
			Button.Lock.Visible = false
		end
	end

	if Button:FindFirstChild("ButtonName") then
		Button.ButtonName.Text = Button.Name
	end

	Button.MouseButton1Click:Connect(function()
		if canOpenOnClick then
			game.ReplicatedStorage["Audio"]["Click"]:Play()
			if GuiToOpenOnClick:IsA("ScreenGui") then
				if GuiToOpenOnClick.Enabled == false then
					GuiToOpenOnClick.Enabled = true
					if Fx then
						Fx()
					end
				else
					if canClose then 
						GuiToOpenOnClick.Enabled = false
					end
				end
			else
				if GuiToOpenOnClick.Visible == false then
					GuiToOpenOnClick.Visible = true
					if Fx then
						Fx()
					end
				else
					if canClose then 
						GuiToOpenOnClick.Visible = false
					end

					if GuiToOpenOnClick == ConfirmationFrame then
						if Fx then
							Fx()
						end
					end
				end
			end
		else
			game.ReplicatedStorage["Audio"]["Fail"]:Play()
			promptgamepass(Button:GetAttribute("GamepassId"))
		end
	end)

	Button.MouseButton1Down:Connect(function() -- simply animates the click of the button
		if not Button:FindFirstChild("AspectRatio") then return end
		Button.AspectRatio.AspectRatio = 1.15
	end)
	Button.MouseButton1Up:Connect(function()
		if not Button:FindFirstChild("AspectRatio") then return end
		Button.AspectRatio.AspectRatio = 1
	end)
	Button.MouseEnter:Connect(function()
		if not Button:FindFirstChild("AspectRatio") then return end
		Button.AspectRatio.AspectRatio = 1
	end)
	Button.MouseLeave:Connect(function()
		if not Button:FindFirstChild("AspectRatio") then return end
		Button.AspectRatio.AspectRatio = 1
	end)
end

local function DisplayUpdate() -- updates the pets display
	task.wait(0.15)
	local EquippedPets = game:GetService("HttpService"):JSONDecode(Player:WaitForChild("Hidden"):WaitForChild("EquippedPets").Value) -- getting equipped pets table
	local PetsTable = game:GetService("HttpService"):JSONDecode(Player.Hidden.Pets.Value) -- getting pets table
	
	--set base numbers
	local NumEquipped, NumOwned = 0,0
	for i in EquippedPets do
		NumEquipped += 1
	end
	for i in PetsTable do
		NumOwned += 1
	end 

	if ownsgamepass(201468093) then -- more pets equipped --"Gamepass"
		PetsEquippedTextLabel.Text = NumEquipped .."/6"
	else
		PetsEquippedTextLabel.Text = NumEquipped .."/3"
	end

	if ownsgamepass(201469579) then -- more pets storage --"Gamepass"
		PetsStorageTextLabel.Text = NumOwned .."/20"
	else
		PetsStorageTextLabel.Text = NumOwned .."/10"
	end
end

local function PetsOpen() -- runs when pets gui is opened
	for _, v in pairs(PetInventoryFrame:GetChildren()) do
		if v.Name ~= "Sample" and v:IsA("ImageLabel") then
			v:Destroy()
		end
	end-- clears the old samples


	local EquippedPets = game:GetService("HttpService"):JSONDecode(Player:WaitForChild("Hidden"):WaitForChild("EquippedPets").Value) -- gets equipped pet table
	local PetsTable = game:GetService("HttpService"):JSONDecode(Player.Hidden.Pets.Value) -- gets pet table

	DisplayUpdate()-- updates pet display

	for key, Pet in PetsTable do -- creates new samples
		local NewSample = PetSample:Clone()
		NewSample.Name = Pet
		NewSample.PetName.Text = Pet
		NewSample.Parent = PetInventoryFrame
		local PetEquipped = false
		for index in EquippedPets do
			if index == key then
				PetEquipped = true
			end
		end
		if PetEquipped then
			NewSample.BackgroundColor3 = Color3.new(0.352941, 1, 0.407843)
		else
			NewSample.BackgroundColor3 = Color3.new(1, 1, 1)
		end

		local function Confirmation() -- sets the selected pet when the confimation gui opens
			SetSelectedPet(Pet, key, NewSample)
		end

		ButtonSetup(NewSample:WaitForChild("Delete"):WaitForChild("Button"), ConfirmationFrame, Confirmation) -- sets up confirm button
		NewSample.PetName.MouseButton1Click:Connect(function() -- equips the pet
			PetEquipped = not PetEquipped
			if PetEquipped then
				local Equippedpets = game:GetService("HttpService"):JSONDecode(Player:WaitForChild("Hidden"):WaitForChild("EquippedPets").Value)
				local Equipped = 0
				for _ in Equippedpets do
					Equipped += 1
				end
				local maxEquip
				if ownsgamepass(201468093) then -- checks if player owns more equips gamepass
					maxEquip = 6
				else
					maxEquip = 3
				end

				if Equipped < maxEquip then  -- makes sure plr doesnt exceed his max equip amt
					NewSample.BackgroundColor3 = Color3.new(0.352941, 1, 0.407843)
					PetRemote:FireServer("Equip", Pet, key)	
					DisplayUpdate()
				end
			else 
				NewSample.BackgroundColor3 = Color3.new(1, 1, 1)
				PetRemote:FireServer("Unequip", Pet, key)
				DisplayUpdate()
			end
		end)
		NewSample.Visible = true
	end
end

local function ConfirmDelete() -- deletes selected pet
	PetRemote:FireServer("Delete", SelectedPetName, SelectedPetKey)
	SelectedPetDisplay:Destroy()
	SelectedPetDisplay = nil
	SelectedPetName = nil
	SelectedPetKey = nil

	DisplayUpdate() -- updates pets display
end

local function ConfirmCancel() -- cancels Confirmation
	SelectedPetDisplay = nil
	SelectedPetName = nil
	SelectedPetKey = nil

	DisplayUpdate() -- updates pets display
end

local ShopConnections = {} -- table for storing connections so i can find and delete them later in the script

local function RobuxShopGui()
	for _, Item in pairs(ShopGamepasses:GetChildren()) do --loops through the gamepass buttons and sets them up to work properly
		if Item:GetAttribute("GamepassId") ~= nil and Item:IsA("ImageLabel") then  -- a sanity check so a script or another item isnt seen as a item we should do logic with
			local OwnedDisplay = Item:WaitForChild("OwnedDisplay")
			local OwnedText = OwnedDisplay:WaitForChild("Owned")
			local GamepassId = Item:GetAttribute("GamepassId")

			if ShopConnections[GamepassId] then -- if the connection already exists disconnect it and set it to nil
				ShopConnections[GamepassId]:Disconnect()
				ShopConnections[GamepassId] = nil
			end

			if ownsgamepass(GamepassId) then -- checks if the player owns the gamepass
				OwnedDisplay.BackgroundColor3 = Color3.new(0.12549, 1, 0.447059)
				OwnedText.Text = "✓"
			elseif not ownsgamepass(GamepassId) then -- checks if the player doesnt own the gamepass
				OwnedDisplay.BackgroundColor3 = Color3.new(1, 1, 1)
				OwnedText.Text = "X"

				ShopConnections[GamepassId] = Item.Button.MouseButton1Click:Connect(function() -- set up the prompt on click
					promptgamepass(GamepassId)
					ShopConnections[GamepassId]:Disconnect()
					ShopConnections[GamepassId] = nil
				end)

			end
		end
	end
end

local function RobuxDevProductShopGui() -- sets up the devproduct buttons
	for _, Item in pairs(ShopDevProducts:GetChildren()) do
		if Item:GetAttribute("GamepassId") ~= nil and Item:IsA("ImageLabel") then 
			local GamepassId = Item:GetAttribute("GamepassId")

			Item.Button.MouseButton1Click:Connect(function() -- sets up the click for prompt 
				promptproduct(GamepassId)
			end)

		end
	end
end

repeat
	task.wait()
until Player:GetAttribute("LoadedData") == true --wait until all data is loaded onto the player from the server so nothing errors 

Player:WaitForChild("Hidden"):WaitForChild("Pets").Changed:Connect(function() -- sets up an display update for if the pets value changes
	if PetsGui.Enabled then
		DisplayUpdate() -- updates the pets display
	end
end)

local function GP() -- Gamepass(GP) tab open function
	ShopDevProducts.Visible = false
	TitleTextLabel.Text = "Gamepasses"
	GamepassTextLabel.ZIndex = 3
	GemsTextLabel.ZIndex = 2
	GemsTextLabel.TextXAlignment = Enum.TextXAlignment.Right
end
ButtonSetup(GamepassesButton, ShopGamepasses, GP, false) --set up the button press to run GP on click

local function DP() -- DevProduct(DP) tab open function
	ShopGamepasses.Visible = false
	TitleTextLabel.Text = "Gems"
	GamepassTextLabel.ZIndex = 2
	GemsTextLabel.ZIndex = 2
	GemsTextLabel.TextXAlignment = Enum.TextXAlignment.Center
end
ButtonSetup(GemsButton, ShopDevProducts, DP, false) --set up the button press to run DP on click

RobuxDevProductShopGui() -- runs dev product setup once on respawn
ButtonSetup(PetButton, PetsGui, PetsOpen) -- sets up pets open button
ButtonSetup(ShopButton, ShopGui, RobuxShopGui) -- sets up robux shop open button
ButtonSetup(MountButton, MountsGui) -- sets up mounts gui open button
ButtonSetup(CodesButton, CodesGui) -- sets up codes open button

ButtonSetup(ConfirmationDeleteButton, ConfirmationFrame, ConfirmDelete) -- sets up confirmation delete button
ButtonSetup(ConfirmationCancelButton, ConfirmationFrame, ConfirmCancel) -- sets up confirmation cancel button
