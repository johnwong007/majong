require("app.Logic.Config.UserDefaultSetting")
local myInfo = require("app.Model.Login.MyInfo")
local PrivateHallView = class("PrivateHallView", function()
	return display.newLayer()
end)
-- require("app.Tools.StringFormat")
-- require("app.Logic.Config.UserDefaultSetting")
function PrivateHallView:create()
    GameSceneManager:setJumpLayer(GameSceneManager.AllLayer.ZIDINGYI) 
    --[[初始化工作]]
    -------------------------------------------------------
    self:setNodeEventEnabled(true)

    -------------------------------------------------------
    local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/MainPage_dif/mainpageBG.png")
    self.m_hallBg = cc.ui.UIImage.new(tmpFilename)
    self.m_hallBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
        :addTo(self)

    local topItemPosY = display.height - 57

    --[[返回按钮]]
    local backBtn = cc.ui.UIPushButton.new({normal="picdata/public/back.png", pressed="picdata/public/back.png",
        disabled="picdata/public/back.png"})
    backBtn:align(display.CENTER, 57, topItemPosY)
        :onButtonClicked(handler(self, self.pressBack))
        :addTo(self)

    --[[金币、商城]]
    local toolBarTop = require("app.Component.ToolBarTop").new({dispatchEvtOpen = "HidePrivateHallSearch", dispatchEvtClose = "ShowPrivateHallSearch",showDebaoDiamond = true})
    toolBarTop:setPosition(CONFIG_SCREEN_WIDTH/2--[[ + 37]],topItemPosY)
    self:addChild(toolBarTop)
    self.m_goldNum = toolBarTop.m_goldNum
    self.m_scoreNum = toolBarTop.m_scoreNum

    local btnHZJL = CMButton.new({normal = "picdata/public2/btn_h62_blue.png",pressed = "picdata/public2/btn_h62_blue2.png"},function () 
        self:hideSearchInput()
        local RewardLayer      = require("app.GUI.recharge.DebaoZuanLayer")
        CMOpen(RewardLayer,self)
        end,nil,{textPath = "picdata/shop/w_title_zs.png"})
    btnHZJL:setPosition(CONFIG_SCREEN_WIDTH-100,topItemPosY)
    self:addChild(btnHZJL)
    -- btnHZJL:setVisible(false)

    --[[设置按钮]]
    local setBtn = cc.ui.UIPushButton.new({normal="picdata/hall/setBtn.png", pressed="picdata/hall/setBtn2.png",
        disabled="picdata/hall/setBtn2.png"})
    setBtn:align(display.CENTER, display.width-57, topItemPosY)
        :onButtonClicked(handler(self, self.pressHiddenRoom))
        :addTo(self)
        :setTouchSwallowEnabled(false)
    setBtn:setVisible(false)

    ------------------------------------------------------------------------------------------------
    --[[设置界面]]
    self.m_hiddenLayerBg = cc.ui.UIImage.new("picdata/hall/hiddenLayerBG.png")
    self.m_hiddenLayerBg:align(display.RIGHT_TOP, setBtn:getPositionX()+40, setBtn:getPositionY())
        :addTo(self, 2)

    local startY = 50
    local posX = 40
    local gapY = 60
        --[[隐藏按钮]]
    -------------------------------------------------------
    self.sixRoomButton = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "隐藏6人", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :align(display.LEFT_CENTER, posX, startY+3*gapY)
        :onButtonStateChanged(function(event)
            self:hiddenLayerButtonClick(1001,event.target:isButtonSelected())
        end)
        :addTo(self.m_hiddenLayerBg)

    self.nineRoomButton = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "隐藏9人", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :align(display.LEFT_CENTER, posX, startY+2*gapY)
        :onButtonStateChanged(function(event)
            self:hiddenLayerButtonClick(1002,event.target:isButtonSelected())
        end)
        :addTo(self.m_hiddenLayerBg)

    self.fullButton = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "隐藏满员", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :align(display.LEFT_CENTER, posX, startY+gapY)
        :onButtonStateChanged(function(event)
            self:hiddenLayerButtonClick(888,event.target:isButtonSelected())
        end)
        :addTo(self.m_hiddenLayerBg)    

    self.emptyButton = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "隐藏空桌", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :align(display.LEFT_CENTER, posX, startY)
        :onButtonStateChanged(function(event)
            self:hiddenLayerButtonClick(999,event.target:isButtonSelected())
        end)
        :addTo(self.m_hiddenLayerBg)

    if self.hiddeFullR then
        self.fullButton:setButtonSelected(true)
    end
    if self.hiddeEmptyR then
        self.emptyButton:setButtonSelected(true)
    end

    if self.hideSixSeatR then
        self.sixRoomButton:setButtonSelected(true)
    end
    if self.hideNineSeatR then
        self.nineRoomButton:setButtonSelected(true)
    end

    self.m_hiddenLayerBg:setVisible(false)

    local hiddenLayerX = setBtn:getPositionX()+40
    local hiddenLayerY = setBtn:getPositionY()
    local hiddenLayerWidth = self.m_hiddenLayerBg:getContentSize().width
    local hiddenLayerHeight = self.m_hiddenLayerBg:getContentSize().height
    self.m_hiddenMasklayer = display.newLayer()
    self:addChild(self.m_hiddenMasklayer)
    self.m_hiddenMasklayer:setTouchEnabled(false)
    self.m_hiddenMasklayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            local pos  = cc.p(event.x, event.y)
            local rect = cc.rect(hiddenLayerX-hiddenLayerWidth, hiddenLayerY-hiddenLayerHeight, 
                hiddenLayerWidth, 250)
            if not cc.rectContainsPoint(rect, pos) then
                self:pressHiddenRoom()
            end
            return true
        end
    end)
    -------------------------------------------------------

    --[[房间名背景]]
    local tempImg = cc.ui.UIImage.new("picdata/hall/hallTableBG.png")
    local searchBg = cc.ui.UIImage.new("picdata/hall/bg_srk.png")
    searchBg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, tempImg:getContentSize().height-searchBg:getContentSize().height/2-60)
        :addTo(self, 1)

    self.searchButton = cc.ui.UIPushButton.new({normal="picdata/hall/btn_rj.png", 
        pressed="picdata/hall/btn_rj2.png", 
        disabled="picdata/hall/btn_rj2.png"})
    self.searchButton:align(display.RIGHT_CENTER, searchBg:getPositionX()+searchBg:getContentSize().width/2-10, 
        searchBg:getPositionY())
        :addTo(self, 1)
        :onButtonClicked(function(event)
            self:pressSearchButton(event)
            end)
        :setTouchSwallowEnabled(false)
    self.searchButton:setButtonLabel("normal", cc.ui.UILabel.new({
        text = "确定入局",
        font = "黑体",
        size = 26,
        color = cc.c3b(255,255,255)
        }))

    tempImg = cc.ui.UIImage.new("picdata/hall/btn_rj.png")
    self.searchInput = CMInput:new({
        -- bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 8,
        -- minLength = 6,
        place     = "输入朋友局ID,和朋友一起切磋",
        color     = cc.c3b(255, 255, 255),
        fontSize  = 24,
        size = cc.size(616,32),
        inputMode = 2
        -- bgPath    = "picdata/privateHall/private_input.png",
        -- inputFlag = 0
    })
    self.searchInput:setPosition(searchBg:getPositionX()-70, searchBg:getPositionY())
    self.searchInput:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(self.searchInput, 1)
    -- self.searchInput:setVisible(true)
    ------------------------------------------------------------------------------------------------
    cc.ui.UIImage.new("picdata/hall/hallTableBG.png")
        :align(display.CENTER_BOTTOM, CONFIG_SCREEN_WIDTH/2, -10)
        :addTo(self)
    
    ------------------------------------------------------------------------------------------------

    self.m_hall:enterHallRequest()
    self.m_hall:getBulletin()
    -- self.clubId = 186
    if self.clubId then
        self.m_hall:getClubTableLists(self.clubId)
    else
        self.m_hall:getTableLists("ALL",PRIVATE_TYPE,"ASC")
    end
    self:refreshRoom()
