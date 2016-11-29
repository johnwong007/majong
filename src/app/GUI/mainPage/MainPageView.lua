local CCBLoader = require("CCB.Loader")
local Oop = require("Oop.init")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
local RoomViewManager = require("app.GUI.RoomViewManager")
local GameLayerManager  = require("app.GUI.GameLayerManager")
local NetCallBack = require("app.Network.Http.NetCallBack")
require("app.Tools.StringFormat")
require("app.CommonDataDefine.CommonDataDefine")
require("app.GUI.ProfitNotification")
local MusicPlayer = require("app.Tools.MusicPlayer")
SWITCH_TO_EGSHall="EGSHall"


--[[
Callbacks:
    

Members:
    
]]
local MainPageView = Oop.class("MainPageView", function(owner)
    -- @param "UI.ccb" => code root
    -- @param "ccb/"   => ccbi folder
    CCBLoader:setRootPath("app.GUI.mainPage", "ccb")
    return CCBLoader:load("MainPageView", owner)
end)
--[[
    推送连接
]]
function MainPageView:connectPushSocket()
    require("app.Network.Socket.PushCommandRequest")
    self.pushRequest = PushCommandRequest:shareInstance()
end
function MainPageView:ctor()
    -- @TODO: constructor
     local CMMaskLayer = CMMask.new()
    self:addChild(CMMaskLayer)
    self.mAllBtn = {}
    self:manualLoadxml()

    self:connectPushSocket()

    GameSceneManager.mCurSceneType = GameSceneManager.AllScene.MainPageView
    self.m_mainPage = require("app.Logic.mainPage.DebaoMainPage"):new()
    self.m_mainPage:setMainPageCallback(self)
    self.m_mainPage:addTo(self)


    self:registerScriptHandler(handler(self, self.onNodeEvent))
    self:uploadDeviceInfo()
    
end

function MainPageView:onNodeEvent(event)
    if event == "enter" then
        self:onEnter()
    elseif event == "exit" then
        self:onExit()
    elseif event == "enterTransitionFinish" then
        self:onEnterTransitionFinish()
    end
end

function MainPageView:onEnterTransitionFinish()
     self.m_refreshInfoId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
        handler(self, self.refreshInfo),15.0,false)

    self.m_mainPage:enterMainPageRequest()

	DBHttpRequest:getAccountInfo(function(event) if self.httpResponse then self:httpResponse(event) end end)
	
    if not UserConfig.getAffichesSign then
        DBHttpRequest:getAffiches(function(tableData,tag) if self.NethttpResponse then self:NethttpResponse(tableData,tag) end end,myInfo.data.userId)
    end

    DBHttpRequest:getUserVipInfo(function(tableData,tag) if self.NethttpResponse then self:NethttpResponse(tableData,tag) end end,myInfo.data.userId)

    QManagerListener:Attach({{layerID = eMainPageViewID,layer = self}})
    self:personInfoInit()

    local JumpLayer = GameSceneManager:getJumpLayer()
    if JumpLayer then
        self:SwitchLayer(JumpLayer)
        GameSceneManager:setJumpLayer(nil)
    else
        self:showTipBox()
    end
    
end

function MainPageView:onEnter()
    TourneyGuideReceiver:sharedInstance():registerCurrentView(self)
    ProfitNotification:sharedInstance():registerCurrentView(self, eProViewMainView)
    self:addPropertyObserver()
end

function MainPageView:onExit()
    -- dump("MainPageView:onExit")
    QManagerListener:Detach(eMainPageViewID)
    if self.m_refreshInfoId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_refreshInfoId)
    end
    self:removeMemory()
    self:removePropertyObserver()
end

function MainPageView:addPropertyObserver()
    self.m_announceObserver = GV.CMDataProxy:addPropertyObserver(GV.CMDataProxy.DATA_KEYS.USERCONFIG, "noReadAffichesIDs", handler(self, self.updateAnnounceRedPoint))
end

function MainPageView:removePropertyObserver()
    GV.CMDataProxy:removePropertyObserver(GV.CMDataProxy.DATA_KEYS.USERCONFIG, "noReadAffichesIDs", self.m_announceObserver)
end

function MainPageView:removeMemory()
    local memoryPath = {}
    memoryPath[1] = require("app.GUI.allrespath.MainPagePath")
    memoryPath[2] = require("app.GUI.allrespath.PersonalCenterPath")
    memoryPath[3] = require("app.GUI.allrespath.ShopPath")
    memoryPath[4] = require("app.GUI.allrespath.RewardPath")
    memoryPath[5] = require("app.GUI.allrespath.GoldPath")
    -- dump(memoryPath)
    for j = 1,#memoryPath do 
        for i,v in pairs(memoryPath[j]) do
            display.removeSpriteFrameByImageName(v)
        end
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function MainPageView:updateCallBack(data)
    if data.tag == "addFreeGold" then           --免费金币
        myInfo.data.showFreegoldTips = true
        self.mAllBtn["freeGold"]:addRedDot()
    elseif data.tag == "removeFreeGold" then
        myInfo.data.showFreegoldTips = false
        self.mAllBtn["freeGold"]:removeRedDot()
    elseif data.tag == "addApplyBuy" then       --朋友局买入申请
        myInfo.data.showApplyBuy = true
        self.mAllBtn["message"]:addRedDot()
    elseif data.tag == "removeApplyBuy" then
        myInfo.data.showApplyBuy = false
        self.mAllBtn["message"]:removeRedDot()
    elseif data.tag == "addBuyTips" then
        self:addApplyBuyTip()
    elseif data.tag == "vipChange" then
        self.m_uservipinfo:setString(string.format("VIP %d",myInfo.data.vipLevel or 0))
    else
        self:refreshInfo(1)
    end
