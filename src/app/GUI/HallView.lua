local GameLayerManager  = require("app.GUI.GameLayerManager")
local MusicPlayer = require("app.Tools.MusicPlayer")
local myInfo = require("app.Model.Login.MyInfo")
local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")

--[[
Callbacks:
    "pressBuyNumTitle",
    "pressPlayNum",
    "pressPrimary",
    "pressIntermediate",
    "pressSenior",
    "pressPrivate",
    "pressExchangegold",
    "pressExchangescore",
    "pressQuickStart",
    "pressHiddenRoom",
    "backToMainpage",

Members:
    self.iconLeft CCSprite
    self.iconRight CCSprite
    self.primaryMenuBG CCSprite
    self.intermediateMenuBG CCSprite
    self.seniorMenuBG CCSprite
    self.privateMenuBG CCSprite
    self.m_score CCLabelTTF
    self.m_gold CCLabelTTF
    self.pleaseWait CCLabelTTF
    self.createRoom CCLabelTTF
]]
local HallView = Oop.class("HallView", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.GUI", "ccb")
    return CCBLoader:load("HallView", owner)
end)
---
function HallView:ctor(showType)
    -- @TODO: constructor
    self.m_checkBoxTag = false
    self.m_bSoundEnabled = false
    local CMMaskLayer = CMMask.new()
    self.m_backMenu:getParent():addChild(CMMaskLayer)
    local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/MainPage_dif/mainpageBG.png")
    self.m_hallBg:setTexture(tmpFilename)

    local toolBarTop = require("app.Component.ToolBarTop"):new()
    toolBarTop:setPosition(CONFIG_SCREEN_WIDTH/2,display.height - 50)
    self:addChild(toolBarTop, 2)
    self.m_goldNum = toolBarTop.m_goldNum
    self.m_scoreNum = toolBarTop.m_scoreNum

    --[[按钮重新定义]]
    self.m_backMenu:setVisible(false)
    self.m_hiddenRoomMenu:setVisible(false)
    self.m_quickStartMenu:setVisible(false)
    self.m_hiddenRoomMenu:setEnabled(false)
    self.m_backMenu:setEnabled(false)
    self.m_quickStartMenu:setEnabled(false)
    self.privateItem:setVisible(false)

    local backMenu = cc.ui.UIPushButton.new({
        normal = "back.png",
        pressed = "back.png",
        disabled = "back.png",
        })
        :onButtonClicked(function(event) 
            self:backToMainpage()
            end)
        :addTo(self.m_backMenu:getParent()):align(display.CENTER, self.m_backMenu:getPositionX(), self.m_backMenu:getPositionY())
        :setTouchSwallowEnabled(false)

    local hiddenRoomMenu = cc.ui.UIPushButton.new({
        normal = "setBtn.png",
        pressed = "setBtn2.png",
        disabled = "setBtn2.png",
        })
        :onButtonClicked(function(event) 
            self:pressHiddenRoom()
            end)
        :addTo(self.m_hiddenRoomMenu:getParent()):align(display.CENTER, self.m_hiddenRoomMenu:getPositionX(), self.m_hiddenRoomMenu:getPositionY())
        :setTouchSwallowEnabled(false)

    self.quickStartMenu = cc.ui.UIPushButton.new({
        normal = "quickStart.png",
        pressed = "quickStart.png",
        disabled = "quickStart.png",
        })
        :onButtonClicked(function(event)
            self:pressQuickStart()
            end)
        -- :addTo(self.m_quickStartMenu:getParent()):align(display.CENTER, self.m_quickStartMenu:getPositionX(), self.m_quickStartMenu:getPositionY())
    self.quickStartMenu:addTo(self):align(display.CENTER, self.m_quickStartMenu:getPositionX()-480+CONFIG_SCREEN_WIDTH/2, self.m_quickStartMenu:getPositionY())
        :setTouchSwallowEnabled(false)

    self.createRoomMenu = cc.ui.UIPushButton.new({
        normal = "createRoom.png",
        pressed = "createRoom1.png",
        disabled = "createRoom1.png",
        })
        :onButtonClicked(function(event)
            self:pressCreateRoom()
            end)
        self.createRoomMenu:addTo(self):align(display.CENTER, self.quickStartMenu:getPositionX(), self.quickStartMenu:getPositionY())
        :setTouchSwallowEnabled(false)
    self.createRoomMenu:setVisible(false) 

    self.pleaseWait:setVisible(false)
    self.createRoom:setVisible(false)
    self.currentCourse = nil              --当前场次
    -- self:currentCourseHighlight(self.currentCourse)

    --[[初始化工作]]
    -------------------------------------------------------
    self.leftGameLevel = Left_PrimaryField
    self.showHiddeLayer = true
    self.hiddeFullR = UserDefaultSetting:getInstance():getHideFullRoom()
    self.hiddeEmptyR = UserDefaultSetting:getInstance():getHideEmptyRoom()
    self.showSixSeatR = UserDefaultSetting:getInstance():getShowSixSeat()
    self.showNineSeatR = UserDefaultSetting:getInstance():getShowNineSeat()
    self.hideSixSeatR = UserDefaultSetting:getInstance():getHideSixSeat()
    self.hideNineSeatR = UserDefaultSetting:getInstance():getHideNineSeat()
    -- UserDefaultSetting:getInstance():setHideFullRoom(false)
    -- UserDefaultSetting:getInstance():setHideEmptyRoom(false)
    -- dump(self.hiddeFullR)
    -- print(self.hiddeEmptyR)
    self.tableUp = true
    self.blindUp = true
    self.curNumUp = true
    self.buyUp = true
    self.m_hall = require("app.Logic.Hall.DebaoHall"):new()
    self.m_hall:setHallCallback(self)
    self.m_hall:addTo(self)

    self.firstIn = true
    self.m_bBulletShow = false
    self.m_isRakePointShow = false

    -------------------------------------------------------
    self.m_hall:enterHallRequest()
    self.m_hall:getBulletin()
    --[[上报点击情况]]
    self.m_hall:dataReport()

    --[[缓冲标识]]
    self.m_pLoadingView = require("app.GUI.BuyLoadingScene"):new()
    self:addChild(self.m_pLoadingView, 1000)

    --[[隐藏按钮]]
    -------------------------------------------------------
    self.sixRoomButton = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "隐藏6人", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :align(display.LEFT_CENTER, self.sixRoomNode:getPositionX(), self.sixRoomNode:getPositionY())
        :onButtonStateChanged(function(event)
            self:hiddenLayerButtonClick(1001,event.target:isButtonSelected())
        end)
        :addTo(self.sixRoomNode:getParent())

    self.nineRoomButton = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "隐藏9人", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :align(display.LEFT_CENTER, self.nineRoomNode:getPositionX(), self.nineRoomNode:getPositionY())
        :onButtonStateChanged(function(event)
            self:hiddenLayerButtonClick(1002,event.target:isButtonSelected())
        end)
        :addTo(self.sixRoomNode:getParent())

    self.fullButton = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "隐藏满员", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :align(display.LEFT_CENTER, self.fullNode:getPositionX(), self.fullNode:getPositionY())
        :onButtonStateChanged(function(event)
            self:hiddenLayerButtonClick(888,event.target:isButtonSelected())
        end)
        :addTo(self.sixRoomNode:getParent())    

    self.emptyButton = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :setButtonLabel(cc.ui.UILabel.new({text = "隐藏空桌", size = 16,  color = display.COLOR_WHITE}))
        :setButtonLabelOffset(40, 0)
        :setButtonLabelAlignment(display.LEFT_CENTER)
        :align(display.LEFT_CENTER, self.emptyNode:getPositionX(), self.emptyNode:getPositionY())
        :onButtonStateChanged(function(event)
            self:hiddenLayerButtonClick(999,event.target:isButtonSelected())
        end)
        :addTo(self.sixRoomNode:getParent())

    -- self:hiddeFullRoom(self.hiddeFullR)
    self:refreshRoom()
    if self.hiddeFullR then
        self.fullButton:setButtonSelected(true)
    end
    if self.hiddeEmptyR then
        self.emptyButton:setButtonSelected(true)
    end
    -- if not self.showSixSeatR then
    --     self.sixRoomButton:setButtonSelected(true)
    -- end
    -- if not self.showNineSeatR then
    --     self.nineRoomButton:setButtonSelected(true)
    -- end

    if self.hideSixSeatR then
        self.sixRoomButton:setButtonSelected(true)
    end
    if self.hideNineSeatR then
        self.nineRoomButton:setButtonSelected(true)
    end

    self.hiddenLayer:setVisible(false)
    self.hiddenLayer:setLocalZOrder(3)
    self.m_hiddenLayerBg:setLocalZOrder(3)

    local hiddenLayerX = self.m_hiddenLayerBg:getPositionX()
    local hiddenLayerY = self.m_hiddenLayerBg:getPositionY()
    local hiddenLayerWidth = self.m_hiddenLayerBg:getContentSize().width
    local hiddenLayerHeight = self.m_hiddenLayerBg:getContentSize().height
    self.m_hiddenMasklayer = display.newLayer()
    self.hiddenLayer:addChild(self.m_hiddenMasklayer)
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
    self:ordinaryFieldLayerInit()
    self:changeLeftIndex(self.leftGameLevel)

    self.m_hiddenLayerBg:setTouchEnabled(true)
    self.m_hiddenLayerBg:setTouchSwallowEnabled(true)

    self.m_showType = showType

    if self.m_showType == COURSE_PRIMARY then
        self:pressPrimary()
    elseif self.m_showType == COURSE_INTERMEDIATE then
        self:pressIntermediate()
    elseif self.m_showType == COURSE_SENIOR then
        self:pressSenior()
    elseif self.m_showType == COURSE_PRIVATE then
        self:pressPrivate()
    end
    self:registerScriptHandler(handler(self, self.onNodeEvent))
