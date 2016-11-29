--
-- Author: junjie
-- Date: 2015-11-23 14:23:14
--
--日常任务
local CMCommonLayer = require("app.Component.CMCommonLayer")
local TaskListLayer = class("TaskListLayer",CMCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
local CMButton = require("app.Component.CMButton")
local QDataTaskList = nil
function TaskListLayer:ctor()
	self:setNodeEventEnabled(true)
	QDataTaskList = QManagerData:getCacheData("QDataTaskList")
	TaskListLayer.super.ctor(self,{titlePath = "picdata/task/taskDialogTitle.png"})
end

function TaskListLayer:create()
	TaskListLayer.super.initUI(self)
	local secBg = cc.Sprite:create("picdata/public/tc1_bg2.png")
	secBg:setPosition(self.mBg:getContentSize().width/2, secBg:getContentSize().height/2+25)
	self.mBg:addChild(secBg)
	local btnSign = CMButton.new({normal = "picdata/task/btn_qiandao.png",pressed = "picdata/task/btn_qiandao.png"},handler(self, self.onMenuSign), {scale9 = false})    
    :align(display.CENTER, 110,self.mBg:getContentSize().height-48) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)
     if myInfo.data.isSigned then
        btnSign:setTexture("picdata/task/btn_qiandao.png",true)
        btnSign:setTouchEnabled(false)
     end
    local isExist = QDataTaskList:isExistMsgData()
    if isExist then
		self:createTaskList( )
	else
		CMDelay(self, 0.3, function ()
			DBHttpRequest:taskListAll(function(tableData,tag) self:httpResponse(tableData,tag) end)
		end)
	end
end
function TaskListLayer:onExit()
	if QDataTaskList:checkIsReady() then
		QManagerListener:Notify({layerID = eMainPageViewID,tag = "addFreeGold"})
	else
		QManagerListener:Notify({layerID = eMainPageViewID,tag = "removeFreeGold"})
	end
	QManagerData:removeCacheData("QDataTaskList")
	QDataTaskList = nil
end
--[[
	创建列表
]]
function TaskListLayer:createTaskList( )
	-- body
	self.mListSize = cc.size(810 ,480)	
	self.mTaskList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(32,30, self.mListSize.width, self.mListSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchListener))
    :addTo(self.mBg,1)    

    self.cfgData = QDataTaskList:getMsgData() or {}    
	for i = 1,#self.cfgData do 
	   	-- local content     
	    -- content = cc.LayerColor:create(
	    --     cc.c4b(math.random(250),
	    --         math.random(250),
	    --         math.random(250),
	    --         250))
	    -- content:setContentSize(self._listSize.width-20, nHeight)
	    -- content:setTouchEnabled(true)    
	    -- item:addChild(content)  

		self:createListItem(i)	
	end	
	self.mTaskList:reload()	
end

function TaskListLayer:createListItem(idx)

	local data = self.cfgData[idx]
	
	local item = self.mTaskList:newItem()
	local bg = cc.Sprite:create("picdata/task/bg_list.png") 
	local bgWidth = bg:getContentSize().width
   	local bgHeight= bg:getContentSize().height  
	bg:setPosition(100,100)
    item:addContent(bg)   
   	item:setItemSize(bgWidth,bgHeight+6)
   	self.mTaskList:addItem(item)	


   	local golden = cc.Sprite:create("picdata/task/icon_jb.png")
   	golden:setPosition(10+golden:getContentSize().width/2,bgHeight/2)
   	bg:addChild(golden)

   	local strDetail = data.name
   	if data.target ~= 0 then
   		 strDetail = string.format("%s(进度:%s/%s)",strDetail, data.prog , data.target)
   	end
   	local sDetail = cc.ui.UILabel.new({text = strDetail,size = 24,color = cc.c3b(255,255,255)})	
   	sDetail:setAnchorPoint(0,0.5)
	sDetail:setPosition(110,bgHeight/2+15)
	bg:addChild(sDetail)

	local strAward =  "奖励: " .. data.rdesc
	local sAward = cc.ui.UILabel.new({text = strAward,size = 20,color = cc.c3b(254,249,195)})	
   	sAward:setAnchorPoint(0,0.5)
	sAward:setPosition(110,bgHeight/2-15)
	bg:addChild(sAward)

	local nStatus = data.status

	--local nStatus = 2 
	local sp
	if nStatus == "NOTREADY" then
		sp = cc.Sprite:create("picdata/task/btn_before.png")
	elseif nStatus == "READY" then 
		sp = CMButton.new({normal = "picdata/task/btn_lq.png"},function () self:onMenuGetAward(data.key) end)    
	elseif nStatus == "DONE" then
		sp = cc.Sprite:create("picdata/task/icon_finsh.png")
		local mask = cc.Sprite:create("picdata/task/bg_list.png") 
		mask:setPosition(bgWidth/2,bgHeight/2)
		mask:setOpacity(200)
		bg:addChild(mask,1)
	end
	sp:setPosition(bgWidth - 110,bgHeight/2)
	bg:addChild(sp)
end
function TaskListLayer:touchListener(event)

end
--[[
	签到按钮
]]
function TaskListLayer:onMenuSign()
	if GIOSCHECK then return end
	self:setLocalZOrder(1)
	local RewardLayer = require("app.GUI.reward.RewardLayer"):new({nType = 1})
	CMOpen(RewardLayer, self:getParent())
    self:onMenuClose()

end

--[[
	请求领取
]]
function TaskListLayer:onMenuGetAward(activityId)
	DBHttpRequest:taskFinishAndReward(function(tableData,tag) self:httpResponse(tableData,tag) end,activityId,"")
end

--[[
	网络回调
]]
function TaskListLayer:httpResponse(tableData,tag)

	--dump(tableData,tag)
	if tag == POST_COMMAND_taskListAll then  				--请求列表回调	
		QDataTaskList:Init(tableData)		
		DBHttpRequest:getActivityData(function(tableData,tag) self:httpResponse(tableData,tag) end, 206, "")
	elseif tag == POST_COMMAND_taskFinishAndReward or tag == POST_COMMAND_JoinActivity then 	--领取奖励回调
		local text = ""
		local isSuc 
		if tableData.CODE == 10000 then
			if tag == POST_COMMAND_JoinActivity then
				local goldNum = 1000
				if tonumber(myInfo.data.vipLevel) ~= 0 then
					goldNum = 3000
				end
				 myInfo.data.totalChips =  myInfo.data.totalChips + goldNum
				 tableData.LIST[1]["key"] = "206"
			end
			text = "领取成功"
			isSuc = true
			QManagerListener:Notify({layerID = eMainPageViewID})
			QDataTaskList:updateMsgData(tableData.LIST)
			if self.mTaskList then self.mTaskList:removeFromParent() self.mTaskList = nil end
			self:createTaskList( )
		else
			text = "领取失败,请稍候再试"
			isSuc = false
		end
		local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = isSuc})
            CMOpen(CMToolTipView,self)
	elseif tag == POST_COMMAND_GetActivityData then 		--活动剩余次数
		if tableData.CODE == 10000 then
			QDataTaskList:addMsgData(tableData.LIST[1].LEFT_TIMES)
			self:createTaskList()
		end
	end
	
end


return TaskListLayer