end
function MainPageView:refreshInfo(dt)
    DBHttpRequest:getAccountInfo(function(event) self:httpResponse(event)end)
    -- self.reward_tips:setVisible(true)
end
--[[
    添加返回大厅按钮
]]
function MainPageView:addSwitchButton()
 
    local isFind = false
    local DouDiZhuAccount = require("app.GUI.login.DouDiZhuAccount")
    for i,v in pairs(DouDiZhuAccount) do 
        if myInfo.data.userName == v.name then
            isFind = true 
            break
        end
    end

    if isFind and GIOSCHECK then
        local btnBack = CMButton.new({normal = "picdata/public2/btn_h74_green.png",pressed = "picdata/public2/btn_h74_green2.png"},
            function () 
                local RewardLayer      = require("app.GUI.login.ChoiceGameLayer")
                CMOpen(RewardLayer, self,{isNotAdd = true},0)
            end)
        btnBack:setButtonLabel("normal",cc.ui.UILabel.new({
        --UILabelType = 1,
        color = cc.c3b(177, 255, 51),
        text = "返回大厅",
        size = 32,
        font = "fonts/FZZCHJW--GB1-0.TTF",
        }) )    
        btnBack:setPosition(160,display.height/2)
        self:addChild(btnBack,1)
    end
end
--[[个人信息]]
function MainPageView:personInfoInit()
    self:loadHeadPhoto()
end

function MainPageView:loadHeadPhoto()
    self.m_headSprite = require("app.GUI.HeadImage"):createWithImageUrl("",myInfo.data.userPotrait,
        cc.size(100,100),myInfo.data.privilege,cc.size(23.0,17.0),myInfo.data.userSex)
    self.m_headSprite:setPosition(cc.p(60, 580))
    -- self.m_headerLayer:addChild(self.m_headSprite, 4)
end
function MainPageView:showTipBox()
    if  GIOSCHECK then return end
    if not myInfo.data.isFirstLogin then 
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.ACTIVITY,self,0,0)
    end
    if not myInfo.data.isSigned then
        DBHttpRequest:getLoginSignInfo(function(tableData,tag) if self.NethttpResponse then self:NethttpResponse(tableData,tag) end end)
    end

    myInfo.data.isFirstLogin = true
end
--[[
    上传硬件信息
]]
function MainPageView:uploadDeviceInfo()
    local isLoad = UserDefaultSetting:getInstance():getIsUpLoadDevice()
    if not isLoad then
        local uuid = QManagerPlatform:getUniqueStr()
        DBHttpRequest:uploadDeviceInfo(function(tableData,tag) if self.NethttpResponse then self:NethttpResponse(tableData,tag) end end,uuid)
    end

end
function MainPageView:HideButton()
    if GIOSCHECK then
        self.mYuLeBg:setVisible(false)
        self.mYuLeBtn:setVisible(false)
        self.mAllBtn["activity"]:setVisible(false)
        self.mAllBtn["excharge"]:setVisible(false)
    end
