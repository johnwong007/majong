--
-- Author: junjie
-- Date: 2016-04-20 16:17:43
--
--留言板
local FightCommonLayer = require("app.GUI.fightTeam.FightCommonLayer")
local FTChatNode = class("FTChatNode",FightCommonLayer)
-- local QManagerPlatform   = require("app.Tools.QManagerPlatform"):getInstance({})
local myInfo = require("app.Model.Login.MyInfo")
local QDataFightTeamList = nil
require("app.Network.Http.DBHttpRequest")
GChatText = {}
-- 400x的tag统一给gaf动画使用
local TAG_GAF_RECORD = 4001
local TAG_GAF_RECORD_BG = 4002
local TAG_GAF_CHAT      = 4003
local TOOL_TIP_TAG = 3333
local mMaxScrollPage = 2
local EnumMenu = {
	eBtnBack     = 1,
	eBtnExpress  = 2, 		    --按队名搜
	eBtnSendExpress = 3,		--发送表情
	eBtnCreateDebao = 4,		--创建朋友局
	eBtnPlayVoice   = 5,		--播放语音
	eBtnSendText    = 6, 		--发送文本
	eBtnEnterRoom   = 7, 		--进入牌局

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
local ErrorTipAndroid = 
{
    TIMEOUT =  "超时",
    UNKNOWN =  "未知原因失败。",
    SEND_FREQUENCY_TOO_FAST =  "发送消息频率过快",
    NOT_IN_DISCUSSION   =  "不在讨论组。",
    JOIN_IN_DISCUSSION  =  "加入讨论失败",
    CREATE_DISCUSSION   =  "创建讨论组失败",
    INVITE_DICUSSION    =  "设置讨论组邀请状态失败",
    NOT_IN_GROUP    =  "不在群组。",
    NOT_IN_CHATROOM =  "不在聊天室。",
    GET_USERINFO_ERROR  =  "获取用户失败",
    REJECTED_BY_BLACKLIST   =  "在黑名单中。",
    RC_NET_CHANNEL_INVALID  =  "通信过程中，当前 Socket 不存在。",
    RC_NET_UNAVAILABLE  =  "Socket 连接不可用。",
    RC_MSG_RESP_TIMEOUT =  "通信超时。",
    RC_HTTP_SEND_FAIL   =  "导航操作时，Http 请求失败。",
    RC_HTTP_REQ_TIMEOUT =  "HTTP 请求失败。",
    RC_HTTP_RECV_FAIL   =  "HTTP 接收失败。",
    RC_NAVI_RESOURCE_ERROR  =  "导航操作的 HTTP 请求，返回不是200。",
    RC_NODE_NOT_FOUND   =  "导航数据解析后，其中不存在有效数据。",
    RC_DOMAIN_NOT_RESOLVE   =  "导航数据解析后，其中不存在有效 IP 地址。",
    RC_SOCKET_NOT_CREATED   =  "创建 Socket 失败。",
    RC_SOCKET_DISCONNECTED  =  "Socket 被断开。",
    RC_PING_SEND_FAIL   =  "PING 操作失败。",
    RC_PONG_RECV_FAIL   =  "PING 超时。",
    RC_MSG_SEND_FAIL    =  "消息发送失败。",
    RC_CONN_ACK_TIMEOUT =  "做 connect 连接时，收到的 ACK 超时。",
    RC_CONN_PROTO_VERSION_ERROR =  "参数错误。",
    RC_CONN_ID_REJECT   =  "参数错误，App Id 错误。",
    RC_CONN_SERVER_UNAVAILABLE  =  "服务器不可用。",
    RC_CONN_USER_OR_PASSWD_ERROR    =  "Token 错误。",
    RC_CONN_NOT_AUTHRORIZED =  "App Id 与 Token 不匹配。",
    RC_CONN_REDIRECTED  =  "重定向，地址错误。",
    RC_CONN_PACKAGE_NAME_INVALID    =  "NAME 与后台注册信息不一致。",
    RC_CONN_APP_BLOCKED_OR_DELETED  =  "APP 被屏蔽、删除或不存在。",
    RC_CONN_USER_BLOCKED    =  "用户被屏蔽。",
    RC_DISCONN_KICK =  "Disconnect，由服务器返回，比如用户互踢。",
    RC_DISCONN_EXCEPTION    =  "Disconnect，由服务器返回，比如用户互踢。",
    RC_QUERY_ACK_NO_DATA    =  "协议层内部错误。query，上传下载过程中数据错误。",
    RC_MSG_DATA_INCOMPLETE  =  "协议层内部错误。",
    BIZ_ERROR_CLIENT_NOT_INIT   =  "未调用 init 初始化函数。",
    BIZ_ERROR_DATABASE_ERROR    =  "数据库初始化失败。",
    BIZ_ERROR_INVALID_PARAMETER =  "传入参数无效。",
    BIZ_ERROR_NO_CHANNEL    =  "通道无效。",
    BIZ_ERROR_RECONNECT_SUCCESS =  "重新连接成功。",
    BIZ_ERROR_CONNECTING    =  "连接中，再调用 connect 被拒绝。",
    MSG_ROAMING_SERVICE_UNAVAILABLE =  "消息漫游服务未开通",
    FORBIDDEN_IN_GROUP  =  "群组被禁言",
    CONVER_REMOVE_ERROR =  "删除会话失败",
    CONVER_GETLIST_ERROR    =  "拉取历史消息",
    CONVER_SETOP_ERROR  =  "会话指定异常",
    CONVER_TOTAL_UNREAD_ERROR   =  "获取会话未读消息总数失败",
    CONVER_TYPE_UNREAD_ERROR    =  "获取指定会话类型未读消息数异常",
    CONVER_ID_TYPE_UNREAD_ERROR =  "获取指定用户ID&会话类型未读消息数异常",
    GROUP_SYNC_ERROR    =  "",
    GROUP_MATCH_ERROR   =  "匹配群信息系异常",
    CHATROOM_ID_ISNULL  =  "加入聊天室Id为空",
    CHARTOOM_JOIN_ERROR =  "加入聊天室失败",
    CHATROOM_HISMESSAGE_ERROR   =  "拉取聊天室历史消息失败",
    BLACK_ADD_ERROR =  "加入黑名单异常",
    BLACK_GETSTATUS_ERROR   =  "获得指定人员再黑名单中的状态异常",
    BLACK_REMOVE_ERROR  =  "移除黑名单异常",
    DRAF_GET_ERROR  =  "获取草稿失败",
    DRAF_SAVE_ERROR =  "保存草稿失败",
    DRAF_REMOVE_ERROR   =  "删除草稿失败",
    SUBSCRIBE_ERROR =  "关注公众号失败",
    QNTKN_GET_ERROR =  "",
    COOKIE_ENABLE   =  "cookie被禁用",
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

function FTChatNode:ctor()
	self:setNodeEventEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        self:checkTouchInSprite_(event.x, event.y)
    end)
	QDataFightTeamList = require("app.Logic.Datas.QDataFightTeamList"):Instance()
	self.mCfgData = {}
    self.mTargetId = "DebaoClub"..myInfo.data.userClubId
	self.mAllNode = {}
	self.mAllListHeight = 0   --聊天列表高度
	self.curPaiJuNum    = 0   --当前牌局数量
    self.m_schedulerPool = require("app.Tools.SchedulerPool").new()
end
function FTChatNode:onExit()
    self.m_talkButton:removeLocalScheduler()
    QManagerPlatform:quitClubRoom({['TargetId']=self.mTargetId})
    QManagerListener:Detach(eFTChatNodeID)
end
function FTChatNode:onEnter()
	-- self:enterChatRoom()
    QManagerListener:Attach({{layerID = eFTChatNodeID,layer = self}})
end
--[[
    UI创建
]]
function FTChatNode:create()
	FTChatNode.super.ctor(self,{bgType = 2,showClose = 0,titlePath = "picdata/fightteam/w_t_zd.png",size = cc.size(CONFIG_SCREEN_WIDTH,display.height)}) 
    FTChatNode.super.initUI(self)
    self:createTitleNode()
	self:createRightList()
	self:createExpressUI() 
	self:createExpressBg()
    self:registerRongYun(handler(self, self.enterChatRoom))
	-- self:createGroupButton()
	if not QDataFightTeamList:getMsgData(2) then
		DBHttpRequest:getClubMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId,myInfo.data.userId)
	end
	DBHttpRequest:priTableList(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)
