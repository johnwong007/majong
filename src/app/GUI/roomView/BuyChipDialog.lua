require("app.Logic.Config.UserDefaultSetting")
require("app.Tools.StringFormat")
local DialogBase = require("app.GUI.roomView.DialogBase")

local BuyChipDialog = class("BuyChipDialog", DialogBase)

function BuyChipDialog:dialog(pCallback, pCallbackFuc, max, min, userchips, bigblind, coinType, isAdd, deauftValue, needShowAutoBuySign)
	local dialog = BuyChipDialog:new()
	dialog.TargetSel=pCallback
	dialog.buySelector=pCallbackFuc
	if dialog:init(max, min, userchips, bigblind, coinType, isAdd, deauftValue, needShowAutoBuySign) then
		return dialog
	else
		dialog = nil
		return nil
	end
end

function BuyChipDialog:ctor()
	DialogBase:ctor()

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
end

function BuyChipDialog:init( max, min, userchips, bigblind, coinType, isAdd, deauftValue, needShowAutoBuySign)
	if max < min or bigblind <= 0 then
		return false
	end
    
	self:manualLoadxml()
	
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
	
	local temp = "我的账户余额:" .. StringFormat:FormatFloat(self.m_myCoin)
--	((CCLabelTTF*)GetCCNodeByID("zhanghuyue"))->setString(temp.c_str())
    
	temp = StringFormat:FormatDecimals(min,2)
	self.m_dialogLayer.m_zuixiaomairu:setString(temp)
    
	temp = StringFormat:FormatDecimals(max,2)
	self.m_dialogLayer.m_zuidamairu:setString(temp)

	local chipLabelPosX = self.m_dialogLayer.m_mr_label:getPositionX()
	local chipLabelPosY = self.m_dialogLayer.m_mr_label:getPositionY()
    -- self.chipLabel = cc.LabelBMFont:create(StringFormat:FormatDecimals(deauftValue, 2),"picdata/gamescene/chipNum.fnt")
    self.chipLabel = cc.LabelTTF:create(StringFormat:FormatDecimals(deauftValue, 2),"fonts/FZZCHJW--GB1-0.TTF", 45)
    self.chipLabel:setPosition(cc.p(chipLabelPosX,chipLabelPosY))
	self.chipLabel:setColor(cc.c3b(255,241,0))
	self.m_dialogLayer.m_zuidamairu:getParent():addChild(self.chipLabel,888)
	self.m_dialogLayer.m_mr_label:setVisible(false)
    
	self.m_dialogLayer.m_buyProgBG:setVisible(false)
	self.m_dialogLayer.m_buyProgress:setVisible(false)
	self.m_dialogLayer.m_buyChipsThumb:setVisible(false)

	local sliderSize = self.m_dialogLayer.m_buyProgress:getContentSize()
	local sliderImages = {bar="buyProgBG.png",button="buyChipsThumb.png"}
	local pSlider = cc.ui.UISlider.new(display.LEFT_TO_RIGHT, sliderImages)
	pSlider:onSliderValueChanged(handler(self,self.valueChange))
		:setSliderSize(sliderSize.width, sliderSize.height)
		:setSliderValue(50)
		:align(display.CENTER,self.m_dialogLayer.m_buyProgress:getPositionX(),
			self.m_dialogLayer.m_buyProgress:getPositionY())
		:addTo(self.m_dialogLayer.m_zuidamairu:getParent())
	self.m_pSlider = pSlider


	-- print(max)
	-- print(min)
	-- print(bigblind)
	if (((max - min)/bigblind) <= 0) then
		pSlider:setTouchEnabled(false)
	else
		local tmpTotalValue = max-min
		local tmpDefaultValue = ((deauftValue - min)*100/tmpTotalValue)
		if tmpDefaultValue > 100 then
			tmpDefaultValue = 100
		elseif tmpDefaultValue < 0 then
			tmpDefaultValue = 0
		end
		pSlider:setSliderValue(tmpDefaultValue)
	end
	
	self.m_dialogLayer.m_zidongmairu:setVisible(false)
	local checkBoxImages = {off="checkboxOff.png",on="checkboxOn.png"}
	local box = cc.ui.UICheckBoxButton.new(checkBoxImages)
	box:onButtonStateChanged(handler(self,self.pressZdmrButton))
		:align(display.RIGHT_CENTER,self.m_dialogLayer.m_zidongmairu:getPositionX(),
			self.m_dialogLayer.m_zidongmairu:getPositionY())
	box:addTo(self.m_dialogLayer.m_zuidamairu:getParent())
	
	local bselected = UserDefaultSetting:getInstance():getAutoBuyChip()
	box:setButtonSelected(bselected)
	self.m_bAutoBuyin = bselected
	
	self.m_dialogLayer.m_zuixiaomairu:setString(min.."")
	self.m_dialogLayer.m_zuidamairu:setString(max.."")

	self:setVisible(false)
	return true
end

function BuyChipDialog:manualLoadxml()
	-- cc.ui.UIImage.new("mrcz_tc_bg.png")
	-- 	:align(display.CENTER, display.cx, display.cy)
	-- 	:addTo(self)
	self.m_dialogLayer = require("app.GUI.roomView.BuyChipDialogLayer"):new()
	self:addChild(self.m_dialogLayer)
end

function BuyChipDialog:valueChange(event)
	self.m_currentValue = self.m_min+event.value*self.m_valuePerUnit
	self.chipLabel:setString(StringFormat:FormatDecimals(self.m_currentValue, 2).."")
end

function BuyChipDialog:button_click(tag)
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
    end
end

function BuyChipDialog:pressZdmrButton(event)
	local bCheck = event.target:isButtonSelected()
	self.m_bAutoBuyin = bCheck
end

return BuyChipDialog