end
function MainPageView:manualLoadxml()
        local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName(GDIFROOTRES .. "picdata/MainPage_dif/mainpageBG.png")
    self.m_mainPageBg:setTexture(tmpFilename)
    self.m_footBg:setPositionX(self.m_footBg:getContentSize().width/2)

    local rootPath = "picdata/MainPage/"

        -------------------------------------------------------
                        --[[顶层重写]]

    self.m_headerLayer = display.newNode()
    self.m_headerLayer:setPosition(0,display.height - 57)
    self:addChild(self.m_headerLayer)
  
    local userBg = cc.ui.UIImage.new("head_bg.png")
        :align(display.LEFT_CENTER, 94, 0)
        :addTo(self.m_headerLayer) 

    self.m_personinfo = CMButton.new({normal= "picdata/public/head_line.png",pressed = "picdata/public/head_line.png"},function () self:SwitchLayer(308) end)    
    :align(display.CENTER, 65, 0) --设置位置 锚点位置和坐标x,y
    :addTo(self.m_headerLayer)


    local headPic = CMCreateHeadBg(myInfo.data.userPotrait,cc.size(100,100))
    headPic:setPosition(self.m_personinfo:getPositionX(), self.m_personinfo:getPositionY())
    self.m_headerLayer:addChild(headPic)
    self.mHeadPic = headPic
    
    --等级
    local levelBg = cc.Sprite:create(rootPath.."btn_lv.png")
    levelBg:setPosition(92, -40)
    self.m_headerLayer:addChild(levelBg)

    self.m_userlevel = cc.ui.UILabel.new({
        text = string.format("Lv. %d",myInfo.data.userLevel or 1),
        font = "Arial",
        size = 16,
        color = cc.c3b(255, 255, 255)
        })
        :align(display.LEFT_CENTER, levelBg:getContentSize().width/2-15, levelBg:getContentSize().height/2)
        :addTo(levelBg)
      

    --VIP
    local btnVip = CMButton.new({normal= rootPath.."btn_vip.png"},function () self:SwitchLayer(113) end)    
    :align(display.CENTER, userBg:getContentSize().width/2, userBg:getContentSize().height/2 - 15 ) --设置位置 锚点位置和坐标x,y
    :addTo(userBg)

    self.m_uservipinfo = cc.ui.UILabel.new({
        text = string.format("VIP %d",myInfo.data.vipLevel or 0),
        font = "fonts/FZZCHJW--GB1-0.TTF",
        size = 18,
        color = cc.c3b(73, 22, 26)
        })
        :align(display.CENTER, 0, 0)
        :addTo(btnVip)   
       
     --玩家昵称 
    self.m_username = cc.ui.UILabel.new({
        text = CMStringToString(myInfo.data.userName,10,true),
        font = "黑体",
        size = 24,
        color = cc.c3b(255, 255, 255)
        })
        :addTo(userBg)
     self.m_username:setPosition(userBg:getContentSize().width/2-self.m_username:getContentSize().width/2, userBg:getContentSize().height/2 + 15)
    
    --金币、商城
    local toolBarTop = require("app.Component.ToolBarTop"):new()
    toolBarTop:setPosition(CONFIG_SCREEN_WIDTH/2 + 37,display.height - 57)
    self:addChild(toolBarTop)

    self.m_goldNum = toolBarTop.m_goldNum
    self.m_scoreNum = toolBarTop.m_scoreNum

    --消息和公告
    local topbg2 = cc.Sprite:create("picdata/MainPage/top_1_bg2.png")
    topbg2:setPosition(self.m_mainPageBg:getContentSize().width - topbg2:getContentSize().width/2-2, display.height - 57)
    self:addChild(topbg2)

    local btnMessage = CMButton.new({normal = "picdata/MainPage/btn_news2.png"},function () self:SwitchLayer(307) end,{scale9 = false},{redDot = myInfo.data.showApplyBuy})    
    :align(display.CENTER, 50,topbg2:getContentSize().height/2) --设置位置 锚点位置和坐标x,y
    :addTo(topbg2)
    self.mAllBtn["message"] = btnMessage

    local btnAnnounce = CMButton.new({normal = "picdata/MainPage/btn_news.png"},function () self:SwitchLayer(311) end)    
    :align(display.CENTER, topbg2:getContentSize().width - 50,topbg2:getContentSize().height/2) --设置位置 锚点位置和坐标x,y
    :addTo(topbg2)
    -- 未读公告红点
    self.m_announceRedPoint = cc.Sprite:create("picdata/public_new/icon_tipsdot_red.png")
    self.m_announceRedPoint:setPosition(topbg2:getContentSize().width-20,topbg2:getContentSize().height-10)
    self.m_announceRedPoint:addTo(topbg2)
    self.m_announceRedPoint:setVisible(false)

    -------------------------------------------------------
    -------------------------------------------------------
                        --[[中间层重写]]

    if GDIFROOTRES  == "scene/" then
        centerOffx = 300
        bottomOffx = 100
    else
        centerOffx = 330
        bottomOffx = 120
    end
  
    
    local btnPath = {
    [1] = {normal="center_btn_1.png",     pressed = "center_btn_select.png",index = 102},
    [2] = {normal="center_btn_2.png",     pressed = "center_btn_select.png",index = 103},    
    [3] = {normal="center_btn_3.png",     pressed = "center_btn_select.png",index = 106}, 

    }
    local posx = self.m_mainPageBg:getContentSize().width/2 - centerOffx
    local posy = self.m_mainPageBg:getContentSize().height/2 + 20
    for i = 1,3 do 
        local bg = cc.Sprite:create(rootPath..btnPath[i].normal)
        bg:setPosition(posx, posy)
        self:addChild(bg)
        local btn = CMButton.new({normal= rootPath..btnPath[i].normal,pressed = rootPath..btnPath[i].pressed},function () self:SwitchLayer(btnPath[i].index) end, {scale9 = false})    
        :align(display.CENTER, bg:getContentSize().width/2, bg:getContentSize().height/2) --设置位置 锚点位置和坐标x,y
        :addTo(bg)

        posx = posx + centerOffx
        if i == 1 then
            self.mYuLeBtn = btn
            self.mYuLeBg  = bg
        end
    end
       
    local btnPath = {
    [1] = {normal="foot_2_btn_act.png",     pressed = "foot_2_btn_act2.png"     ,index = 108,name = "activity",redDot = nil},
    [2] = {normal="foot_2_btn_exchange.png",pressed = "foot_2_btn_exchange2.png",index = 109,name = "excharge",redDot = nil},    
    [3] = {normal="foot_2_btn_bonuse.png",  pressed = "foot_2_btn_bonuse2.png"  ,index = 110,name = "freeGold",redDot = myInfo.data.showFreegoldTips},
    [4] = {normal="foot_2_btn_zd.png",      pressed = "foot_2_btn_zd2.png"     ,index = 114,name = "more",redDot = nil}, 
    [5] = {normal="foot_2_btn_.png",        pressed = "btn_2_foot_3t.png"       ,index = 305,name = "",redDot = nil},
    [6] = {normal="foot_2_btn_more.png",    pressed = "foot_2_btn_more.png"     ,index = 111,name = "more",redDot = nil}, 

    }
    local posx = self.m_mainPageBg:getContentSize().width/2 - 2.8*bottomOffx
    local posy = self.m_footBg:getContentSize().height/2
    for i = 1,#btnPath do 
        local btn = CMButton.new({normal= rootPath..btnPath[i].normal,pressed = rootPath..btnPath[i].pressed},function () self:SwitchLayer(btnPath[i].index) end, {scale9 = false},{redDot = btnPath[i].redDot})    
        :align(display.CENTER, posx, posy) --设置位置 锚点位置和坐标x,y
        :addTo(self,2)
        if i == 3 then 
            self.mFreeGold = cc.Sprite:create(rootPath..btnPath[i].pressed)
            self.mFreeGold:setPosition(posx, posy)
            self:addChild(self.mFreeGold,2)
        end
        if btnPath[i].name then
            self.mAllBtn[btnPath[i].name] = btn
        end
        posx = posx + bottomOffx
    end

    --更多
    self.hiddenLayer = display.newNode()
    self.hiddenLayer:setPositionX(self.mAllBtn["more"]:getPositionX()-645)
    self.hiddenLayer:setVisible(false)
    self:addChild(self.hiddenLayer,2)

    local moreBg = cc.ui.UIImage.new(rootPath.."foot_3_bg_more.png")
        :align(display.RIGHT_CENTER, 700, 138)
        :addTo(self.hiddenLayer)
    
    local btnPath = {
        [1] = {normal="foot_2_btn_phone.png",   pressed = "foot_2_btn_phone2.png"   ,index = 310}, 
        [2] = {normal="foot_2_btn_teach.png",   pressed = "foot_2_btn_teach2.png"   ,index = 309},
        [3] = {normal="foot_2_btn_setting.png", pressed = "foot_2_btn_setting2.png" ,index = 302},       
        [4] = {normal="foot_2_btn_help.png",    pressed = "foot_2_btn_help2.png"    ,index = 112},
        [5] = {normal="foot_2_btn_friends.png", pressed = "foot_2_btn_friends2.png" ,index = 306},    
    }
    local posx = moreBg:getContentSize().width/2 - 190
    local posy = moreBg:getContentSize().height/2 + 10
    for i = 1,5 do 
        local btn = CMButton.new({normal= rootPath..btnPath[i].normal,pressed = rootPath..btnPath[i].pressed},function () self:SwitchLayer(btnPath[i].index) end, {scale9 = false})    
        :align(display.CENTER,posx,posy) --设置位置 锚点位置和坐标x,y
        :addTo(moreBg)
        posx = posx + 95
    end
   
   local btnShop = CMButton.new({normal= rootPath.."foot_2_btn_shop.png",pressed = rootPath.."foot_2_btn_shop2.png"},function () self:SwitchLayer(304) end, {scale9 = false})    
    :align(display.CENTER, 85, posy) --设置位置 锚点位置和坐标x,y
    :addTo(self,2)    

    self.m_footerLayer:setLocalZOrder(1)
    self.m_quickStart = CMButton.new({normal="foot_4_chip3.png"},function () self:SwitchLayer(301) end, {scale9 = false})    
    :align(display.CENTER, self.m_quickStartBk:getPositionX(), self.m_quickStartBk:getPositionY()) --设置位置 锚点位置和坐标x,y
    :addTo(self,1)

    self:runQuickStartLight()
    self:runFreeGoldLight(self.mFreeGold)
    self:HideButton()
    self:addApplyBuyTip()
    self:addSwitchButton()