end

---
-- 注册融云
--
-- @handler callback 注册完成回调，注册过程会卡住
--
function FTChatNode:registerRongYun(callback)
    if not GIsConnectRCToken then
        self.m_schedulerPool:delayCall(handler(self, function() 
            HttpClient:getRCToken({
                function(tableData,tag)
                    if tableData.code == 200 then
                        local rcData = {["AppKey"]= "8luwapkvuz8jl",["Token"]= tableData.token,
                        ["UserId"]=myInfo.data.userId,["Username"]=myInfo.data.userName,["UserPotraitUri"]=myInfo.data.userPotraitUri}
                        QManagerPlatform:initRongCloud(rcData)
                        GIsConnectRCToken = true
                    end
                    callback()
                end, 
                function(code, tag)
                    callback()
                end},
                myInfo.data.userId,myInfo.data.userName,myInfo.data.userPotraitUri)
        end), 1, "RongYun")
    else
        callback()
    end
end

--[[
    聊天声音回调
]]
function FTChatNode:updateCallBack(data)
	if data.tag == "showInputBox" then
		if self.mChatBox then self.mChatBox:setVisible(true) end 		--显示输入框
	else 																--添加消息
	    table.insert(GChatText,data)
	    if #GChatText == 1 then
	        if self and self.addTextCell then
	        	if data.nType == "tableMsg" then
	        		DBHttpRequest:priTableList(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userClubId)
	        	end
	            self:addTextCell(data)
	        end
	    end
	end
end
--[[
	测试按钮
]]
function FTChatNode:createGroupButton()
	local CMGroupButton = require("app.Component.CMGroupButton")
	local groupBtn = CMGroupButton.new({callback = handler(self,self.onGroupCallBack),
	name = {"发送文字","创建牌局","进入房间","发送表情","发送语音","禁止聊天","解除禁止"},
	size = cc.size(700,60),
	direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,})
	groupBtn:create()
	groupBtn:setPosition(40,self.mBg:getContentSize().height-80)
	groupBtn:setTouchEnabled(false)	
	self.mBg:addChild(groupBtn)
	-- groupBtn:checkTouchInSprite_(1)
	self.groupBtn = groupBtn
