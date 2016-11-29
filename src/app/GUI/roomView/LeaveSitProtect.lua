--
-- Author: wangj
-- Date: 2016-06-23 12:12:43
--
local myInfo = require("app.Model.Login.MyInfo")
local info_text = "功能:留座十分钟"
local price_table = {
	["1"] = 100,
	["2"] = 100,
	["5"] = 100,
	["10"] = 200,
	["25"] = 200,
	["50"] = 400,
	["100"] = 400,
	["500"] = 1000,
	["1000"] = 1000
	}

local LeaveSitProtect = class("LeaveSitProtect", function()
	return display.newNode()
	-- return display.newColorLayer(cc.c4b( 0,0,0,0))
end)

--[[
	成员变量说明：
	

]]

function LeaveSitProtect:ctor(params)
	self.params = params or {}
	self.loc = self.params.loc or cc.p(0,0)
	self.animTime = self.params.animTime or 1
	self.bgPic = self.params.bgPic or "picdata/LeaveSitProtect/coffee.png"

	self:setNodeEventEnabled(true) 	

	self.m_applyDelayTime = 0

	self.smallBlind = tostring(self.params.smallBlind) or 100
	self.price = price_table[self.smallBlind] or 50
end
function LeaveSitProtect:create()
	self:initUI()
