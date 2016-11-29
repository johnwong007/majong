C_FOLD_CARD = "弃牌"
C_CALL_CARD = "跟注"
C_CHECK_CARD = "看牌"
C_ALLIN_CARD = "全下"
C_RAISE_CARD = "加注"
C_FOLD_OR_CHECK_CARD = "弃或看"
C_CALL_ANYWAY_CARD = "跟任何注"
C_COME_BACK_SEAT = "我回来了"
C_FAST_FOLD_CARD = "快速弃牌"

--预选按钮
C_CHECK_BUTTON_NORMAL  = "picdata/gamescene/button_7_up_caozuoanniu_android.png" --
C_CHECK_BUTTON_SELECT  = "picdata/gamescene/button_7_down_caozuoanniu_android.png" --
C_CHECK_BUTTON_BG_PIC = "picdata/gamescene/button_7_empty_caozuoanniu_android.png"

OPERATE_BOARD_ALLIN_UP ="picdata/table/allinBtn.png"--按钮正常状态
OPERATE_BOARD_ALLIN_DOWN ="picdata/table/allinBtn1.png"--按钮正常状态
OPERATE_BOARD_CALL_UP ="picdata/table/callBtn.png"--按钮正常状态
OPERATE_BOARD_CALL_DOWN ="picdata/table/callBtn1.png"--按钮按下状态
OPERATE_BOARD_CHECK_UP ="picdata/table/checkBtn.png"--按钮正常状态
OPERATE_BOARD_CHECK_DOWN ="picdata/table/checkBtn1.png"--按钮按下状态
OPERATE_BOARD_RAISE_UP ="picdata/table/raiseBtn.png"--按钮正常状态
OPERATE_BOARD_RAISE_DOWN ="picdata/table/raiseBtn1.png"--按钮按下状态
OPERATE_BOARD_FOLD_UP ="picdata/table/foldBtn.png"--弃牌按钮正常状态
OPERATE_BOARD_FOLD_DOWN ="picdata/table/foldBtn1.png"--弃牌按钮按下状态
OPERATE_BOARD_RAISENUM_UP ="picdata/table/raiseNumBtn.png"--滑动条右侧加注按钮正常状态
OPERATE_BOARD_RAISENUM_DOWN ="picdata/table/raiseNumBtn1.png"--滑动条右侧加注按钮按下状态

OPERATE_BOARD_RAISEBTN_UP ="picdata/table/btn_qadd2.png"--滑动条左侧加注按钮正常状态
OPERATE_BOARD_RAISEBTN_DOWN ="picdata/table/btn_qadd2_2.png"--滑动条左侧加注按钮按下状态


OPERATE_CHECKBOX_CA_NOT_SELECTED ="picdata/table/caCheckbox.png"
OPERATE_CHECKBOX_CA_SELECTED ="picdata/table/caCheckbox1.png"
OPERATE_CHECKBOX_CO_NOT_SELECTED ="picdata/table/coCheckbox.png"
OPERATE_CHECKBOX_CO_SELECTED ="picdata/table/coCheckbox1.png"
OPERATE_CHECKBOX_F_NOT_SELECTED ="picdata/table/fCheckbox.png"
OPERATE_CHECKBOX_F_SELECTED ="picdata/table/fCheckbox1.png"
OPERATE_CHECKBOX_BG ="picdata/table/btn_pre.png"
OPERATE_CHECKBOX_SELECTED ="picdata/table/btn_pre2.png"
OPERATE_BOARD_SELF_BACK_DOWN ="picdata/table/selfBack.png"
OPERATE_BOARD_SELF_BACK_UP ="picdata/table/selfBack.png"

zOpback = 0
zOpButton = 1

--[[OBNewerGuide]]
	kOBNGNone = 0
	kOBNGFlopRaise = 1
	kOBNGPocketRaise = 2

--[[显示面板类型]]
		kTypeNone = 0
		kTypeComeback = 1
		kTypeFoldCheckRaise = 3
		kTypeFoldCallRaise = 4
		kTypeFoldAllInRaise = 5
		kTypeCheckBox = 6
        kTypeRaise = 7

--[[按钮操作类型]]
        kTagComeback = 0 
		kTagFold = 1 
		kTagCheck = 2 
		kTagRaise = 3 
		kTagAllIn = 4 
		kTagCall = 5 
		kTagAdvanceFold = 6 
		kTagAdvanceCallFold = 7 
		kTagAdvanceCallAnyway = 8 
        kTagAdvanceFastFold = 9 
        kTagAdvanceCheck = 10 
        kTagAdvanceCall = 11 
        kTagCallSlider = 12 
        kTagQuickRaise1 = 13 
        kTagQuickRaise2 = 14 
        kTagQuickRaise3 = 15 

local OperateBoard = class("OperateBoard", function()
		return display.newNode()
	end)

function OperateBoard:create(isRushRoom)
	isRushRoom = isRushRoom or false
	local p = OperateBoard:new()
	p:init(isRushRoom)
	return p
end

function OperateBoard:ctor()
	self.m_bHasCallback = false
	self.m_fRaiseNum = 0
	self.m_AdvanceIndex = -1
    self._pot = 0
    self.m_extra = 0
    self._moveValue = 0
    self.m_betChips = -1
    self._max = 0

    self._mCallAnywayType = 0
end

	--类型
	--0:回座  --1:弃牌  --2:看牌
	--3:加注  --4:全下  --5:跟注
function OperateBoard:getClickType() 
	return self.m_nClickType
end
    
	--加注数量
function OperateBoard:getRaiseNum()
	return self.m_fRaiseNum
end

--获取预选按钮索引
function OperateBoard:getSelectedCheckBoxIndex() 
	return self.m_AdvanceIndex
end

--获取当前面板
	--0:None 1:comeback 2:fold_check_raise 3:fold_call_raise 4:allIn_raise 5:checkbox
function OperateBoard:getCurrentType()
	return self.m_eCurrent+0
end
    
function OperateBoard:setRaiseSliderEnabled(isEnabled) 
	self.m_raiseSlider:setEnabled(isEnabled)
end

function OperateBoard:init(isRushRoom)
	self:manualLoadxml()
	self:initCheckGroup()
	self:initRaiseSlider()
	self.m_boolIsRushRoom = isRushRoom

	self:initFoldCallRaise()
	self:initFoldCheckRaise()
	self:initFoldAllInRaise()
	self:initComebackSeat()
end