end
--[[
	创建表情页数
]]
function FTChatNode:createDot(_curNum,_totalNum)
	local node = cc.Node:create()

	local posx = 0
	local posy = 0

	for i = 1,_totalNum do		
		local dot_pre = cc.Sprite:create("picdata/setting/listPointGray.png")
		dot_pre:setPosition(cc.p(posx,posy))
		posx = posx + 20
		node:addChild(dot_pre)
	end

	self._dotNor = cc.Sprite:create("picdata/setting/listPoint.png")
	self._dotNor:setPosition(cc.p(0,posy))
	node:addChild(self._dotNor)

	node:setContentSize(cc.size(self._dotNor:getContentSize().width*_totalNum,self._dotNor:getContentSize().height))
	return node
end
--[[
	创建表情面板
]]
function FTChatNode:createExpressBg()
	local node = cc.Node:create()
	node:setPosition(0, -125)
	self.mBg:addChild(node,1)
	self.mAllNode["expressNode"] = node 	--表情
	self.mAllNode["expressNode"]:setVisible(false)
	-- local labelSize = cc.size(self.mBgWidth,85)
    local labelSize = cc.size(display.width,85)
	local bg = cc.ui.UIImage.new("picdata/fightteam/tanchuchuang.png", {scale9 = true})
    bg:setLayoutSize(labelSize.width,labelSize.height)
	bg:setPosition((self.mBgWidth -labelSize.width)/2 ,250)
	node:addChild(bg)

	local labelSize = cc.size(labelSize.width,250)
	local bg2 = cc.ui.UIImage.new("picdata/fightteam/tanchuchuang_bg.png", {scale9 = true})
    bg2:setLayoutSize(labelSize.width,labelSize.height)
	bg2:setPosition((self.mBgWidth -labelSize.width)/2,0)
	node:addChild(bg2)

	local dot = self:createDot(1,mMaxScrollPage)
	dot:setPosition(self.mBgWidth/2-dot:getContentSize().width/2,30)
	node:addChild(dot,2)

	self:createPageView(node)
end
--[[
    是否触摸在聊天案板
]]
function FTChatNode:checkTouchInSprite_(x, y)   
    local isTouch =  self.mAllNode["expressNode"] and self.mAllNode["expressNode"]:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    if isTouch then

    else
        if self.mAllNode["expressNode"]:isVisible() then
            self.mAllNode["expressNode"]:setVisible(false)
            self.mAllNode["chatNode"]:setPositionY(-50)
        end
    end
end
--创建TableView
function FTChatNode:createPageView(parent)	
	local width = self.mBgWidth
	local height = 250
	local x = 0
	local y = 0

    self.mPageview = cc.ui.UIPageView.new {
        bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "sunset.png",
        viewRect = cc.rect(x, y, width, height),
        column = 1, row = 1,
        padding = {left = 0, right = 0, top = 0, bottom = 0},
        columnSpace = 0, rowSpace = 0}
        :onTouch(handler(self, self.touchListener))        
        :addTo(parent,1)    
    
   	self:createPageExpressItem()
    self.mPageview:reload()
end
--[[
	创建所有表情内容
]]
function FTChatNode:createPageExpressItem()	
	local index = 1
	local posx = 0
	local posy = 0
	for i = 1,mMaxScrollPage do 
		posx = 55
		posy = 200
		local item = self.mPageview:newItem()
		self.mPageview:addItem(item)
		for j = 1,16 do   
			index = (i-1)*16 + j
			if index > 30 then 
				return 
			end
			-- local sp = cc.Sprite:create(string.format("picdata/face/%s.png",index))
			-- sp:setPosition(posx,posy)
			-- item:addChild(sp)
			local data = {
				["index"] = index
			}
			local btnSendExpress = CMButton.new({normal = string.format("picdata/face/%s.png",index)},function () self:onMenuCallBack(EnumMenu.eBtnSendExpress,data) end)
			btnSendExpress:setPosition(posx,posy)
			btnSendExpress:setTouchSwallowEnabled(false)
			item:addChild(btnSendExpress)

			posx = posx + 115
			if index%8 == 0 then 
				posx = 55
				posy = 90
			end
		end

	end
end
function FTChatNode:touchListener(event)
    -- dump(event)     
    --local listView = event.listView
    if 1 > event.pageIdx then    	
   		self.mPageview:gotoPage(1)    	
    elseif mMaxScrollPage < event.pageIdx then    	  	
   		self.mPageview:gotoPage(mMaxScrollPage)
    end
    self._dotNor:setPositionX((self.mPageview:getCurPageIdx()-1)*20)