end

function PrivateHallView:ctor(params)
    self.showHiddeLayer = true
    self.hiddeFullR = UserDefaultSetting:getInstance():getHideFullRoom()
    self.hiddeEmptyR = UserDefaultSetting:getInstance():getHideEmptyRoom()
    self.showSixSeatR = UserDefaultSetting:getInstance():getShowSixSeat()
    self.showNineSeatR = UserDefaultSetting:getInstance():getShowNineSeat()
    self.hideSixSeatR = UserDefaultSetting:getInstance():getHideSixSeat()
    self.hideNineSeatR = UserDefaultSetting:getInstance():getHideNineSeat()
    
    self.m_hall = require("app.Logic.Hall.DebaoHall"):new()
    self.m_hall:setHallCallback(self)
    self.m_hall:addTo(self)
    --[[上报点击情况]]
    self.m_hall:dataReport()
    self.leftGameLevel = Left_Private

    if type(params)~="table" then
        params = {}
    end

    params = params or {}
    self.clubId = params.clubId or nil
end

function PrivateHallView:showSearchInput(event)
    self.searchInput:setVisible(true)
end

function PrivateHallView:hideSearchInput(event)
    self.searchInput:setVisible(false)
end

function PrivateHallView:pressSearchButton(event)
    local id = self.searchInput:getText()
    if id=="" then
        local text = "id不能为空"
        local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = true})
        CMOpen(CMToolTipView,self)
        return
    end
    self.m_hall:getDiyTableIdByFid(id)
