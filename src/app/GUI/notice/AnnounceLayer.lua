--
-- Author: junjie
-- Date: 2016-01-27 14:20:22
--
--公告
local AnnounceLayer = class("AnnounceLayer",function() 
	return display.newColorLayer(cc.c4b( 0,0,0,0))
end)
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")

local bgWidth
local bgHeight

local btnTag = 101
local redPointTag = 102
local titleTag = 103

function AnnounceLayer:ctor(params)
	self.params = params or {}	
	self.params.titleText = self.params.titleText or "温馨提示"
end

function AnnounceLayer:create()
    self:setTouchSwallowEnabled(false)
	DBHttpRequest:getAffiches(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId)	
end

function AnnounceLayer:initUI(data)
    self:setTouchSwallowEnabled(true)	
	self.m_data = data or {}

    -- local bg = cc.Sprite:create("picdata/public_new/bg_tc.png")
    -- bgWidth = bg:getContentSize().width
    -- bgHeight= bg:getContentSize().height
    -- self.mSize = cc.size(bgWidth - 100,bgHeight-100)
    -- bg:setPosition(display.cx,display.cy)
    -- self:addChild(bg)
    -- self.mBg = bg

    bgWidth = 914
    bgHeight= 626
    local bg = cc.ui.UIImage.new("picdata/public_new/bg_tc.png",{scale9=true})
    bg:setLayoutSize(bgWidth, bgHeight)
    self.mSize = cc.size(bgWidth - 100,bgHeight-100)
    bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2,CONFIG_SCREEN_HEIGHT/2)
    self:addChild(bg)
    self.mBg = bg

    local btnClose = CMButton.new({normal = "picdata/public_new/btn_close.png",pressed = "picdata/public_new/btn_close_p.png"},
            function ()
                if not CMIsNull(self.m_titleList) then
                    if self.m_titleList:isVisible() then
                        CMClose(self)
                    else
                        self:onOneToListAnim()
                    end
                else
                    CMClose(self)
                end
            end, {scale9 = false})    
        :align(display.CENTER, bgWidth-45,bgHeight-50) --设置位置 锚点位置和坐标x,y
        :addTo(bg)

    local title = cc.Sprite:create("picdata/announce/w_title_gg.png")
    title:pos(bgWidth/2, bgHeight - title:getContentSize().height/2 - 25)
    title:addTo(bg, nil, titleTag)

    local secNode = display.newNode():pos(0, -title:getContentSize().height-43):addTo(self.mBg)

    -- 创建标题listView
    self.m_titleList = cc.ui.UIListView.new {
            viewRect = cc.rect(0,  title:getContentSize().height+57, bgWidth-10, bgHeight-title:getContentSize().height-57),      
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            scrollbarImgV = "picdata/public_new/slider.png",
        }:addTo(secNode)

    local idStr = UserDefaultSetting:getInstance():getAnnounceIDs()
    
    -- 创建各个公告标题Item
    for i, v in ipairs(self.m_data) do
        if string.find(idStr, v.id) then
            v.isRead = true
        end
        local item = self.m_titleList:newItem()
        item:setTouchEnabled(true)
        item:setTouchSwallowEnabled(false)

        local itemNode = display.newNode()
        item:addContent(itemNode)

        local itemBg = cc.Sprite:create("picdata/announce/btn_news.png"):addTo(itemNode)

        local secTitle =  cc.ui.UILabel.new({
                color = cc.c3b(255, 255, 255),
                text  = v.title or "",
                size  = 24,
                align = cc.ui.TEXT_ALIGNMENT_LEFT,
                font = "黑体",
            }):pos(20, itemBg:getContentSize().height/2 + 10)
        itemBg:addChild(secTitle)



        local timeLabel =  cc.ui.UILabel.new({
                color = cc.c3b(109, 136, 189),
                text  = v.time or "",
                size  = 20,
                align = cc.ui.TEXT_ALIGNMENT_LEFT,
            }):pos(20, itemBg:getContentSize().height/2 - 25)
        itemBg:addChild(timeLabel)

        if not v.isRead then
            cc.Sprite:create("picdata/public_new/icon_tipsdot_red.png")
                :pos(itemBg:getContentSize().width/2 - 10, itemBg:getContentSize().height/2 - 10)
                :addTo(itemNode, nil, redPointTag)
        end

        if i == 1 then
            item:setItemSize(bgWidth, 120)
            itemBg:pos(0, -6)
        else
            item:setItemSize(bgWidth, 112)
        end

        item:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(evt)
                if evt.name == "began" then
                    self.m_clickItemCancel = false
                    self.m_touchItemBeganX = evt.x
                    self.m_touchItemBeganY = evt.y
                    CMSpriteImage(itemBg, "picdata/announce/btn_news_p.png")
                    return true
                elseif evt.name == "moved" then
                    if math.abs(self.m_touchItemBeganX - evt.x) > 20 or math.abs(self.m_touchItemBeganY - evt.y) > 20 then
                        self.m_clickItemCancel = true
                        CMSpriteImage(itemBg, "picdata/announce/btn_news.png")
                        return
                    end
                elseif evt.name == "ended" or evt.name == "cancelled" then
                    if not self.m_clickItemCancel then
                        local redPoint = itemNode:getChildByTag(redPointTag)
                        if redPoint then
                            redPoint:removeFromParent()
                        end
                        self:onListToOneAnim(v)
                        CMSpriteImage(itemBg, "picdata/announce/btn_news.png")
                    end
                end
            end)
        self.m_titleList:addItem(item)
    end
    self.m_titleList:reload()

    -- 创建裁剪区域，用于展示一条详细公告的动画
    local rect = cc.rect(0,
                    0,
                    bgWidth-5,
                    bgHeight)
    self.m_clipNode = display.newClippingRegionNode(rect)
    -- self.m_clipNode = display.newNode()
    self.m_clipNode:addTo(self.mBg)