end
--[[
	创建聊天面板
]]
function FTChatNode:createExpressUI()
	local node = cc.Node:create()
	node:setPosition(0,-50)
	self.mBg:addChild(node,2)
	self.mAllNode["chatNode"] = node

	local CMChatButton = require("app.Component.CMChatButton")
    self.m_talkButton = CMChatButton.new({normal = "picdata/fightteam/btn_yy.png"},
    {
        callBegin   = function ()  self:onChatMenuCallBack(1) end,
        callMoveIn  = function ()  self:onChatMenuCallBack(2) end,
        callMoveOut = function ()  self:onChatMenuCallBack(3) end,
        callEndIn   = function ()  self:onChatMenuCallBack(4) end,
        callEndOut  = function ()  self:onChatMenuCallBack(5) end,})    
    :align(display.CENTER, 40, 0) 
    :addTo(node)
    self.m_talkButton.isClick = false

    local inputBox = CMInput:new({
        --bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 300,
        placeColor= cc.c3b(255,255,255),
        -- place     = "有没有兴趣加入我的战队",
        color     = cc.c3b(255,255,255),
        scale9    = true,
        fontSize  = 24,
        bgPath    = "picdata/fightteam/bg_srk.png" , 
        size      = cc.size(755,56) ,    
        forePath  = "picdata/fightteam/btn_send.png" ,
        foreAlign    = CMInput.RIGHT,
        foreCallBack = function () self:onMenuCallBack(EnumMenu.eBtnSendText) end,
        listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
    })
    inputBox:setForBgVisible(false)
    inputBox:setPosition(85,-28)
    node:addChild(inputBox )


    local btnExpress = CMButton.new({normal = "picdata/fightteam/btn_bq.png"},function () self:onMenuCallBack(EnumMenu.eBtnExpress) end)
	btnExpress:setPosition(self.mBgWidth-40,0)
	node:addChild(btnExpress)

	self.mChatBox = inputBox

end

