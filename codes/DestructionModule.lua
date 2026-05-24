local AttackModule = {}
AttackModule.__index = AttackModule

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local Debris = game:GetService("Debris")
local DamageSound = Assets.Audio:WaitForChild("DamageSound")
local FinalDamageSound = Assets.Audio:WaitForChild("FinalDamageSound")

function AttackModule.New(player)
	local self = setmetatable({}, AttackModule)
	self.Player = player
	self.Character = player.Character
	self.HRP = self.Character:FindFirstChild("HumanoidRootPart")
	return self
end

function AttackModule:Hitbox(clientCFrame)
	local Part = Instance.new("Part")
	local HitboxSize = Vector3.new(10, 10, 5)
	local PlayerScale = self.Character:GetScale()/1.5
	local HitboxScale = HitboxSize * PlayerScale
	Part.Size = HitboxScale
	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1
	Part.CFrame = clientCFrame * CFrame.new(0, -0.1, -2)
	Part.Parent = self.Character

	self:Detect(clientCFrame, Part)
end

function AttackModule:Detect(clientCFrame,Hitbox)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {self.Character}

	local hitParts = workspace:GetPartsInPart(Hitbox, overlapParams)

	for _, hitPart in ipairs(hitParts) do
		if CollectionService:HasTag(hitPart, "Damage") then
			self:Damage(hitPart)
		end
	end

	game:GetService("Debris"):AddItem(Hitbox, 0.2)
end

function AttackModule:Damage(HitPart)
	
	HitPart:SetAttribute("DamagePoints", HitPart:GetAttribute("DamagePoints") - 1)
	if HitPart:GetAttribute("DamagePoints") <= 0 then
		local soundClone = FinalDamageSound:Clone()
		soundClone.Parent = self.Character
		soundClone:Play()
		game:GetService("Debris"):AddItem(soundClone, soundClone.TimeLength + 0.5)
		HitPart:Destroy()
	end
	
	if HitPart:GetAttribute("DamagePoints") <= 5 then
		HitPart.Anchored = false
	end
	
	local Highlight = Instance.new("Highlight")
	Highlight.Parent = HitPart
	Highlight.Adornee = HitPart
	Highlight.FillTransparency = 0.5
	Highlight.OutlineTransparency = 1
	
	self:Destruction(HitPart)
	
	game:GetService("Debris"):AddItem(Highlight, 0.2)
end



function AttackModule:Destruction(Part)

	local soundClone = DamageSound:Clone()
	soundClone.Parent = Part
	soundClone:Play()
	game:GetService("Debris"):AddItem(soundClone, soundClone.TimeLength + 0.5)

	Part.Size = Part.Size - (Part.Size * 0.075)

	for i = 1, 7 do
		local debrisPart = Instance.new("Part")
		local RandomSize = math.random(1,3) / 3
		debrisPart.Size = Vector3.new(RandomSize,RandomSize,RandomSize)
		debrisPart.Position = Part.Position + Vector3.new(
			math.random(-2,2),
			math.random(-2,2),
			math.random(-2,2)
		)
		debrisPart.Color = Part.Color
		debrisPart.Material = Part.Material
		debrisPart.Shape = Enum.PartType.Block
		debrisPart.Anchored = false
		debrisPart.CanCollide = false
		debrisPart.Parent = workspace.DebrisFolder

		-- random rotation
		debrisPart.CFrame = debrisPart.CFrame * CFrame.Angles(
			math.rad(math.random(0,360)),
			math.rad(math.random(0,360)),
			math.rad(math.random(0,360))
		)

		-- random launch direction
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(99999,99999,99999)
		bodyVelocity.Velocity = Vector3.new(
			math.random(-25,25),
			math.random(10,35),
			math.random(-25,25)
		)
		bodyVelocity.Parent = debrisPart

		-- random spin
		local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
		bodyAngularVelocity.MaxTorque = Vector3.new(99999,99999,99999)
		bodyAngularVelocity.AngularVelocity = Vector3.new(
			math.random(-15,15),
			math.random(-15,15),
			math.random(-15,15)
		)
		bodyAngularVelocity.Parent = debrisPart

		Debris:AddItem(bodyAngularVelocity, 0.15)
		Debris:AddItem(bodyVelocity, 0.15)
		Debris:AddItem(debrisPart, 1.5)
	end
end

return AttackModule