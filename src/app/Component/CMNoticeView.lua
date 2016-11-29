--
-- Author: junjie
-- Date: 2016-02-18 16:14:38
--
--游戏广播
local CMNoticeView = class("CMNoticeView", function()
	return display.newNode()
end)
local CMColorLabel = require("app.Component.CMColorLabel")
function CMNoticeView:ctor(params)
	self._params = params or {}	
	self:initUI()
end

function CMNoticeView:initUI()
	local cfgData = {}
	local textTip = ""
	local sTips   = self._params.message --or "广播"..#GBroadTips
	sTips = sTips .. "#07"
	-- if self._params.BroadCastId == 0 then
	-- 	sTips = self._params.Text or ""
	-- else
	-- 	cfgData = ParaseBroadCast.getItemData(self._params.BroadCastId)
	-- 	textTip = CMSplit(self._params.Text or "", "#")	
	-- 	sTips   = cfgData.context or ""
	-- end
	-- if QManagerScene:getSceneId() == 5 and cfgData.showPos == 3 then 
	-- 	--print("战斗")
	-- 	return
	-- end	
	--local textTip = CMSplit(self._params.Text or "", "#")	
	--local sTips   = cfgData.context or ""	
	function Params(t)
		if #t >= 1 then 		
			local value = t[1]
			table.remove(t,1)
			if (#t > 0) then
				return value,Params(t)
			else 
				return value
			end		
		end
	end

	--sTips = string.format(sTips,Params(textTip))
		
	local width = display.width
	local height= display.height
	self._bg = cc.Sprite:create("picdata/MainPage/bg_news.png")
	self._bg:setPosition(width/2,height-self._bg:getContentSize().height/2)
	self:addChild(self._bg)	

	self._size = self._bg:getContentSize()
	local bound = {x = 0, y = 0, width = self._size.width, height = self._size.height} 	

	self._scrollView = cc.ui.UIScrollView.new({
	    direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
	    viewRect = bound, 
	   -- scrollbarImgH = "scroll/barH.png",
	   -- scrollbarImgV = "scroll/bar.png",
	   bgColor = cc.c4b(255,0,0,0)
	})          
    :addTo(self._bg)
 
	self._text = CMColorLabel.new({text = sTips,size = 28})
	self._text:setPosition(self._size.width,self._size.height/2)		
	self._scrollView:addChild(self._text)
		
	self._time = (self._text:getContentWidth()+self._size.width)/200
	--dump(self._text:getContentWidth(),self._time)
	local action1 = transition.moveTo(self._text, {x = -self._text:getContentWidth(), y = self._size.height/2, time = self._time, onComplete = function()
        self._text:setPosition(self._size.width,self._size.height/2)
        self:removeFromParent()
        table.remove(GBroadTips,1)
        
        if #GBroadTips >= 1 then 
        	local BroadCastNode      = require("app.Component.CMNoticeView").new(GBroadTips[1])			
			cc.Director:getInstance():getRunningScene():addChild(BroadCastNode,100)
        else  
        	        	
        end		      	 
    end})    		
end
--[[
	广播播放/添加队列
]]
function CMNoticeView:playNotice(params)
	table.insert(GBroadTips,params)
	if #GBroadTips == 1 then				
		local BroadCastNode      = require("app.Component.CMNoticeView").new(params)			
		cc.Director:getInstance():getRunningScene():addChild(BroadCastNode,100)	
	end
end
return CMNoticeView