--[[
	标签信息
]]
function FTChatNode:createTitleNode()

	local btnClose = CMButton.new({normal = "picdata/fightteam/btn_back.png",pressed = "picdata/fightteam/btn_back2.png"},
		function () self:onMenuCallBack(EnumMenu.eBtnBack) end, {scale9 = false})    
    :align(display.CENTER, CONFIG_SCREEN_WIDTH/2-430,self.mBg:getContentSize().height-50) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

	local size = cc.size(928,414)
	viewbg = cc.ui.UIImage.new("picdata/fightteam/bg_tc2.png", {scale9 = true})
    viewbg:setLayoutSize(size.width,size.height)
	viewbg:setPosition(self.mBgWidth/2-464,self.mBgHeight/2-205)
	self:addChild(viewbg)
	self.mBgWidth = size.width
	self.mBgHeight= size.height
	self.mBg      = viewbg
	local title = cc.Sprite:create("picdata/fightteam/w_ql.png")
	title:setPosition(self.mBgWidth/2, self.mBgHeight-40)
	viewbg:addChild(title)

	local labelSize = cc.size(928,4)
	local labelBg = cc.ui.UIImage.new("picdata/fightteam/bg_tc_line.png", {scale9 = true})
    labelBg:setLayoutSize(labelSize.width,labelSize.height)
	labelBg:setPosition(self.mBgWidth/2-labelSize.width/2,self.mBgHeight-70)
	viewbg:addChild(labelBg)

	local btnCreate = CMButton.new({normal = "picdata/fightteam/bg_dbj.png"},
		function () self:onMenuCallBack(EnumMenu.eBtnCreateDebao) end, {scale9 = false})    
    :align(display.CENTER, self.mBgWidth - 80,self.mBgHeight-35) --设置位置 锚点位置和坐标x,y
    :addTo(viewbg)
    
    local content = cc.ui.UILabel.new({
            text  = "创建",
            size  = 20,
            color = cc.c3b(0, 255, 255),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
    content:setPosition(0,13)
    btnCreate:addChild(content,0,101)

    local content = cc.ui.UILabel.new({
            text  = "朋友局",
            size  = 20,
            color = cc.c3b(0, 255, 255),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
    content:setPosition(-10,-10)
    btnCreate:addChild(content,0,102)

    self.mAllNode["btnCreate"] = btnCreate
end
--[[
    创建聊天内容
]]
function FTChatNode:createRightList( tableData)
    -- body
    tableData = self.mCfgData or {}
    self.mListSize = cc.size(928,343  ) 
    self.mList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(0, 0, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
    -- if #tableData == 0 then return end
    for i = 1,#tableData do 
        local item = self:createPageItem(i,self.mCfgData)
        self.mList:addItem(item)
    end 
    
    self.mList:reload() 
end
function FTChatNode:touchRightListener(event)
    local name, x, y = event.name, event.x, event.y 
     if name == "began" then
        self:checkTouchInSprite_(x,y)
    end
end
function FTChatNode:createPageItem(idx,serData)
    -- dump(serData,idx)
    -- print(serData.content)
    -- textMsg,voiceMsg,expressionMsg,tableMsg
	serData = serData or {}
	local playerData = QDataFightTeamList:getMsgMemberPlayerData(2,serData.userId) or {}
    local item = self.mList:newItem()   
    local playHeadPath = playerData["4006"]
    local playerName   = playerData["2004"] or ""
    local playerUserId = playerData["2003"] or ""
    local isSelfData   = false
    if playerUserId == myInfo.data.userId then
    	isSelfData = true
    end
    local node = cc.Node:create() 
    local itemSize = cc.size(self.mListSize.width,60)
	
    if tostring(serData.nType) == "textMsg" then        --文字消息
    	local temp = cc.ui.UILabel.new({
            text  = string.format("%s",tostring(serData.content or "")),
            size  = 24,
            color = cc.c3b(255, 255, 255),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
            -- dimensions = cc.size(480,0),
        })
        local tempWidth = temp:getContentSize().width
        if tempWidth > 500 then tempWidth = 500 end
    	local content = cc.ui.UILabel.new({
                text  = string.format("%s",tostring(serData.content or "")),
                size  = 24,
                color = cc.c3b(255, 255, 255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                dimensions = cc.size(tempWidth+15,0),
            })

    	local labelSize = cc.size(content:getContentSize().width,content:getContentSize().height+10)
    	itemSize.height = labelSize.height + 35

		local labelBg = cc.ui.UIImage.new("picdata/fightteam/ql_other.png", {scale9 = true})
	    labelBg:setLayoutSize(labelSize.width,labelSize.height)
		labelBg:setPosition(86,itemSize.height/2-labelSize.height/2-15)
		node:addChild(labelBg)
        
        local arrow = cc.Sprite:create("picdata/fightteam/ql_t.png")
		arrow:setPosition(83, labelSize.height/2+5)
		node:addChild(arrow)

        content:setPosition(5,labelSize.height/2)
        labelBg:addChild(content)

        if isSelfData then
        	content:setScaleX(-1)
        	content:setPositionX(labelSize.width - 5)
        	node:setScaleX(-1)
        end
    elseif tostring(serData.nType) == "voiceMsg" then      --语音消息
    	-- dump(serData)
    	local nPlayTime = serData.duration or 1
    	local width = 20*nPlayTime
    	if width < 40 then width = 40 end
    	if width > 500 then width = 500 end
    	itemSize.height = 75
    	
		local data = {["idx"] = idx,["fileName"] = serData.content or "",["pos"] = cc.p(103,itemSize.height/2-15),["parent"] = node,["nPlayTime"] = nPlayTime}
        local btnPlay = CMButton.new({normal = "picdata/fightteam/ql_other.png"},
        	function () self:onMenuCallBack(EnumMenu.eBtnPlayVoice,data) end,{scale9 = true},{scale = false})
            -- function () self:playAudio(idx,serData.content) end,{scale9 = true},{scale = false})
            -- btnPlay:setButtonLabel("normal",cc.ui.UILabel.new({
            --     --UILabelType = 1,
            --     color = cc.c3b(156, 255, 0),
            --     text = "播放",
            --     size = 28,
            --     font = "FZZCHJW--GB1-0",
            -- }) )  

        
        btnPlay:setButtonSize(width,40) 
        btnPlay:setPosition(86+btnPlay:getButtonSize().width/2,itemSize.height/2-15)
        btnPlay:setTouchSwallowEnabled(false)
        node:addChild(btnPlay)

        local arrow = cc.Sprite:create("picdata/fightteam/ql_t.png")
		arrow:setPosition(83, btnPlay:getPositionY())
		node:addChild(arrow)

		local xinhao = cc.Sprite:create("picdata/fightteam/xinhao.png")
		xinhao:setScaleX(-1)
		xinhao:setPosition(103, itemSize.height/2-15)
		node:addChild(xinhao)
		
		local sTime  = cc.ui.UILabel.new({
            text  = string.format("%s\"",nPlayTime),
            size  = 24,
            color = cc.c3b(178, 204, 255),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
        })
    	sTime:setPosition(btnPlay:getPositionX()+btnPlay:getButtonSize().width/2+5,btnPlay:getPositionY())
   	 	node:addChild(sTime)

   	 	if isSelfData then
        	sTime:setScaleX(-1)
        	sTime:setPositionX(btnPlay:getPositionX()+btnPlay:getButtonSize().width/2 + 40)
        	node:setScaleX(-1)
        end
    elseif  tostring(serData.nType) == "tableMsg" then      --牌局消息
    	local data = string.split(serData.content or "",";")
    	-- dump(data)
    	local sAllType = {
	    	["COMMON"] = "普通局",
   		}

    	local gameId = data[1] or ""
        local tableName = data[2] or ""
        local playType = sAllType[data[3]] or "普通局"
        local tableTime = data[4] or "2012/12/2 10:23"
        local tableMang = data[5] or ""
        local tableOwner= data[6]
        local tableType = data[7]
        -- local content   = string.format("%s;%s;%s;%s;%s",gameId,tableName,playType,tableTime,tableMang)

        local btnPlay = CMButton.new({normal = "picdata/fightteam/bg_pj.png"},
        function ()  self:onMenuCallBack(EnumMenu.eBtnEnterRoom,data) end,nil,{scale = false})  
        itemSize.height = btnPlay:getButtonSize().height + 35
        btnPlay:setPosition(btnPlay:getButtonSize().width/2+86,itemSize.height/2-15)
        btnPlay:setTouchSwallowEnabled(false)
        node:addChild(btnPlay)
        -- btnPlay:setScaleX(-1)
        local arrow = cc.Sprite:create("picdata/fightteam/bg_pj_t.png")
		arrow:setPosition(83, itemSize.height/2-15)
		node:addChild(arrow)


		local labelText = {
			{text = tableName},{text = playType},{text = tableTime},
			{text = tableMang}
		}
		local posy = btnPlay:getButtonSize().height - 90
		local posx = -btnPlay:getButtonSize().width/2 + 5
		for i = 1,#labelText do 
			local content = cc.ui.UILabel.new({
	            text  = labelText[i].text,
	            size  = 24,
	            color = cc.c3b(255, 255, 255),
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            --UILabelType = 1,
	            font  = "黑体",
	        })
	    	content:setPosition(posx,posy)
	   	 	btnPlay:addChild(content)

	   	 	posy = posy - 30
		end

		if isSelfData then
			btnPlay:setScaleX(-1)
        	node:setScaleX(-1)
        end
    elseif tostring(serData.nType) == "expressionMsg" then      --表情消息
        itemSize.height = 100
        local index  = serData.content or 1
        local sp = cc.Sprite:create(string.format("picdata/face/%s.png",index))
        sp:setScale(0.8)
		sp:setPosition(116,itemSize.height/2-15)
		node:addChild(sp)

		if isSelfData then
        	node:setScaleX(-1)
        	sp:setScaleX(-0.8)
        end
    else
        -- local sTip = "2016年1月20日 20点20分"
        -- local sTip1= "玩家 加入了俱乐部" 
        itemSize.height = 100
        local labelText = {
			{text = serData.content or "",fontsize = 20,size = cc.size(250,30)},
			{text = string.format("%s 加入群聊",playerName),fontsize = 22,size = cc.size(350,40)}
		}
		local posy = 50

		for i=1,#labelText do 
	        local labelSize = labelText[i].size
	    
			local labelBg = cc.ui.UIImage.new("picdata/fightteam/bg_zt_30.png", {scale9 = true})
		    labelBg:setLayoutSize(labelSize.width,labelSize.height)
			labelBg:setPosition(itemSize.width/2-labelSize.width/2,posy)
			node:addChild(labelBg)

			local content = cc.ui.UILabel.new({
	            text  = labelText[i].text,
	            size  = labelText[i].fontsize,
	            color = cc.c3b(104, 123, 156),
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            --UILabelType = 1,
	            font  = "黑体",
	        })
	    	content:setPosition(labelSize.width/2-content:getContentSize().width/2,labelSize.height/2)
	   	 	labelBg:addChild(content)

	   	 	posy = posy - 50
		end
    end

    if tostring(serData.nType) ~= "enterRoomMsg" then
		local bgWidth = itemSize.width
	    local bgHeight= itemSize.height
	    
	    local headBG = CMCreateHeadBg(playHeadPath,cc.size(50,50))
		headBG:setPosition(50,bgHeight/2-10)
		node:addChild(headBG)

		local kuang = cc.Sprite:create("picdata/fightteam/touxiang.png")
		kuang:setPosition(50,headBG:getPositionY())
		node:addChild(kuang)

		local name = cc.ui.UILabel.new({
	                text  = playerName,
	                size  = 20,
	                color = cc.c3b(117, 130, 164),
	                align = cc.ui.TEXT_ALIGN_LEFT,
	                --UILabelType = 1,
	                font  = "黑体",
	            })
		name:setPosition(86,bgHeight-20)
	    node:addChild(name)
	    if isSelfData then
	    	name:setScaleX(-1)
	    	name:setPositionX(86+name:getContentSize().width)
	    	
	    end
	end
	item:addContent(node)
    node:setContentSize(self.mListSize.width,itemSize.height)
    item:setItemSize(self.mListSize.width,itemSize.height)

    self.mAllListHeight = self.mAllListHeight + itemSize.height
    return item
end
--[[
    测试按钮组回调，模拟消息
]]
function FTChatNode:onGroupCallBack(index)
	if index == 1 then 		--发送
       local text = self.mChatBox:getText()
        if text == "" then 
            text = "阿斯顿发生的发生阿斯顿发生的发生的发生的发发阿斯顿发生的"
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
            local gameId = "GAME001#1462879408020000CASH1130"
            local tableName = "test1"  
            local playType  = "COMMON"   
            local tableTime = "2012/12/2 10:23"
            local tableMang = "123/246"
            local tableOwner= "3300"--myInfo.data.userId
            local tableType = "CASH"

            local content   = string.format("%s;%s;%s;%s;%s;%s;%s",gameId,tableName,playType,tableTime,tableMang,tableOwner,tableType)
            local msgData = {targetId=self.mTargetId,content=content,userId=myInfo.data.userId or "1234",nType="tableMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
            self:addTextCell(msg)
        end
    elseif index == 3 then  --进入房间
        local text = self.mChatBox:getText()
        if text == "" then 
            text = "456"
        end
        if text ~= "" then
        	local t = os.date("*t", os.time())
    		local strTime = string.format("%04d-%02d-%02d日 %02d:%02d",t.year,t.month,t.day,t.hour,t.min)
            local msgData = {targetId=self.mTargetId,content=strTime,userId=myInfo.data.userId or "1234",nType="enterRoomMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
            -- self:addTextCell(msg)
        end
    elseif index == 4 then  --表情
        local text = self.mChatBox:getText()
        if text == "" then 
            text = "456"
        end
        if text ~= "" then
            local msgData = {targetId=self.mTargetId,content=2,userId=myInfo.data.userId or "1234",nType="expressionMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
            self:addTextCell(msg)
        end
 	elseif index == 5 then  --语音
        local text = self.mChatBox:getText()
        if text == "" then 
            text = "456"
        end
        if text ~= "" then
            local msgData = {targetId=self.mTargetId,content=text,userId=myInfo.data.userId or "1234",nType="voiceMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
            self:addTextCell(msg)
        end
    elseif index == 6 then
        DBHttpRequest:ignoreRCMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,self.mTargetId,1)
    elseif index == 7 then
        DBHttpRequest:rollbackRCMembers(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,self.mTargetId)
	end
end
--[[
    添加一条聊天内容
]]
function FTChatNode:addTextCell(data)
    self.mCfgData = self.mCfgData or {}
    table.insert(self.mCfgData,data)
    -- table.insert(self.mCfgData,{content = text})
    -- dump(self.mCfgData)
    local item = self:createPageItem(#self.mCfgData,data)
    self.mList:addItem(item)
    self.mList:reload()
    -- self.mChatBox:setText("")
    -- local needShowCell = 4
    -- if #self.mCfgData > needShowCell then
    --     self.mList:moveItems(1,#self.mCfgData,0,(#self.mCfgData-needShowCell)*50,false)
    -- end
    if self.mAllListHeight > 343 then
    	self.mList:moveItems(1,#self.mCfgData,0,self.mAllListHeight - 230,false)
    end
    table.remove(GChatText,1)
    if #GChatText >= 1 then 
        if self and self.addTextCell then
            self:addTextCell(GChatText[1]) 
        end                   
    end     
end
function FTChatNode:onMenuCallBack(tag,data)
	-- dump(tag,data)
	if tag == EnumMenu.eBtnBack then
		self.mChatBox:setVisible(false)
		local FTManager      = require("app.GUI.fightTeam.FTManager"):Instance()
		local FTMyTeamLayer = FTManager:getMyTeamLayer()
		if not FTMyTeamLayer then return end
		FTMyTeamLayer:initNodeLabel(1)
	elseif tag == EnumMenu.eBtnExpress then
		local isVisible = self.mAllNode["expressNode"]:isVisible()
		self.mAllNode["expressNode"]:setVisible(not isVisible)
		if isVisible then 
			self.mAllNode["chatNode"]:setPositionY(-50)
		else
			self.mAllNode["chatNode"]:setPositionY(165)
		end
	elseif tag == EnumMenu.eBtnSendExpress then
		local msgData = {targetId=self.mTargetId,content=data.index,userId=myInfo.data.userId or "1234",nType="expressionMsg"}
        local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
        QManagerPlatform:sendMessage(msg)
    self:onMenuCallBack(EnumMenu.eBtnExpress)
    elseif tag == EnumMenu.eBtnSendText then
    	local text = self.mChatBox:getText()
        if text ~= "" then
            local msgData = {targetId=self.mTargetId,content=text,userId=myInfo.data.userId or "1234",nType="textMsg"}
            local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:sendMessage(msg)
            self.mChatBox:setText("")
        end
	elseif tag == EnumMenu.eBtnPlayVoice then
		local gafData = {['gafFile']="picdata/fightteam/chat.gaf",['tag']=TAG_GAF_CHAT,['pos']=cc.p(data.pos.x,data.pos.y),["parent"] = data.parent,["nPlayTime"]=data.nPlayTime}
        self:playChatGAF(gafData)
		self:playAudio(data.idx,data.fileName)
	elseif tag == EnumMenu.eBtnCreateDebao then
        self.mChatBox:setVisible(false)
		local PrivateHallView = CMOpen(require("app.GUI.hallview.PrivateHallView"), self, {clubId = myInfo.data.userClubId}, 0, 10)
         if self.curPaiJuNum == 0  then
            PrivateHallView:hideSearchInput() 
            CMOpen(require("app.GUI.dialogs.CreateDebaoRoomDialog"), cc.Director:getInstance():getRunningScene(), 0, 0, 0)
        end
       
	elseif tag == EnumMenu.eBtnEnterRoom then
		-- dump(data[7],data[1])
		DBHttpRequest:getTableInfo(function(tableData,tag,extraData) self:httpResponse(tableData,tag,data) end,data[7],data[1])
	end
end

--[[
	进入聊天室房间
]]
function FTChatNode:enterChatRoom(data)
    self.m_schedulerPool:delayCall(handler(self, function() 
        QManagerPlatform:enterClub({["callBack"] = function (data,tag) self:enterRoomCallBack(data,{nType = "enterClub"}) end,["messageCount"] = 20,['targetId']=self.mTargetId,['clubName']="1111"})
    end), 1, "RongYun")
end

local sendTips = {
    -- ["enterClub"]       = "进入房间",
    -- ["textMsg"]         = "发送消息",
    -- ["tableMsg"]        = "进入房间",
    -- ["expressionMsg"]   = "进入房间",
    -- ["voiceMsg"]        = "进入房间",
}
--[[
	发送消息回调
]]
function FTChatNode:enterRoomCallBack(data,msgData) 
    if device.platform == "android" then
        data = json.decode(data)
    end
    dump("======================>")
    dump("战队发送消息回调")
    dump(data)
    dump("======================>")
    local nType = msgData.nType
    local nTips = ""
    if nType == "enterClub" then

    elseif nType == "textMsg" then

    elseif nType == "tableMsg" then

    elseif nType == "expressionMsg" then

    elseif nType == "voiceMsg" then
        msgData.content = data.content
        msgData.duration= data.duration or msgData.duration
    elseif nType == "enterRoomMsg" then

    end
    if data.success then
        if nType ~= "enterClub" then
            self:addTextCell(msgData)
        else

      --   	local t = os.date("*t", os.time())
    		-- local strTime = string.format("%04d年%02d月%02d日 %02d:%02d:%02d",t.year,t.month,t.day,t.hour,t.min,t.sec)
      --       local msgData = {targetId=self.mTargetId,content= strTime,userId=myInfo.data.userId or "1234",nType="enterRoomMsg"}
      --       local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
      --       QManagerPlatform:sendMessage(msg)
        end
    else
        if nType ~= "enterClub" then
            if device.platform == "android" then 
                CMShowTip(ErrorTipAndroid[data.status] or "")
            else
                CMShowTip(ErrorTip[data.status] or "")
            end
        else
            self.m_enterClubTimes = (self.m_enterClubTimes or 0) + 1
            if self.m_enterClubTimes < 3 then
                self:enterChatRoom()
                return
            end
            CMShowTip("进入聊天室失败,请关闭后重试!")
        end
    end

end
--[[
    显示发送成功与失败提示
]]
function FTChatNode:showToolTips(data)
    if self:getChildByTag(TOOL_TIP_TAG) then
        return
    end
    self.toolTips = require("app.Component.CMToolTipView").new({text = data.msg,isSuc = data.flag})
    self.toolTips:create()
    self:addChild(self.toolTips, 10, TOOL_TIP_TAG)
end
--[[
    移除发送语音动画
]]
function FTChatNode:removeMicAnimations()
    if self:getChildByTag(TAG_GAF_RECORD) then
        self:removeChildByTag(TAG_GAF_RECORD, true)
    end
    if self:getChildByTag(TAG_GAF_RECORD_BG) then
        self:removeChildByTag(TAG_GAF_RECORD_BG, true)
    end
end
--[[
    播放录音动画
]]
function FTChatNode:playGAF(data)
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
--[[
    播放语音动画
]]
function FTChatNode:playChatGAF(data)
	if self.mChatGAFAni  then self.mChatGAFAni:removeFromParent() self.mChatGAFAni = nil end
	local nPlayTime = data.nPlayTime
	local parent = data.parent or self
	local asset = gaf.GAFAsset:create(data.gafFile)
    local animation = asset:createObject()
    parent:addChild(animation,1,data.tag)
    animation:setPosition(data.pos)
    animation:setAnchorPoint(cc.p(0.5,0.5))
    animation:setLooped(true, true)
    animation:start()

    self.mLastChatGAFAni = animation
    self.mChatGAFAni  = animation

    --移除
    CMDelay(self.mChatGAFAni,nPlayTime,function () 
    	if self.mChatGAFAni and self.mLastChatGAFAni == self.mChatGAFAni then 
    		self.mChatGAFAni:removeFromParent()
    		 self.mChatGAFAni = nil 
    	end
    	end)
end
--[[
    录音按钮响应回调
]]
function FTChatNode:onChatMenuCallBack(tag)
    if tag == 1 then
        self:removeMicAnimations()
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
            local msgData = {targetId=self.mTargetId,content=text,userId=myInfo.data.userId or "1234",nType="voiceMsg",["duration"] = time}
             local msg = {["callBack"] = function (data,msg) self:enterRoomCallBack(data,msgData) end,["targetId"]=msgData.targetId,["content"]=msgData.content,["userId"]=msgData.userId,["nType"]=msgData.nType}
            QManagerPlatform:stopClubRecord({["callBack"] = function (data,tag) self:enterRoomCallBack(data,msgData) end,["TargetId"]=self.mTargetId,["userId"]=myInfo.data.userId,["duration"] = time,["fromWhere"] = "receiveMsg"})
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
function FTChatNode:playAudio(idx,fileName)
    QManagerPlatform:stopPlayAudio()
    QManagerPlatform:playAudio({content = fileName})
end
-- 输入事件监听方法
function FTChatNode:onEdit(event, editbox)
   if event == "return" then
    	local text = editbox:getText()
    	if text == "" then
    		self.mChatBox:setForBgVisible(false)
    	else
    		self.mChatBox:setForBgVisible(true)
    	end
    -- 从输入框返回
        --print("从输入框返回")       
    end
    
end
--[[
	跳转私人局
]]
function FTChatNode:enterDebaoJu(data)
	-- local gameId = data[1] or ""
 --    local tableName = data[2] or ""
 --    local tableType = sAllType[data[3]] or "普通局"
 --    local tableTime = data[4] or "2012/12/2 10:23"
 --    local tableMang = data[5] or ""
    
	local PrivateHallView = require("app.GUI.hallview.PrivateHallView").new()
	PrivateHallView:setTouchSwallowEnabled(false)
    PrivateHallView:addTo(self)
    local eachInfo = {}
    eachInfo.tableId = data[1]-- "GAME001#1462866968060000CASH1124"
    eachInfo.tableOwner = data[6] or "" --"6230"
    eachInfo.playType = data[3] or "COMMON"
    eachInfo.parent = self
    PrivateHallView:hallEnterRoom(eachInfo)
end

--[[
	网络回调
]]
function FTChatNode:httpResponse(tableData,tag,extraData)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GET_priTableList then 
		if tableData and type(tableData) == "table" and tableData["LIST"] then 
			local num = #tableData["LIST"]
			if num >0 then
				self.curPaiJuNum = num
				local sNum = self.mAllNode["btnCreate"]:getChildByTag(101)
				sNum:setString(num)
				sNum:setPositionX(20 - sNum:getContentSize().width/2)
				self.mAllNode["btnCreate"]:getChildByTag(102):setString("进行中")
			end
		end
	elseif tag == POST_COMMAND_GET_getClubMembers then 
		QDataFightTeamList:Init(tableData,2)
	elseif tag == POST_COMMAND_GETTABLEINFO then
		if tonumber(tableData) == -404 then 
			CMShowTip("牌桌已过期")
		else
			self:enterDebaoJu(extraData)
		end
	end

end

function FTChatNode:onCleanup()
    self.m_schedulerPool:clearByTag("RongYun") 
end

return FTChatNode