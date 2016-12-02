local CommonFragment = require("app.architecture.components.CommonFragment")
local CMRadioButton = require("app.Component.CMRadioButton")
local HallCreateRoomFragment = class("HallCreateRoomFragment", function()
		return CommonFragment:new()
	end)

function HallCreateRoomFragment:ctor(params)
	self.params = params
    self:setNodeEventEnabled(true)
end

function HallCreateRoomFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function HallCreateRoomFragment:onEnterTransitionFinish()
end

function HallCreateRoomFragment:create()
	CommonFragment.initUI(self)
	self:initUI()
end

function HallCreateRoomFragment:initUI()
	local contentWidth = self.bgWidth-60
	local contentHeight = self.bgHeight*0.875-180
	local bg = cc.ui.UIImage.new("picdata/public/popup/img_rect.png", {scale9 = true})
    bg:setLayoutSize(contentWidth, contentHeight)
    bg:align(display.CENTER_BOTTOM, CONFIG_SCREEN_WIDTH/2, 100)
    	:addTo(self)

    self.m_pBtnConfirm = CMButton.new({normal = {"picdata/public/popup/btn_confirm.png"},
        pressed = {"picdata/public/popup/btn_confirm.png"}},
        function () self:createRoom() end, nil, {changeAlpha = true})
    self.m_pBtnConfirm:setPosition(CONFIG_SCREEN_WIDTH/2, 
    	60)
    self:addChild(self.m_pBtnConfirm)
	local confirmLabel = cc.ui.UILabel.new({
	        color = cc.c3b(255, 255, 236),
	        text  = "确定",
	        size  = 28,
	        font  = "font/FZZCHJW--GB1-0.TTF",
        	})
    confirmLabel:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
    self.m_pBtnConfirm:setButtonLabel("normal", confirmLabel)

    local button_images = {
        off = "picdata/hall/create_room/btn_tab.png",
        off_pressed = "picdata/hall/create_room/btn_tab_s.png",
        off_disabled = "picdata/hall/create_room/btn_tab.png",
        on = "picdata/hall/create_room/btn_tab_s.png",
        on_pressed = "picdata/hall/create_room/btn_tab.png",
        on_disabled = "picdata/hall/create_room/btn_tab.png",
    }
    local button_titles = {"鸡平胡","血流成河","步步高","红中癞子"}
    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    for i=1,#button_titles do
    	local button = cc.ui.UICheckBoxButton.new(button_images)
            :align(display.LEFT_CENTER)
        local label = cc.ui.UILabel.new({
	        color = cc.c3b(255, 255, 236),
	        text  = button_titles[i],
	        size  = 28,
	        font  = "font/FZZCHJW--GB1-0.TTF",
        	})
    	label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
        button:setButtonLabel("off", label)
        if string.utf8len(button_titles[i])==4 then
        	button:setButtonLabelOffset(-52, 8)
        else
        	button:setButtonLabelOffset(-40, 8)
        end
        group:addButton(button)
    end
        group:setButtonsLayoutMargin(2, 2, 2, 2)
        :onButtonSelectChanged(function(event)
            -- printf("Option %d selected, Option %d unselected", event.selected, event.last)
            if event.selected==1 then
            end
        end)
        :align(display.LEFT_BOTTOM, bg:getPositionX()-contentWidth/2, bg:getPositionY()+contentHeight-16)
        :addTo(self)
        group:getButtonAtIndex(1):setButtonSelected(true)
        -- group:getButtonAtIndex(4):setVisible(false)

    local padding = 35
   	--------------------------------------局数-------------------------------------
    local startPosX = bg:getPositionX()-contentWidth/2+94
    local startPosY = bg:getPositionY()+contentHeight-45
    cc.ui.UILabel.new({
        color = cc.c3b(255, 115, 115),
        text  = "局数",
        size  = 28,
        font  = "font/FZZCHJW--GB1-0.TTF",
    	})
    	:align(display.CENTER, startPosX, startPosY)
    	:addTo(self)

    local button_images2 = {
        off = "picdata/hall/create_room/img_radio.png",
        off_pressed = "picdata/hall/create_room/img_radio_s.png",
        off_disabled = "picdata/hall/create_room/img_radio.png",
        on = "picdata/hall/create_room/img_radio_s.png",
        on_pressed = "picdata/hall/create_room/img_radio.png",
        on_disabled = "picdata/hall/create_room/img_radio.png",
    }
    local button_titles2 = {"4局(房卡*2)","8局(房卡*2)"}
    local group2 = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    for i=1,#button_titles2 do
    	local button = cc.ui.UICheckBoxButton.new(button_images2)
            :align(display.LEFT_CENTER)
        local label = cc.ui.UILabel.new({
	        color = cc.c3b(0, 0, 0),
	        text  = button_titles2[i],
	        size  = 28,
	        font  = "font/FZZCHJW--GB1-0.TTF",
        	})
    	-- label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
        button:setButtonLabel("off", label)
        button:setButtonLabelOffset(30, 0)
        group2:addButton(button)
    end
        group2:setButtonsLayoutMargin(20, 20, 20, 20)
        :onButtonSelectChanged(function(event)
            -- printf("Option %d selected, Option %d unselected", event.selected, event.last)
            if event.selected==1 then
            end
        end)
        :align(display.LEFT_BOTTOM, startPosX+50, startPosY-40)
        :addTo(self)
        group2:getButtonAtIndex(1):setButtonSelected(true)

    startPosY = startPosY-padding
    local line = cc.ui.UIImage.new("picdata/hall/create_room/img_line.png")
    	:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, startPosY)
    	:addTo(self)
    line:setScaleX((contentWidth-40)/line:getContentSize().width)
   	--------------------------------------封顶-------------------------------------
    startPosY = startPosY-padding
    cc.ui.UILabel.new({
        color = cc.c3b(255, 115, 115),
        text  = "抓鸟",
        size  = 28,
        font  = "font/FZZCHJW--GB1-0.TTF",
    	})
    	:align(display.CENTER, startPosX, startPosY)
    	:addTo(self)

    local button_titles3 = {"不抓鸟","2个","4个","6个"}
    local group3 = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    for i=1,#button_titles3 do
    	local button = cc.ui.UICheckBoxButton.new(button_images2)
            :align(display.LEFT_CENTER)
        local label = cc.ui.UILabel.new({
	        color = cc.c3b(0, 0, 0),
	        text  = button_titles3[i],
	        size  = 28,
	        font  = "font/FZZCHJW--GB1-0.TTF",
        	})
    	-- label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
        button:setButtonLabel("off", label)
        button:setButtonLabelOffset(30, 0)
        group3:addButton(button)
    end
        group3:setButtonsLayoutMargin(20, 20, 20, 20)
        :onButtonSelectChanged(function(event)
            -- printf("Option %d selected, Option %d unselected", event.selected, event.last)
            if event.selected==1 then
            end
        end)
        :align(display.LEFT_BOTTOM, startPosX+50, startPosY-40)
        :addTo(self)
        group3:getButtonAtIndex(1):setButtonSelected(true)

    startPosY = startPosY-padding
    local line2 = cc.ui.UIImage.new("picdata/hall/create_room/img_line.png")
    	:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, startPosY)
    	:addTo(self)
    line2:setScaleX((contentWidth-40)/line:getContentSize().width)
   	--------------------------------------封顶-------------------------------------
    startPosY = startPosY-padding
    cc.ui.UILabel.new({
        color = cc.c3b(255, 115, 115),
        text  = "玩法",
        size  = 28,
        font  = "font/FZZCHJW--GB1-0.TTF",
    	})
    	:align(display.CENTER, startPosX, startPosY)
    	:addTo(self)

    local button_titles4 = {"自摸","点炮"}
    local group4 = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
    for i=1,#button_titles4 do
    	local button = cc.ui.UICheckBoxButton.new(button_images2)
            :align(display.LEFT_CENTER)
        local label = cc.ui.UILabel.new({
	        color = cc.c3b(0, 0, 0),
	        text  = button_titles4[i],
	        size  = 28,
	        font  = "font/FZZCHJW--GB1-0.TTF",
        	})
    	-- label:enableShadow(cc.c4b(0,0,0,190),cc.size(2,-2))
        button:setButtonLabel("off", label)
        button:setButtonLabelOffset(30, 0)
        group4:addButton(button)
    end
        group4:setButtonsLayoutMargin(20, 20, 20, 20)
        :onButtonSelectChanged(function(event)
            -- printf("Option %d selected, Option %d unselected", event.selected, event.last)
            if event.selected==1 then
            end
        end)
        :align(display.LEFT_BOTTOM, startPosX+50, startPosY-40)
        :addTo(self)
        group4:getButtonAtIndex(1):setButtonSelected(true)


    startPosY = startPosY-padding
    local line3 = cc.ui.UIImage.new("picdata/hall/create_room/img_line.png")
    	:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, startPosY)
    	:addTo(self)
    line3:setScaleX((contentWidth-40)/line:getContentSize().width)
   	--------------------------------------多选区域-------------------------------------
    startPosY = startPosY-padding-20
    local checkPadding = 150
    self.m_pBtnJiangDui = CMRadioButton:new({
        hint = "258将",
        hintColorOff = cc.c3b(0, 0, 0),
        hintColorOn = cc.c3b(255,0,0),
        off="picdata/hall/create_room/img_check.png",
        on="picdata/hall/create_room/img_check_s.png",
        hintOffset = cc.p(10,0)
        })
    self.m_pBtnJiangDui:align(display.CENTER, startPosX+72, startPosY)
    self.m_pBtnJiangDui:addTo(self)

    self.m_pBtnDuiDuiHu = CMRadioButton:new({
        hint = "对对胡",
        hintColorOff = cc.c3b(0, 0, 0),
        hintColorOn = cc.c3b(255,0,0),
        off="picdata/hall/create_room/img_check.png",
        on="picdata/hall/create_room/img_check_s.png",
        hintOffset = cc.p(10,0)
        })
    self.m_pBtnDuiDuiHu:align(display.CENTER, self.m_pBtnJiangDui:getPositionX()+checkPadding, self.m_pBtnJiangDui:getPositionY())
    self.m_pBtnDuiDuiHu:addTo(self)

    self.m_pBtnQiangGangHu = CMRadioButton:new({
        hint = "抢杠胡",
        hintColorOff = cc.c3b(0, 0, 0),
        hintColorOn = cc.c3b(255,0,0),
        off="picdata/hall/create_room/img_check.png",
        on="picdata/hall/create_room/img_check_s.png",
        hintOffset = cc.p(10,0)
        })
    self.m_pBtnQiangGangHu:align(display.CENTER, self.m_pBtnDuiDuiHu:getPositionX()+checkPadding, self.m_pBtnJiangDui:getPositionY())
    self.m_pBtnQiangGangHu:addTo(self)

    startPosY = startPosY-padding+20
    local line3 = cc.ui.UIImage.new("picdata/hall/create_room/img_line.png")
    	:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, startPosY)
    	:addTo(self)
    line3:setScaleX((contentWidth-40)/line:getContentSize().width)
   	--------------------------------------多选区域-------------------------------------
    startPosY = startPosY-padding-20

    local hint = cc.ui.UILabel.new({
        color = cc.c3b(225, 0, 0),
        text  = "注:房卡将在第一局结算时扣除，提前解散不扣房卡",
        size  = 28,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_CENTER
    	})
   	hint:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, startPosY)
   		:addTo(self)
end

function HallCreateRoomFragment:createRoom()
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomView)
end

return HallCreateRoomFragment