end

function HallView:onNodeEvent(event)
    if event == "enter" then
        self.m_bSoundEnabled = true
        TourneyGuideReceiver:sharedInstance():registerCurrentView(self)
    
        ProfitNotification:sharedInstance():registerCurrentView(self, eProViewHallView)

        -- self.m_refreshInfoId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        --     handler(self, self.refreshInfo),15.0,false)

    -- local value = cc.UserDefault:getInstance():getIntegerForKey("SHOW_FINAL_STATICS"..myInfo.data.userId, 1)
    -- if value==1 then
    --     local tableId = cc.UserDefault:getInstance():getIntegerForKey("FINAL_STATICS_ID"..myInfo.data.userId)
    --     CMOpen(require("app.GUI.dialogs.FinalStaticsDialog"), self, 
    --         {m_tableId = tableId}, true, 1001)

    --     cc.UserDefault:getInstance():setIntegerForKey("SHOW_FINAL_STATICS"..myInfo.data.userId, 0)
    --     cc.UserDefault:getInstance():flush()
    -- end
    -- elseif event == "exit" then

    --     -- if self.m_refreshInfoId then
    --     --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_refreshInfoId)
    --     -- end
    elseif event == "exit" then
        self:removeMemory()
    end
end
function HallView:removeMemory()
    local memoryPath = {}
    memoryPath[1] = require("app.GUI.allrespath.HallPath")
   for j = 1,#memoryPath do 
        for i,v in pairs(memoryPath[j]) do
            display.removeSpriteFrameByImageName(v)
        end
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function HallView:refreshInfo(dt)
    DBHttpRequest:getAccountInfo(function(event) self:httpResponse(event)end)
