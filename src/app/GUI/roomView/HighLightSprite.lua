TOURNEY_TABLE_TIP_PATH ="picdata/table/cardTips.png"
CASH_TABLE_TIP_PATH ="picdata/table/cardTips.png"

local HighLightSprite = class("HighLightSprite", function()
		return display.newNode()
	end)

function HighLightSprite:ctor()
	self.m_removeMSId = nil
    self:setNodeEventEnabled(true)
end

function HighLightSprite:onNodeEvent(tag)
	if tag == "exit" then
    	self:onExit()
	end
end

function HighLightSprite:onExit()
    	if self.m_removeMSId then
    		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_removeMSId)
			self.m_removeMSId = nil
		end
end

function HighLightSprite:initWithType(cardType, tableType)
	-- normal_info_log("HighLightSprite:initWithType")

	local path = (tableType == eTourneyTable) and TOURNEY_TABLE_TIP_PATH or CASH_TABLE_TIP_PATH
	local bgSprite = cc.Sprite:create(path)
	self:addChild(bgSprite)
    
	local CARD_TYPE_COUNT = 10
	local CardType = {"高牌","对子","两对","三条","顺子","同花","葫芦","四条","同花顺","皇家同花顺"}
	local str = (cardType >= 1 and cardType <= CARD_TYPE_COUNT) and CardType[cardType] or ""
	local nameLabel = cc.LabelTTF:create(str,"黑体",20)
	nameLabel:setColor(cc.c3b(185,255,255))
	self:addChild(nameLabel)
    
	self.m_removeMSId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
		handler(self, self.removeMySelf), 5, false)
    
	return true
end

function HighLightSprite:initWithInfo(info)

	if(cc.Sprite:init()) then
	
		return false
	end
    
	local nameLabel = cc.LabelTTF:create(info,"Arial",14)
	nameLabel:setColor(cc.c3b(255,255,255))
	self:addChild(nameLabel,1)
    
	--背景大小和文本自适应
	local layerC = cc.LayerColor:create(cc.c4b(30,30,30,150),nameLabel:getContentSize().width+44,30)
	layerC:setPosition(cc.p(-layerC:getContentSize().width*0.5,-layerC:getContentSize().height*0.5))
	self:addChild(layerC,0)
    
	self.m_removeMSId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
		handler(self, self.removeMySelf), 5, false)
    
	return true
end

function HighLightSprite:removeMySelf(dt)
    if self.m_removeMSId then
    	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_removeMSId)
		self.m_removeMSId = nil
	end
	self:getParent():removeChild(self, true)
end

function HighLightSprite:removeMe()
    if self.m_removeMSId then
    	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_removeMSId)
		self.m_removeMSId = nil
	end
	self:getParent():removeChild(self, true)
end

function HighLightSprite:createWithType(type, tableType)
	local sp = HighLightSprite:new()
	if(sp and sp:initWithType(type,tableType)) then
		return sp
	end
	return nil
end

function HighLightSprite:createWithInfo(info)

	local sp = HighLightSprite:new()
	if(sp and sp:initWithInfo(info)) then
		return sp
	end
   
	return nil
end

return HighLightSprite
