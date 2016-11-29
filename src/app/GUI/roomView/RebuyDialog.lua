require("app.Tools.StringFormat")
local DialogBase = require("app.GUI.roomView.DialogBase")

eRebuyNothing = 0
eRebuyAddChips = 1
eRebuyCharge = 2
eRebuyTimeOutPassive = 3
eRebuyTimeOutManual = 4

local kQuitRebuyActionTag = 1235
local kManualQuitRebuyTag = 1236

local RebuyDialog = class("RebuyDialog", DialogBase)

function RebuyDialog:dialog(pCallback, pCallbackFuc, rebuyValue, rebuyAdd, bEnoughMoney, countDown, isAddon, payType)
	isAddon = isAddon and isAddon or false
	payType = payType and payType or "GOLD"
	self.payType = payType
	local dialog = RebuyDialog:new()
	dialog.TargetSel=pCallback
	dialog.buySelector=pCallbackFuc
	dialog:init(rebuyValue, rebuyAdd, bEnoughMoney, countDown,isAddon,payType)
	return dialog
end

function RebuyDialog:ctor()
	self.m_limitTime = 0
	self.m_countDown = 0
    
	self.m_bManulAction = false
    
    self.addLabel = nil
	self.TargetSel = nil	--调用者指针
	self.buySelector = nil--调用者 需要的函数指针
end

function RebuyDialog:init(rebuyValue, rebuyAdd, bEnoughMoney, countDown, isAddon, payType)
	-- payType = "POINT"
	self.payType = payType
	self:manualLoadxml()
	self.m_limitTime = countDown
	self.m_countDown = countDown
    
    self.addLabel = cc.LabelBMFont:create(StringFormat:FormatDecimals(rebuyAdd, 2),"picdata/gamescene/chipNum.fnt")
    self.addLabel:setPosition(cc.p(480, 425))
    self.m_node:addChild(self.addLabel,1)
    local pay
    if (payType == "RAKEPOINT") then
        pay="支付积分:"
    elseif  (payType == "POINT") then
        pay="支付德堡钻:"
    else
        pay="支付金币:"
    end
	self.rebuyvalue:setString(pay..rebuyValue)
    local title = self.dialogTitle
	if (isAddon) then
		if(not bEnoughMoney) then
		
			self.noenough:setVisible(true)
            title:setString("余额不足")

		else
		
			self.addmore:setVisible(true)
            title:setString("最终加码")

		end
    else 
		if(not bEnoughMoney) then
		
			self.noenough:setVisible(true)
            title:setString("余额不足")
		else
		
			self.addmore:setVisible(true)
            title:setString("重购")
		end
	end
    
	if (countDown > 0) then
	
		self.m_bManulAction = false
		self.quittip:setVisible(true)
		self.countdown:setVisible(true)
        
		local countLabel = self.countdown
		local count = countDown .. "s"
		countLabel:setString(count)
        
		local time = cc.DelayTime:create(1.0)
		local action = cc.CallFunc:create(handler(self, self.countDownLimitTime))
		local seq =  cc.Sequence:create(time, action)
		local repeatAct = cc.Repeat:create(seq, countDown+2)
		repeatAct:setTag(kQuitRebuyActionTag)
		self:runAction(repeatAct)
	else
	
		self.m_bManulAction = true
		self.addtipinfo:setVisible(true)
		local seq = cc.Sequence:create(cc.DelayTime:create(15), cc.CallFunc:create(handler(self, self.manualRebuyTimeOut)))
		seq:setTag(kManualQuitRebuyTag)
		self:runAction(seq)
        
	end
    
	
    
	return true
end