end



function PrivateHallView:onExit()
    if self.eventShowSearch then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.eventShowSearch)
        self.eventShowSearch = nil
    end
    if self.eventHideSearch then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(self.eventHideSearch)
        self.eventHideSearch = nil
    end
    TourneyGuideReceiver:sharedInstance():registerCurrentView(nil)
    QManagerListener:Detach(ePrivateHallViewID)
    QManagerListener:Notify({layerID = eFTMyTeamLayerID,tag = "showInputBox",index = 3})
end

function PrivateHallView:onEnter()
    TourneyGuideReceiver:sharedInstance():registerCurrentView(self)
    self.eventShowSearch = cc.EventListenerCustom:create("ShowPrivateHallSearch", function(event)
            self:showSearchInput(event)
        end)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.eventShowSearch, 12)

    self.eventHideSearch = cc.EventListenerCustom:create("HidePrivateHallSearch", function(event)
            self:hideSearchInput(event)
        end)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.eventHideSearch, 12)
    -- SHOW_FINAL_STATICS = "GAME001#1465358269060000CASH1278"
    if SHOW_FINAL_STATICS then
        local layer = require("app.GUI.dialogs.FinalStaticsDialog").new({m_tableId = SHOW_FINAL_STATICS})
        self:addChild(layer, 1001)
        SHOW_FINAL_STATICS = nil
        self:hideSearchInput()
    end
     QManagerListener:Attach({{layerID = ePrivateHallViewID,layer = self}})
end
function PrivateHallView:updateCallBack(data)
    if data.tag == "showInputBox" then
        self.searchInput:setVisible(true)
    end
end
function PrivateHallView:refreshMySilverCoin()
    self.m_goldNum:setString(StringFormat:FormatDecimals(myInfo.data.totalChips,2))
    self.m_scoreNum:setString(StringFormat:FormatDecimals(myInfo.data.userDebaoDiamond,2))
end

function PrivateHallView:showBulletin(bulletinStr)
    if bulletinStr ~= "" then
       -- dump("PrivateHallView:showBulletin这里还需要完善") 
    end
end

function PrivateHallView:pressBack()
	CMClose(self, true)
    GameSceneManager:setJumpLayer(nil) 

    local event = cc.EventCustom:new("GetUserTableList")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function PrivateHallView:pressHiddenRoom()
	if self.m_hiddenLayerBg:isVisible() then
		self.m_hiddenLayerBg:setVisible(false)
    	self.m_hiddenMasklayer:setTouchEnabled(false)
	else
		self.m_hiddenLayerBg:setVisible(true)
    	self.m_hiddenMasklayer:setTouchEnabled(true)
	end
end

function PrivateHallView:hiddenLayerButtonClick(tag, isSelected)
    if tag == 888 then
        self.hiddeFullR = isSelected
        UserDefaultSetting:getInstance():setHideFullRoom(self.hiddeFullR)
    elseif tag == 999 then
        self.hiddeEmptyR = isSelected
        UserDefaultSetting:getInstance():setHideEmptyRoom(self.hiddeEmptyR)
    elseif tag == 1001 then
        self.hideSixSeatR = isSelected
        UserDefaultSetting:getInstance():setHideSixSeat(self.hideSixSeatR)
        if self.m_checkBoxTag == true then
            self.m_checkBoxTag = false
        end

        if self.hideSixSeatR == true and self.hideNineSeatR == true then 
            self.m_checkBoxTag = true
            self.nineRoomButton:setButtonSelected(false)
            return
        end
    elseif tag == 1002 then
        self.hideNineSeatR = isSelected
        UserDefaultSetting:getInstance():setHideNineSeat(self.hideNineSeatR)
        if self.m_checkBoxTag == true then
            self.m_checkBoxTag = false
        end

        if self.hideSixSeatR == true and self.hideNineSeatR == true then 
            self.m_checkBoxTag = true
            self.sixRoomButton:setButtonSelected(false)
            return
        end
    end
    self:refreshRoom()