end

--[[
    由列表转向一条详细公告
]]
function AnnounceLayer:onListToOneAnim(datas, needAnim)
    if not CMIsNull(self.m_titleList) then
        self.m_titleList:setVisible(false)
    end
    if not CMIsNull(self.mBg) then
        self.mBg:getChildByTag(titleTag):removeFromParent()
    end
    if not CMIsNull(self.m_oneAnnounceNode) then
        self.m_oneAnnounceNode:setVisible(true)
    end
    self:onShowOneAnnounce(datas)
    if needAnim ~= false then
        self.m_oneAnnounceNode:pos(self.mBg:getContentSize().width, 0)
        self.m_oneAnnounceNode:moveTo(0.3, 0, 0)
        local btn = self.mBg:getChildByTag(btnTag)
        if not CMIsNull(btn) then
            btn:fadeIn(0.2)
        end
    else
        self.m_oneAnnounceNode:pos(0, 0)
    end
end

--[[
    由一条详细公告转向列表
]]
function AnnounceLayer:onOneToListAnim()
    if self.m_data and #self.m_data == 1 then
        CMClose(self)
        return
    end
    if not CMIsNull(self.m_oneAnnounceNode) then
        transition.moveTo(self.m_oneAnnounceNode, {time=0.3, x=self.mBg:getContentSize().width, easing="sineOut", onComplete=function()
                if not CMIsNull(self.m_titleList) then
                    self.m_titleList:setVisible(true)
                end
                if not CMIsNull(self.mBg) then
                    self.mBg:getChildByTag(titleTag):removeFromParent()
                    local title = cc.Sprite:create("picdata/announce/w_title_gg.png")
                    title:pos(bgWidth/2, bgHeight - title:getContentSize().height/2 - 25)
                    title:addTo(self.mBg, nil, titleTag)
                end
            end})
    else
        if not CMIsNull(self.m_titleList) then
            self.m_titleList:setVisible(true)
        end
        if not CMIsNull(self.mBg) then
            self.mBg:getChildByTag(titleTag):removeFromParent()
            local title = cc.Sprite:create("picdata/announce/w_title_gg.png")
            title:pos(bgWidth/2, bgHeight - title:getContentSize().height/2 - 25)
            title:addTo(self.mBg, nil, titleTag)
        end
    end
    if not CMIsNull(self.mBg) then
        local btn = self.mBg:getChildByTag(btnTag)
        if not CMIsNull(btn) then
            btn:fadeOut(0.2)
            transition.fadeOut(btn, {time=0.2, onComplete=function()
                    if not CMIsNull(btn) then
                        btn:removeFromParent()
                    end
                end})
        end
    end