end

function HallView:hiddenLayerButtonClick(tag, isSelected)
    MusicPlayer:getInstance():playButtonSound()
    if tag == 888 then
        self.hiddeFullR = isSelected
        UserDefaultSetting:getInstance():setHideFullRoom(self.hiddeFullR)
        -- self:hiddeFullRoom(self.hiddeFullR)
    elseif tag == 999 then
        self.hiddeEmptyR = isSelected
        UserDefaultSetting:getInstance():setHideEmptyRoom(self.hiddeEmptyR)
        -- self:hiddeEmptyRoom(self.hiddeEmptyR)
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
        -- self.showSixSeatR = not isSelected
        -- UserDefaultSetting:getInstance():setShowSixSeat(self.showSixSeatR)
        -- if self.showNineSeatR then
        --     if self.showSixSeatR then 
        --         self:showAllRoom()
        --     else
        --         self:showNineSeat()
        --     end
        -- else
        --     if self.showSixSeatR then 
        --         self:showSixSeat()
        --     end
        -- end
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
        -- self.showNineSeatR = not isSelected
        -- UserDefaultSetting:getInstance():setShowNineSeat(self.showNineSeatR)
        -- if self.showSixSeatR then
        --     if self.showNineSeatR then
        --         self:showAllRoom()
        --     else
        --         self:showSixSeat()
        --     end
        -- else
        --     if self.showNineSeatR then 
        --         self:showNineSeat()
        --     end
        -- end
    end
    self:refreshRoom()