function OperateBoard:manualLoadxml()
	self.pool_raise_background = cc.ui.UIImage.new("operateBG.png")
	-- self.pool_raise_background:align(display.CENTER, 480,41)
	self.pool_raise_background:align(display.CENTER, 480,4100)
		:addTo(self, zOpback)
		:setVisible(false)
	self.pool_raise_background:setScaleX(SCREEN_IPHONE5 and 1.183 or 1)

	self.player_operate_button_layer = display.newNode()
	self.player_operate_button_layer:addTo(self, zOpback)
		-- :setVisible(false)
	self.pool_raise_button_layer = display.newNode()
	self.pool_raise_button_layer:addTo(self, zOpback)
		-- :setVisible(false)

	self.max = cc.ui.UIPushButton.new({normal="allinBtn.png",pressed="allinBtn1.png",disabled="allinBtn1.png"})
	self.max:align(display.LEFT_BOTTOM, display.width-184-10, 2)
		:addTo(self.pool_raise_button_layer, 2)
		:onButtonClicked(function() self:button_click(999) end)
end

function OperateBoard:button_click(tag)
	if tag == 102 then --[[1/2 pool]]
		self:raise(0.5 * self._pot + self.m_extra)
	elseif tag == 203 then --[[2/3 pool]]
		self:raise(2.0 / 3 * self._pot + self.m_extra)
	elseif tag == 100 then --[[底池]]
		self:raise(self._pot + self.m_extra)
	elseif tag == 999 then --[[最大]]
		self:raise(self._max)
	elseif tag == 998 then --[[最小]]
		self:raise(self._min)
	elseif tag == 103 then --[[3个大盲]]
		self:raise(3 * self._moveValue)
	elseif tag == 104 then --[[4个大盲]]
		self:raise(4 * self._moveValue)
	elseif tag == 101 then --[[2个大盲]]
		self:raise(2 * self._moveValue)
	end
end

function OperateBoard:initCheckGroup()
	local SPACEC_WIDTH = 164
	local RADIO_BUTTON_IMAGES = {
    off = "btn_pre.png",
    off_pressed = "btn_pre2.png",
    off_disabled = "btn_pre.png",
    on = "btn_pre2.png",
    on_pressed = "btn_pre.png",
    on_disabled = "btn_pre2.png",}

    local tempPosX = display.width

    self.m_pAdvanceF = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
			:setButtonLabel(cc.ui.UILabel.new({text="弃牌",font="fonts/FZZCHJW--GB1-0.TTF",size=26}))
			:setButtonLabelOffset(20, 0)
			:setButtonLabelAlignment(display.CENTER)
			:align(display.CENTER,-190-190-120+tempPosX,29)
			:onButtonStateChanged(function(event)
					self:doAfterClickButton(kTagAdvanceFold)
				end)
			:addTo(self,4)

	self.m_pAdvanceCheck = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
			:setButtonLabel(cc.ui.UILabel.new({text="看牌",font="fonts/FZZCHJW--GB1-0.TTF",size=26}))
			:setButtonLabelOffset(20, 0)
			:setButtonLabelAlignment(display.CENTER)
			:align(display.CENTER,-190-120+tempPosX,29)
			:onButtonStateChanged(function(event)
					self:doAfterClickButton(kTagAdvanceCheck)
				end)
			:addTo(self,4)

	self.m_pAdvanceCOF = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
			:setButtonLabel(cc.ui.UILabel.new({text="看或弃",font="fonts/FZZCHJW--GB1-0.TTF",size=26}))
			:setButtonLabelOffset(20, 0)
			:setButtonLabelAlignment(display.CENTER)
			:align(display.CENTER,-190-190-120+tempPosX,29)
			:onButtonStateChanged(function(event)
					self:doAfterClickButton(kTagAdvanceCallFold)
				end)
			:addTo(self,4)

	self.m_pAdvanceCall = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
			:setButtonLabel(cc.ui.UILabel.new({text="跟",font="fonts/FZZCHJW--GB1-0.TTF",size=26}))
			:setButtonLabelOffset(20, 0)
			:setButtonLabelAlignment(display.CENTER)
			:align(display.CENTER,-190-120+tempPosX,29)
			:onButtonStateChanged(function(event)
					self:doAfterClickButton(kTagAdvanceCall)
				end)
			:addTo(self,4)

	self.m_pAdvanceCA = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
			:setButtonLabel(cc.ui.UILabel.new({text="跟任意注",font="fonts/FZZCHJW--GB1-0.TTF",size=26}))
			:setButtonLabelOffset(20, 0)
			:setButtonLabelAlignment(display.CENTER)
			:align(display.CENTER,-120+tempPosX,29)
			:onButtonStateChanged(function(event)
					self:doAfterClickButton(kTagAdvanceCallAnyway)
				end)
			:addTo(self,4)

	-- self.m_pAdvanceCA1 = cc.ui.UICheckBoxButton.new(RADIO_BUTTON_IMAGES)
	-- 		:setButtonLabel(cc.ui.UILabel.new({text="跟任意注",font="fonts/FZZCHJW--GB1-0.TTF",size=26}))
	-- 		:setButtonLabelOffset(20, 0)
	-- 		:setButtonLabelAlignment(display.CENTER)
	-- 		:align(display.CENTER,-120+tempPosX,29)
	-- 		:onButtonStateChanged(function(event)
	-- 				-- self:doAfterClickButton(kTagAdvanceCallAnyway)
	-- 				self:doAfterClickButton(-1)
	-- 			end)
	-- 		:addTo(self,4)


	-- self.group1 = cc.ui.UICheckBoxButtonGroup.new()
	-- 	:addButton(self.m_pAdvanceF)
	-- 	:addButton(self.m_pAdvanceCall)
	-- 	:addButton(self.m_pAdvanceCA)
	-- 	:setButtonsLayoutMargin(10,10,10,10)
	-- 	:onButtonSelectChanged(function(event)
 --            -- normal_info_log("Option %d selected, Option %d unselected"..event.selected..event.last)
 --            if event.selected == 1 then
 --            	self:doAfterClickButton(kTagAdvanceFold)
 --            elseif event.selected == 2 then
 --            	self:doAfterClickButton(kTagAdvanceCall)
 --            elseif event.selected == 3 then
 --            	self:doAfterClickButton(kTagAdvanceCallAnyway)
 --            end
	-- 	end)
	-- 	:align(display.CENTER, 120, 0)
	-- 	:addTo(self,4)
	-- 	-- :setVisible(false)

	-- self.group2 = cc.ui.UICheckBoxButtonGroup.new()
	-- 	:addButton(self.m_pAdvanceCheck)
	-- 	:addButton(self.m_pAdvanceCOF)
	-- 	:addButton(self.m_pAdvanceCA1)
	-- 	:setButtonsLayoutMargin(10,10,10,10)
	-- 	:onButtonSelectChanged(function(event)
 --           	if event.selected == 1 then
 --            	self:doAfterClickButton(kTagAdvanceCheck)
 --            elseif event.selected == 2 then
 --            	self:doAfterClickButton(kTagAdvanceCallFold)
 --            elseif event.selected == 3 then
 --            	self:doAfterClickButton(kTagAdvanceCallAnyway)
 --            end
	-- 		end)
	-- 	:align(display.CENTER, 120, 0)
	-- 	:addTo(self,4)
	
	if self.m_boolIsRushRoom then
		self.m_fastFoldBtn = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_FOLD_UP,pressed=OPERATE_BOARD_FOLD_DOWN,disabled=OPERATE_BOARD_FOLD_DOWN})
		self.m_fastFoldBtn:align(display.CENTER, 480, 42)
		-- :setButtonLabel(cc.ui.UILabel.new({
		-- 	text = C_FAST_FOLD_CARD,
		-- 	font = "fonts/FZZCHJW--GB1-0.TTF",
		-- 	size = 26,
		-- 	align = cc.ui.TEXT_ALIGNMENT_CENTER,
		-- 	color = cc.c3b(255,236,204)
		-- 	}))
		:addTo(self,4)
		:onButtonClicked(function() self:doAfterClickButton(kTagAdvanceFold) end)
	end
	self.m_AdvanceIndex = -1