end

function PrivateHallView:refreshRoom()
    if true then return end
    if self.hideSixSeatR == false and self.hideNineSeatR == false and
        self.hiddeFullR == false and self.hiddeEmptyR == false then
        -- dump("ShowAll")
        self.m_hall:hideRoomNew(ListShowType.ShowAll)
    elseif self.hideSixSeatR == true and self.hideNineSeatR == false and
        self.hiddeFullR == false and self.hiddeEmptyR == false then
        -- dump("HideSix")
        self.m_hall:hideRoomNew(ListShowType.HideSix)
    elseif self.hideSixSeatR == false and self.hideNineSeatR == true and
        self.hiddeFullR == false and self.hiddeEmptyR == false then
        -- dump("HideNine")
        self.m_hall:hideRoomNew(ListShowType.HideNine)
    elseif self.hideSixSeatR == false and self.hideNineSeatR == false and
        self.hiddeFullR == false and self.hiddeEmptyR == true then
        -- dump("HideEmpty")
        self.m_hall:hideRoomNew(ListShowType.HideEmpty)
    elseif self.hideSixSeatR == true and self.hideNineSeatR == false and
        self.hiddeFullR == false and self.hiddeEmptyR == true then
        -- dump("HideEmptyHideSix")
        self.m_hall:hideRoomNew(ListShowType.HideEmptyHideSix)
    elseif self.hideSixSeatR == false and self.hideNineSeatR == true and
        self.hiddeFullR == false and self.hiddeEmptyR == true then
        -- dump("HideEmptyHideNine")
        self.m_hall:hideRoomNew(ListShowType.HideEmptyHideNine)
    elseif self.hideSixSeatR == false and self.hideNineSeatR == false and
        self.hiddeFullR == true and self.hiddeEmptyR == false then
        -- dump("HideFull")
        self.m_hall:hideRoomNew(ListShowType.HideFull)
    elseif self.hideSixSeatR == true and self.hideNineSeatR == false and
        self.hiddeFullR == true and self.hiddeEmptyR == false then
        -- dump("HideFullHideSix")
        self.m_hall:hideRoomNew(ListShowType.HideFullHideSix)
    elseif self.hideSixSeatR == false and self.hideNineSeatR == true and
        self.hiddeFullR == true and self.hiddeEmptyR == false then
        -- dump("HideFullHideNine")
        self.m_hall:hideRoomNew(ListShowType.HideFullHideNine)
    elseif self.hideSixSeatR == false and self.hideNineSeatR == false and
        self.hiddeFullR == true and self.hiddeEmptyR == true then
        -- dump("HideEmptyHideFull")
        self.m_hall:hideRoomNew(ListShowType.HideEmptyHideFull)
    elseif self.hideSixSeatR == true and self.hideNineSeatR == false and
        self.hiddeFullR == true and self.hiddeEmptyR == true then
        -- dump("HideEmptyHideFullHideSix")
        self.m_hall:hideRoomNew(ListShowType.HideEmptyHideFullHideSix)
    elseif self.hideSixSeatR == false and self.hideNineSeatR == true and
        self.hiddeFullR == true and self.hiddeEmptyR == true then
        -- dump("HideEmptyHideFullHideNine")
        self.m_hall:hideRoomNew(ListShowType.HideEmptyHideFullHideNine)
    end
end

function PrivateHallView:showTableListNew(myTableList)
    local x,y
    if self.hallTableView then
        x,y=self.hallTableView.tableView:getScrollNode():getPosition()
        self:removeChild(self.hallTableView, true)
        self.hallTableView = nil
    end
    
    self.hallTableView = require("app.GUI.hallview.HallTableView"):createWithData(myTableList, self.leftGameLevel, bShowBullet)
    self.hallTableView:addTo(self)
    self.hallTableView:setHallEnterRoomDelegate(self)

    if y then
        self.hallTableView:scrollTo(x,y)
    end
