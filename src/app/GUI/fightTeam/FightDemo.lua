--
-- Author: junjie
-- Date: 2016-04-25 12:17:58
--
--废弃－－Demo
local CMCommonLayer = require("app.Component.CMCommonLayer")
local FightDemo = class("FightDemo",CMCommonLayer)
local CMGroupButton = require("app.Component.CMGroupButton")
local QManagerPlatform   = require("app.Tools.QManagerPlatform"):getInstance({})
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
-- 400x的tag统一给gaf动画使用
local TAG_GAF_RECORD = 4001
local TAG_GAF_RECORD_BG = 4002
local TOOL_TIP_TAG = 3333
local EnumMenu = {
	eBtnTeamName = 1, 		--按队名搜
	eBtnTeamHead = 2,		--按对战搜

}
local ErrorCode = {
    -- 未知错误（预留）
    KNOWN = -1,    
    -- 已被对方加入黑名单
    REJECTED_BY_BLACKLIST = 405,    
    -- 超时
    ERRORCODE_TIMEOUT = 5004,    
    -- 发送消息频率过高，1秒钟最多只允许发送5条消息
    SEND_MSG_FREQUENCY_OVERRUN = 20604,    
    -- 不在该讨论组中
    NOT_IN_DISCUSSION = 21406,    
    -- 不在该群组中
    NOT_IN_GROUP = 22406,    
    -- 在群组中已被禁言
    FORBIDDEN_IN_GROUP = 22408,    
    -- 不在该聊天室中
    NOT_IN_CHATROOM = 23406,    
    -- 在该聊天室中已被禁言
    FORBIDDEN_IN_CHATROOM = 23408,    
    -- 已被踢出聊天室
    KICKED_FROM_CHATROOM = 23409,    
    -- 聊天室不存在
    RC_CHATROOM_NOT_EXIST = 23410,    
    -- 聊天室成员超限
    RC_CHATROOM_IS_FULL = 23411,    
    -- 当前连接不可用（连接已经被释放）
    RC_CHANNEL_INVALID = 30001,    
    -- 当前连接不可用
    RC_NETWORK_UNAVAILABLE = 30002,    
    -- SDK没有初始化@discussion 在使用SDK任何功能之前，必须先Init。
    CLIENT_NOT_INIT = 33001,    
    -- 数据库错误@discussion 请检查您使用的Token和userId是否正确。
    DATABASE_ERROR = 33002,    
    -- 开发者接口调用时传入的参数错误@discussion 请检查接口调用时传入的参数类型和值。
    INVALID_PARAMETER = 33003,    
    -- 历史消息云存储业务未开通
    MSG_ROAMING_SERVICE_UNAVAILABLE = 33007,    
    -- 无效的公众号。(由会话类型和Id所标识的公众号会话是无效的)
    INVALID_PUBLIC_NUMBER = 29201,
}
local ErrorTip = {    
    [ErrorCode.KNOWN                          ] = "未知错误（预留）",    
    [ErrorCode.REJECTED_BY_BLACKLIST          ] = "已被对方加入黑名单",    
    [ErrorCode.ERRORCODE_TIMEOUT              ] =  "超时",    
    [ErrorCode.SEND_MSG_FREQUENCY_OVERRUN     ] = "发送消息频率过高，1秒钟最多只允许发送5条消息",    
    [ErrorCode.NOT_IN_DISCUSSION              ] = "不在该讨论组中",    
    [ErrorCode.NOT_IN_GROUP                   ] = "不在该群组中",     
    [ErrorCode.FORBIDDEN_IN_GROUP             ] = "在群组中已被禁言",    
    [ErrorCode.NOT_IN_CHATROOM                ] =  "不在该聊天室中",    
    [ErrorCode.FORBIDDEN_IN_CHATROOM          ] =  "在该聊天室中已被禁言",    
    [ErrorCode.KICKED_FROM_CHATROOM           ] = "已被踢出聊天室",    
    [ErrorCode.RC_CHATROOM_NOT_EXIST          ] = "聊天室不存在",    
    [ErrorCode.RC_CHATROOM_IS_FULL            ] = "聊天室成员超限",    
    [ErrorCode.RC_CHANNEL_INVALID             ] = "当前连接不可用（连接已经被释放）",    
    [ErrorCode.RC_NETWORK_UNAVAILABLE         ] = "当前连接不可用",    
    [ErrorCode.CLIENT_NOT_INIT                ] = "SDK没有初始化@discussion 在使用SDK任何功能之前，必须先Init。",    
    [ErrorCode.DATABASE_ERROR                 ] = "数据库错误@discussion 请检查您使用的Token和userId是否正确。",    
    [ErrorCode.INVALID_PARAMETER              ] = "开发者接口调用时传入的参数错误@discussion 请检查接口调用时传入的参数类型和值。",    
    [ErrorCode.MSG_ROAMING_SERVICE_UNAVAILABLE ] = "历史消息云存储业务未开通",     
    [ErrorCode.INVALID_PUBLIC_NUMBER          ] = "无效的公众号。(由会话类型和Id所标识的公众号会话是无效的)",

}
GChatText = {}
function FightDemo:ctor()
    -- local eventDispatcher = self:getEventDispatcher()
    -- local listener = nil

    -- function handleBuyGoods(event) 
    --     dump("handleBuyGoods")
    -- end
    -- listener = cc.EventListenerCustom:create("HandleKey.kDidBuyGoods", handleBuyGoods)
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	self:setNodeEventEnabled(true)
	self.mCfgData = {}
    self.mTargetId = "DebaoClub".."1099"
