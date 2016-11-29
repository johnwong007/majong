MAIN_POT_IMG_PATH ="picdata/table/mainPotIcon.png"--主池图片
SIDE_POT_IMG_PATH ="picdata/table/sidePotIcon.png"--偏池图片
BACK_POT_IMG_PATH ="picdata/table/potBG.png"--奖池背景

local PotLayer = class("PotLayer", function()
		return cc.Sprite:create()
	end)

function PotLayer:create(isMain)
	local layer = PotLayer:new()
	layer:init(isMain)
	return layer
end

function PotLayer:ctor()
	self.m_chip = nil
end

--[[获取奖池大小]]
function PotLayer:getPot() 
	return self.m_dChip
end

--[[add by wangj]]
function PotLayer:subChips(chipsN)
	self.m_dChip=self.m_dChip-chipsN
end

--改变奖池
function PotLayer:setPot(pot)

	local bRet = false
	if self.m_chip then
		self.m_chip:setChips(pot)
		self.m_dChip = pot
		bRet = true
	end
	
	return bRet
end

--设置静态筹码
function PotLayer:setStaticPot(pot)

	local bRet = false
	if self.m_chip then
		self.m_chip:setStaticChips(pot)
		self.m_dChip = pot
		bRet = true
	end
    
	return bRet
end

--奖池添加
function PotLayer:addPot(add)

	local bRet = false
	if(self.m_chip) then
		self.m_chip:addChips(add)
		self.m_dChip = self.m_dChip + add
		bRet = true
	end
    
	return bRet
end

function PotLayer:init(isMain)
    
	local pBg = cc.Sprite:create(BACK_POT_IMG_PATH)
	if(not pBg) then
		return false
	end
	pBg:setAnchorPoint(cc.p(0,0))
	pBg:setPosition(cc.p(0,0))
	local size = pBg:getContentSize()
	self:setContentSize(size)
	self:ignoreAnchorPointForPosition(false)
	self:addChild(pBg)
    
	local pChipImg = cc.Sprite:create(isMain and MAIN_POT_IMG_PATH or SIDE_POT_IMG_PATH)
	if not pChipImg then
		return false
	end
	pChipImg:setAnchorPoint(cc.p(0,0.5))
	pChipImg:setPosition(cc.p(-pChipImg:getContentSize().width / 2,size.height / 2))
	self:addChild(pChipImg)
	
	self.m_chip = require("app.GUI.roomView.ChipLabel"):create(0,"picdata/gamescene/chipNumSmall.fnt",-1)

    if self.m_chip then
		self.m_chip:setAnchorPoint(cc.p(0.5,0.5))
		self.m_chip:setPosition(cc.p(size.width / 2 + 3,size.height / 2+4))
		self.m_chip:setColor(cc.c3b(255,255,255))
		self:addChild(self.m_chip)
	end
    
	return true
end

return PotLayer