-- Tukui API, see DOCS/API.txt for more informations

local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

local noop = T.dummy
local floor = math.floor
local class = T.myclass
local texture = C.media.blank
local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

-- pixel perfect script of custom ui Scale.
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/C["general"].uiscale
local Scale = function(x)
    return mult*math.floor(x/mult+.5)
end

T.Scale = function(x) return Scale(x) end
T.mult = mult

---------------------------------------------------
-- TEMPLATES
---------------------------------------------------

local function GetTemplate(t)
	if t == "Tukui" then
		borderr, borderg, borderb = .6, .6, .6
		backdropr, backdropg, backdropb = .1, .1, .1
	elseif t == "ClassColor" then
		local c = T.oUF_colors.class[class]
		borderr, borderg, borderb = c[1], c[2], c[3]
		backdropr, backdropg, backdropb = unpack(C["media"].backdropcolor)
	elseif t == "Elv" then
		borderr, borderg, borderb = .3, .3, .3
		backdropr, backdropg, backdropb = .1, .1, .1	
	elseif t == "Duffed" then
		borderr, borderg, borderb = .2, .2, .2
		backdropr, backdropg, backdropb = .02, .02, .02
	elseif t == "Dajova" then
		borderr, borderg, borderb = .05, .05, .05
		backdropr, backdropg, backdropb = .1, .1, .1
	elseif t == "Eclipse" then
		borderr, borderg, borderb = .1, .1, .1
		backdropr, backdropg, backdropb = 0, 0, 0
	elseif t == "Hydra" then
		borderr, borderg, borderb = .2, .2, .2
		backdropr, backdropg, backdropb = .075, .075, .075
	else
		borderr, borderg, borderb = unpack(C["media"].bordercolor)
		backdropr, backdropg, backdropb = unpack(C["media"].backdropcolor)
	end
end

---------------------------------------------------
-- END OF TEMPLATES
---------------------------------------------------

local function Size(frame, width, height)
	frame:SetSize(Scale(width), Scale(height or width))
end

local function Width(frame, width)
	frame:SetWidth(Scale(width))
end

local function Height(frame, height)
	frame:SetHeight(Scale(height))
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5)
	-- anyone has a more elegant way for this?
	if type(arg1)=="number" then arg1 = Scale(arg1) end
	if type(arg2)=="number" then arg2 = Scale(arg2) end
	if type(arg3)=="number" then arg3 = Scale(arg3) end
	if type(arg4)=="number" then arg4 = Scale(arg4) end
	if type(arg5)=="number" then arg5 = Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