end

function AnnounceLayer:onMenuCallBack(tag, id)
	if tag == 1 then
        if self.m_data and #self.m_data > 0 then
            for i, v in pairs(self.m_data) do
                if v.id == id then
                    if v.status == 0 or v.status == 2 then
                        self:onOneToListAnim()
                    else
                        DBHttpRequest:getAward(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,v.id) 
                    end
                    break
                end
            end
        end
	end
end

-- 显示一条详细公告
function AnnounceLayer:onShowOneAnnounce(itemData)
    if GV.UserConfig.noReadAffichesIDs[itemData.id] then
        local cpTable = clone(GV.UserConfig.noReadAffichesIDs)
        cpTable[itemData.id] = nil
        GV.UserConfig.noReadAffichesIDs = cpTable
    end
    local idStr = UserDefaultSetting:getInstance():getAnnounceIDs()
    if not string.find(idStr, itemData.id) then
        UserDefaultSetting:getInstance():setAnnounceIDs(idStr .. "," .. itemData.id)
    end
    if CMIsNull(self.m_oneAnnounceNode) then
        self.m_oneAnnounceNode = display.newNode():addTo(self.m_clipNode)
    end
    self.m_oneAnnounceNode:removeAllChildren()

    local secTitle =  cc.ui.UILabel.new({
        color = cc.c3b(255, 255, 255),
        text  = itemData.title or "",
        size  = 36,
        font  = "黑体",
    })
    secTitle:setPosition(bgWidth/2-secTitle:getContentSize().width/2, bgHeight-secTitle:getContentSize().height/2-25)
    secTitle:addTo(self.mBg, nil, titleTag)

    local bound
    local text = string.gsub(itemData.content or "","#","\n")
    -- text = "内通关可获题内\nDelayTimess  sssdddddDD淡淡的"
    -- text = "题内通关可获题内通关可获得题内通\n满星评\n满星题内通题内通题内通评得满星评价满星评价评价关通关可获得题内通满星评价满星评价\n\n奖励内容：\n门票"
    -- text = text .. text
    -- text = text .. text

    local startPos = string.find(text, "奖励：") 
    if startPos then
        local awardText = string.sub(text, startPos)
        text = string.sub(text, 1, startPos - 1)
        cc.Sprite:create("picdata/public_new/line.png"):pos(bgWidth/2, 200):addTo(self.m_oneAnnounceNode)

        local awardBound
        if itemData and itemData.status == 1 then
            awardBound = {x = 0, y = 120, width = bgWidth-10, height = 75}  
        else
            awardBound = {x = 0, y = 15, width = bgWidth-10, height = 180}  
        end

        local awardNode = display.newNode()     

        local awardLabel = cc.ui.UILabel.new({
            color = cc.c3b(255, 255, 255),
            text  = awardText or "",
            size  = 28,
            font  = "黑体",
            textAlign = cc.TEXT_ALIGNMENT_LEFT,
            dimensions = cc.size(awardBound.width - 110, 0)
        })  

        if awardLabel:getContentSize().height < awardBound.height then
            awardNode:setContentSize(awardBound.width, awardLabel:getContentSize().height)
        else
            awardNode:setContentSize(awardBound.width, awardBound.height)
        end

        awardLabel:pos(60, awardLabel:getContentSize().height/2)
        awardLabel:addTo(awardNode, 2)

        awardNode:pos(0, awardNode:getCascadeBoundingBox().height/2)

        local awardScrollView = cc.ui.UIScrollView.new({
                direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
                viewRect = awardBound, 
                scrollbarImgV = "picdata/public_new/slider.png",
            })
            :addScrollNode(awardNode)
            -- ＊＊＊注意：这里的zorder要比其他的高，会破坏之后添加同等级的node的截屏效果，之前添加的不会，比较奇怪
            :addTo(self.m_oneAnnounceNode, 2)
        awardScrollView:resetPosition()

        bound = {x = 0, y = 210, width = bgWidth-10, height = bgHeight-297} 
    else
        bound = {x = 0, y = 15, width = bgWidth-10, height = bgHeight-102}  
    end

    local node = display.newNode()     

    local sTip = cc.ui.UILabel.new({
            text = text,
            font = "黑体",
            color = cc.c3b(180,192,220),
            size = 26,
            align = cc.ui.TEXT_ALIGN_LEFT,
            dimensions = cc.size(bound.width - 110, 0)
        })    

    if sTip:getContentSize().height < bound.height then
        node:setContentSize(bound.width, sTip:getContentSize().height)
    else
        node:setContentSize(bound.width, bound.height)
    end

    sTip:pos(60, sTip:getContentSize().height/2)
    sTip:addTo(node, 2)

    local item = cc.ui.UIScrollView.new({
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            viewRect = bound, 
            scrollbarImgV = "picdata/public_new/slider.png",
        })
        :addScrollNode(node)
        -- ＊＊＊注意：这里的zorder要比其他的高，会破坏之后添加同等级的node的截屏效果，之前添加的不会，比较奇怪
        :addTo(self.m_oneAnnounceNode, 2)
    node:pos(0, node:getCascadeBoundingBox().height/2)
    item:resetPosition()

    local btnState = self.mBg:getChildByTag(btnTag)
    if btnState then
        btnState:removeFromParent()
    end

    --0 没有 1 有
    local nState = itemData.status or 3
    local btnString  = "确定"
    if nState == 1 then -- 可领
        btnState = CMButton.new({normal = "picdata/public_new/btn_greenlong.png",pressed = "picdata/public_new/btn_greenlong_p.png"},
                function () 
                    self:onMenuCallBack(1,itemData.id) 
                end, {scale9=true})
            :setButtonSize(880,100)
            :setButtonLabel(cc.ui.UILabel.new({
                color = cc.c3b(255, 255, 255),
                text  = "领取",
                size  = 40,
                font  = "黑体",
            }))
            :align(display.CENTER, bgWidth/2,70) --设置位置 锚点位置和坐标x,y
            :addTo(self.mBg,0,btnTag)
    elseif nState == 2 then -- 已领
        cc.Sprite:create("picdata/public_new/icon_yiling.png"):pos(bgWidth-120, 130):addTo(self.m_oneAnnounceNode)
    end
