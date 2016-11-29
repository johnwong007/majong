
local GameLayerManager  = require("app.GUI.GameLayerManager")
local myInfo = require("app.Model.Login.MyInfo")
require("app.CommonDataDefine.CommonDataDefine")
local ToolBarTop = class("ToolBarTop", function()
	return display.newNode()
end)
function ToolBarTop:onEnterTransitionFinish()
    QManagerListener:Attach({{layerID = eToolBarToopID,layer = self}})
end
function ToolBarTop:onExit()
    QManagerListener:Detach(eToolBarToopID)
end
function ToolBarTop:ctor(params)
    if params and params.dispatchEvtOpen then
        self.dispatchEvtOpen = params.dispatchEvtOpen
    end
    if params and params.dispatchEvtClose then
        self.dispatchEvtClose = params.dispatchEvtClose
    end
    self:setNodeEventEnabled(true)  
	local bg = cc.Sprite:create(GDIFROOTRES .. "picdata/MainPage_dif/top_1_bg.png")
    local bgWidth = bg:getContentSize().width
    local bgHeight= bg:getContentSize().height
    -- bg:setPosition(bgWidth/2, 0)
    self:addChild(bg)

    cc.ui.UIImage.new("top_3_icon_coin.png")
        :align(display.LEFT_CENTER, 10, bgHeight/2)
        :addTo(bg)

    self.m_exchangegold = cc.ui.UIPushButton.new({normal="top_3_btn_add.png", pressed="top_3_btn_add2.png", selected="top_3_btn_add2.png"})
        :align(display.LEFT_CENTER, 230, bgHeight/2)
        :addTo(bg)
    self.m_exchangegold:onButtonClicked(function(event) 
        self:exchangeGold()
    end)

    local integral = nil
    if not params.showDebaoDiamond then
        integral = cc.ui.UIImage.new("picdata/MainPage/top_4_icon_integral.png")
            :align(display.LEFT_CENTER, 300, bgHeight/2)
            :addTo(bg)
    else
        integral = cc.ui.UIImage.new("picdata/public2/icon_dbz.png")
            :align(display.LEFT_CENTER, 300, bgHeight/2)
            :addTo(bg)
    end

    self.m_exchangescore = cc.ui.UIPushButton.new({normal="top_4_btn_gift.png", pressed="top_4_btn_gift2.png", selected="top_4_btn_gift2.png"})
        :align(display.LEFT_CENTER, 490, bgHeight/2)
        :addTo(bg)
    self.m_exchangescore:onButtonClicked(function(event) 
        self:exchangeScore()
    end)
  
            --[[金币信息]]

    self.m_goldNum = cc.LabelBMFont:create(StringFormat:FormatDecimals(myInfo.data.totalChips or 0,2),"picdata/MainPage/goldNum.fnt")
    self.m_goldNum:setAnchorPoint(cc.p(0, 0.5))
    self.m_goldNum:setPosition(65,bgHeight/2)
    bg:addChild(self.m_goldNum)
    
    self.m_scoreNum = cc.LabelBMFont:create(StringFormat:FormatDecimals(myInfo.data.userDebaoDiamond or 0,2),"picdata/MainPage/scorenum.fnt")
    self.m_scoreNum:setAnchorPoint(cc.p(0, 0.5))
    self.m_scoreNum:setPosition(355,bgHeight/2)
    bg:addChild(self.m_scoreNum)

     if GDIFROOTRES  == "scene/" then
        self.m_exchangegold:setPositionX(208)
        self.m_exchangescore:setPositionX(440)
        integral:setPositionX(270)
        self.m_scoreNum:setPositionX(325)
    end

    if  GIOSCHECK then
         self.m_exchangescore:setVisible(false)
    end
end

function ToolBarTop:exchangeGold()
	local layer = GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.SHOPGOLD,self:getParent(),nil,nil,self.dispatchEvtOpen) 
    layer.dispatchEvtClose = self.dispatchEvtClose
end

function ToolBarTop:exchangeScore()
    local layer = GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.EXCHARGE,self:getParent(),nil,nil,self.dispatchEvtOpen) 
    layer.dispatchEvtClose = self.dispatchEvtClose
end
--[[
    金币、积分刷新
]]
function ToolBarTop:updateCallBack(data)
    self.m_goldNum:setString(StringFormat:FormatDecimals(myInfo.data.totalChips or 0,2))
    self.m_scoreNum:setString(StringFormat:FormatDecimals(myInfo.data.diamondBalance or 0,2))
end
return ToolBarTop