end
function FightDemo:onExit()
    self.m_talkButton:removeLocalScheduler()
    QManagerPlatform:quitClubRoom({['TargetId']=self.mTargetId})
    QManagerListener:Detach(eFightDemoID)
end
function FightDemo:onEnter()
    QManagerListener:Attach({{layerID = eFightDemoID,layer = self}})
    -- self:enterChatRoom(data)
end
--[[
    聊天声音回调
]]
function FightDemo:updateCallBack(data)
    -- if data.nType == "textMsg" then       --文字消息
        table.insert(GChatText,data)
        if #GChatText == 1 then
            if self and self.addTextCell then
                self:addTextCell(data)
            end
        end
    -- end
end
--[[
	UI创建
]]
function FightDemo:create() 
 	FightDemo.super.ctor(self,{bgType = 2}) 
    FightDemo.super.initUI(self)
    self:createInput()
	self:createGroupButton()
	self:createRightList()
    self:enterChatRoom()
    self:creataChatButton()

end
    

function FightDemo:createGroupButton()
	local groupBtn = CMGroupButton.new({callback = handler(self,self.onGroupCallBack),
	name = {"发送文字","创建牌局","发送表情","禁止聊天","解除禁止"},
	size = cc.size(600,60),
	direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,})
	groupBtn:create()
	groupBtn:setPosition(40,self.mBg:getContentSize().height-80)
	groupBtn:setTouchEnabled(false)	
	self.mBg:addChild(groupBtn)
	-- groupBtn:checkTouchInSprite_(1)
	self.groupBtn = groupBtn
end

function FightDemo:enterChatRoom(data)
    -- QManagerPlatform:getRCTotalUnreadCount({["callBack"] = function (data) self:enterRoomCallBack(data) end})
    QManagerPlatform:enterClub({["callBack"] = function (data,tag) self:enterRoomCallBack(data,{nType = "enterClub"}) end,["messageCount"] = 20,['targetId']=self.mTargetId,['clubName']="1111"})