end

function OperateBoard:initRaiseSlider()
	self.m_raiseSlider = require("app.GUI.roomView.RaiseSlider"):create(self)
	self.m_raiseSlider:setPosition(cc.p(0,0))
	self.m_raiseSlider:addTo(self, 4)
	self.m_raiseSlider:setEnabled(false)
	self.m_raiseSlider:setCallback(self.pool_raise_button_layer, handler(self,self.doAfterSliderChanged))

    --[[滑动条旁边的加注按钮]]
		self.m_RaiseNum = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_RAISENUM_UP,
			pressed=OPERATE_BOARD_RAISENUM_DOWN,disabled=OPERATE_BOARD_RAISENUM_DOWN})
		self.m_RaiseNum:align(display.LEFT_BOTTOM, display.width-184-10, 2)
		:setButtonLabel(cc.ui.UILabel.new({
			text = C_RAISE_CARD,
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider,4,kTagRaise)
		:onButtonClicked(function() self:doAfterClickButton(kTagRaise) end)

	local gapY = 0
	local buttonHeight = 92
	local startY = 85+gapY+buttonHeight/2
	local buttonPosX = display.width-185
	self.m_minRaiseButton = cc.ui.UIPushButton.new({normal="btn_qadd1.png",pressed="btn_qadd1_2.png",disabled="btn_qadd1_2.png"})
	self.m_minRaiseButton:align(display.CENTER, buttonPosX, startY)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "最小",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider, 2)
		:onButtonClicked(function() self:button_click(998) end)
		:setTouchSwallowEnabled(true)

	self.m_maxRaiseButton = cc.ui.UIPushButton.new({normal="btn_qadd1.png",pressed="btn_qadd1_2.png",disabled="btn_qadd1_2.png"})
	self.m_maxRaiseButton:align(display.CENTER, buttonPosX, startY+(gapY+buttonHeight)*4)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "最大",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider, 2)
		:onButtonClicked(function() self:button_click(999) end)
		:setTouchSwallowEnabled(true)


	self.two_big_blind = cc.ui.UIPushButton.new({normal="btn_qadd1.png",pressed="btn_qadd1_2.png",disabled="btn_qadd1_2.png"})
	self.two_big_blind:align(display.CENTER, buttonPosX, startY+(gapY+buttonHeight)*1)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "2倍\n大盲",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider, 2)
		:onButtonClicked(function() self:button_click(101) end)
		:setTouchSwallowEnabled(true)

	self.three_big_blind = cc.ui.UIPushButton.new({normal="btn_qadd1.png",pressed="btn_qadd1_2.png",disabled="btn_qadd1_2.png"})
	self.three_big_blind:align(display.CENTER, buttonPosX, startY+(gapY+buttonHeight)*2)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "3倍\n大盲",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider, 2)
		:onButtonClicked(function() self:button_click(103) end)
		:setTouchSwallowEnabled(true)

	self.four_big_blind = cc.ui.UIPushButton.new({normal="btn_qadd1.png",pressed="btn_qadd1_2.png",disabled="btn_qadd1_2.png"})
	self.four_big_blind:align(display.CENTER, buttonPosX, startY+(gapY+buttonHeight)*3)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "4倍\n大盲",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider, 2)
		:onButtonClicked(function() self:button_click(104) end)
		:setTouchSwallowEnabled(true)

	self.half_pool = cc.ui.UIPushButton.new({normal="btn_qadd1.png",pressed="btn_qadd1_2.png",disabled="btn_qadd1_2.png"})
	self.half_pool:align(display.CENTER, buttonPosX, startY+(gapY+buttonHeight)*1)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "1/2\n底池",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider, 2)
		:onButtonClicked(function() self:button_click(102) end)
		:setTouchSwallowEnabled(true)

	self.two_thirds = cc.ui.UIPushButton.new({normal="btn_qadd1.png",pressed="btn_qadd1_2.png",disabled="btn_qadd1_2.png"})
	self.two_thirds:align(display.CENTER, buttonPosX, startY+(gapY+buttonHeight)*2)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "2/3\n底池",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider, 2)
		:onButtonClicked(function() self:button_click(203) end)
		:setTouchSwallowEnabled(true)

	self.pool = cc.ui.UIPushButton.new({normal="btn_qadd1.png",pressed="btn_qadd1_2.png",disabled="btn_qadd1_2.png"})
	self.pool:align(display.CENTER, buttonPosX, startY+(gapY+buttonHeight)*3)
		:setButtonLabel("normal", cc.ui.UILabel.new({
			text = "1倍\n底池",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.m_raiseSlider, 2)
		:onButtonClicked(function() self:button_click(100) end)
		:setTouchSwallowEnabled(true)

		self.m_RaiseBtn1 = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_RAISEBTN_UP,
			pressed=OPERATE_BOARD_RAISEBTN_DOWN,disabled=OPERATE_BOARD_RAISEBTN_DOWN})
		-- self.m_RaiseBtn1:align(display.LEFT_BOTTOM, SCREEN_IPHONE5 and -22 or 0, 6)
		self.m_RaiseBtn1:align(display.LEFT_BOTTOM, 3000, 6)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "100",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.pool_raise_button_layer,4,kTagQuickRaise1)
		:onButtonClicked(function() self:doAfterClickButton(kTagQuickRaise1) end)
		:setTouchSwallowEnabled(true)

		self.m_RaiseBtn2 = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_RAISEBTN_UP,
			pressed=OPERATE_BOARD_RAISEBTN_DOWN,disabled=OPERATE_BOARD_RAISEBTN_DOWN})
		-- self.m_RaiseBtn2:align(display.LEFT_BOTTOM, SCREEN_IPHONE5 and -88 or 100, 6)
		self.m_RaiseBtn2:align(display.LEFT_BOTTOM, 3000, 6)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "200",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.pool_raise_button_layer,4,kTagQuickRaise2)
		:onButtonClicked(function() self:doAfterClickButton(kTagQuickRaise2) end)
		:setTouchSwallowEnabled(true)



		self.m_RaiseBtn3 = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_RAISEBTN_UP,
			pressed=OPERATE_BOARD_RAISEBTN_DOWN,disabled=OPERATE_BOARD_RAISEBTN_DOWN})
		-- self.m_RaiseBtn3:align(display.LEFT_BOTTOM, SCREEN_IPHONE5 and 197 or 199, 6)
		self.m_RaiseBtn3:align(display.LEFT_BOTTOM, 3000, 6)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "300",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self.pool_raise_button_layer,4,kTagQuickRaise3)
		:onButtonClicked(function() self:doAfterClickButton(kTagQuickRaise3) end)
		:setTouchSwallowEnabled(true)

		