end

function HallView:refreshRoom()
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

function HallView:hiddenRoom()
    if self.hiddeFullR then
        if self.hiddeEmptyR then
            self.m_hall:hideRoom(Show_All)
        else
            self.m_hall:hideRoom(Hide_FullShow_Empty)
        end
    else
        if self.hiddeEmptyR then
            self.m_hall:hideRoom(Show_FullHide_Empty)
        else
            self.m_hall:hideRoom(Show_All)
        end
    end
end

function HallView:hiddeFullRoom(hide)
    self:hiddenRoom()
end

function HallView:hiddeEmptyRoom(hide)
    self:hiddenRoom()
end

function HallView:showSixSeat()
    self.m_hall:hideRoom(show_sixSeat)
end

function HallView:showNineSeat()
    self.m_hall:hideRoom(show_nineSeat)
end

function HallView:showAllRoom()
    self.m_hall:hideRoom(Show_All)
end
 
function HallView:currentCourseHighlight(index)
    --隐藏场次按钮的背景
    -- self.primaryMenuBG:setVisible(false)
    -- self.intermediateMenuBG:setVisible(false)
    -- self.seniorMenuBG:setVisible(false)
    -- self.privateMenuBG:setVisible(false)
    --场次按钮都置为未选中状态
    self.primaryItem:unselected()
    self.intermediateItem:unselected()
    self.seniorItem:unselected()
    self.privateItem:unselected()
    -- 显示选中场次的背景、将菜单置为选中状态

    if index == COURSE_INTERMEDIATE then 
        self.intermediateItem:selected()
    elseif index == COURSE_SENIOR then
        self.seniorItem:selected()
    elseif index == COURSE_PRIVATE then
        self.privateItem:selected()
    else
        self.primaryItem:selected()
    end
end

function HallView:showBulletin(bulletinStr)
    if bulletinStr ~= "" then
       normal_info_log("HallView:showBulletin这里还需要完善") 
    end
end

function HallView:refreshMySilverCoin()
    self.m_goldNum:setString(StringFormat:FormatDecimals(myInfo.data.totalChips,2))
    self.m_scoreNum:setString(StringFormat:FormatDecimals(myInfo.data.diamondBalance,2))
end

function HallView:ordinaryFieldLayerInit()
    local leaveType = UserDefaultSetting:getInstance():getGameLeaveType()
    self.leftGameLevel = Left_PrimaryField
    if leaveType == 0 then
        self.leftGameLevel = Left_PrimaryField
    elseif leaveType == 1 then
        self.currentCourse = COURSE_INTERMEDIATE
        self.leftGameLevel = Left_IntermediateCourse
    elseif leaveType == 2 then
        self.currentCourse = COURSE_SENIOR
        self.leftGameLevel = Left_Senior
    elseif leaveType == 3 then
        self.leftGameLevel = Left_RakePoint
    elseif leaveType == 4 then
        self.currentCourse = COURSE_PRIVATE
        self.leftGameLevel = Left_Private
    end
    self:currentCourseHighlight(self.currentCourse)
    self.sequenceType = Sequence_CurNum
    self.curNumUp = true
