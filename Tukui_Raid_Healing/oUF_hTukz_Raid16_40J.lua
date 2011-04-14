local ADDON_NAME, ns = ...
local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui) 
if not C.unitframes.enable and C.interface.style ~= "Jasje" == true then return end

local font2 = C["media"].uffont
local font1 = C["media"].font
local pixelfont = C["media"].pixelfont
local normTex = C["media"].normTex

local function Shared(self, unit)
	self.colors = T.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = T.SpawnMenu
	
	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	if C["raidlayout"].healer == true then
	health:Height(40.3*C.raidlayout.gridscale*T.raidscale)
	else
	health:Height(27.3*C.raidlayout.gridscale*T.raidscale)
	end
	health:SetStatusBarTexture(normTex)
	self.Health = health
	
	if C["raidlayout"].gridhealthvertical == true then
		health:SetOrientation('VERTICAL')
	end
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(normTex)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = (0.3)
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:Point("CENTER", health, "CENTER", 1, -8)
	health.value:SetFont(C.media.pixelfont, 8, "MONOCHROMEOUTLINE")
	health.value:SetTextColor(1,1,1)
	self.Health.value = health.value

	health.PostUpdate = T.PostUpdateHealthRaid

	health.frequentUpdates = true
	
	if C.unitframes.unicolor == true then
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(.3, .3, .3, 1)
		health.bg:SetVertexColor(.1, .1, .1, 1)		
	else
		health.colorDisconnected = true
		health.colorClass = true
		health.colorReaction = true			
	end
	
	-- border
	local Healthbg = CreateFrame("Frame", nil, self)
	Healthbg:Point("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
	Healthbg:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
	Healthbg:SetTemplate("Hydra")
	Healthbg:CreateShadow("Hydra")
	Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	Healthbg:SetFrameLevel(2)
	self.Healthbg = Healthbg
	-- end border	
	
	-- hydra glow
		self:HookScript("OnEnter", function(self)
			if not UnitIsConnected(self.unit) or UnitIsDead(self.unit) or UnitIsGhost(self.unit) or (not UnitInRange(self.unit) and not UnitIsPlayer(self.unit) )then return end
			local hover = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
			health:SetStatusBarColor(hover.r, hover.g, hover.b)
			health.classcolored = true
		end)
		
		self:HookScript("OnLeave", function(self)
			if not UnitIsConnected(self.unit) or UnitIsDead(self.unit) or UnitIsGhost(self.unit) then return end
			local r, g, b = oUF.ColorGradient(UnitHealth(self.unit)/UnitHealthMax(self.unit), unpack(C["raidlayout"].gradient))
			health:SetStatusBarColor(r, g, b)
			health.classcolored = false
		end)
	-- end hydra glow
	
	local power = CreateFrame("StatusBar", nil, self)
	if C["raidlayout"].healer == true then
	power:Size(58, 2)
	else
	power:Size(40, 2)
	end
	power:Point("LEFT", health, "BOTTOMLEFT", 5, -2)
	power:SetFrameLevel(4)
	power:SetStatusBarTexture(normTex)
	self.Power = power

	-- power border
	local powerborder = CreateFrame("Frame", nil, self)
	T.CreatePanel(powerborder, 1, 1, "CENTER", health, "CENTER", 0, 0)
	powerborder:ClearAllPoints()
	powerborder:SetPoint("TOPLEFT", power, T.Scale(-2), T.Scale(2))
	powerborder:SetPoint("BOTTOMRIGHT", power, T.Scale(2), T.Scale(-2))
	powerborder:SetFrameStrata("MEDIUM")
    powerborder:SetTemplate("Hydra")
	powerborder:SetFrameLevel(4)
	self.powerborder = powerborder
	-- end border

	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4
	
	if C["unitframes"].showsmooth == true then
		power.Smooth = true
	end
		
	if C["unitframes"].unicolor == true then
		power.colorTapping = true
		power.colorClass = true
	else
		power.colorPower = true
	end
	
	local name = health:CreateFontString(nil, "OVERLAY")
    name:SetPoint("CENTER", health, "CENTER", 1, 8)
	name:SetFont(C.media.pixelfont, 8, "MONOCHROMEOUTLINE")
	self:Tag(name, "[Tukui:getnamecolor][Tukui:nameshort]")
	self.Name = name
		
    if C["raidlayout"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
	end
	
	if C["raidlayout"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(15*T.raidscale)
		RaidIcon:Width(15*T.raidscale)
		RaidIcon:SetPoint('CENTER', self, 'TOP')
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*C["raidlayout"].gridscale*T.raidscale)
	ReadyCheck:Width(12*C["raidlayout"].gridscale*T.raidscale)
	ReadyCheck:SetPoint('CENTER') 	
	self.ReadyCheck = ReadyCheck
	
	--local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	--picon:SetPoint('CENTER', self.Health)
	--picon:SetSize(16, 16)
	--picon:SetTexture[[Interface\AddOns\Tukui\medias\textures\picon]]
	--picon.Override = T.Phasing
	--self.PhaseIcon = picon
	
	if not C["raidlayout"].raidunitdebuffwatch == true then
		self.DebuffHighlightAlpha = 1
		self.DebuffHighlightBackdrop = true
		self.DebuffHighlightFilter = true
	end
	
	if C["raidlayout"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["raidlayout"].raidalphaoor}
		self.Range = range
	end
	
	if C["unitframes"].showsmooth == true then
		health.Smooth = true
	end

	------------------------------------------------------------------------
	--      Debuff Highlight
	------------------------------------------------------------------------
		local dbh = self.Health:CreateTexture(nil, "OVERLAY", Healthbg)
		dbh:SetAllPoints(self)
		dbh:SetTexture(TukuiCF["media"].normTex)
		dbh:SetBlendMode("ADD")
		dbh:SetVertexColor(0,0,0,0)
		self.DebuffHighlight = dbh
		self.DebuffHighlightFilter = true
		self.DebuffHighlightAlpha = 0.2
	-- end	
	
if C["unitframes"].healcomm then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
	if C["raidlayout"].gridhealthvertical then
			mhpb:SetOrientation("VERTICAL")
			mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
			mhpb:Width(66*C["raidlayout"].gridscale*T.raidscale)
			mhpb:Height(50*C["raidlayout"].gridscale*T.raidscale)		
	else
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:Width(66*C["raidlayout"].gridscale*T.raidscale)
	end				
		mhpb:SetStatusBarTexture(normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
	if C["raidlayout"].gridhealthvertical then
			ohpb:SetOrientation("VERTICAL")
			ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
			ohpb:Width(66*C["raidlayout"].gridscale*T.raidscale)
			ohpb:Height(50*C["raidlayout"].gridscale*T.raidscale)
	else
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:Width(6*C["raidlayout"].gridscale*T.raidscale)
	end
		ohpb:SetStatusBarTexture(normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
end
	
	if C["raidlayout"].raidunitdebuffwatch == true then
		-- AuraWatch (corner icon)
		T.createAuraWatch(self,unit)
		
		-- Raid Debuffs (big middle icon)
		local RaidDebuffs = CreateFrame('Frame', nil, self)
		RaidDebuffs:Height(18*C["raidlayout"].gridscale)
		RaidDebuffs:Width(18*C["raidlayout"].gridscale)
		RaidDebuffs:Point('CENTER', health, 1,0)
		RaidDebuffs:SetFrameStrata(health:GetFrameStrata())
		RaidDebuffs:SetFrameLevel(health:GetFrameLevel() + 2)
		
		RaidDebuffs:SetTemplate("Default")
		
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, 'OVERLAY')
		RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
		RaidDebuffs.icon:Point("TOPLEFT", 2, -2)
		RaidDebuffs.icon:Point("BOTTOMRIGHT", -2, 2)
		
		-- just in case someone want to add this feature, uncomment to enable it
		--[[
		if C["unitframes"].auratimer then
			RaidDebuffs.cd = CreateFrame('Cooldown', nil, RaidDebuffs)
			RaidDebuffs.cd:SetPoint("TOPLEFT", T.Scale(2), T.Scale(-2))
			RaidDebuffs.cd:SetPoint("BOTTOMRIGHT", T.Scale(-2), T.Scale(2))
			RaidDebuffs.cd.noOCC = true -- remove this line if you want cooldown number on it
		end
		--]]
		
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, 'OVERLAY')
		RaidDebuffs.count:SetFont(C["media"].pixelfont, 9, "MONOCHROMEOUTLINE")
		RaidDebuffs.count:SetPoint('BOTTOMRIGHT', RaidDebuffs, 'BOTTOMRIGHT', 0, 2)
		RaidDebuffs.count:SetTextColor(1, .9, 0)
		
		self.RaidDebuffs = RaidDebuffs
    end

	return self
end

oUF:RegisterStyle('TukuiHealRaid', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealRaid")	
	if C["raidlayout"].healer == true then	
        local raid = self:SpawnHeader("TukuiHealGrid", nil, "raid,party",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', T.Scale(68),
			'initial-height', T.Scale(40.3),
			"showRaid", true,
			"showParty", true,
			"showPlayer", C["raidlayout"].showplayerinparty,
			"xoffset", T.Scale(7),
			"yOffset", T.Scale(-7),
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"columnSpacing", T.Scale(10),
			"columnAnchorPoint", "TOP"		
		) 
		raid:SetPoint("BOTTOM", InvTukuiActionBarBackground, 0, 107) 
    else	
        local raid = self:SpawnHeader("TukuiHealGrid", nil, "raid,party",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', T.Scale(50),
			'initial-height', T.Scale(27.3),
			"showRaid", true,
			"showParty", true,
			"showPlayer", C["raidlayout"].showplayerinparty,
			"xoffset", T.Scale(7),
			"yOffset", T.Scale(-7),
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"columnSpacing", T.Scale(10),
			"columnAnchorPoint", "TOP"		
		) 
		raid:SetPoint("TOPLEFT", UIParent, 15, -10)		
	end
end)

--[[
-- only show 5 groups in raid (25 mans raid)
local MaxGroup = CreateFrame("Frame")
MaxGroup:RegisterEvent("PLAYER_ENTERING_WORLD")
MaxGroup:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MaxGroup:SetScript("OnEvent", function(self)
	local inInstance, instanceType = IsInInstance()
	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
		TukuiGrid:SetAttribute("groupFilter", "1,2,3,4,5")
	else
		TukuiGrid:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
	end
end)
]]--