end

function OperateBoard:initFoldCallRaise()
		self.m_Fold_FCAR = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_FOLD_UP,
			pressed=OPERATE_BOARD_FOLD_DOWN,disabled=OPERATE_BOARD_FOLD_DOWN})
		self.m_Fold_FCAR:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagFold) end)

		self.m_Call_FCAR = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_CALL_UP,
			pressed=OPERATE_BOARD_CALL_DOWN,disabled=OPERATE_BOARD_CALL_DOWN})
		self.m_Call_FCAR:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = C_CALL_CARD,
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 32,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagCall) end)

		self.m_Raise_FCAR = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_RAISE_UP,
			pressed=OPERATE_BOARD_RAISE_DOWN,disabled=OPERATE_BOARD_RAISE_DOWN})
		self.m_Raise_FCAR:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagCallSlider) end)

		self.m_FoldCallRaise = display.newNode()
		self:addButtonToLayer(self.m_FoldCallRaise,self.m_Fold_FCAR,self.m_Call_FCAR,self.m_Raise_FCAR)
end

function OperateBoard:initFoldCheckRaise()
		self.m_Fold_FCHR = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_FOLD_UP,
			pressed=OPERATE_BOARD_FOLD_DOWN,disabled=OPERATE_BOARD_FOLD_DOWN})
		self.m_Fold_FCHR:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagFold) end)

		self.m_Check_FCHR = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_CHECK_UP,
			pressed=OPERATE_BOARD_CHECK_DOWN,disabled=OPERATE_BOARD_CHECK_DOWN})
		self.m_Check_FCHR:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 32,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagCheck) end)

		self.m_Raise_FCHR = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_RAISE_UP,
			pressed=OPERATE_BOARD_RAISE_DOWN,disabled=OPERATE_BOARD_RAISE_DOWN})
		self.m_Raise_FCHR:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagCallSlider) end)

		self.m_FoldCheckRaise = display.newNode()
		self:addButtonToLayer(self.m_FoldCheckRaise,self.m_Fold_FCHR,self.m_Check_FCHR,self.m_Raise_FCHR)
end

function OperateBoard:initFoldAllInRaise()
	--[[弃牌]]
		self.m_Fold_FCAA = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_FOLD_UP,
			pressed=OPERATE_BOARD_FOLD_DOWN,disabled=OPERATE_BOARD_FOLD_DOWN})
		self.m_Fold_FCAA:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagFold) end)

    --[[跟注]]
		self.m_Call_FCAA = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_CALL_UP,
			pressed=OPERATE_BOARD_CALL_DOWN,disabled=OPERATE_BOARD_CALL_DOWN})
		self.m_Call_FCAA:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = C_CALL_CARD..5366,
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 32,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagAllIn) end)

	--[[全下]]
		self.m_ALLIN_FCAA = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_ALLIN_UP,
			pressed=OPERATE_BOARD_ALLIN_DOWN,disabled=OPERATE_BOARD_ALLIN_DOWN})
		self.m_ALLIN_FCAA:align(display.LEFT_BOTTOM, 0, 0)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:onButtonClicked(function() self:doAfterClickButton(kTagAllIn) end)

		self.m_FoldAllInRaise = display.newNode()
		self:addButtonToLayer(self.m_FoldAllInRaise,self.m_Fold_FCAA,self.m_Call_FCAA,self.m_ALLIN_FCAA)
end

function OperateBoard:initComebackSeat()
	self.m_comebackSeat = cc.ui.UIPushButton.new({normal=OPERATE_BOARD_SELF_BACK_UP,
		pressed=OPERATE_BOARD_SELF_BACK_DOWN,disabled=OPERATE_BOARD_SELF_BACK_DOWN})
	-- self.m_comebackSeat:align(display.LEFT_BOTTOM, 687, 64)
	self.m_comebackSeat:align(display.RIGHT_BOTTOM, CONFIG_SCREEN_WIDTH-20, 10)
		:setButtonLabel(cc.ui.UILabel.new({
			text = "",
			font = "fonts/FZZCHJW--GB1-0.TTF",
			size = 26,
			align = cc.ui.TEXT_ALIGNMENT_CENTER,
			color = cc.c3b(255,236,204)
			}))
		:addTo(self, zOpButton, kTagComeback)
		:onButtonClicked(function(event)
 			self:doAfterClickButton(kTagComeback)
			end)
		-- :setVisible(false)
end

function OperateBoard:addButtonToLayer(pParent, pBtn1, pBtn2, pBtn3)
	SPACE = 10.0
	local size = pBtn1:getContentSize()
	pBtn3:align(display.LEFT_BOTTOM, display.width-184-SPACE, 0)
		:addTo(pParent)
	pBtn2:align(display.LEFT_BOTTOM, pBtn3:getPositionX()-184-SPACE, 0)
		:addTo(pParent)
	pBtn1:align(display.LEFT_BOTTOM, pBtn2:getPositionX()-184-SPACE, 0)
		:addTo(pParent)
	pParent:align(display.LEFT_BOTTOM, 0, 0)
		:addTo(self.player_operate_button_layer, 3)
		-- self.player_operate_button_layer:setVisible(true)
end

function OperateBoard:doPressAdvanceButton(clickType)
	local index = self.m_nClickType - kTagAdvanceFold
	if index == self.m_AdvanceIndex then

	end
end