end
function LeaveSitProtect:initUI()
	self.m_infoButton = CMButton.new({normal = "picdata/OperateDelay/btn_qas.png",pressed = "picdata/OperateDelay/btn_qas2.png"}, handler(self, self.showInfo), {scale9 = false})
	self.m_infoButton:setButtonLabelOffset(8, 0) 
	self.m_infoButton:setPosition(self.loc.x-30,self.loc.y+60)
	self:addChild(self.m_infoButton, 2)

	self.m_applyButton = CMButton.new({normal = "picdata/OperateDelay/btn.png",pressed = "picdata/OperateDelay/btn2.png"}, handler(self, self.menuCallBack), {scale9 = false})
	self.m_applyButton:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(255, 255, 255),
	    text = ""..self.price,
	    size = 18,
	    font = "黑体"
		}) )   
	self.m_applyButton:setButtonLabelOffset(8, 0) 
	self.m_applyButton:setPosition(self.loc.x,self.loc.y)
	self:addChild(self.m_applyButton, 2)

	self.m_clockBg = cc.ui.UIImage.new("picdata/OperateDelay/t_bg.png")
		:align(display.CENTER, self.loc.x, self.loc.y+30)
		:addTo(self)
	self.m_clockBg = cc.ui.UIImage.new(self.bgPic)
		:align(display.CENTER, self.loc.x, self.loc.y+30)
		:addTo(self)

	self.m_light = cc.ui.UIImage.new("picdata/OperateDelay/light.png")
		:align(display.CENTER, self.m_clockBg:getPositionX(), self.m_clockBg:getPositionY())
		:addTo(self)
	self.m_light:setOpacity(0)

	self.m_hintNode = display.newNode()
		:align(display.CENTER, self.m_clockBg:getPositionX()-8, self.m_clockBg:getPositionY()+30)
		:addTo(self, 1)

	self.m_hintIcon = cc.ui.UIImage.new("picdata/OperateDelay/icon_zuan.png")
		:align(display.RIGHT_CENTER, 0, 0)
		:addTo(self.m_hintNode)

	self.m_hintLabel = cc.ui.UILabel.new({
		text = ""..self.price,
		font = "黑体",
		size = 20,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 0, 0)
		:addTo(self.m_hintNode)
	self.m_hintIcon:setOpacity(0)
	self.m_hintLabel:setOpacity(0)

	self.m_infoNode = display.newNode()
		:align(display.CENTER, self.m_clockBg:getPositionX()-30, self.m_clockBg:getPositionY()+68)
		:addTo(self, 1)

	self.m_infoBg = cc.ui.UIImage.new("picdata/LeaveSitProtect/bg_tips.png")
		:align(display.CENTER, 0, 0)
		:addTo(self.m_infoNode)

	self.m_infoLabel = cc.ui.UILabel.new({
		text = ""..info_text,
		font = "黑体",
		size = 20,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.CENTER, 0, 12)
		:addTo(self.m_infoNode)
	self.m_infoNode:setVisible(false)
end

function LeaveSitProtect:setPokerBgPos(data)
	self.m_pokerBgPos = data
end

function LeaveSitProtect:updateLeaveSitProtectButtonPos(publicCardNum)
	local posx = 600
	if publicCardNum == 0 then
		posx = (self.m_pokerBgPos[1].x+self.m_pokerBgPos[5].x)/2
	elseif publicCardNum == 3 then
		posx = (self.m_pokerBgPos[4].x+self.m_pokerBgPos[5].x)/2
	elseif publicCardNum == 4 then
		posx = self.m_pokerBgPos[5].x
	end
	self.m_applyButton:setPositionX(posx)
	self.m_clockBg:setPositionX(posx)
	self.m_light:setPositionX(posx)
	self.m_hintNode:setPositionX(posx-8)
	if self.m_infoNode then
		self.m_infoNode:setPositionX(posx)
	end
end

function LeaveSitProtect:showInfo()
	if self.m_infoNode then
		if self.m_infoNode:isVisible() then
			self.m_infoNode:stopAllActions()
			self.m_infoNode:setVisible(false)
			return
		end
		self.m_infoNode:setVisible(true)
		transition.execute(self.m_infoNode, cc.DelayTime:create(4), {
			onComplete = function() 
				self.m_infoNode:setVisible(false)
			end
			})
	end
end

function LeaveSitProtect:menuCallBack()
	if self.m_animationStarted then
		return
	end
	self.m_animationStarted = true
	self:doAnimation()
	if self.m_infoNode then
		self.m_infoNode:setVisible(false)
	end
	if self.params.callback then
		self.params.callback(self.price)
	end
end

function LeaveSitProtect:doAnimation()
	self.m_light:setOpacity(100)
	self.m_light:setScale(0.8)
	self.m_hintIcon:setOpacity(100)
	self.m_hintLabel:setOpacity(100)
	self.m_hintIcon:setPositionY(0)
	self.m_hintLabel:setPositionY(0)
	transition.execute(self.m_light, cc.Sequence:create({cc.ScaleTo:create(self.animTime/2, 1.2),cc.FadeOut:create(self.animTime/2)}), {
		onComplete = function()	
			self:setVisible(false)
			self.m_animationStarted = false
		end
		})
	transition.execute(self.m_hintIcon, cc.Spawn:create({cc.MoveBy:create(self.animTime, cc.p(0,25)),cc.FadeOut:create(self.animTime)}))
	transition.execute(self.m_hintLabel, cc.Spawn:create({cc.MoveBy:create(self.animTime, cc.p(0,25)),cc.FadeOut:create(self.animTime)}))
end

function LeaveSitProtect:setViewVisible(isVisible)
	if isVisible then
		self:setVisible(true)
	else
		
		if not self.m_animationStarted then
			self:setVisible(false)
		end
	end
end

function LeaveSitProtect:updateApplyDelayTime(times)
	times = times or 0
	self.m_applyDelayTime = times
	self:getActualPrice()
	self:updatePrice()
end

function LeaveSitProtect:getActualPrice()
	return self.price
end

function LeaveSitProtect:updatePrice()
	self.m_applyButton:setButtonLabelString("normal", ""..self.price)
	self.m_hintLabel:setString(""..self.price)
end

function LeaveSitProtect:addApplyDelayTimes()
	self.m_applyDelayTime = self.m_applyDelayTime+1
	self:getActualPrice()
	self:updatePrice()
end

function LeaveSitProtect:showDelayView(remainTime)
	self:setVisible(true)
	self:updateApplyDelayTime(0)
	self:stopAllActions()
	transition.execute(self, cc.DelayTime:create(remainTime), {
			onComplete = function()
				self:setVisible(false)
			end
		})
end

return LeaveSitProtect