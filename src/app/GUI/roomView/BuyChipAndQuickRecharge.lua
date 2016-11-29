require("app.Logic.Config.UserDefaultSetting")
require("app.Tools.StringFormat")
local myInfo = require("app.Model.Login.MyInfo")
local DialogBase = require("app.GUI.roomView.DialogBase")
local MusicPlayer = require("app.Tools.MusicPlayer")

local ShowBuyChip = 0
local ShowQuickRecharge = 1
local slider_ratio = {50,100,150,200}

local BuyChipAndQuickRecharge = class("BuyChipAndQuickRecharge", function(event)
        return DialogBase:new()
    end)

function BuyChipAndQuickRecharge:dialog(pCallback, pCallbackFuc, max, min, userchips, bigblind, coinType, isAdd, deauftValue, needShowAutoBuySign, currentShow, serviceCharge, isPriTable)
	
	-- dump(max)
	-- dump(min)
	-- dump(userchips)
	-- dump(bigblind)
	-- dump(coinType)
	-- dump(isAdd)
	-- dump(deauftValue)
	-- dump(needShowAutoBuySign)
	-- dump(currentShow)
	local dialog = BuyChipAndQuickRecharge:new()
	dialog.TargetSel=pCallback
	dialog.buySelector=pCallbackFuc
	dialog:initBuyChipView(max, min, userchips, bigblind, coinType, isAdd, deauftValue, needShowAutoBuySign, serviceCharge, isPriTable)
	dialog:initQuickRechargeView()
	if type(currentShow)~="number" or currentShow~=1 then
		currentShow = 0
	end
	dialog.m_currentShow = currentShow

	dialog:swithLayer()
	return dialog
end

--[[payType:"GOLD"(金币)、"POINT"(德堡钻)]]
function BuyChipAndQuickRecharge:setPayType(payType)
	self.payType = payType
	self.m_rechargeOption:setPayType(self.payType)
	self.m_rechargeOption:createListView()
end

function BuyChipAndQuickRecharge:ctor()
	self.m_userChip = 0.0
	self.m_myCoin = 0.0
	self.m_isAddChips = false
	self.m_bigBlind = 0.0
    
	self.m_bAutoBuyin = false
    
	self.m_bNeedShowAutoSign = false
    
	self.m_max = 0.0
	self.m_min = 0.0
	self.m_valuePerUnit = 0
	self.m_currentValue = 0
    
	self.m_pSlider = nil
    
	self.TargetSel = nil	--[[调用者指针]]
	self.buySelector = nil --[[调用者 需要的函数指针]]
    self.chipLabel = nil

    self.m_sliderValue = nil

	self:manualLoadxml()

	MusicPlayer:getInstance():playDialogOpenSound()
end

function BuyChipAndQuickRecharge:initBuyChipView(max, min, userchips, bigblind, coinType, isAdd, deauftValue, needShowAutoBuySign, serviceCharge, isPriTable)
	if max < min or bigblind <= 0 then
		return false
	end
	self.isPriTable = isPriTable
	self.serviceCharge = serviceCharge
	self.m_isAddChips=isAdd
	self.m_userChip = userchips
	self.m_bigBlind = bigblind
	self.m_max = max
	self.m_min = min
	self.m_currentValue = deauftValue
	self.m_valuePerUnit = (max-min)/100
	self.m_bNeedShowAutoSign = not UserDefaultSetting:getInstance():getAutoBuyChip() and needShowAutoBuySign
    
	local type = coinType == kGold and "金币" or "银币"
	self.m_myCoin = self.m_userChip-- coinType == kGold ? MyInfo::shareInstance()->userGoldCoin:MyInfo::shareInstance()->userSliverCoin
	
	local temp = "我的账户余额:" .. StringFormat:FormatDecimals(self.m_myCoin, 2)