local function SetTemplate(f, t, tex)
	if tex then texture = C.media.normTex else texture = C.media.blank end
	
	GetTemplate(t)
		
	f:SetBackdrop({
	  bgFile = texture, 
	  edgeFile = C.media.blank, 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	
	if t == "Transparent" then backdropa = 0.8 else backdropa = 1 end
	
	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb)
end

local function CreatePanel(f, t, w, h, a1, p, a2, x, y)
	GetTemplate(t)
	
	if t == "Transparent" then backdropa = 0.8 else backdropa = 1 end
	
	local sh = Scale(h)
	local sw = Scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, Scale(x), Scale(y))
	f:SetBackdrop({
	  bgFile = C["media"].blank, 
	  edgeFile = C["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	
	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb)
end
-- hydra slide in/out
local function Animate(self, x, y, duration)
	self.anim = self:CreateAnimationGroup("Move_In")
	self.anim.in1 = self.anim:CreateAnimation("Translation")
	self.anim.in1:SetDuration(0)
	self.anim.in1:SetOrder(1)
	self.anim.in2 = self.anim:CreateAnimation("Translation")
	self.anim.in2:SetDuration(duration)
	self.anim.in2:SetOrder(2)
	self.anim.in2:SetSmoothing("OUT")
	self.anim.out1 = self:CreateAnimationGroup("Move_Out")
	self.anim.out2 = self.anim.out1:CreateAnimation("Translation")
	self.anim.out2:SetDuration(duration)
	self.anim.out2:SetOrder(1)
	self.anim.out2:SetSmoothing("IN")
	self.anim.in1:SetOffset(Scale(x), Scale(y))
	self.anim.in2:SetOffset(Scale(-x), Scale(-y))
	self.anim.out2:SetOffset(Scale(x), Scale(y))
	self.anim.out1:SetScript("OnFinished", function() self:Hide() end)
end

local function SlideIn(self)
	if not self.anim then
		Animate(self)
	end

	self.anim.out1:Stop()
	self:Show()
	self.anim:Play()
end

local function SlideOut(self)
	if self.anim then
		self.anim:Finish()
	end

	self.anim:Stop()
	self.anim.out1:Play()
end

local function SetBorder(f)
	f:SetBackdropColor(.075, .075, .075, 0.7)
	f:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	border = CreateFrame("Frame", nil, f)
	border:SetPoint("TOPLEFT", f, "TOPLEFT", T.Scale(-1), T.Scale(1))
	border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", T.Scale(1), T.Scale(-1))
	border:SetFrameStrata("BACKGROUND")
	border:SetFrameLevel(1)
	border:SetBackdrop { edgeFile = TukuiCF["media"].blank, edgeSize = T.Scale(3), insets = {left = 0, right = 0, top = 0, bottom = 0} }
	border:SetBackdropColor(unpack(C["media"].backdropcolor))
	border:SetBackdropBorderColor(unpack(C["media"].backdropcolor))
end

local function CreateShadow(f, t)
	if f.shadow then return end -- we seriously don't want to create shadow 2 times in a row on the same frame.
	
	borderr, borderg, borderb = 0, 0, 0
	backdropr, backdropg, backdropb = 0, 0, 0
	
	if t == "ClassColor" then
		local c = T.oUF_colors.class[class]
		borderr, borderg, borderb = c[1], c[2], c[3]
		backdropr, backdropg, backdropb = unpack(C["media"].backdropcolor)
	end
	
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:Point("TOPLEFT", -3, 3)
	shadow:Point("BOTTOMLEFT", -3, -3)
	shadow:Point("TOPRIGHT", 3, 3)
	shadow:Point("BOTTOMRIGHT", 3, -3)
	shadow:SetBackdrop( { 
		edgeFile = C["media"].glowTex, edgeSize = T.Scale(3),
		insets = {left = T.Scale(5), right = T.Scale(5), top = T.Scale(5), bottom = T.Scale(5)},
	})
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.8)
	f.shadow = shadow
end

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = noop
	object:Hide()
end

local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))] -- did this for button hover, pushed

-- styleButton function authors are Chiril & Karudon.
local function StyleButton(b, c) 
    local name = b:GetName()
 
    local button          = _G[name]
    local icon            = _G[name.."Icon"]
    local count           = _G[name.."Count"]
    local border          = _G[name.."Border"]
    local hotkey          = _G[name.."HotKey"]
    local cooldown        = _G[name.."Cooldown"]
    local nametext        = _G[name.."Name"]
    local flash           = _G[name.."Flash"]
    local normaltexture   = _G[name.."NormalTexture"]
	local icontexture     = _G[name.."IconTexture"]
	
	local hover = b:CreateTexture("frame", nil, self) -- hover
	hover:SetTexture(color.r, color.g, color.b,0.3)
	hover:SetHeight(button:GetHeight())
	hover:SetWidth(button:GetWidth())
	hover:Point("TOPLEFT",button,2,-2)
	hover:Point("BOTTOMRIGHT",button,-2,2)
	button:SetHighlightTexture(hover)

	local pushed = b:CreateTexture("frame", nil, self) -- pushed
	pushed:SetTexture(.075,.075,.075,.9)
	pushed:SetHeight(button:GetHeight())
	pushed:SetWidth(button:GetWidth())
	pushed:Point("TOPLEFT",button,2,-2)
	pushed:Point("BOTTOMRIGHT",button,-2,2)
	button:SetPushedTexture(pushed)
 
	if c then
		local checked = b:CreateTexture("frame", nil, self) -- checked
		checked:SetTexture(color.r, color.g, color.b,.5)
		checked:SetHeight(button:GetHeight())
		checked:SetWidth(button:GetWidth())
		checked:Point("TOPLEFT",button,2,-2)
		checked:Point("BOTTOMRIGHT",button,-2,2)
		button:SetCheckedTexture(checked)
	end
end

local function FontString(parent, name, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(mult, -mult)
	
	if not name then
		parent.text = fs
	else
		parent[name] = fs
	end
	
	return fs
end

local function addapi(object)
	local mt = getmetatable(object).__index
	mt.Size = Size
	mt.Point = Point
	mt.SetTemplate = SetTemplate
	mt.CreatePanel = CreatePanel
	mt.SetBorder = SetBorder -- hydra border
	mt.CreateShadow = CreateShadow
	mt.Kill = Kill
	mt.CreateTransparentPanel = CreateTransparentPanel
	mt.StyleButton = StyleButton
	mt.Width = Width
	mt.Height = Height
	mt.FontString = FontString
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end