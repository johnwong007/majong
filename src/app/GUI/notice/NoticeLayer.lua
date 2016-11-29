--
-- Author: junjie
-- Date: 2015-12-02 18:27:19
--
local NoticeLayer = class("NoticeLayer",function() 
	return display.newNode()
end)
require("app.Network.Http.DBHttpRequest")
require("app.Network.Socket.TcpCommandRequest")
local CMButton = require("app.Component.CMButton")
local myInfo = require("app.Model.Login.MyInfo")
local QDataNoticeList = nil
local EnumMenu = {
    eBtnRefuse = 1,
    eBtnAccept = 2,
}
function NoticeLayer:ctor(params)
    self:setNodeEventEnabled(true)
    QDataNoticeList = QManagerData:getCacheData("QDataNoticeList")
	self.params = params or {}
end
function NoticeLayer:create()
    self:initUI()
end
function NoticeLayer:initUI()
    self:setContentSize(600,500)
    self.mBg = self
    if self.params.nType == 4 then
        self.mListPosX = 248
        self.mListPosY = 33
        self.mListSize = cc.size(595,480)
        self:createApplyBuy() 
    elseif self.params.nType == 5 then
        self:createApplyBuyBg()
        self:createApplyBuy()
        self.mListPosX = 38
        self.mListPosY = 33
        self.mListSize = cc.size(635,440)
    else
        self:createRightList(self.params.nType) 
    end
    
end
function NoticeLayer:onExit()
    if self.params.nType == 4 or self.params.nType == 5 then 
        if QDataNoticeList:checkIsReady(self.params.nType) then
            QManagerListener:Notify({layerID = eMainPageViewID,tag = "addApplyBuy"})
            QManagerListener:Notify({layerID = eRoomViewID,tag = "addApplyBuy"})
        else
            QManagerListener:Notify({layerID = eMainPageViewID,tag = "removeApplyBuy"})
            QManagerListener:Notify({layerID = eRoomViewID,tag = "removeApplyBuy"})
        end
    end
    QManagerData:removeCacheData("QDataNoticeList",self.params.nType)
end
-- function NoticeLayer:createButtonGroup()

-- 	local bg = cc.Sprite:create("picdata/public/btn_1_menu.png")
-- 	bg:setScaleX(1.53)
-- 	bg:setPosition(self.mBg:getContentSize().width/2,450)
-- 	self.mBg:addChild(bg)

-- 	self.menu = cc.Sprite:create("picdata/public/btn_1_menu2.png")
-- 	self.mBg:addChild(self.menu)
--     local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)    
--     :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/notice/w_mune_xtxx2.png",off_pressed = "picdata/notice/w_mune_xtxx.png", on = "picdata/notice/w_mune_xtxx.png",}))
--     :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/notice/w_mune_grrz2.png",off_pressed = "picdata/notice/w_mune_grrz.png", on = "picdata/notice/w_mune_grrz.png",}))
--     :addButton(cc.ui.UICheckBoxButton.new({off = "picdata/notice/w_menu_czjl2.png",off_pressed = "picdata/notice/w_menu_czjl.png", on = "picdata/notice/w_menu_czjl.png",}))
   
--     :setButtonsLayoutMargin(0, 3, 0, 18)
--     :onButtonSelectChanged(function(event)
--         local group = self.mGroup:getButtonAtIndex(event.selected)
--         self.menu:setPosition(group:getPositionX()+103,group:getPositionY()+436)
--         self:createRightList( event.selected)
--         self.mLastType =  event.selected
--     end)
--     :align(display.LEFT_TOP, 103,436)
--     :addTo(self.mBg,1)
--      self.mGroup = group
--     group:getButtonAtIndex(1):setButtonSelected(true)