end

function MainPageView:runFreeGoldLight(node)
    local act1 = cc.FadeOut:create(0.6)
    local act2 = cc.FadeIn:create(0.6)
    local seq  = cc.Sequence:create(act1,act2)

    node:runAction(cc.RepeatForever:create(seq))
end

function MainPageView:runQuickStartLight()
    local pNode = self.rotateChip
    local chipsFade = cc.ui.UIImage.new("chipsFade.png")
        :align(display.CENTER, pNode:getPositionX(), pNode:getPositionY())
        :addTo(pNode:getParent())
    self.m_quickStartBk:removeFromParent()
    pNode:getParent():addChild(self.m_quickStartBk)
    if pNode then
        local fadeSeq = cc.Sequence:create(cc.FadeOut:create(1),cc.DelayTime:create(0.5),cc.FadeIn:create(1))

        local rotateSeq = cc.Sequence:create(cc.DelayTime:create(0.5),cc.RotateBy:create(0.5, 90),
            cc.RotateBy:create(0.5, 270),cc.DelayTime:create(1))

        pNode:runAction(cc.RepeatForever:create(rotateSeq))
        chipsFade:runAction(cc.RepeatForever:create(fadeSeq))
    end   
end
--[[
    首次创建牌局提示
]]
function MainPageView:addApplyBuyTip()
    if UserDefaultSetting:getInstance():getPrivateRoomMsgHint() then       
        UserDefaultSetting:getInstance():setPrivateRoomMsgHint(false)
    else 
        return
    end
    local node = cc.Node:create()
    local bg = cc.Sprite:create("picdata/public/tips_bg.png")
    local bgWidth = bg:getContentSize().width
    local bgHeight= bg:getContentSize().height
    node:addChild(bg,0,100)

    local ang = cc.Sprite:create("picdata/public/tips_triangle.png")
    ang:setPosition(bgWidth/2, bgHeight + ang:getContentSize().height/2-4)
    bg:addChild(ang,0,101)

    local tip1 = cc.ui.UILabel.new({
            text  = "朋友局的申请",
            size  = 16,
            color = cc.c3b(0,255,255),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
    tip1:setPosition(bgWidth/2-tip1:getContentSize().width/2,bgHeight/2+9)
    bg:addChild(tip1,0,102)

    local tip2 = cc.ui.UILabel.new({
            text  = "在这里也可以审批哦~",
            size  = 16,
            color = cc.c3b(0,255,255),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
    tip2:setPosition(bgWidth/2-tip2:getContentSize().width/2,bgHeight/2-9)
    bg:addChild(tip2,0,103)

    node:setPosition(self.mAllBtn["message"]:getParent():getPositionX()-42,self.mAllBtn["message"]:getParent():getPositionY()-52)
    self:addChild(node,1)
    
    self.mTipNode = node
   
    for i = 1,3 do 
        transition.fadeOut(bg:getChildByTag(100+i),{time = 4})
    end
    transition.fadeOut(bg,{time = 8, onComplete = function()
    if self.mTipNode then self.mTipNode:removeFromParent() self.mTipNode  = nil end
            end,})

    return node
end
----------------------------------------------------------
function MainPageView:showOnlinePersonCallback(num)
    -- normal_info_log("MainPageView:showOnlinePersonCallback功能未实现")
    -- RecommendMatchLayer* layer = (RecommendMatchLayer*)this->getChildByTag(RECOMMEND_MATCH_LAYER_TAG);
    -- if(layer)
    -- {
    --     layer->updateOnline(num);
    -- }
    
end

--[[显示新手引导]]
function MainPageView:showNewerGuide(isNewer)
end

function MainPageView:updateUserInfoUI()
    -- normal_info_log("MainPageView:updateUserInfoUI")
    
end

function MainPageView:setSafeSettingVisible(isVisible)

end
----------------------------------------------------------
--[[观察者模式回掉]]
----------------------------------------------------------
function MainPageView:onUserHeadImageChangeCallback(event)
    -- normal_info_log("onUserHeadImageChangeCallback功能未实现")
end

function MainPageView:mainPageCallback(event)
    -- normal_info_log("mainPageCallback功能未实现")
end

function MainPageView:buyItemCallback(event)
    -- normal_info_log("buyItemCallback功能未实现")
end
----------------------------------------------------------
--[[设置大厅来源 c++版本是放在构造函数中传过来]]
function MainPageView:setFromType(type)   
    self.m_fromType = type
    if self.m_fromType == "login" then
        self:showGuideLayer(myInfo.data.isNewer)
        self:showGameTechPopLayer(myInfo.data.isNewer)
        self.m_fromType = ""
    end

    if self.m_fromType == "replay" then
        self:SwitchLayer(308)
    end

    if self.m_fromType == "rankLayer" then
        self:SwitchLayer(305)
    end

    if self.m_fromType == "activityLayer" then
        self:SwitchLayer(102)
    end

    if self.m_fromType == "hallGold" or self.m_fromType == "TourneyGold" or self.m_fromType == "SNGGold" then
        self:SwitchLayer(201)
    end

    if self.m_fromType == "hallScore" or self.m_fromType == "TourneyScore" or self.m_fromType == "SNGScore" then
        self:SwitchLayer(202)
        self.m_fromType = ""
    end
end
--[[
    更改头像
]]
function MainPageView:updateHeadPic(filePath)
    self.mHeadPic:changeHead(filePath) 
    
end
--[[切换页面]]
function MainPageView:SwitchLayer(index)
    -- if index==0 then
    --     return
    -- end

    if index~=111 then --点击其他按钮，将更多隐藏
        self.hiddenLayer:setVisible(false)
        self.mAllBtn["more"]:setButtonImage("normal","foot_2_btn_more.png")
        self.mAllBtn["more"]:setButtonImage("pressed","foot_2_btn_more.png")
        self.mAllBtn["more"]:setButtonImage("disabled","foot_2_btn_more.png")
    end

    if index == 302 then        --更多
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.MORESET,self)
    elseif index == 303 then    --奖励
        
    elseif index == 304 or index == 201 then    --商城
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self) 
    elseif index == 305 then    --排行榜
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.RANK,self)
    elseif index == 306 then    --朋友
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.FRIEND,self)
    elseif index == 307 then    --消息
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.MAILCENTER,self)
    elseif index == 308 then    --个人中心
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.PERSONCENTER,self)
    elseif index == 309 then    
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.JIAOXUE,self)
    elseif index == 310 then    --绑定手机
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.PHONEBIND,self)
    elseif index == 301 then    --快速开始
        GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{m_isFromMainPage = true,isQuickStart = true })
    elseif index == 311 then    --公告
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.ANNOUNCE,self)
    elseif index == 101 then    --
    elseif index == 102 then    --活动场    
        -- local AlertDialog = require("app.Component.CMAlertDialog")
        -- CMOpen(AlertDialog,self,{text = "娱乐场建设中,开放时间请留意官网公告!"})

        CMOpen(require("app.GUI.hallview.PrivateHallView"), self, nil, true, 10)
    elseif index == 103 or index == SWITCH_TO_EGSHall then    --进入普通场
        --[[这里如果发送消息，切换页面时回报错，已经放到DebaoHall中执行]]
        -- DBHttpRequest:dataReport(function(event) self:httpResponse(event)
        --     end,89, 1, "")
       GameSceneManager:switchSceneWithType(EGSHall)
    elseif index == 104 then    --
        if self.m_centerLayer2 then
            self.m_centerLayer2:setVisible(true)
        end
        if self.m_centerLayer1 then
            self.m_centerLayer1:setVisible(false)
        end
    elseif index == 105 then    --
        if self.m_centerLayer2 then
            self.m_centerLayer2:setVisible(false)
        end
        if self.m_centerLayer1 then
            self.m_centerLayer1:setVisible(true)
        end
    elseif index == 106 then    --锦标赛
        GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.TourneyList)

        -- CMOpen(require("app.GUI.Tourney.TourneyHallView"), self, 0, true, 10)
    elseif index == 107 then    --SNG赛
    elseif index == 108 then    --活动
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.ACTIVITY,self)
    elseif index == 109 or index == 202  then    --兑换
         GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.EXCHARGE,self)
    elseif index == 110 then    --免费
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.DIALYTASK,self)
    elseif index == 111 then    --更多
        if self.hiddenLayer:isVisible() then           
            self.hiddenLayer:setVisible(false)
            self.mAllBtn["more"]:setButtonImage("normal","foot_2_btn_more.png")
            self.mAllBtn["more"]:setButtonImage("pressed","foot_2_btn_more.png")
            self.mAllBtn["more"]:setButtonImage("disabled","foot_2_btn_more.png")
        else
            self.hiddenLayer:setVisible(true)
            self.mAllBtn["more"]:setButtonImage("normal","foot_2_btn_more2.png")
            self.mAllBtn["more"]:setButtonImage("pressed","foot_2_btn_more2.png")
            self.mAllBtn["more"]:setButtonImage("disabled","foot_2_btn_more2.png")
        end
    elseif index == 112 then    -- 帮助
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.HELP,self)
    elseif index == 113 then    -- VIP
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.VIP,self)
    elseif index == 114 then
        -- CMShowTip("暂未开启")
        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.FIGHTTEAM,self)
   -- elseif index == 201 then    --
   -- elseif index == 202 then    --
    elseif index == 1001 then    --
    end