end

-- 无公告
function AnnounceLayer:showNoAnnounce()
    self:setTouchSwallowEnabled(true)
    -- local bg = cc.Sprite:create("picdata/public_new/bg_tc.png")
    -- bgWidth = bg:getContentSize().width
    -- bgHeight= bg:getContentSize().height
    -- self.mSize = cc.size(bgWidth - 100,bgHeight-100)
    -- bg:setPosition(display.cx,display.cy)
    -- self:addChild(bg)
    -- self.mBg = bg

    bgWidth = 914
    bgHeight= 626
    local bg = cc.ui.UIImage.new("picdata/public_new/bg_tc.png",{scale9=true})
    bg:setLayoutSize(bgWidth, bgHeight)
    self.mSize = cc.size(bgWidth - 100,bgHeight-100)
    bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2,CONFIG_SCREEN_HEIGHT/2)
    self:addChild(bg)
    self.mBg = bg

    local btnClose = CMButton.new({normal = "picdata/public_new/btn_close.png",pressed = "picdata/public_new/btn_close_p.png"},
            function ()
                CMClose(self)
            end, {scale9 = false})    
        :align(display.CENTER, bgWidth-45,bgHeight-50) --设置位置 锚点位置和坐标x,y
        :addTo(bg)

    local title = cc.Sprite:create("picdata/announce/w_title_gg.png")
    title:pos(bgWidth/2, bgHeight - title:getContentSize().height/2 - 25)
    title:addTo(bg, nil, titleTag)

    cc.Sprite:create("picdata/public_new/icon_empty.png"):pos(bgWidth/2, bgHeight/2 + 50):addTo(bg)
    
    local noAnnounceLabel = cc.ui.UILabel.new({
            color = cc.c3b(180, 192, 220),
            text  = "暂无公告",
            size  = 32,
            font  = "黑体",
        }):addTo(bg)
    noAnnounceLabel:pos(bgWidth/2 - noAnnounceLabel:getContentSize().width/2, bgHeight/2 - 50)

    -- 展示缩放动画
    self.mBg:setScale(0.8)
    transition.scaleTo(self.mBg, {scale=1, time=0.3, easing="backOut"})