-- end
function NoticeLayer:createRightList( nType)
   if nType == self.mLastType then return end   
    local cfgData = QDataNoticeList:getMsgData(nType)
 
    if not cfgData then 
        DBHttpRequest:GetAllNoticesInfo(function(tableData,tag) self:httpResponse(tableData,tag,nType) end,tostring(nType))
        return
    end 
    if type(cfgData) ~= "table" or #cfgData == 0 then 
        self:createApplyBuyNothing()
        return 
    end
    self.mLastType = nType
    --self.mActivitySprite ={}
    if self.mList then self.mList:removeFromParent() self.mList = nil end
    -- body
    self.mListSize = cc.size(595,480) 
    self.mList = cc.ui.UIListView.new {
       -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(248,33, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)   
   for i = 1,#cfgData do 
       

        local item = self.mList:newItem() 
     
        local serData = cfgData[i] or {}
        local temp = cc.ui.UILabel.new({
                text  = serData[NOTICE_CONTENT],
                size  = 24,
                font  = "黑体",
                dimensions = cc.size(500,0),
            })

        --local tempHeight = math.ceil(temp:getContentSize().width/400) * 24 + 80
        local tempHeight = temp:getContentSize().height + 82
        local node = cc.Node:create()
       
        local bg   = cc.Sprite:create("picdata/notice/bg_1_time.png")
        local bgwidth = bg:getContentSize().width
        local bgHeight= bg:getContentSize().height
        local itemSize = cc.size(self.mListSize.width,tempHeight)
        bg:setPosition(bgwidth/2+30,itemSize.height - bgHeight)
        node:addChild(bg)

        item:addContent(node)
        node:setContentSize(self.mListSize.width,itemSize.height)
        item:setItemSize(self.mListSize.width,itemSize.height)
        self.mList:addItem(item)

        -- local content     
        -- content = cc.LayerColor:create(
        --     cc.c4b(math.random(250),
        --         math.random(250),
        --         math.random(250),
        --         250))
        -- content:setContentSize(itemSize.width, itemSize.height)
        -- content:setTouchEnabled(true)    
        -- item:addChild(content) 

         local time = cc.ui.UILabel.new({
                text  = self:TransitionTime(serData[NOTICE_DATE] or "1999-01-01 00:00:00"),
                size  = 18,
                color = cc.c3b(134, 153, 191),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
            })
        time:setPosition(bgwidth/2-time:getContentSize().width/2,bgHeight/2)
        bg:addChild(time)

        local icon = cc.Sprite:create(self:TransitionTitle(serData[NOTICE_TITLE] or "活动"))
        icon:setPosition(40,itemSize.height-60)
        node:addChild(icon)

        local title = cc.ui.UILabel.new({
                text  = string.format("%s",serData[NOTICE_TITLE] or "标题"),
                size  = 24,
                color = cc.c3b(140, 166, 216),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
            })
        title:setPosition(icon:getPositionX() + 30,icon:getPositionY())
        node:addChild(title)

        local content = cc.ui.UILabel.new({
                text  = serData[NOTICE_CONTENT] or "",
                size  = 24,
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                dimensions = cc.size(500,0),
            })
        content:setPosition(title:getPositionX(),title:getPositionY()-content:getContentSize().height/2 - 16)
        node:addChild(content)
        
        local line = cc.Sprite:create("picdata/friend/line.png")
        line:setScaleX(2.5)
        line:setPosition(bgwidth/2+45, -2)
        node:addChild(line)
    end 

    self.mList:reload() 
end
--[[
    没有购买背景
]]
function NoticeLayer:createApplyBuyNothing()
    if self.mNoBuyNode then return end
    local bgWidth =  1090
    local bgHeight =  500
    self.mNoBuyNode = cc.Node:create()
    self.mBg:addChild(self.mNoBuyNode)
    local icon = cc.Sprite:create("picdata/public/icon_empty.png")
    icon:setPosition(bgWidth/2, bgHeight/2+70)
    self.mNoBuyNode:addChild(icon,1)
    local tips = "暂无消息"
    if self.params.nType >=4 then 
        tips = "暂无申请"
    end
    local name = cc.ui.UILabel.new({
        text  = tips,
        color = cc.c3b(134, 153, 191),
        size  = 24,
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
        font  = "黑体",
    })
    name:setPosition(bgWidth/2-name:getContentSize().width/2, bgHeight/2 - 30)
    self.mNoBuyNode:addChild(name) 

    if self.params.nType == 5 then
        self.mNoBuyNode:setPosition(-187,-20)
    end    
end
--[[
    牌桌内购买背景
]]
function NoticeLayer:createApplyBuyBg()
    local CMMaskLayer = CMMask.new()
    self:addChild(CMMaskLayer)
     local bg = cc.Sprite:create("picdata/bill/bg.png")
     bg:setPosition(display.cx,display.cy)
     self:addChild(bg)
     self.mBg = bg
     local secBg = cc.Sprite:create("picdata/bill/bg2.png")
     secBg:setPosition(bg:getContentSize().width/2, secBg:getContentSize().height/2+30)
     bg:addChild(secBg)

     local title = cc.Sprite:create("picdata/bill/w_mrsq.png")
    title:setPosition(self.mBg:getContentSize().width/2,self.mBg:getContentSize().height - title:getContentSize().height - 25)
    self.mBg:addChild(title)

    local btnClose = CMButton.new({normal = "picdata/public/btn_2_close.png",pressed = "picdata/public/btn_2_close2.png"},function () CMClose(self) end, {scale9 = false})    
    :align(display.CENTER, self.mBg:getContentSize().width - 30,self.mBg:getContentSize().height-30) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
end
--[[
    买入申请
]]
function NoticeLayer:createApplyBuy()
   
    local cfgData = QDataNoticeList:getMsgData(self.params.nType)
     if not cfgData then
         DBHttpRequest:getMyPriTable(function(tableData,tag) self:httpResponse(tableData,tag) end,"OPEN")
         return
    end
    -- dump(cfgData)
    local lens = 0
    for i,v in pairs(cfgData) do 
        if v["apply"] and #v["apply"] > 0 then
            lens = #v["apply"]
            break
        end
    end

    if self.mList then self.mList:removeFromParent() self.mList = nil end
    if lens == 0 then
        self:createApplyBuyNothing()
        return
    end
   
    local btnRefusePath = "picdata/notice/btn_no1.png"
    local btnRefusePath2= "picdata/notice/btn_no11.png"
    local btnAcceptPath = "picdata/notice/btn_yes1.png"
    local btnAcceptPath2 = "picdata/notice/btn_yes11.png"
  
    
    -- body
    -- self.mListSize = cc.size(595,480) 
    self.mList = cc.ui.UIListView.new {
       -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(self.mListPosX,self.mListPosY, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)   
   for i = 1,#cfgData do 
        local itemData = cfgData[i]
        -- dump(itemData)
        if itemData["apply"] and #itemData["apply"] >0 then
            if self.mNoBuyNode then self.mNoBuyNode:removeFromParent() self.mNoBuyNode = nil end
            for j = 1,#itemData["apply"]+1 do
                local item = self.mList:newItem() 
                local node = display.newNode()
                local bgWidth = self.mListSize.width
                local bgHeight= 70
                if j == 1 then                     
                    bgWidth = self.mListSize.width
                    bgHeight= 100
                    
                    local nameBg   = cc.Sprite:create("picdata/notice/bg_title1.png")
                    nameBg:setPosition(bgWidth/2,80)
                    node:addChild(nameBg)

                    local name = cc.ui.UILabel.new({
                            text  = itemData[TABLE_NAME] or "",
                            size  = 20,
                            color = cc.c3b(134, 153, 191),
                            align = cc.ui.TEXT_ALIGN_LEFT,
                            --UILabelType = 1,
                            font  = "黑体",
                        })
                    name:setPosition(nameBg:getContentSize().width/2-name:getContentSize().width/2,nameBg:getContentSize().height/2)
                    nameBg:addChild(name)

                    local titleBg = cc.Sprite:create("picdata/notice/bg_fl1.png")
                    titleBg:setPosition(bgWidth/2,30)
                    node:addChild(titleBg)

                    local titleName = {{text = "玩家",x = nameBg:getPositionX()-nameBg:getContentSize().width/2+20},{text = "买入筹码",x = nameBg:getPositionX()-nameBg:getContentSize().width/2+260}}
                    
                    for i = 1,#titleName do 
                        local title = cc.ui.UILabel.new({
                            text  = titleName[i].text,
                            size  = 20,
                            color = cc.c3b(135,154,192),
                            align = cc.ui.TEXT_ALIGN_LEFT,
                            --UILabelType = 1,
                            font  = "黑体",
                            })
                        title:setPosition(titleName[i].x, titleBg:getPositionY())
                        node:addChild(title)
                    end
                   self.NamePosX = titleName[1].x
                   self.BuyPosX  = titleName[2].x
                else
                    local serverData = itemData["apply"][j-1] or {}
                    serverData.tableId = itemData[TABLE_ID]
                    serverData.payType = itemData["PAY_TYPE"]
                     local name = cc.ui.UILabel.new({
                        text  = CMStringToString(revertPhoneNumber(tostring(serverData[USER_NAME])),22,true),
                        size  = 24,
                        align = cc.ui.TEXT_ALIGN_LEFT,
                        --UILabelType = 1,
                        font  = "黑体",
                    })
                    name:setPosition(self.NamePosX,bgHeight/2)
                    node:addChild(name) 


                     local num = cc.ui.UILabel.new({
                        text  = serverData["BUY_CHIPS"],
                        size  = 24,       
                        align = cc.ui.TEXT_ALIGN_LEFT,
                        --UILabelType = 1,
                        font  = "黑体",
                    })
                    num:setPosition(self.BuyPosX,bgHeight/2)
                    node:addChild(num) 

                    local btnRefuse = CMButton.new({normal = btnRefusePath,pressed = btnRefusePath2},function () self:onMenuCallBack(EnumMenu.eBtnRefuse,serverData) end,{scale9 = false},{scale = false})
                    btnRefuse:setButtonLabel("normal",cc.ui.UILabel.new({
                    --UILabelType = 1,
                    --color = cc.c3b(129, 163, 229),
                    text = "拒绝",
                    size = 22,
                    font = "FZZCHJW--GB1-0",
                    }) )    
                    btnRefuse:setPosition(self.BuyPosX+180,bgHeight/2)
                    btnRefuse:setTouchSwallowEnabled(false)
                    node:addChild(btnRefuse)

                    local btnAccept = CMButton.new({normal = btnAcceptPath,pressed = btnAcceptPath2},function () self:onMenuCallBack(EnumMenu.eBtnAccept,serverData) end,{scale9 = false},{scale = false})
                    btnAccept:setButtonLabel("normal",cc.ui.UILabel.new({
                    --UILabelType = 1,
                    --color = cc.c3b(129, 163, 229),
                    text = "同意",
                    size = 22,
                    font = "FZZCHJW--GB1-0",
                    }) ) 
                    btnAccept:setPosition(self.BuyPosX+280,bgHeight/2)
                    btnAccept:setTouchSwallowEnabled(false)
                    node:addChild(btnAccept)

                    local line = cc.Sprite:create("picdata/friend/line.png")
                    line:setScaleX(2.8)
                    line:setPosition(bgWidth/2, -2)
                    node:addChild(line)
                end

                 node:setContentSize(bgWidth,bgHeight+7)
                item:setItemSize(bgWidth,bgHeight+7)
                item:addContent(node)
                self.mList:addItem(item)
            end
        end
    end

    self.mList:reload()
end
function NoticeLayer:onMenuCallBack(tag,itemData)
    if tag == EnumMenu.eBtnRefuse or tag == EnumMenu.eBtnAccept then
        local code = 10000
        if tag == EnumMenu.eBtnRefuse then 
            code = -1
        end
        local recData = {{layerID = COMMAND_APPLY_ANSWER_RESP,layer = self}}
        TcpCommandRequest:shareInstance():reqBuyinApplyAnswer(code, itemData.tableId, itemData[USER_ID], itemData[USER_NAME], tonumber(itemData["BUY_CHIPS"]), itemData[ORDER_ID], itemData.payType,recData)
    end
end
function NoticeLayer:TransitionTime(sTime)
     -- local str = "2012-24-23 03:39:36"    
    local pattern = " "
    local fpos ,lpos =  string.find(sTime,pattern)
    sTime = string.sub(sTime,1,lpos-1)
    sTime = string.gsub(sTime,"-","/")
    return sTime
end

function NoticeLayer:TransitionTitle(sTitle)
    local path = {
    "picdata/notice/news-huodong.png",
    "picdata/notice/news-jbs.png",
    "picdata/notice/news-libao.png",
    "picdata/notice/news-qiandao.png",
    "picdata/notice/news-shousheng.png",
    "picdata/notice/news-shoushu.png",
    "picdata/notice/news-tf.png",
    "picdata/notice/news-vip.png",
    "picdata/notice/news-zhangdui.png",
    "picdata/notice/news.png",
}

    local allIconTip = {"活动","锦标赛","礼包","签到","首胜","手数","提示","vip","战队"}
    --sTitle = "每周签到"
    for i,v in pairs(allIconTip) do 
        local pattern = v 
        local fPos,lPos = string.find(sTitle,v)
        if fPos then
           return path[i]
        end
    end
    return path[10]
end
function NoticeLayer:touchRightListener(event)
    local name, x, y = event.name, event.x, event.y 
    
     if name == "clicked" then
       -- self:checkTouchInSprite_(self.touchBeganX,self.touchBeganY,event.itemPos)
     else
        if name == "began" then
            self.touchBeganX = x
            self.touchBeganY = y
           return true
        end     
     end
    
end
function NoticeLayer:checkTouchInSprite_(x, y,itemPos)    
    for i = 1,#self.mActivitySprite do      
        if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then                               
            
        else
            
        end
    end 
end
--[[
	网络回调
]]
function NoticeLayer:httpResponse(tableData,tag,nType,tableId)
	dump(tableData,tag)
    if tag == POST_COMMAND_GETALLNOTICEINFO then
        self.mLastType = nil
        QDataNoticeList:Init(tableData,tonumber(nType)) 
        self:createRightList(nType)
    elseif tag == POST_COMMAND_GET_MY_PRITABLE then
        if type(tableData) ~= "table" then return end 
        if not tableData["INFO"] or tonumber(tableData["INFO"]["num"]) <= 0 then self:createApplyBuyNothing() return end
        QDataNoticeList:Init(tableData["LIST"],tonumber(self.params.nType)) 
        local cfgData = QDataNoticeList:sortData(tableData["LIST"])
        if #cfgData == 0 then self:createApplyBuyNothing() return end
        for i,v in pairs(cfgData) do 
            if v["PAY_TYPE"] == "VGOLD" then --自定义－－
                DBHttpRequest:getBuyinApplyOrders(function(tableData,tag) self:httpResponse(tableData,tag,self.params.nType,v[TABLE_ID]) end,v[TABLE_ID])
            end
        end
    elseif tag == POST_COMMAND_BUYIN_APPLY_ORDERS then
        if type(tableData) ~= "table" then return end 
        QDataNoticeList:addMsgData(nType,tableData["LIST"],tableId)
        self:createApplyBuy()
    end
end
function NoticeLayer:updateCallBack(tableData)
  
    local layerID = tableData.layerID
      -- dump(tableData,layerID)
    if layerID == COMMAND_APPLY_ANSWER_RESP then
        local sTips = "操作成功"
        if tableData["0001"]    == -11015 then
            sTips = "操作失败"
        end
        QDataNoticeList:removeMsgDataByType(self.params.nType,tableData)
        self:createApplyBuy()
        CMShowTip(sTips)
    end
end
return NoticeLayer