end

function PrivateHallView:showClubTableList(myTableList)
    if self.hallTableView then
        self:removeChild(self.hallTableView, true)
        self.hallTableView = nil
    end

    self.hallTableView = require("app.GUI.hallview.HallTableView"):createWithData(myTableList, self.leftGameLevel, bShowBullet)
    self.hallTableView:addTo(self)
    self.hallTableView:setHallEnterRoomDelegate(self)
end

--[[进入游戏房间]]
function PrivateHallView:hallEnterRoom(eachInfo)
    --[[记录进入当前进入的场次级别]]
    local parent = eachInfo.parent or self
    self.m_enterMatchInfo = eachInfo
    self.tableId = eachInfo.tableId
    self.playType = eachInfo.playType
    if eachInfo.playType == "MTT" or eachInfo.playType == "SNG" then
        eachInfo.matchId = eachInfo.uniqKey
        -- CMOpen(require("app.GUI.matchWait.MatchWaitInfo"), self, eachInfo, true, 1)
        -- return 
    end
    if eachInfo.playType == "SNG" or eachInfo.playType == "MTT" then
        -- if string.find(eachInfo.applyList,myInfo.data.userId..":") then
        --     CMShowTip("您已经报名该赛事!")
        --     return
        -- end
        -- self.tableId = eachInfo.uniqKey
        -- local bigBlind = StringFormat:FormatDecimals(eachInfo.bigBlind,-1)
        -- local smallBlind=StringFormat:FormatDecimals(eachInfo.smallBlind,-1)
        -- local params = {callback = function(node) self:joinSng(node) end, matchName = eachInfo.tableName, matchLevel = ""..smallBlind.."/"..bigBlind,
        --     startChips = eachInfo.buyChipsMin, blindTime = eachInfo.upSeconds}
        -- local RewardLayer = require("app.GUI.dialogs.MatchApplyDialog").new(params) 

        -- CMOpen(RewardLayer, parent, 0, 1, kZMax)

        -- self:joinSng()
            -- local event = cc.EventCustom:new("HidePrivateHallSearch")
            -- cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

        self:enterMatchWaitRoom()
        return
    end
    if eachInfo.tableOwner~=myInfo.data.userId then

        local dialog = require("app.GUI.hallview.EnterPasswordDialog").new({m_pCallbackUI = function(params) self:enterRoom(params) end})
        dialog:addTo(parent, 1001)
        dialog:show()
        dialog:showPrivateHallSearch(true)
    else
        if self.m_hall then
            self.m_hall:joinTable(eachInfo.tableId)
        end
    end
end

function PrivateHallView:enterMatchWaitRoom(params)
    params = params or {}
    local event = cc.EventCustom:new("HidePrivateHallSearch")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    self.m_enterMatchInfo.password = params.passsword
    CMOpen(require("app.GUI.matchWait.MatchWaitInfo"), self, self.m_enterMatchInfo, true, 1)
end

function PrivateHallView:enterRoom(params)
    params = params or {}
    local event = cc.EventCustom:new("HidePrivateHallSearch")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    if self.m_hall then
		self.m_hall:joinTable(self.tableId, params.passsword, self.playType)
	end
end

function PrivateHallView:searchRoomCallback(data)
    self.searchRoomInfo = data
    local eachInfo = {}
    eachInfo.tableId = self.searchRoomInfo.tableId
    self:hallEnterRoom(eachInfo)
end

function PrivateHallView:enterRoomFromTableId(tableId, passWord) 
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = tableId,passWord = passWord,m_isFromMainPage = true,from = GameSceneManager.AllLayer.ZIDINGYI,needRongYun = true})
end

function PrivateHallView:showHint(text, isSuc)
    text = text or ""
    isSuc = isSuc or false
    local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = isSuc})
    CMOpen(CMToolTipView,self)
end

function PrivateHallView:showTip(text)
    text = text or ""
    CMShowTip(text)
end

function PrivateHallView:joinSng(node)
    local dialog = require("app.GUI.hallview.EnterPasswordDialog").new({m_pCallbackUI = function(params) self:enterRoom(params) end})
    dialog:addTo(self, 1001)
    dialog:show()
    dialog:showPrivateHallSearch(true)
end

return PrivateHallView