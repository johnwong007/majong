--
-- Author: wangj
-- Date: 2016-06-23 12:12:43
--
local myInfo = require("app.Model.Login.MyInfo")
local info_text = "功能：时间恢复到15秒\n价格：同一轮思考中，首\n次重置花费50德堡钻，之\n后每次翻倍收费。"


local OperateDelay = class("OperateDelay", function()
	return display.newNode()
	-- return display.newColorLayer(cc.c4b( 0,0,0,0))
end)

--[[
	成员变量说明：
	

]]

function OperateDelay:ctor(params)
	self.params = params or {}
	self.loc = self.params.loc or cc.p(0,0)
	self.price = self.params.price or 50
	self.animTime = self.params.animTime or 1
	self:setNodeEventEnabled(true) 	

	self.m_applyDelayTime = 0
end
function OperateDelay:create()
	self:initUI()
end
function OperateDelay:initUI()
	self.m_infoButton = CMButton.new({normal = "picdata/OperateDelay/btn_qas.png",pressed = "picdata/OperateDelay/btn_qas2.png"}, handler(self, self.showInfo), {scale9 = false})
	self.m_infoButton:setButtonLabelOffset(8, 0) 
	self.m_infoButton:setPosition(self.loc.x-30,self.loc.y+60)
	self:addChild(self.m_infoButton, 2)

	self.m_applyButton = CMButton.new({normal = "picdata/OperateDelay/btn.png",pressed = "picdata/OperateDelay/btn2.png"}, handler(self, self.menuCallBack), {scale9 = false})
	self.m_applyButton:setButtonLabel("normal",cc.ui.UILabel.new({
	    --UILabelType = 1,
	    color = cc.c3b(248, 192, 255),
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
	self.m_clock = cc.ui.UIImage.new("picdata/OperateDelay/t_clock.png")
		:align(display.CENTER, self.m_clockBg:getPositionX(), self.m_clockBg:getPositionY())
		:addTo(self)
	self.m_light = cc.ui.UIImage.new("picdata/OperateDelay/light.png")
		:align(display.CENTER, self.m_clockBg:getPositionX(), self.m_clockBg:getPositionY())
		:addTo(self)
	self.m_light:setOpacity(0)

	self.m_clockHour = cc.ui.UIImage.new("picdata/OperateDelay/t_shi.png")
		:align(display.LEFT_CENTER, self.m_clockBg:getPositionX(), self.m_clockBg:getPositionY())
		:addTo(self)

	self.m_clockMinute = cc.ui.UIImage.new("picdata/OperateDelay/t_fen.png")
		:align(display.BOTTOM_CENTER, self.m_clockBg:getPositionX(), self.m_clockBg:getPositionY())
		:addTo(self)

	self.m_hintNode = display.newNode()
		:align(display.CENTER, self.m_clockBg:getPositionX()-8, self.m_clockBg:getPositionY()+30)
		:addTo(self, 1)

	self.m_hintIcon = cc.ui.UIImage.new("picdata/OperateDelay/icon_zuan.png")
		:align(display.RIGHT_CENTER, -5, 0)
		:addTo(self.m_hintNode)

	self.m_hintLabel = cc.ui.UILabel.new({
		text = ""..self.price,
		font = "黑体",
		size = 20,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, -5, 0)
		:addTo(self.m_hintNode)
	self.m_hintIcon:setOpacity(0)
	self.m_hintLabel:setOpacity(0)

	self.m_infoNode = display.newNode()
		:align(display.CENTER, self.m_clockBg:getPositionX()-30, self.m_clockBg:getPositionY()+100)
		:addTo(self, 1)

	self.m_infoBg = cc.ui.UIImage.new("picdata/tourneyNew/bg_tips.png")
		:align(display.CENTER, 0, 0)
		:addTo(self.m_infoNode)
	self.m_infoBg:setRotation(180)

	self.m_infoLabel = cc.ui.UILabel.new({
		text = ""..info_text,
		font = "黑体",
		size = 20,
		color = cc.c3b(255,255,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, -110, 10)
		:addTo(self.m_infoNode)
	self.m_infoNode:setVisible(false)
end

function OperateDelay:showInfo()
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

function OperateDelay:menuCallBack()
	if self.params.callback then
		self.params.callback(self.price)
	end
	self:doAnimation()
end

function OperateDelay:doAnimation()
	self.m_light:setOpacity(100)
	self.m_light:setScale(0.8)
	self.m_hintIcon:setOpacity(100)
	self.m_hintLabel:setOpacity(100)
	self.m_hintIcon:setPositionY(0)
	self.m_hintLabel:setPositionY(0)
	transition.execute(self.m_light, cc.Sequence:create({cc.ScaleTo:create(self.animTime/2, 1.2),cc.FadeOut:create(self.animTime/2)}))
	transition.execute(self.m_clock, cc.Sequence:create({cc.ScaleTo:create(self.animTime/2, 1.2), cc.ScaleTo:create(self.animTime/2, 1.0)}))
	transition.execute(self.m_clockMinute, cc.RotateBy:create(0.2, -360))
	transition.execute(self.m_hintIcon, cc.Spawn:create({cc.MoveBy:create(self.animTime, cc.p(0,25)),cc.FadeOut:create(self.animTime)}))
	transition.execute(self.m_hintLabel, cc.Spawn:create({cc.MoveBy:create(self.animTime, cc.p(0,25)),cc.FadeOut:create(self.animTime)}))
end

function OperateDelay:updateApplyDelayTime(times)
	times = times or 0
	self.m_applyDelayTime = times
	self:getActualPrice()
	self:updatePrice()
end

function OperateDelay:getActualPrice()
	local value = 50
	for i=1,self.m_applyDelayTime do
		value = value*2
	end
	self.price = value
	return value
end

function OperateDelay:updatePrice()
	self.m_applyButton:setButtonLabelString("normal", ""..self.price)
	self.m_hintLabel:setString(""..self.price)
	self:stopAllActions()
	transition.execute(self, cc.DelayTime:create(13), {
			onComplete = function()
				self:setVisible(false)
			end,
		})
end

function OperateDelay:addApplyDelayTimes()
	self.m_applyDelayTime = self.m_applyDelayTime+1
	self:getActualPrice()
	self:updatePrice()
end

function OperateDelay:showDelayView(remainTime)
	self:setVisible(true)
	self:updateApplyDelayTime(0)
	self:stopAllActions()
	transition.execute(self, cc.DelayTime:create(remainTime), {
			onComplete = function()
				self:setVisible(false)
			end
		})
end

return OperateDelay