end
local sendTips = {
    -- ["enterClub"]       = "进入房间",
    -- ["textMsg"]         = "发送消息",
    -- ["tableMsg"]        = "进入房间",
    -- ["expressionMsg"]   = "进入房间",
    -- ["voiceMsg"]        = "进入房间",
}
function FightDemo:enterRoomCallBack(data,msgData) 
    local nType = msgData.nType
    -- dump(data,nType)
    local nTips = ""
    if nType == "enterClub" then

    elseif nType == "textMsg" then

    elseif nType == "tableMsg" then

    elseif nType == "expressionMsg" then

    elseif nType == "voiceMsg" then
        msgData.content = data.content
    elseif nType == "enterRoomMsg" then

    end
    if data.success then
        if nType ~= "enterClub" then
            self:addTextCell(msgData)
        else
            local msgData = {targetId=self.mTargetId,content="2016年1月20日 20点20分",userId=myInfo.data.userId or "1234",nType="enterRoomMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
        end
    else
        if nType ~= "enterClub" then
            CMShowTip(ErrorTip[data.status] or "")
           
        else
            CMShowTip("进入房间失败,错误代码为"..data.status)
        end
    end

end
function FightDemo:createInput()
	local inputBox = CMInput:new({
        --bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 60,
        place     = "不超过60个字符",
        color     = cc.c3b(0,0,0),
        fontSize  = 30,
        bgPath    = "picdata/friend/bg_srk.png" ,        
        --listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
    })
    inputBox:setPosition(self.mBg:getContentSize().width/2,70)
    self.mBg:addChild(inputBox )

	self.mChatBox = inputBox
end
function FightDemo:onGroupCallBack(index)
	if index == 1 then 		--发送
       local text = self.mChatBox:getText()
        if text == "" then 
            text = "123"
        end
        if text ~= "" then
            local msgData = {targetId=self.mTargetId,content=text,userId=myInfo.data.userId or "1234",nType="textMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
            -- self:addTextCell(msg)
        end
     
	elseif index == 2 then  --牌局
		local text = self.mChatBox:getText()
        if text == "" then 
            text = "456"
        end
        if text ~= "" then
            
            local msgData = {targetId=self.mTargetId,content=text,userId=myInfo.data.userId or "1234",nType="tableMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
            -- self:addTextCell(msg)
        end
    elseif index == 3 then  --表情
        local text = self.mChatBox:getText()
        if text == "" then 
            text = "456"
        end
        if text ~= "" then
            local msgData = {targetId=self.mTargetId,content=text,userId=myInfo.data.userId or "1234",nType="expressionMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
            -- self:addTextCell(msg)
        end
    elseif index == 4 then
        DBHttpRequest:ignoreRCMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,self.mTargetId,1)
    elseif index == 5 then
        DBHttpRequest:rollbackRCMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,self.mTargetId)
	end
end
--[[
    添加一条聊天内容
]]
function FightDemo:addTextCell(data)
    self.mCfgData = self.mCfgData or {}
    table.insert(self.mCfgData,{content = text})
    -- dump(self.mCfgData)
    local item = self:createPageItem(#self.mCfgData,data)
    self.mList:addItem(item)
    self.mList:reload()
    self.mChatBox:setText("")
    local needShowCell = 8
    if #self.mCfgData > needShowCell then
        self.mList:moveItems(1,#self.mCfgData,0,(#self.mCfgData-needShowCell)*50,false)
    end
    table.remove(GChatText,1)
    if #GChatText >= 1 then 
        if self and self.addTextCell then
            self:addTextCell(GChatText[1]) 
        end                   
    end     
end
function FightDemo:createRightList( tableData)
    -- body
    tableData = self.mCfgData or {}
    self.mListSize = cc.size(810,420  ) 
    self.mList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(30, 100, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    -- :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
    if #tableData == 0 then return end
    for i = 1,#tableData do 
        local item = self:createPageItem(i,self.mCfgData)
        self.mList:addItem(item)
    end 
    
    self.mList:reload() 
end
function FightDemo:createPageItem(idx,serData)
    -- dump(serData,idx)
    -- print(serData.content)
    -- textMsg,voiceMsg,expressionMsg,tableMsg
	serData = serData or {}
    local item = self.mList:newItem()  
   
    local node = cc.Node:create() 
    local itemSize = cc.size(self.mListSize.width,50)
	local bgWidth = itemSize.width
    local bgHeight= itemSize.height
     item:addContent(node)
    node:setContentSize(self.mListSize.width,itemSize.height)
    item:setItemSize(self.mListSize.width,itemSize.height)
    if tostring(serData.nType) == "textMsg" then        --文字消息
         local content = cc.ui.UILabel.new({
                text  = string.format("［%s］ %s",idx,tostring(serData.content or "")),
                size  = 20,
                color = cc.c3b(255, 255, 255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                dimensions = cc.size(580,48),
            })
        content:setPosition(120,bgHeight/2-10)
        node:addChild(content)
    elseif tostring(serData.nType) == "voiceMsg" then      --语音消息
        local btnPlay = CMButton.new({normal = "picdata/public/btn_1_110_green.png",pressed = "picdata/public/btn_1_110_green2.png"},
            function () self:playAudio(idx,serData.content) end)
            btnPlay:setButtonLabel("normal",cc.ui.UILabel.new({
                --UILabelType = 1,
                color = cc.c3b(156, 255, 0),
                text = "播放",
                size = 28,
                font = "FZZCHJW--GB1-0",
            }) )    
            btnPlay:setPosition(120,bgHeight/2)
            btnPlay:setTouchSwallowEnabled(false)
            node:addChild(btnPlay)
    elseif  tostring(serData.nType) == "tableMsg" then      --牌局消息
        local btnPlay = CMButton.new({normal = "picdata/public/btn_1_110_green.png",pressed = "picdata/public/btn_1_110_green2.png"},
            function ()  end)
            btnPlay:setButtonLabel("normal",cc.ui.UILabel.new({
                --UILabelType = 1,
                color = cc.c3b(156, 255, 0),
                text = "牌局"..idx,
                size = 28,
                font = "FZZCHJW--GB1-0",
            }) )    
            btnPlay:setPosition(120,bgHeight/2)
            btnPlay:setTouchSwallowEnabled(false)
            node:addChild(btnPlay)
    elseif tostring(serData.nType) == "expressionMsg" then      --表情消息
         local btnPlay = CMButton.new({normal = "picdata/public/btn_1_110_green.png",pressed = "picdata/public/btn_1_110_green2.png"},
            function ()  end)
            btnPlay:setButtonLabel("normal",cc.ui.UILabel.new({
                --UILabelType = 1,
                color = cc.c3b(156, 255, 0),
                text = "添加表情",
                size = 28,
                font = "FZZCHJW--GB1-0",
            }) )    
            btnPlay:setPosition(120,bgHeight/2)
            btnPlay:setTouchSwallowEnabled(false)
            node:addChild(btnPlay)
    else
        -- local sTip = "2016年1月20日 20点20分"
        -- local sTip1= "玩家 加入了俱乐部" 
         local content = cc.ui.UILabel.new({
                text  = string.format("［%s］ %s",idx,tostring(serData.content or "")),
                size  = 20,
                color = cc.c3b(255, 255, 255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                dimensions = cc.size(580,48),
            })
        content:setPosition(120,bgHeight/2-10)
        node:addChild(content)
    end
    return item
end
--[[
    语音按钮
]]
function FightDemo:creataChatButton()
    local CMChatButton = require("app.Component.CMChatButton")
    self.m_talkButton = CMChatButton.new({normal = "picdata/table/icon_speech.png"},
    {
        callBegin   = function ()  self:onMenuCallBack(1) end,
        callMoveIn  = function ()  self:onMenuCallBack(2) end,
        callMoveOut = function ()  self:onMenuCallBack(3) end,
        callEndIn   = function ()  self:onMenuCallBack(4) end,
        callEndOut  = function ()  self:onMenuCallBack(5) end,})    
    :align(display.CENTER, 100, 50) 
    :addTo(self)
    -- self.m_talkButton:setVisible(false)
    self.m_talkButton.isClick = false
    -- self:setTalkButtonVisible(true)
end
function FightDemo:showToolTips(data)
    if self:getChildByTag(TOOL_TIP_TAG) then
        return
    end
    self.toolTips = require("app.Component.CMToolTipView").new({text = data.msg,isSuc = data.flag})
    self.toolTips:create()
    self:addChild(self.toolTips, 10, TOOL_TIP_TAG)
end
function FightDemo:removeMicAnimations()
    if self:getChildByTag(TAG_GAF_RECORD) then
        self:removeChildByTag(TAG_GAF_RECORD, true)
    end
    if self:getChildByTag(TAG_GAF_RECORD_BG) then
        self:removeChildByTag(TAG_GAF_RECORD_BG, true)
    end
end
function FightDemo:playGAF(data)
    local asset = gaf.GAFAsset:create(data.gafFile)
    local animation = asset:createObject()
    self:addChild(animation,1,data.tag)
    -- local origin = cc.Director:getInstance():getVisibleOrigin()
    -- local size = cc.Director:getInstance():getVisibleSize()
    animation:setPosition(data.pos)
    animation:setAnchorPoint(cc.p(0.5,0.5))
    animation:setLooped(true, true)
    animation:start()
end
function FightDemo:onMenuCallBack(tag)
    if tag == 1 then
        -- start record
        self.m_talkButton:setTexture("picdata/table/icon_speech2.png")
        QManagerPlatform:startClubRecord()
        
        local recordBG = cc.Sprite:create("picdata/table/bg_tips.png")
        recordBG:setPosition(display.cx,display.cy)
        local micImg = cc.Sprite:create("picdata/table/icon_mic.png")
        micImg:setPosition(146,176)
        recordBG:add(micImg, 2)
        self:addChild(recordBG,1,TAG_GAF_RECORD_BG)
        local data = {['gafFile']="picdata/table/mic.gaf",['tag']=TAG_GAF_RECORD,['pos']=cc.p(display.cx+40,display.cy)}
        self:playGAF(data)

    elseif tag == 2 then 

    elseif tag == 3 then
        -- print(btnHelp:getTouchTime())
            self:removeMicAnimations()
            local data = {['msg']='录音取消',['flag']=false}
            self:showToolTips(data)
            QManagerPlatform:cancelClubRecord()
     elseif tag == 4 then 
        self:removeMicAnimations()
        local time = self.m_talkButton:getTouchTime()
        if time < 1 then
            if self.m_talkButton.isClick ~= true then
                self.m_talkButton.isClick = true

                QManagerPlatform:setPlayFlag({['playFlag']='NO'})
                local data = {['msg']='关闭声音',['flag']=false,['duration'] = 1}
                self:showToolTips(data)
                self.m_talkButton:setTexture("picdata/table/icon_nospeech.png")
            else
                self.m_talkButton.isClick = false
                QManagerPlatform:setPlayFlag({['playFlag']='YES'})
                local data = {['msg']='开启声音',['flag']=true,['duration'] = 1}
                self:showToolTips(data)
                self.m_talkButton:setTexture("picdata/table/icon_speech.png")
            end
        else
            local data = {['msg']='发送语音',['flag']=true}
            self:showToolTips(data)
            self.m_talkButton:setTexture("picdata/table/icon_speech.png")
            local msgData = {targetId=self.mTargetId,content=text,userId=myInfo.data.userId or "1234",nType="voiceMsg"}
             local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:stopClubRecord({["callBack"] = function (data,tag) self:enterRoomCallBack(data,"voiceMsg") end,["TargetId"]=self.mTargetId,["userId"]=myInfo.data.userId})
        end
    -- elseif tag == 4 then
        -- print(btnHelp:getTouchTime())
        -- local time 

    elseif tag == 5 then
        -- print(btnHelp:getTouchTime())
        -- 结束
    end
end
--[[
播放语音内容
]]
function FightDemo:playAudio(idx,fileName)
    QManagerPlatform:stopPlayAudio()
    QManagerPlatform:playAudio({content = fileName})
end
--[[
	网络回调
]]
function FightDemo:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_IGNORERCMEMBERS then 
		
	end

end
return FightDemo