end

--[[从数据库获取上次退出游戏时选择的游戏场次，默认为NoviceField]]
function HallView:changeLeftIndex(type)

    self.m_pLoadingView:setVisible(false)
    self.leftGameLevel = type
    if self.leftGameLevel == Left_PrimaryField then
        self.m_hall:getTableLists(GOLD_TYPE,PRIMARY_TYPE,"DESC")
    elseif self.leftGameLevel == Left_IntermediateCourse then
        self.m_hall:getTableLists(GOLD_TYPE,MIDDLE_TYPE,"DESC")
    elseif self.leftGameLevel == Left_Senior then
        self.m_hall:getTableLists(GOLD_TYPE,HIGH_TYPE,"DESC")
    elseif self.leftGameLevel == Left_RakePoint then
        self.m_hall:getTableLists(RAKEPOINT_TYPE,ALL_TYPE,"ASC")
    elseif self.leftGameLevel == Left_Private then
        self.m_hall:getTableLists(GOLD_TYPE,PRIVATE_TYPE,"ASC")
    end
    if self.leftGameLevel == Left_Private then
        self.quickStartMenu:setVisible(false)
        self.createRoomMenu:setVisible(true) 
    else
        self.quickStartMenu:setVisible(true)
        self.createRoomMenu:setVisible(false) 
    end
end

function HallView:showTableListNew(myTableList)
    if self.hallTableView then
        self:removeChild(self.hallTableView, true)
        self.hallTableView = nil
    end
    self.hallTableView = require("app.GUI.hallview.HallTableView"):createWithData(myTableList, self.leftGameLevel, bShowBullet)
    self.hallTableView:addTo(self)
    self.hallTableView:setHallEnterRoomDelegate(self)
end

--[[按钮事件]]
-----------------------------------------------------------
function HallView:pressBuyNumTitle(sender, event)
    -- @TODO: implement this
end

function HallView:pressPlayNum(sender, event)
    -- @TODO: implement this
end

function HallView:pressPrimary(sender, event, needSound)
    local lastCourse = self.currentCourse
    self.currentCourse = COURSE_PRIMARY
    self:currentCourseHighlight(self.currentCourse)
    if self.m_bSoundEnabled == COURSE_PRIMARY then
        return
    end
    if lastCourse then
        MusicPlayer:getInstance():playButtonSound()
    end
    self:changeLeftIndex(Left_PrimaryField)
end

function HallView:pressIntermediate(sender, event)
    local lastCourse = self.currentCourse
    self.currentCourse = COURSE_INTERMEDIATE
    self:currentCourseHighlight(self.currentCourse)
    if self.m_bSoundEnabled == COURSE_INTERMEDIATE then
        return
    end
    if self.m_bSoundEnabled then
        MusicPlayer:getInstance():playButtonSound()
    end
    self:changeLeftIndex(Left_IntermediateCourse)
end

function HallView:pressSenior(sender, event)
    local lastCourse = self.currentCourse
    self.currentCourse = COURSE_SENIOR
    self:currentCourseHighlight(self.currentCourse)
    if lastCourse == COURSE_SENIOR then
        return
    end
    if self.m_bSoundEnabled then
        MusicPlayer:getInstance():playButtonSound()
    end
    self:changeLeftIndex(Left_Senior)
end

function HallView:pressPrivate(sender, event)
    local lastCourse = self.currentCourse
    self.currentCourse = COURSE_PRIVATE
    self:currentCourseHighlight(self.currentCourse)
    if lastCourse == COURSE_PRIVATE then
        return
    end
    if self.m_bSoundEnabled then
        MusicPlayer:getInstance():playButtonSound()
    end
    self:changeLeftIndex(Left_Private)
end

function HallView:pressExchangegold(sender, event)
    -- @TODO: implement this
end

function HallView:pressExchangescore(sender, event)
    -- @TODO: implement this
end