function OperateBoard:doAfterClickButton(clickType)
	-- normal_info_log("OperateBoard:doAfterClickButton 点击按钮需要完善")  
	local tmpClickType = self.m_nClickType
	if clickType~= nil then
		self.m_nClickType = clickType
	end
    -- if(self.m_nClickType == kTagAdvanceFold or self.m_nClickType == kTagAdvanceCall 
    -- 	or (self.m_nClickType == kTagAdvanceCallAnyway and self._mCallAnywayType == 0)) then
    if self.m_nClickType == kTagAdvanceFold or self.m_nClickType == kTagAdvanceCall 
    	or self.m_nClickType == kTagAdvanceCallAnyway or self.m_nClickType == kTagAdvanceCheck
    	or self.m_nClickType == kTagAdvanceCallFold then
    
        local index = self.m_nClickType - kTagAdvanceFold
      
        if(index == self.m_AdvanceIndex) then
        	
            self.m_pAdvanceF:setButtonSelected(false)
            self.m_pAdvanceCall:setButtonSelected(false)
            self.m_pAdvanceCA:setButtonSelected(false)
            -- self.m_pAdvanceCA1:setButtonSelected(false)
            self.m_pAdvanceCheck:setButtonSelected(false)
            self.m_pAdvanceCall:setButtonSelected(false)
            self.m_pAdvanceF:setButtonSelected(false)
            self.m_AdvanceIndex = -1
        
        else
        			
            self.m_pAdvanceCheck:setButtonSelected(self.m_nClickType == kTagAdvanceCheck)
            self.m_pAdvanceCOF:setButtonSelected(self.m_nClickType == kTagAdvanceCallFold)
            -- self.m_pAdvanceCA1:setButtonSelected(self.m_nClickType == kTagAdvanceCallAnyway)
        			
            self.m_pAdvanceF:setButtonSelected(self.m_nClickType == kTagAdvanceFold)
            self.m_pAdvanceCall:setButtonSelected(self.m_nClickType == kTagAdvanceCall)
            self.m_pAdvanceCA:setButtonSelected(self.m_nClickType == kTagAdvanceCallAnyway)
            if self.m_nClickType == kTagAdvanceCallAnyway then
            	self._mCallAnywayType = 1
            	    	-- dump("====================================kTagAdvanceCallAnyway跟任意住=========================================")
            end
            self.m_AdvanceIndex = index
        end		
    -- elseif (self.m_nClickType == kTagAdvanceCheck or self.m_nClickType == kTagAdvanceCallFold 
    -- 	or (self.m_nClickType == kTagAdvanceCallAnyway and self._mCallAnywayType ~= 0)) then
    --     local index = self.m_nClickType - kTagAdvanceFold
    --     if(index == self.m_AdvanceIndex) then
        
    --         self.m_pAdvanceCheck:setButtonSelected(false)
    --         self.m_pAdvanceCOF:setButtonSelected(false)
    --         self.m_pAdvanceCA1:setButtonSelected(false)
    --         self.m_AdvanceIndex = -1
        
    --     else
    --         self.m_pAdvanceCheck:setButtonSelected(self.m_nClickType == kTagAdvanceCheck)
    --         self.m_pAdvanceCOF:setButtonSelected(self.m_nClickType == kTagAdvanceCallFold)
    --         self.m_pAdvanceCA1:setButtonSelected(self.m_nClickType == kTagAdvanceCallAnyway)
    --         if self.m_nClickType == kTagAdvanceCallAnyway then
    --         	self._mCallAnywayType = 1
    --         end
    --         self.m_AdvanceIndex = index
    --     end
    else
    
        if (self.m_nClickType == kTagCallSlider) then
            self:switchType(kTypeRaise)
            return
        end
        if(self.m_nClickType == kTagRaise) then
        
            if(self.m_raiseSlider:getMaximumValue() <= self.m_raiseSlider:getValue()) then
                self.m_nClickType = kTagAllIn
            end
        elseif (self.m_nClickType == kTagQuickRaise1) then
        
            self.m_nClickType = kTagRaise
            self.m_fRaiseNum = 10 * self._moveValue
            if (self.m_raiseSlider:getMaximumValue() <= 10 * self._moveValue) then
                self.m_nClickType = kTagAllIn
            end
        elseif (self.m_nClickType == kTagQuickRaise2) then
            self.m_nClickType = kTagRaise
            self.m_fRaiseNum = 25 * self._moveValue
            if (self.m_raiseSlider:getMaximumValue() <= 25 * self._moveValue) then
                self.m_nClickType = kTagAllIn
            end
        elseif (self.m_nClickType == kTagQuickRaise3) then
            self.m_nClickType = kTagRaise
            self.m_fRaiseNum = 50 * self._moveValue
            if (self.m_raiseSlider:getMaximumValue() <= 50 * self._moveValue) then
                self.m_nClickType = kTagAllIn
            end

        end
        
        self:switchType(kTypeNone)
    end
  
    if(self.m_bHasCallback and self.m_callback) then
   		self.m_callback(self)
    end
	if clickType==tmpClickType then
    	self.m_nClickType = -1
    end
end

function OperateBoard:doAfterSliderChanged(pSender)
	-- normal_info_log("OperateBoard:doAfterSliderChanged 点击加注需要完善")
	local p = pSender
    local tmp = p:getValue()
    self.m_fRaiseNum = tmp

    if(self.m_eCurrent == kTypeFoldCallRaise) then
    
        if (tmp==self._max) then
            -- self.max:setVisible(true)
            self.m_RaiseNum:setButtonLabelString("normal", "全下")
        else
            if (self.m_RaiseNum) then
                self.max:setVisible(false)
                self.m_RaiseNum:setVisible(true)
                self.m_RaiseNum:setButtonLabelString("normal", StringFormat:FormatDecimals(tmp))
                
                self.m_RaiseBtn1:setVisible(true)
                self.m_RaiseBtn1:setButtonLabelString("normal", StringFormat:FormatDecimals(10 * self._moveValue))
                self.m_RaiseBtn2:setVisible(true)
                self.m_RaiseBtn2:setButtonLabelString("normal", StringFormat:FormatDecimals(25 * self._moveValue))
                self.m_RaiseBtn3:setVisible(true)
                self.m_RaiseBtn3:setButtonLabelString("normal", StringFormat:FormatDecimals(50 * self._moveValue))
            end
        end
    elseif(self.m_eCurrent == kTypeFoldCheckRaise) then
    
        if (tmp==self._max) then
            -- self.max:setVisible(true)
            self.m_RaiseNum:setButtonLabelString("normal", "全下")
        else
            if (self.m_RaiseNum) then
               self.max:setVisible(false)
                self.m_RaiseNum:setVisible(true)
                self.m_RaiseNum:setButtonLabelString("normal", StringFormat:FormatDecimals(tmp))
                
                self.m_RaiseBtn1:setVisible(true)
                self.m_RaiseBtn1:setButtonLabelString("normal", StringFormat:FormatDecimals(10 * self._moveValue))
                self.m_RaiseBtn2:setVisible(true)
                self.m_RaiseBtn2:setButtonLabelString("normal", StringFormat:FormatDecimals(25 * self._moveValue))
                self.m_RaiseBtn3:setVisible(true)
                self.m_RaiseBtn3:setButtonLabelString("normal", StringFormat:FormatDecimals(50 * self._moveValue))
            end
        end
    end