function RebuyDialog:manualLoadxml()
	self.background = cc.ui.UIImage.new("rebuyBG.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	local width = 490
	local height = 320
	self.m_node = display.newNode()
	self.m_node:addTo(self)
	self.m_node:setContentSize(self.background:getContentSize())
	self.m_node:setPosition(self.background:getPositionX()-width, self.background:getPositionY()-height)

	self.rebuyvalue = cc.ui.UILabel.new({
		text = "",
		font = "黑体",
		size = 28,
		color = cc.c3b(0,214,186),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, 480, 300)
		:addTo(self.m_node)

	self.cancel = cc.ui.UIPushButton.new({normal="btn_2_close.png", pressed="btn_2_close2.png", disabled="btn_2_close2.png"})
		:align(display.CENTER, 811, 533)
		:addTo(self.m_node, 1)
		:onButtonClicked(function(event)
			self:button_click("cancel")
			end)

	self.dialogTitle = cc.ui.UILabel.new({
		text = "",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 36,
		color = cc.c3b(218,197,152),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, 480, 498)
		:addTo(self.m_node)
	--------------------------------------------------
	self.addmore = display.newNode()
	self.addmore:addTo(self.m_node)
	self.addmore:setVisible(false)
	
		cc.ui.UIImage.new("picdata/tourney/rebuyChipsIcon.png")
			:align(display.CENTER, 240, 410)
			:addTo(self.addmore)

	-- if self.payType and self.payType=="POINT" then
	-- 	local iconDbz = cc.ui.UIImage.new("picdata/public2/icon_dbz.png")
	-- 	iconDbz:align(display.CENTER, 240, 410)
	-- 		:addTo(self.addmore)
	-- 	iconDbz:setScale(1.4)
	-- else
	-- 	cc.ui.UIImage.new("picdata/tourney/rebuyChipsIcon.png")
	-- 		:align(display.CENTER, 240, 410)
	-- 		:addTo(self.addmore)
	-- end

	self.addmorebutton = cc.ui.UIPushButton.new({normal="rebuyBtn.png", pressed="rebuyBtn.png", disabled="rebuyBtn.png"})
		:align(display.CENTER, 480, 222)
		:addTo(self.addmore, 1)
		:onButtonClicked(function(event)
			self:button_click("addmorebutton")
			end)	
	--------------------------------------------------
	self.noenough = display.newNode()
	self.noenough:addTo(self.m_node)
	self.noenough:setVisible(false)


	if self.payType == "POINT" then
		self.noenoughmoneybutton = cc.ui.UIPushButton.new({normal="picdata/public/btn_green.png", 
			pressed="picdata/public/btn_green2.png", 
			disabled="picdata/public/btn_green2.png"})
		self.noenoughmoneybutton:align(display.CENTER, 480, 162)
			:addTo(self.noenough, 1)
			:onButtonClicked(function(event)
				self:button_click("noenoughmoneybutton")
				end)
			-- :setTouchSwallowEnabled(false)

		local label = cc.ui.UILabel.new({
			text = "充值德堡钻",
			font = "黑体",
			size = 26,
			color = cc.c3b(215,255,178)
			})
	    label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
		self.noenoughmoneybutton:setButtonLabel("normal", label)
	else
		self.noenoughmoneybutton = cc.ui.UIPushButton.new({normal="buyGoldBtn.png", pressed="buyGoldBtn.png", disabled="buyGoldBtn.png"})
			:align(display.CENTER, 480, 162)
			:addTo(self.noenough, 1)
			:onButtonClicked(function(event)
				self:button_click("noenoughmoneybutton")
				end)
	end

	self.addtipinfo = cc.ui.UILabel.new({
		text = "在限定时间内筹码小于初始筹码时可以重新买入。",
		font = "Arial",
		size = 22,
		color = cc.c3b(117,117,128),
		align = cc.TEXT_ALIGNMENT_CENTER,
		dimensions = cc.size(600, 400)
		})
		:align(display.CENTER, 480, 148)
		:addTo(self.noenough)
	self.addtipinfo:setVisible(false)

	self.quittip = cc.ui.UILabel.new({
		text = "离场倒计时:",
		font = "Arial",
		size = 22,
		color = cc.c3b(117,117,128),
		align = cc.TEXT_ALIGNMENT_CENTER,
		-- dimensions = cc.size(370, 400)
		})
		:align(display.CENTER, 470, 148)
		:addTo(self.noenough)
	self.quittip:setVisible(false)

	self.countdown = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 22,
		color = cc.c3b(238,238,255),
		align = cc.TEXT_ALIGNMENT_LEFT,
		-- dimensions = cc.size(370, 400)
		})
		:align(display.CENTER, 550, 148)
		:addTo(self.noenough)
	self.countdown:setVisible(false)
end

function RebuyDialog:manualRebuyTimeOut()

	self:stopActionByTag(kManualQuitRebuyTag)
	if (self.TargetSel and self.buySelector) then
	
		self.buySelector(eRebuyTimeOutManual)
	end
	self:remove()
end

function RebuyDialog:countDownLimitTime()

	local label = self.countdown
	if (label) then
		if (self.m_countDown < 0) then
		
			self:stopActionByTag(kQuitRebuyActionTag)
			if (self.TargetSel and self.buySelector) then
			
				self.buySelector(eRebuyTimeOutPassive)
			end
			self:remove()
		else
		
			label:setString(self.m_countDown.."s")
		end
	end
end

function RebuyDialog:button_click(tag)
	self:stopAllActions()
	if (tag == "rebuyclose") or (tag == "cancel") then
		if (self.TargetSel and self.buySelector) then
			self.buySelector(eRebuyNothing)
		end
		-- self:remove()
	elseif (tag == "noenoughmoneybutton") then
		if (self.TargetSel and self.buySelector) then
			self.buySelector(eRebuyCharge, self.payType)
		end
		-- self:remove()
	elseif (tag == "addmorebutton") then
		if (self.TargetSel and self.buySelector) then
			self.buySelector(eRebuyAddChips)
		end
		-- self:remove()
	end
end

return RebuyDialog