end

--[[
	网络回调
]]
function AnnounceLayer:httpResponse(tableData,tag)
    if tag == POST_COMMAND_ANNOUNCEINFO then
        UserConfig.getAffichesSign = true
        local index, itemData = next(tableData)
        if index == nil or type(itemData) ~= "table" then
            -- CMShowTip("暂无公告")
            self:showNoAnnounce()
        else
            local idStr = UserDefaultSetting:getInstance():getAnnounceIDs()
            local idsTable = {}
            table.foreach(tableData, function(i, v)
                    if not string.find(idStr, v.id) then
                        idsTable[v.id] = true
                    end
                end)
            GV.UserConfig.noReadAffichesIDs = idsTable
            self:initUI(tableData)
            if self.params and self.params.itemData then
                -- 参数中带有itemData,自动弹窗这条详细公告
                self:onListToOneAnim(self.params.itemData, false)
            elseif #self.m_data == 1 then
                -- 只有一条公告，则直接显示详细公告
                self:onListToOneAnim(self.m_data[1], false)
            end
            -- 展示缩放动画
            self.mBg:setScale(0.8)
            transition.scaleTo(self.mBg, {scale=1, time=0.3, easing="backOut"})
        end
    elseif tag == POST_COMMAND_ANNOUNCEAWARD then
        if not tableData then return end 
    	local text = ""
    	local isSuc
        local isEnabled = false
        if self.m_data and #self.m_data > 0 then
            for i, v in pairs(self.m_data) do
                if v.id == tableData.nid then
                    v.status = 2
                    break
                end
            end
        end
    	if tableData.status == 0 then
    		QManagerListener:Notify({layerID = eMainPageViewID})
    		text = "领取成功"
    		isSuc= true
        elseif tableData.status == 2 then
            text = "领取失败,请稍候再试"
            isSuc= false
            isEnabled = true
    	else 
    		text = "已领取"
    		isSuc= false
    	end
        if not isEnabled then
            local btn = self.mBg:getChildByTag(btnTag)
            if not CMIsNull(btn) then
                btn:removeFromParent()
            end
            if not CMIsNull(self.m_oneAnnounceNode) then
                cc.Sprite:create("picdata/public_new/icon_yiling.png"):pos(bgWidth-120, 130):addTo(self.m_oneAnnounceNode)
            end
        end
        
    	local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = isSuc})
	    CMOpen(CMToolTipView,self)
    end
end
return AnnounceLayer