end

function OperateBoard:raise(num)
 self.m_RaiseNum:setVisible(true)
	if(num > self._max and math.abs(num - self._max) > 0.01) then
        num = self._max
        --return
    end

    if num~=self._max then
    	num = math.floor(num)
    end

    if(num < self._min and math.abs(num - self._min) > 0.01) then
        return
    end

    if(self.m_eCurrent == kTypeFoldCallRaise) then
  		
        if (num==self._max) then
            
            -- self.max:setVisible(true)
            -- self.m_RaiseNum:setVisible(false)

            
        else 
            if (self.m_RaiseNum) then
                self.max:setVisible(false)

                self.m_RaiseNum:setVisible(true)
                self.m_RaiseNum:setButtonLabelString("normal", StringFormat:FormatDecimals(num))

                self.m_RaiseBtn1:setVisible(true)
                self.m_RaiseBtn1:setButtonLabelString("normal", StringFormat:FormatDecimals(10 * self._moveValue))
                self.m_RaiseBtn2:setVisible(true)
                self.m_RaiseBtn2:setButtonLabelString("normal", StringFormat:FormatDecimals(25 * self._moveValue))
                self.m_RaiseBtn3:setVisible(true)
                self.m_RaiseBtn3:setButtonLabelString("normal", StringFormat:FormatDecimals(50 * self._moveValue))
            end
        end
    elseif(self.m_eCurrent == kTypeFoldCheckRaise) then
    
        if (num==self._max) then
            -- self.max:setVisible(true)
            -- self.m_RaiseNum:setVisible(false)
        else
            if (self.m_RaiseNum) then
                self.max:setVisible(false)
                self.m_RaiseNum:setVisible(true)
                self.m_RaiseNum:setButtonLabelString("normal", StringFormat:FormatDecimals(num))
                
                self.m_RaiseBtn1:setVisible(true)
                self.m_RaiseBtn1:setButtonLabelString("normal", StringFormat:FormatDecimals(10 * self._moveValue))
                self.m_RaiseBtn2:setVisible(true)
                self.m_RaiseBtn2:setButtonLabelString("normal", StringFormat:FormatDecimals(25 * self._moveValue))
                self.m_RaiseBtn3:setVisible(true)
                self.m_RaiseBtn3:setButtonLabelString("normal", StringFormat:FormatDecimals(50 * self._moveValue))
            end
        end
    end

    self.m_raiseSlider:setValue(num)
    self.m_fRaiseNum = num
    self.m_nClickType = kTagRaise
    self:doAfterClickButton(nil)
end

function OperateBoard:setCallback(target, callback)
	self.m_bHasCallback = true
	self.m_target = target
	self.m_callback = callback
end

function OperateBoard:hideAll()
	self.m_eCurrent = kTypeNone
	self:switchType(kTypeNone)
end