end

--[[欢迎页面]]
function MainPageView:showGuideLayer(isNewer)
    if isNewer == true then
        -- normal_info_log("MainPageView:showGuideLayer 新手引导功能未实现")
    end
end

--[[欢迎页面]]
function MainPageView:showGameTechPopLayer(isNewer)
    if isNewer == true then
        -- normal_info_log("MainPageView:showGameTechPopLayer 新手引导功能未实现")
    end
end

function MainPageView:updateAnnounceRedPoint(ids)
    if next(ids) then
        self.m_announceRedPoint:setVisible(true)
    else
        self.m_announceRedPoint:setVisible(false)
    end
end

--[[http请求返回]]
----------------------------------------------------------
function MainPageView:httpResponse(event)
    local ok = (event.name == "completed")
    local request = event.request
 
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- print(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- print(code)
        return
    end
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
    self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

end

function MainPageView:onHttpResponse(tag, content, state)
    if tag == POST_COMMAND_GET_SHOPSWITCH then
        -- UserDefaultSetting:shareInstance()->setAppleCheckFlag(atoi(content.c_str()))
    elseif tag == POST_COMMAND_getExpressInfo then
        self:dealGetExpressInfoResp(content)
    elseif tag == POST_COMMAND_GET_VIP_INFO then
        self:dealVipInfo(content)
    elseif tag == POST_COMMAND_GETACTIVITYNOTIFY then
        self:dealActivityNotifyInfo(content)
    elseif tag == POST_COMMAND_GETNOREADEDNOTICENUM then
        self:dealGetNoReadNotice(content)
    elseif tag == POST_COMMAND_GETACTIVITYNOTREADNUM then
        self:dealGetNoReadActivity(content)
    elseif tag == POST_COMMAND_GETMATCHADCTR then
        self:dealGetMatchAdCtr(content)
    elseif tag == POST_COMMAND_LOGINREWARD then
        self:dealLoginReward(content)
    elseif tag == POST_COMMAND_HUDFORMOBILE then
        self:dealGetUserInfo(content)
    elseif tag == POST_COMMAND_GETACCOUNTINFO then 
        self:dealRereshMoney(content)
    elseif tag == POST_COMMAND_GetLableShowConfig then
        self:dealGetLableShowConfig(content)
    elseif tag == POST_COMMAND_GETDEBAOCOIN then
        self:dealGetDebaoCoin(content)
    elseif tag == POST_UPLOAD_FORM_FILE then
        normal_info_log("POST_UPLOAD_FORM_FILE:"..content)
    elseif tag == POST_COMMAND_SetApplePushToken then
        -- CCUserDefault:sharedUserDefault()->setIntegerForKey(s_boolIsFirstGetToken, 1)
    end
end
--[[
    网络回调
]]
function MainPageView:NethttpResponse(tableData,tag)
     -- dump(tableData,tag)
     -- dump(tableData)
    if tag == POST_COMMAND_HUDFORMOBILE  then
        myInfo.data.userSex  = tableData["4010"]
        myInfo.data.userExperience = tableData["500C"]
        myInfo.data.userLevel = tableData["500D"]
        myInfo.data.userPotrait = tableData["4006"]
        myInfo.data.headCheck   = tableData["4017"]
        self.m_userlevel:setString(string.format("Lv. %s",tableData["500D"]))
        self.m_userlevel:setPositionX(self.m_userlevel:getParent():getContentSize().width/2-self.m_userlevel:getContentSize().width/2)
        local picPath = tableData["4006"]
        local isExist,newPath = NetCallBack:getCacheImage(picPath) 
        if isExist then
            picPath = newPath
            self.mHeadPic:changeHead(picPath,false,picPath)
        else
            NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),"http://www.debao.com"..string.gsub(picPath,".png",".big.png"),"HeadDownLoad",picPath,1)
        end
        
    elseif tag == POST_COMMAND_getUserVipInfo then                  --请求vip信息   
        self.m_uservipinfo:setString(string.format("VIP %d",tableData["500D"]))
        myInfo.data.vipLevel  = tableData["500D"]
        myInfo.data.curVipExp = tableData["5052"]
        myInfo.data.nextVipExp= tableData["5053"]
        myInfo.data.vipRank = tableData["5052"]
        myInfo.data.nextVipRank = tableData["5053"]
        if tonumber(myInfo.data.curVipExp) > 0 then
            myInfo.data.payamount = 1   --设置首充标记
        end
    elseif tag == POST_COMMAND_getLoginSignInfo then
        local curTime = CMFormatTimeStyle(myInfo.data.serverTime)
        if curTime == tableData[FINAL_SIGNIN_DATE] then
            myInfo.data.isSigned = true
            myInfo.data.signTimes = tableData[SIGNIN_TIMES]
        else
            GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.DAILYSIGN,self)
        end
    elseif tag == POST_COMMAND_ANNOUNCEINFO then
        UserConfig.getAffichesSign = true
        -- 检查未读的公告id
        if tableData and #tableData > 0 then
            local idStr = UserDefaultSetting:getInstance():getAnnounceIDs()
            local idsTable = {}
            table.foreach(tableData, function(i, v)
                    if not string.find(idStr, v.id) then
                        idsTable[v.id] = true
                    end
                end)
            GV.UserConfig.noReadAffichesIDs = idsTable
        end
        local dateStr = os.date("%Y-%m-%d", os.time())
        if UserDefaultSetting:getInstance():getAnnouncePopupDate() == dateStr then
            return
        end
        if tableData and #tableData > 0 then
            for i, v in ipairs(tableData) do
                if v.is_popup and v.is_popup ~= "0"  then
                    local idStr = UserDefaultSetting:getInstance():getAnnounceIDs()
                    if not string.find(idStr, v.id) then
                        UserDefaultSetting:getInstance():setAnnouncePopupDate(dateStr)
                        UserDefaultSetting:getInstance():setAnnounceIDs(idStr .. "," .. v.id)
                        --自动弹出公告
                        GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.ANNOUNCE,self,{itemData=v})
                        break
                    end
                end
            end
        end
    elseif tag == POST_COMMAND_GETRCTOKEN then
        -- dump(tableData)
        if tableData.code == 200 then
            -- local rcData = {["AppKey"]= "uwd1c0sxdbup1",["Token"]= tableData.token}
            -- QManagerPlatform:initRongCloud(rcData)
            local rcData = {["AppKey"]= "8luwapkvuz8jl",["Token"]= tableData.token,
            ["UserId"]=myInfo.data.userId,["Username"]=myInfo.data.userName,["UserPotraitUri"]=myInfo.data.userPotraitUri}
            QManagerPlatform:initRongCloud(rcData)
            GIsConnectRCToken = true
        end
    elseif tag == POST_COMMAND_UPLOADDEVICEINFO then
         UserDefaultSetting:getInstance():setIsUpLoadDevice(true)
    end
    --dump(myInfo)
    