function HallView:pressQuickStart(sender, event)
    -- local roomViewManager = require("app.GUI.RoomViewManager"):createRoomViewManager()
    -- roomViewManager.m_isFromMainPage = true
    -- GameSceneManager:switchSceneWithNode(roomViewManager)
    -- roomViewManager:quickStart()
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{m_isFromMainPage = true,isQuickStart = true })
end

function HallView:pressCreateRoom(sender, event)
    local AlertDialog = require("app.Component.CMAlertDialog").new({text = "功能正在建设中，敬请期待！",})
    CMOpen(AlertDialog,self)
end

function HallView:pressHiddenRoom(sender, event)
    if self.hiddenLayer:isVisible() == false then
        self.hiddenLayer:setVisible(true)
        self.m_hiddenMasklayer:setTouchEnabled(true)
    else
        self.hiddenLayer:setVisible(false)
        self.m_hiddenMasklayer:setTouchEnabled(false)
    end
end

function HallView:backToMainpage(sender, event)
    UserDefaultSetting:getInstance():setGameLeaveType(self.leftGameLevel)
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
    -- local scene = display.newScene()
    -- local m_layer = require("app.GUI.mainPage.MainPageView"):new() 
    -- scene:addChild(m_layer)
    -- GameSceneManager:switchScene(scene)
end
-----------------------------------------------------------
--[[进入游戏房间]]
function HallView:hallEnterRoom(eachInfo)
    --[[记录进入当前进入的场次级别]]
    UserDefaultSetting:getInstance():setGameLeaveType(self.leftGameLevel)

    if TRUNK_VERSION==DEBAO_TRUNK then
        if eachInfo.password == "YES" and eachInfo.tableOwner~=myInfo.data.userId then
            if self.dialog then
                self.dialog = nil
            end
            self.dialog = require("app.GUI.hallview.EnterPasswordDialog"):new()
            self.dialog:addTo(self, 1001)
            self.dialog:show()
        elseif eachInfo.smallBlind == myInfo.data.leastSB and myInfo:getTotalChips()>=eachInfo.buyChipsMin*100 then
            local tmpNum = eachInfo.buyChipsMin*100
            local tmpStr = " 亲爱的高手，您的金币已经超过"..tmpNum..",\n不要再欺负菜鸟了,请前往更高级的牌桌打牌吧!"
            self.alertView = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
                    tmpStr,Lang_Button_Confirm)
            self.alertView:show()
        elseif tonumber(myInfo.data.totalChips) < 1000 and eachInfo.listType == "PRIMARY" then
            local view = require("app.Component.EAlertView"):alertView(
                self,self,Lang_Title_Prompt,Lang_QuickStartErrorNotEnoughMoney,Lang_Button_Cancel,Lang_Button_Charge)
            view:show()
            view:setTag(101) --筹码不够提示充值;
        elseif tonumber(myInfo.data.totalChips) < tonumber(eachInfo.buyChipsMin) and eachInfo.listType == "PRIMARY" then
            local tmpStr = "您的金币不足,请前往盲注级别更小牌桌打牌吧!"
            self.alertView = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
                    tmpStr,Lang_Button_Confirm)
            self.alertView:show()
        else
            if eachInfo.listType=="PRIMARY" then
                self.m_hall:tableLevelToGameAddr(eachInfo.bigBlind, eachInfo.smallBlind)
            else
                if self.m_hall then
                    self.m_hall:joinTable(eachInfo.tableId)
                end
            end
        end
    else

    end
end

function HallView:enterRoomFromTableId(tableId, passWord)
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = tableId,passWord = passWord,m_isGameType = true})
    -- local roomViewManager = require("app.GUI.RoomViewManager"):createRoomViewManager()
    -- local scene = display.newScene()
    -- scene:addChild(roomViewManager)
    -- GameSceneManager:switchScene(scene)
    -- roomViewManager.m_isGameType = true
    -- roomViewManager:enterRoomWithTableId(tableId, passWord)
end

function HallView:enterRoom(params)
    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,params)
end

function HallView:clickButtonAtIndex(alertView, index)
    local tag = alertView:getTag()
    if tag == 101 then --筹码不够提示充值;
        if index==1 then
            GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self)
        end
    end
end

return HallView