function OperateBoard:switchType(currentShowType, preShowType)
	-- dump("=====OperateBoard:switchType=====")
	if currentShowType == kTypeComeback then
            self.m_comebackSeat:setVisible(true)
            self.m_pAdvanceCheck:setVisible(false)
            self.m_pAdvanceCall:setVisible(false)
            self.m_pAdvanceF:setVisible(false)
            self.m_pAdvanceCOF:setVisible(false)
            self.m_pAdvanceCA:setVisible(false)
            -- self.m_pAdvanceCA1:setVisible(false)
            self.m_raiseSlider:setEnabled(false)
            self.m_FoldAllInRaise:setVisible(false)
            self.m_FoldCallRaise:setVisible(false)
            self.m_FoldCheckRaise:setVisible(false)
            self.player_operate_button_layer:setVisible(false)
            if(self.m_fastFoldBtn) then 
            	self.m_fastFoldBtn:setVisible(false)
            end
    elseif currentShowType == kTypeFoldCheckRaise then
            self.m_raiseSlider:setEnabled(false)
            self.m_FoldCheckRaise:setVisible(true)
            self.m_comebackSeat:setVisible(false)
            self.m_pAdvanceCheck:setVisible(false)
            self.m_pAdvanceCall:setVisible(false)
            self.m_pAdvanceF:setVisible(false)
            self.m_pAdvanceCOF:setVisible(false)
            self.m_pAdvanceCA:setVisible(false)
            -- self.m_pAdvanceCA1:setVisible(false)
            self.m_FoldAllInRaise:setVisible(false)
            self.m_FoldCallRaise:setVisible(false)
            if(self.m_fastFoldBtn) then
            	self.m_fastFoldBtn:setVisible(false)
            end
    elseif currentShowType == kTypeFoldCallRaise then
            self.m_raiseSlider:setEnabled(false)
            self.m_FoldCallRaise:setVisible(true)
            self.m_comebackSeat:setVisible(false)
            self.m_pAdvanceCheck:setVisible(false)
            self.m_pAdvanceCall:setVisible(false)
            self.m_pAdvanceF:setVisible(false)
            self.m_pAdvanceCOF:setVisible(false)
            self.m_pAdvanceCA:setVisible(false)
            -- self.m_pAdvanceCA1:setVisible(false)
            self.m_FoldAllInRaise:setVisible(false)
            self.m_FoldCheckRaise:setVisible(false)
            if(self.m_fastFoldBtn) then
            	self.m_fastFoldBtn:setVisible(false)
            end
    elseif currentShowType == kTypeFoldAllInRaise then
            self.m_FoldAllInRaise:setVisible(true)
            self.m_comebackSeat:setVisible(false)
            self.m_pAdvanceCheck:setVisible(false)
            self.m_pAdvanceCall:setVisible(false)
            self.m_pAdvanceF:setVisible(false)
            self.m_pAdvanceCOF:setVisible(false)
            self.m_pAdvanceCA:setVisible(false)
            -- self.m_pAdvanceCA1:setVisible(false)
            self.m_raiseSlider:setEnabled(false)
            self.m_FoldCallRaise:setVisible(false)
            self.m_FoldCheckRaise:setVisible(false)
            if(self.m_fastFoldBtn) then
            	self.m_fastFoldBtn:setVisible(false)
            end
    elseif currentShowType == kTypeCheckBox then
            if (self.m_betChips > 0 ) then
                self.m_pAdvanceCheck:setVisible(false)
                self.m_pAdvanceCall:setVisible(true)
                
                local tmp = "跟"..StringFormat:FormatDecimals(self.m_betChips)
                self.m_pAdvanceCall:setButtonLabelString(tmp)

                if self.m_isCallNumChanged then
                  --筹码发生变化  清除跟注预选框预选框  || m_pAdvanceCOF->getIsSelected()
                    if self.m_pAdvanceCall:isButtonSelected() then
                        self.m_pAdvanceCall:setButtonSelected(false)
                        self.m_AdvanceIndex = -1
                    elseif self.m_pAdvanceCOF:isButtonSelected() then
                        self.m_pAdvanceCOF:setButtonSelected(false)
                        self.m_pAdvanceF:setButtonSelected(true)
                        self.m_AdvanceIndex = 0
                    end
                else
                    self.m_pAdvanceCall:setButtonSelected(self.m_nClickType == kTagAdvanceCall)
                end
                self.m_pAdvanceF:setVisible(true)
                self.m_pAdvanceCOF:setVisible(false)
                self.m_pAdvanceCA:setVisible(true)
                -- self.m_pAdvanceCA1:setVisible(false)
            else
                self.m_pAdvanceCheck:setVisible(true)
                self.m_pAdvanceCall:setVisible(false)
                self.m_pAdvanceF:setVisible(false)
                self.m_pAdvanceCOF:setVisible(true)
                self.m_pAdvanceCA:setVisible(true)
                -- self.m_pAdvanceCA:setVisible(false)
                -- self.m_pAdvanceCA1:setVisible(true)
            end

            self.m_comebackSeat:setVisible(false)
            self.m_raiseSlider:setEnabled(false)
            self.m_FoldAllInRaise:setVisible(false)
            self.m_FoldCallRaise:setVisible(false)
            self.m_FoldCheckRaise:setVisible(false)
            self.player_operate_button_layer:setVisible(false)
        
    elseif currentShowType == kTypeNone then
            self.m_comebackSeat:setVisible(false)
            self.m_pAdvanceCheck:setVisible(false)
            self.m_pAdvanceCall:setVisible(false)
            self.m_pAdvanceF:setVisible(false)
            self.m_pAdvanceCOF:setVisible(false)
            self.m_pAdvanceCA:setVisible(false)
            -- self.m_pAdvanceCA1:setVisible(false)
            self.m_raiseSlider:setEnabled(false)
            self.m_FoldAllInRaise:setVisible(false)
            self.m_FoldCallRaise:setVisible(false)
            self.m_FoldCheckRaise:setVisible(false)
            self.player_operate_button_layer:setVisible(false)
            if(self.m_fastFoldBtn) then
            	self.m_fastFoldBtn:setVisible(false)
            end
    elseif currentShowType == kTypeRaise then
            self.m_raiseSlider:setChangeAsValue()
            self.m_comebackSeat:setVisible(false)
            self.m_pAdvanceCheck:setVisible(false)
            self.m_pAdvanceCall:setVisible(false)
            self.m_pAdvanceF:setVisible(false)
            self.m_pAdvanceCOF:setVisible(false)
            self.m_pAdvanceCA:setVisible(false)
            -- self.m_pAdvanceCA1:setVisible(false)
            self.m_raiseSlider:setEnabled(true)
            self.m_RaiseBtn1:setButtonLabelString("normal", StringFormat:FormatDecimals(10 * self._moveValue))
            self.m_RaiseBtn2:setButtonLabelString("normal", StringFormat:FormatDecimals(25 * self._moveValue))
            self.m_RaiseBtn3:setButtonLabelString("normal", StringFormat:FormatDecimals(50 * self._moveValue))

        local hasPot = (self._pot-self._moveValue*1.5 > 0)

       	self.two_big_blind:setVisible(not hasPot)
        self.three_big_blind:setVisible(not hasPot)
       	self.four_big_blind:setVisible(not hasPot)
        
        self.half_pool:setVisible(hasPot)
        self.two_thirds:setVisible(hasPot)
        self.pool:setVisible(hasPot)
       
    end
    


    if(currentShowType == kTypeFoldCheckRaise or currentShowType == kTypeFoldCallRaise 
    	or currentShowType == kTypeFoldAllInRaise) then
    	self.pool_raise_background:setVisible(true)
		self.player_operate_button_layer:setVisible(true)
        self.pool_raise_button_layer:setVisible(false)
        if preShowType and preShowType~=kTypeRaise then
    		self:doAnimation()
    	end
    elseif(currentShowType == kTypeRaise) then
        self.pool_raise_background:setVisible(true)
        -- self.player_operate_button_layer:setVisible(false)
       	self.pool_raise_button_layer:setVisible(true)
    else
        self.pool_raise_background:setVisible(false)
        self.pool_raise_button_layer:setVisible(false)
        self.player_operate_button_layer:setVisible(false)

        self.two_big_blind:setVisible(false)
        self.three_big_blind:setVisible(false)
        self.four_big_blind:setVisible(false)
        
        self.half_pool:setVisible(false)
        self.two_thirds:setVisible(false)
        self.pool:setVisible(false)
    end
end

function OperateBoard:doAnimation()
	transition.execute(self, cc.Sequence:create({cc.MoveTo:create(0.1, cc.p(0,-90)),cc.MoveTo:create(0.3, cc.p(0,0))}), {
		onComplete = function()	
			
		end
		})
end

--[[显示：预选面板]]
function OperateBoard:ShowPreOperate(chips)
	-- dump("=================ShowPreOperate==================")
	if chips > self.m_betChips and self.m_betChips>-1 then
        self.m_isCallNumChanged = true
        -- self:UnSelectProOperate()
    else
        self.m_isCallNumChanged = false
        -- self:resetPreOperate()
    end
	self.m_betChips = chips
    self.m_eCurrent = kTypeCheckBox
    self:switchType(kTypeCheckBox)
end


--显示：我要回座面板
function OperateBoard:ShowComebackSeat()

    self.m_eCurrent = kTypeComeback
    self:switchType(kTypeComeback)
end