end
----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function MainPageView:onHttpDownloadResponse(tag,progress,fileName)
    if tag ==  "HeadDownLoad" then
        if self.mHeadPic then
         self.mHeadPic:changeHead(fileName,false,fileName)
        end
    end 
end
----------------------------------------------------------
function MainPageView:dealGetExpressInfoResp(content)
    local data = require("app.Logic.Datas.Account.ExpressInfo"):new()
    if data:parseJson(content) == BIZ_PARS_JSON_SUCCESS then
        myInfo.data.userPhoneNO = data.userPhoneNo
    end
end

function MainPageView:dealVipInfo(content)
end

function MainPageView:dealActivityNotifyInfo(content)
end

function MainPageView:dealGetNoReadNotice(content)
end

function MainPageView:dealGetNoReadActivity(content)
end

function MainPageView:dealGetMatchAdCtr(content)
end

function MainPageView:dealLoginReward(content)
end

function MainPageView:dealGetUserInfo(content)
end

function MainPageView:dealRereshMoney(content)
   local data = require("app.Logic.Datas.Account.AccountInfo"):new()
    if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS and data.code == "" then
        myInfo.data.totalChips = data.silverBalance
        myInfo.data.diamondBalance     = data.diamondBalance
        myInfo.data.userDebaoDiamond   = data.pointBalance

        self.m_goldNum:setString(StringFormat:FormatDecimals(myInfo.data.totalChips,2))
        self.m_scoreNum:setString(StringFormat:FormatDecimals(myInfo.data.diamondBalance,2))
    end