--	((CCLabelTTF*)GetCCNodeByID("zhanghuyue"))->setString(temp.c_str())
    
	temp = StringFormat:FormatDecimals(min,2)
	self.m_zuixiaomairu:setString(temp)

	temp = StringFormat:FormatDecimals(max,2)
	self.m_zuidamairu:setString(temp)
	
	local chipLabelPosX = self.m_mr_label:getPositionX()
	local chipLabelPosY = self.m_mr_label:getPositionY()
    -- self.chipLabel = cc.LabelBMFont:create(StringFormat:FormatDecimals(deauftValue, 2),"picdata/gamescene/chipNum.fnt")
    self.chipLabel = cc.LabelTTF:create(StringFormat:FormatDecimals(deauftValue, 2),"fonts/FZZCHJW--GB1-0.TTF", 45)
    self.chipLabel:setPosition(cc.p(chipLabelPosX,chipLabelPosY))
	self.chipLabel:setColor(cc.c3b(255,241,0))
	self.m_zuidamairu:getParent():addChild(self.chipLabel,888)
	self.m_mr_label:setVisible(false)

	if not isPriTable then
		self.m_pSlider = cc.ControlSlider:create("picdata/gamescene/buyProgress.png", "picdata/gamescene/buyProgressed.png", "picdata/gamescene/buyChipsThumb.png")
		self.m_pSlider:registerControlEventHandler(handler(self,self.valueChange), cc.CONTROL_EVENTTYPE_VALUE_CHANGED) 
		self.m_pSlider:setMaximumValue(100)
		self.m_pSlider:setMinimumValue(0)
		self.m_pSlider:setValue(50)
		self.m_pSlider:setPosition(display.cx, display.cy+40)
		self.m_zuidamairu:getParent():addChild(self.m_pSlider, 1)
		dump("================>")
		dump(max - min)
		if (((max - min)/bigblind) <= 0) then
			dump("================>")
			self.m_pSlider:setTouchEnabled(false)
			self.m_pSlider:setEnabled(false)
		else
			local tmpTotalValue = max-min
			local tmpDefaultValue = ((deauftValue - min)*100/tmpTotalValue)
			if tmpDefaultValue > 100 then
				tmpDefaultValue = 100
			elseif tmpDefaultValue < 0 then
				tmpDefaultValue = 0
			end
			self.m_pSlider:setValue(tmpDefaultValue)
		end
	else
		self.m_sliderValue = {}
		self.m_sliderValue[1] = min
		if min<self.m_bigBlind*slider_ratio[2] then
			for i=2,#slider_ratio do
				if max<self.m_bigBlind*slider_ratio[i] then
					self.m_sliderValue[#self.m_sliderValue+1] = max
					break
				else
					self.m_sliderValue[#self.m_sliderValue+1] = self.m_bigBlind*slider_ratio[i]
				end
			end
		elseif min<self.m_bigBlind*slider_ratio[3] then
			for i=3,#slider_ratio do
				if max<self.m_bigBlind*slider_ratio[i] then
					self.m_sliderValue[#self.m_sliderValue+1] = max
					break
				else
					self.m_sliderValue[#self.m_sliderValue+1] = self.m_bigBlind*slider_ratio[i]
				end
			end
		elseif min<self.m_bigBlind*slider_ratio[4] then
			for i=4,#slider_ratio do
				if max<self.m_bigBlind*slider_ratio[i] then
					self.m_sliderValue[#self.m_sliderValue+1] = max
					break
				else
					self.m_sliderValue[#self.m_sliderValue+1] = self.m_bigBlind*slider_ratio[i]
				end
			end
		end

		self.m_pSlider = require("app.GUI.dialogs.CommonSlider").new({
	        bgFile = "picdata/gamescene/buyProgress.png", 
	        progressFile = "picdata/gamescene/buyProgressed.png", 
	        thumbFile = "picdata/gamescene/buyChipsThumb.png",
	        position = cc.p(display.cx, display.cy+40),
	        sliderDotNum = #self.m_sliderValue,
	        valueChangedCallback = function(value) self:updateCurrentValue(value) end
			})
		self.m_pSlider:addTo(self.m_zuidamairu:getParent(), 1)
		self.m_pSlider:create()
		if #self.m_sliderValue>1 then
			-- self.m_pSlider:setValue(1)
			-- self:updateCurrentValue(1)
		end
	end

	cc.ui.UIImage.new("buyProgBG.png")
		:align(display.CENTER, display.cx, display.cy+40)
		:addTo(self.m_zuidamairu:getParent())

	local checkBoxImages = {off="checkboxOff.png",on="checkboxOn.png"}
	local box = cc.ui.UICheckBoxButton.new(checkBoxImages)
	box:onButtonStateChanged(handler(self,self.pressZdmrButton))
		:align(display.RIGHT_CENTER, display.cx-240, 270)
	box:addTo(self.m_buyChipsBG)
	
	local bselected = UserDefaultSetting:getInstance():getAutoBuyChip()
	box:setButtonSelected(bselected)
	self.m_bAutoBuyin = bselected

	self.serviceCharge = tonumber(self.serviceCharge)
	local hint = "无服务费"
	if self.serviceCharge and self.serviceCharge>0 then
		hint = "买入同时需支付("..self.serviceCharge.."%买入金币)服务费"
	end
	self.m_buyinHint:setString(hint)

	self:setVisible(false)
	return true
end

function BuyChipAndQuickRecharge:initQuickRechargeView()

end

function BuyChipAndQuickRecharge:manualLoadxml()
	cc.ui.UIImage.new("mrcz_tc_bg.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	self.cancel = cc.ui.UIPushButton.new({normal="btn_2_close.png", pressed="btn_2_close2.png", disabled="btn_2_close2.png"})
		:align(display.CENTER, display.cx+330, display.cy+221)
		:addTo(self, 3)
	self.cancel:onButtonClicked(function(event)
			self:button_click("cancel")
		end)

	self.m_buyChipButton = cc.ui.UIPushButton.new({normal="btn_mr2.png", pressed="btn_mr2.png", disabled="btn_mr2.png"})
		:align(display.CENTER, display.cx-264, display.cy+265)
		:addTo(self, 3)
	self.m_buyChipButton:onButtonClicked(function(event)
			self:button_click("buyChip")
		end)

	self.m_quickRechargeButton = cc.ui.UIPushButton.new({normal="btn_kscz.png", pressed="btn_kscz.png", disabled="btn_kscz.png"})
		:align(display.CENTER, self.m_buyChipButton:getPositionX()+175, self.m_buyChipButton:getPositionY())
		:addTo(self, 3)
	self.m_quickRechargeButton:onButtonClicked(function(event)
			self:button_click("quickRecharge")
		end)
	----------------------------------------------------------------------
	self.m_buyChipsBG = display.newNode()
	self.m_buyChipsBG:addTo(self, 1)
	-- self.m_buyChipsBG:setVisible(false)
	
	cc.ui.UIImage.new("mrcz_tc_mr.png")
		:align(display.CENTER, display.cx, display.cy+100)
		:addTo(self.m_buyChipsBG)

	self.m_zxmr_label = cc.ui.UILabel.new({
		text = "最小",
		font = "黑体",
		size = 26,
		color = cc.c3b(0,214,186),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, display.cx-250, display.cy+140)
		:addTo(self.m_buyChipsBG, 1)

	self.m_zdmr_label = cc.ui.UILabel.new({
		text = "最大",
		font = "黑体",
		size = 26,
		color = cc.c3b(0,214,186),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, display.cx+120, display.cy+140)
		:addTo(self.m_buyChipsBG, 1)

	self.m_zuixiaomairu = cc.ui.UILabel.new({
		text = "0",
		font = "Arial",
		size = 26,
		color = cc.c3b(0,214,186),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, display.cx-250, display.cy+140)
		:addTo(self.m_buyChipsBG, 1)

	self.m_zuidamairu = cc.ui.UILabel.new({
		text = "0",
		font = "Arial",
		size = 26,
		color = cc.c3b(0,214,186),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, display.cx+125, display.cy+140)
		:addTo(self.m_buyChipsBG, 1)

	self.m_mr_label = cc.ui.UILabel.new({
		text = "8000",
		font = "Arial",
		size = 28,
		color = cc.c3b(0,214,186),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, display.cx-40, display.cy+150)
		:addTo(self.m_buyChipsBG, 1)

	cc.ui.UIPushButton.new({normal="buyChipBtn.png", pressed="buyChipBtn.png", disabled="buyChipBtn.png"})
		:align(display.CENTER, display.cx+137, display.cy-157)
		:onButtonClicked(function(event)
			self:button_click("mairuchouma")
		end)
		:addTo(self.m_buyChipsBG, 1)

	cc.ui.UIPushButton.new({normal="cancelBuy.png", pressed="cancelBuy.png", disabled="cancelBuy.png"})
		:align(display.CENTER, display.cx-137, display.cy-157)
		:onButtonClicked(function(event)
			self:button_click("buyclose")
		end)
		:addTo(self.m_buyChipsBG, 1)
	
	self.m_buychiptip = cc.ui.UILabel.new({
		text = "当筹码为0时自动买入",
		font = "黑体",
		size = 26,
		color = cc.c3b(135,154,192),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, display.cx-240, 270)
		:addTo(self.m_buyChipsBG, 1)

	self.serviceCharge = tonumber(self.serviceCharge)
	local hint = "无服务费"
	if self.serviceCharge and self.serviceCharge>0 then
		hint = "买入同时需支付("..self.serviceCharge.."%买入金币)服务费"
	end
	self.m_buyinHint = cc.ui.UILabel.new({
		text = hint,
		font = "黑体",
		size = 24,
		color = cc.c3b(205,0,0),
		align = cc.TEXT_ALIGNMENT_RIGHT
		})
		:align(display.RIGHT_CENTER, 740, 220)
		:addTo(self.m_buyChipsBG, 1)

	----------------------------------------------------------------------
	self.m_quickRechargeBG = display.newNode()
	self.m_quickRechargeBG:addTo(self, 1)
	self.m_quickRechargeBG:setVisible(false)

	self.m_rechargeOption = require("app.GUI.dialogs.RechargeOptionInDialog").new({parent = self, isPriTable = self.isPriTable})
	self.m_quickRechargeBG:addChild(self.m_rechargeOption)
	self:setPosition(LAYOUT_OFFSET)
end

function BuyChipAndQuickRecharge:swithLayer()
	if self.m_currentShow == ShowBuyChip then
    	self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "btn_mr2.png")
    	self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "btn_mr2.png")
    	self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "btn_mr2.png")
    	self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "btn_kscz.png")
    	self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "btn_kscz.png")
    	self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "btn_kscz.png")
    	self.m_buyChipsBG:setVisible(true)
    	self.m_quickRechargeBG:setVisible(false)
    	if self.m_pSlider then
    		if (self.m_max - self.m_min) > 0 then
    			self.m_pSlider:setEnabled(true)
    		end
    	end
	elseif self.m_currentShow == ShowQuickRecharge then
    	self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "btn_mairu.png")
    	self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "btn_mairu.png")
    	self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "btn_mairu.png")
    	self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "btn_kscz2.png")
    	self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "btn_kscz2.png")
    	self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "btn_kscz2.png")
    	self.m_buyChipsBG:setVisible(false)
    	self.m_quickRechargeBG:setVisible(true)
    	if self.m_pSlider then
    		self.m_pSlider:setEnabled(false)
    	end
	end
end

function BuyChipAndQuickRecharge:valueChange(event)
	if event==nil then
	end
	self.m_currentValue = self.m_min+event:getValue()*self.m_valuePerUnit
	self.chipLabel:setString(StringFormat:FormatDecimals(self.m_currentValue, 2).."")
end

function BuyChipAndQuickRecharge:updateCurrentValue(value)
	self.m_currentValue = self.m_sliderValue[value+1]
	self.chipLabel:setString(StringFormat:FormatDecimals(self.m_currentValue, 2).."")
end

function BuyChipAndQuickRecharge:button_click(tag)
	MusicPlayer:getInstance():playDialogCloseSound()
    if tag == "buyclose" or tag=="cancel" then
    	if self.TargetSel and self.buySelector then
            self.buySelector(-1, self.m_bAutoBuyin, self.m_isAddChips)
            UserDefaultSetting:getInstance():setAutoBuyChip(self.m_bAutoBuyin)
        end
        self:remove()
    elseif tag == "mairuchouma" then
    	if self.TargetSel and self.buySelector then
    		self.buySelector(self.m_currentValue, self.m_bAutoBuyin, self.m_isAddChips)
    		UserDefaultSetting:getInstance():setAutoBuyChip(self.m_bAutoBuyin)
    	end
    	self:remove()
    elseif tag == "buyChip" then
    	if self.m_currentShow == ShowQuickRecharge then
    
    -- 		if self.m_currentShow == 1 and not self.m_isAddChips then

				-- local text = "请先坐下才能补充更多筹码"
				-- local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = false})
 			-- 	CMOpen(CMToolTipView,self)
 			-- 	return
    -- 		end

    		self.m_currentShow = ShowBuyChip
    		self:swithLayer()
    	end
    elseif tag == "quickRecharge" then
    	if self.m_currentShow == ShowBuyChip then
    		-- self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "btn_mairu.png")
    		-- self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "btn_mairu.png")
    		-- self.m_buyChipButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "btn_mairu.png")
    		-- self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "btn_kscz2.png")
    		-- self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "btn_kscz2.png")
    		-- self.m_quickRechargeButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "btn_kscz2.png")
    		-- self.m_buyChipsBG:setVisible(false)
    		-- self.m_quickRechargeBG:setVisible(true)

    		self.m_currentShow = ShowQuickRecharge
    		self:swithLayer()
    	end
    end
end

function BuyChipAndQuickRecharge:pressZdmrButton(event)
	local bCheck = event.target:isButtonSelected()
	self.m_bAutoBuyin = bCheck
end

return BuyChipAndQuickRecharge