--显示：弃牌，看牌，加注面板
function OperateBoard:ShowFoldCheckRaiseOp(addMin, addMax, moveValue, pot, extra)
	-- normal_info_log("OperateBoard:ShowFoldCheckRaiseOp 显示：弃牌，看牌，加注面板")
    self._pot = pot
    self._moveValue = moveValue
    self._min = addMin
    self._max = addMax
    self.m_extra = extra
    
    --滑动条
    self.m_raiseSlider:setMinimumValue(addMin)
    self.m_raiseSlider:setMaximumValue(addMax)
    self.m_raiseSlider:setMoveValue(moveValue)
    self.m_raiseSlider:setValue(addMin)
    self.m_raiseSlider:setChangeAsValue()
    
    if (extra ==0) then
        -- self.m_Raise_FCHR.m_menuItem:setNormalImage(cc.Sprite:create("picdata/table/betBtn.png"))
        -- self.m_Raise_FCHR.m_menuItem:setDisabledImage(cc.Sprite:create("picdata/table/betBtn1.png"))
        -- self.m_Raise_FCHR.m_menuItem:setSelectedImage(cc.Sprite:create("picdata/table/betBtn1.png"))

        self.m_Raise_FCHR:setButtonImage("normal","picdata/table/betBtn.png")
        self.m_Raise_FCHR:setButtonImage("pressed","picdata/table/betBtn1.png")
        self.m_Raise_FCHR:setButtonImage("disabled","picdata/table/betBtn1.png")
    end
    
    self.m_fRaiseNum = addMin
    
    local preType = self.m_eCurrent
    self.m_eCurrent = kTypeFoldCheckRaise
    self:switchType(kTypeFoldCheckRaise, preType)
end



--显示：弃牌，跟注，加注面板
function OperateBoard:ShowFoldCallRaiseOp(call, addMin, addMax, moveValue, pot, extra)
 	-- normal_info_log("OperateBoard:ShowFoldCallRaiseOp显示：弃牌，跟注，加注面板")
    self._pot = pot
    self._moveValue = moveValue
    self._min = addMin
    self._max = addMax
    self.m_extra = extra
    
    self.m_Call_FCAR:setButtonLabelString("normal", "跟"..StringFormat:FormatDecimals(call).."")

    --滑动条
    self.m_raiseSlider:setMinimumValue(addMin)
    self.m_raiseSlider:setMaximumValue(addMax)
    self.m_raiseSlider:setMoveValue(moveValue)
    self.m_raiseSlider:setValue(addMin)
    self.m_raiseSlider:setChangeAsValue()
    
    self.m_fRaiseNum = addMin
    
    local preType = self.m_eCurrent
    self.m_eCurrent = kTypeFoldCallRaise
    self:switchType(kTypeFoldCallRaise, preType)
end


--显示：弃牌，跟注，All In
function OperateBoard:ShowFoldCallAllIn(callNum)
 	-- normal_info_log("OperateBoard:ShowFoldCallAllIn显示：弃牌，跟注，All In")

    if (self.m_betChips>0) then
        self.m_Call_FCAA:setButtonLabelString("normal", StringFormat:FormatDecimals(self.m_betChips))
    else
        self.m_Call_FCAA:setButtonLabelString("normal", "跟"..StringFormat:FormatDecimals(callNum))
    end

    local preType = self.m_eCurrent
    self.m_eCurrent = kTypeFoldAllInRaise
    self:switchType(kTypeFoldAllInRaise, preType)
end

--清除预选
function OperateBoard:UnSelectProOperate()

    self.m_pAdvanceF:setButtonSelected(false)
    self.m_pAdvanceCOF:setButtonSelected(false)
    self.m_pAdvanceCA:setButtonSelected(false)
    -- self.m_pAdvanceCA1:setButtonSelected(false)
    self.m_pAdvanceCheck:setButtonSelected(false)
    self.m_pAdvanceCall:setButtonSelected(false)

    
    self.m_pAdvanceCheck:setVisible(false)
    self.m_pAdvanceCall:setVisible(false)
    self.m_pAdvanceF:setVisible(false)
    self.m_pAdvanceCOF:setVisible(false)
    self.m_pAdvanceCA:setVisible(false)
    -- self.m_pAdvanceCA1:setVisible(false)
    if(self.m_fastFoldBtn) then
    	self.m_fastFoldBtn:setVisible(false)
    end
    self.m_AdvanceIndex = -1
    self.m_nClickType = -1
    -- self.m_betChips = 0
end

--隐藏面板
function OperateBoard:hideOperateBoard()
    if(self.m_eCurrent ~= kTypeComeback) then
        self:hideAll()
    end
end


function OperateBoard:showNewerGuideHint(guideHintType)
    local p1 = nil
    local p2 = nil
    local p3 = nil
    
    if(self.m_eCurrent == kTypeFoldCheckRaise) then
        p1 = self.m_FoldCheckRaise:getChildByTag(kTagFold)
        p2 = self.m_FoldCheckRaise:getChildByTag(kTagCheck)
        p3 = self.m_FoldCheckRaise:getChildByTag(kTagRaise)
  
    elseif(self.m_eCurrent == kTypeFoldCallRaise) then
        p1 = self.m_FoldCallRaise:getChildByTag(kTagFold)
        p2 = self.m_FoldCallRaise:getChildByTag(kTagCall)
        p3 = self.m_FoldCallRaise:getChildByTag(kTagRaise)
    
    else
        return
    end

    if(guideHintType == kOBNGPocketRaise) then
        if(p1) then
        	p1:setOpacity(125)
        end
        if(p2) then
        	p2:setOpacity(255)
        end
        if(p3) then
        	p3:setOpacity(255)
        end
  
    elseif(guideHintType == kOBNGFlopRaise) then
        if(p1) then
        	p1:setOpacity(125)
        end
        if(p2) then
        	p2:setOpacity(125)
        end
        if(p3) then
        	p3:setOpacity(255)
        end
    
    else
        if(p1) then
        	p1:setOpacity(225)
        end
        if(p2) then
        	p2:setOpacity(255)
        end
        if(p3) then
        	p3:setOpacity(255)
        end
    end
end

--试图显示快速弃牌
function OperateBoard:showFastFold()
    if(self.m_boolIsRushRoom and self.m_fastFoldBtn) then
        self.m_fastFoldBtn:setVisible(true)
    end
end

function OperateBoard:callNumUpdate(callNum)
	-- if callNum ~= self.m_betChips then
 --        self:resetPreOperate()
 --    end
 --    self.m_betChips = callNum
 --    self.m_eCurrent = kTypeCheckBox
 --    self:switchType(kTypeCheckBox)
end

function OperateBoard:resetPreOperate()
    self.m_pAdvanceF:setButtonSelected(false)
    self.m_pAdvanceCOF:setButtonSelected(false)
    self.m_pAdvanceCA:setButtonSelected(false)
    -- self.m_pAdvanceCA1:setButtonSelected(false)
    self.m_pAdvanceCheck:setButtonSelected(false)
    self.m_pAdvanceCall:setButtonSelected(false)
    self.m_AdvanceIndex = -1
    self.m_nClickType = -1
end

return OperateBoard