end

function MainPageView:dealGetLableShowConfig(content)
end

function MainPageView:dealGetDebaoCoin(content)
end

function MainPageView:addLoudSpeakerMsg(msg)
    local RewardLayer      = require("app.Component.CMNoticeView") -- 广播测试
    RewardLayer:playNotice({})
end

function MainPageView:alertEnterTourneyRoomCallback(matchName, tableId)
        local alertView = require("app.Component.EAlertView"):alertView(
                                                      self.m_currentView,
                                                      self,
                                                      "",
                                                      "您报名的"..matchName.."已经开始，是否立即前往？",
                                                     "弃权", "立即前往")
        alertView:setTag(100)--锦标赛开始提示
        local strId = tableId
        alertView:setUserData(strId)
        alertView:alertShow()
end

function MainPageView:reconnectSuccessedCallback(tableId, userId, isRush) --reconnect room

        local alertView = require("app.Component.EAlertView"):alertView(
                                                      self.m_currentView,
                                                      self,
                                                      "",
                                                      "您正在牌桌内，是否立即前往？",
                                                     "放弃", "立即前往")
        alertView:setTag(101)--普通桌提示
        alertView:setUserData({tableId = tableId,m_isGameType = nil,isRush = isRush})
        alertView:alertShow()

    -- GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = tableId,m_isGameType = nil,isRush = isRush})
end

function MainPageView:clickButtonAtIndex(alertView, index)

    local tag = alertView:getTag()
    if tag == 100 then --锦标赛开始提示
        
            local strId = alertView:getUserData()
            if index == 0 then
            
                self.m_mainPage.tcpRequest:quitTourney(strId, myInfo.data.userId)
                DBHttpRequest:getSngMatch(handler(self,self.httpResponse), 0, "SNG_CRAZY", "REGISTERING", "")
            
            else
                GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = strId,m_isFromMainPage = true,})
            end
            strId = nil 
    elseif tag == 101 then --进入房间提示
        
            local data = alertView:getUserData()
            if index == 0 then
            
            else
                data.m_isFromMainPage = true
                GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager, data)
            end
            strId = nil 
    end
end

function MainPageView:showNewerGuide(isShow)

end


return MainPageView