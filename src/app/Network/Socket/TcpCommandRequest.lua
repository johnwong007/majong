require ("app.Network.CommandDefine")
local ByteArray = require("framework.cc.utils.ByteArray") 
local Protocol = require("app.Network.Socket.Protocol")

local net 	= require("framework.cc.net.init")
cc.utils 				= require("framework.cc.utils.init")
local PacketBuffer = require("app.Network.Socket.PacketBuffer")

local myInfo = require("app.Model.Login.MyInfo")
require("socket")

require("framework.functions")
-- TcpCommandRequest = {}

-- setmetatable(TcpCommandRequest, {__index = cc.Ref})
-- TcpCommandRequest.super    = cc.Ref
-- TcpCommandRequest.__cname = "TcpCommandRequest"
-- TcpCommandRequest.__ctype = 2   -- lua
-- TcpCommandRequest.__index = TcpCommandRequest

TcpCommandRequest = class("TcpCommandRequest")

local requestInstance = nil
sharedTcpCommandRequest = nil
function TcpCommandRequest:ctor()
	requestInstance = self
	-- local tcpConn = require("app.Network.Socket.TcpConnector")
	TcpCommandRequest.m_tcpConnector = require("app.Network.Socket.TcpConnector"):new()
	self.m_schedulerPool = require("app.Tools.SchedulerPool").new()
end

function TcpCommandRequest:shareInstance()
	if sharedTcpCommandRequest == nil then
   		local instance = setmetatable({}, TcpCommandRequest)
		instance.class = TcpCommandRequest
		instance:ctor()
		sharedTcpCommandRequest = instance
	end
	return sharedTcpCommandRequest
end
function TcpCommandRequest:onClosed()
	--sharedTcpCommandRequest = nil
	self:stopPing()
	TcpCommandRequest.m_tcpConnector:onClosed()
	
end
function TcpCommandRequest:addObserver(observer)
	self.m_tcpConnector:addObserver(observer)
end

function TcpCommandRequest:removeObserver(observer)
	self.m_tcpConnector:removeObserver(observer)
end

function TcpCommandRequest:closeConnect(resetReconnectNum)
	self:stopPing()
	self.m_tcpConnector:closeSocket(resetReconnectNum)
end

function TcpCommandRequest:isConnect()
	return self.m_tcpConnector:isConnect()
end

function TcpCommandRequest:connectSocket(ip,port)
	return self.m_tcpConnector:startSocketConnect(ip, port)
end
function TcpCommandRequest:showInterConnect(isLoginOut)
	self.m_tcpConnector:showInterConnect(isLoginOut)
end

function TcpCommandRequest:showInterHttpConnect()
	self.m_tcpConnector:showInterHttpConnect()
end

function TcpCommandRequest:startPing()
	-- dump("startPing")
	if self.pingScriptEntry == nil then
		self.m_pingTimeOutCount = 0
		local sharedScheduler = cc.Director:getInstance():getScheduler()
		self.pingScriptEntry = sharedScheduler:scheduleScriptFunc(self.sendPing, TCP_PING_TIME, false)
	end
end

function TcpCommandRequest:stopPing()
	if self.pingScriptEntry then
		local sharedScheduler = cc.Director:getInstance():getScheduler()
		sharedScheduler:unscheduleScriptEntry(self.pingScriptEntry)
		self.pingScriptEntry = nil
	end
end

function TcpCommandRequest.sendPing(t)
	if not sharedTcpCommandRequest:isConnect() then
		local sharedScheduler = cc.Director:getInstance():getScheduler()
		sharedScheduler:unscheduleScriptEntry(sharedTcpCommandRequest.pingScriptEntry)
		sharedTcpCommandRequest.pingScriptEntry = nil
		return
	end
	local buffer = ""
	buffer = string.gsub(buffer, "\\", "")
	local bufferLen = string.len(buffer)
  	local cmd = PING
  	cmd = 1
  	-- print("TcpCommandRequest···sendPing")
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	finalBuffer:setPos(1)
 	requestInstance.m_tcpConnector:send(finalBuffer:getPack())
 	if requestInstance.m_pingTimeOutHandle then
 		requestInstance.m_schedulerPool:clearById(requestInstance.m_pingTimeOutHandle)
 		requestInstance.m_pingTimeOutHandle = nil
 	end
 	requestInstance.m_pingTimeOutHandle = requestInstance.m_schedulerPool:delayCall(handler(requestInstance, requestInstance.onPingTimeOut),TCP_PING_TIMEOUT)
end

---
-- 心跳包超时处理
--
function TcpCommandRequest:onPingTimeOut()
	self.m_pingTimeOutHandle = nil
	self.m_pingTimeOutCount = (self.m_pingTimeOutCount or 0) + 1
	GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, 3 - self.m_pingTimeOutCount)
	CMPrintToScene("TcpConnector 网络心跳包超时 " .. self.m_pingTimeOutCount .. " 次")
	if network.isInternetConnectionAvailable() or self.m_pingTimeOutCount > TCP_PING_TIMECOUNT then
		print("TcpConnector 网络心跳包超时断开")
		CMPrintToScene("TcpConnector 网络心跳包超时断开")
		self:closeConnect(false)
	end
end

---
-- 接收到心跳包
--
function TcpCommandRequest:onPingReceive()
	self.m_pingTimeOutCount = 0
	self.m_schedulerPool:clearById(self.m_pingTimeOutHandle)
	self.m_pingTimeOutHandle = nil
end

function TcpCommandRequest:reportUserID(userID, version)
	local data = {}
	data["uid"] = userID
	data["ver"] = version
	local buffer = json.encode(data)
	local bufferLen = string.len(buffer)
	bufferLen=bufferLen+4
	local bit = ByteArray.new(ByteArray.ENDIAN_BIG)
	bit:setPos(1)
	bit:writeInt(bufferLen)
	bit:writeInt(COMMAND_PUSH_REPORT_USERID)
	bit:writeStringUShort(buffer)
	self.m_tcpConnector:sendData(bit:getPack())
end

function TcpCommandRequest:sendTestPacket()
  	local data = {}
  	data.list = {}
  	table.insert(data.list,{id = 1001,name = "小房",level = 1,sex = 1})
  	table.insert(data.list,{id = 1002,name = "小田",level = 11,sex = 2})
  	table.insert(data.list,{id = 1003,name = "2222",level = 21,sex = 1})
  	table.insert(data.list,{id = 1004,name = "3333",level = 31,sex = 2})
  	data.userid = 10001
  	local cmd = 1001
	-- print("cmd:", type(cmd))
  	self.m_tcpConnector:sendData(cmd,data)
end

function TcpCommandRequest:sendTencentInitPkg(serverId, openUserId)
  	local data = {}
  	data[SESSION_ID] = myInfo.data.userSession
	local agent=""
	if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
		agent = "ANDROID/1.0"
	elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
		agent = "IOS/1.0"
	else
		agent = "ANDROID/1.0"
	end
    -- agent = "IOS\0471.0"
    agent = "IOS/1.0"
	data[USER_AGENT] = agent
--    data[USER_AGENT] = "FLASH/2.0"

 	data[COMM_PROTO_VER] = "13"



	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_CONNECT
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_10, buffer, bufferLen, cmd)
	-- finalBuffer:setPos(1)
 	self.m_tcpConnector:send(finalBuffer:getPack())

	-- DBLog("here we send data+++> ", bufferLen)
	-- DBLog("here we send+++> ", finalBuffer:toString())
	-- DBLog("here we send buffer size+++> ", finalBuffer:getLen())
end

-- function TcpCommandRequest:encryptPkg(version, data, data_size, type)
--  -- 	local buffer = ""..data
--  -- 	local bufferLen = data_size+6
--  -- 	local __pack1 = string.pack(">I", bufferLen)
--  -- 	local __pack2 = string.pack(">HI", version, type)
--  -- 	local __pack3 = string.pack(">A", buffer)
-- 	-- -- 创建一个ByteArray
-- 	-- local pkgout = ByteArray.new()
-- 	-- pkgout:writeBuf(__pack1)
-- 	-- pkgout:writeBuf(__pack2)
-- 	-- pkgout:writeBuf(__pack3)

-- 	-- -- 不要忘了，lua数组是1基的。而且函数名称比 position 短
--  -- 	return pkgout

--  	local pkgout = ByteArray.new(ByteArray.ENDIAN_BIG)
--  	local bufferLen = string.len(data)+6
--  	pkgout:writeUInt(bufferLen)
--  	pkgout:writeUShort(0x3130)
--  	print(hexToDecimal(3130))
--  	pkgout:writeUInt(0x00000002)
--  	pkgout:writeStringBytes(data)
--  	return pkgout
-- end


--[[取牌桌信息]]
function TcpCommandRequest:getTableInfo(tableId, userId)

	local data = {}
  	data[TABLE_ID] = tableId
  	data[USER_ID] = userId
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_TABLE_INFO
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())

end

--[[玩家入座]]
function TcpCommandRequest:sit(table_id, seat_no, user_id, userName, userSex, headPicURL, privilege)
    -- normal_info_log("================== TcpCommandRequest:sit ===================")
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[SEAT_NO] = 0+seat_no

  	-- data[USER_ID] = ""..user_id
  	-- data[QQ_NAME] = ""..userName
  	-- data[QQ_SEX] = ""..userSex
  	-- data[HeadPic_URL] = ""..headPicURL
  	-- data[PRIVILEGE] = 0+privilege
  	if not  myInfo.data.macId then
  		myInfo.data.macId = QManagerPlatform:getUniqueStr()
  		if myInfo.data.macId == "" then
  			myInfo.data.macId = "192.168.0.23"
  		end
  	end
  	data[RUSH_CLIENT_IP] = myInfo.data.macId

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_SIT
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)

  	-- print(finalBuffer:toString(10))
  	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[加入桌子]]
function TcpCommandRequest:joinTable(table_id, password)
	local data = {}
	password = crypto.md5(password)
  	data[TABLE_ID] = ""..table_id
  	data[PASSWORD] = ""..password
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_TABLE_JOIN
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_10, buffer, bufferLen, cmd)
  	--local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
  	-- local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_13, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[离开桌子]]
function TcpCommandRequest:leaveTable(table_id)
	local data = {}
  	data[TABLE_ID] = ""..table_id
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_TABLE_LEAVE 
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[放弃锦标赛]]
function TcpCommandRequest:quitTourney(table_id, user_id)
	-- dump("quitTourney")
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_TOURNEY_QUIT
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[玩家站起]]
function TcpCommandRequest:sit_out(table_id, user_id)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_SIT_OUT
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[玩家看牌]]
function TcpCommandRequest:checkPoker(table_id, user_id, msg_sequence)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[SEQUENCE] = 0+msg_sequence
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_CHECK
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[玩家跟牌]]
function TcpCommandRequest:callPocker(table_id, user_id, msg_sequence)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[SEQUENCE] = 0+msg_sequence
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_CALL
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[玩家弃牌]]
function TcpCommandRequest:foldPocker(table_id, user_id, msg_sequence)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[SEQUENCE] = 0+msg_sequence
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_FOLD
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[玩家ALLIN]]
function TcpCommandRequest:allIn(table_id, user_id, msg_sequence)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[SEQUENCE] = 0+msg_sequence
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_ALL_IN
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[玩家加注]]
function TcpCommandRequest:raise(table_id, user_id, bet_chips, msg_sequence)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[BET_CHIPS] = 0.0+bet_chips
  	data[SEQUENCE] = 0+msg_sequence
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_RAISE
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[牌桌信息]]
function TcpCommandRequest:tableInfo(tableId, user_id, bet_chips, msg_sequence)
	local data = {}
  	data[TABLE_ID] = ""..table_id
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_TABLE_INFO
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[取消托管]]
function TcpCommandRequest:cancel(table_id, user_id)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_CANCEL_TRUSTEESHIP
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[玩家选择亮牌]]
function TcpCommandRequest:showDown(table_id, user_id, showDownType)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[SHOWDOWN_TYPE] = 0+showDownType
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_SHOWDOWN
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[设置自动缴纳盲注类型]]
function TcpCommandRequest:setAutoBlind(table_id, user_id, autoBlindType)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[AUTO_BLIND_TYPE] = autoBlindType
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_SET_AUTO_BLIND
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[加入等候名单]]
function TcpCommandRequest:joinQueue(table_id, user_id, userName)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[USER_NAME] = ""..userName
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_JOIN_WAITING
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[取消加入等候名单]]
function TcpCommandRequest:quitQueue(table_id, user_id, userName)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[USER_NAME] = ""..userName
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_UNJOIN_WAITING
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[继续保持围观]]
function TcpCommandRequest:keepTable(table_id, user_id)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_KEEP_TABLE
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[聊天]]
function TcpCommandRequest:tableChat(table_id, content, isCharge, chatType)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[CONTENT] = ""..content
  	data[IS_IMAGE_CHARG] = 0+isCharge
  	data[CHAT_TYPE] = ""..chatType
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_TABLE_CHAT
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[
 *好友申请*
 fuserId 自己的userid	
 fuserName 自己的昵称
 tuserId 要加的userid
 tuserName 要加的昵称
 ]]
function TcpCommandRequest:applyFriend(table_id, fuserId, fuserName, tuserId, tuserName)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..fuserId
  	data[USER_NAME] = ""..fuserName
  	data[OTHER_USER_ID] = ""..tuserId
  	data[OTHER_USER_NAME] = ""..tuserName
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_APPLY_FRIEND
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[添加好友处理; isAgree = 1 同意,  isAgree = 0 拒绝]]
function TcpCommandRequest:addFriend(table_id, fuserId, fuserName, tuserId, tuserName, isAgree)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..fuserId
  	data[USER_NAME] = ""..fuserName
  	data[OTHER_USER_ID] = ""..tuserId
  	data[OTHER_USER_NAME] = ""..tuserName
  	data[IS_AGREE] = isAgree and 1 or 0
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_ADD_FRIEND
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:fastSit(userId,userName,bigBlind,payType,tableId,moneyBalance)
	local data = {}
  	data[USER_ID] = ""..userId
  	data[USER_NAME] = ""..userName
  	data[BIG_BLIND] = bigBlind+0.0
  	data[PAY_TYPE] = ""..payType
  	data[TABLE_ID] = ""..tableId
	if payType=="GOLD" then
		data[GOLD_BALANCE] = ""..moneyBalance
	elseif payType=="CASH" then
		data[SILVER_BALANCE] = ""..moneyBalance
	end
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_FAST_SIT
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:buyinReq(table_id, user_id, buyinChips, payType, isRebuy)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[BUY_CHIPS] = 0.0+buyinChips
  	data[PAY_TYPE] = ""..payType
  	data[IS_RE_BUY] = isRebuy and 1 or 0

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_BUY_REQ
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:newBuyinReq(table_id, user_id, buyinChips, payType, isRebuy)
	local data = {}
  	data[TABLE_ID] = ""..table_id
  	data[USER_ID] = ""..user_id
  	data[BUY_CHIPS] = 0.0+buyinChips
  	data[PAY_TYPE] = ""..payType
  	data[IS_RE_BUY] = isRebuy and 1 or 0
  	
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_NEW_BUY_REQ
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[报名锦标赛]]
function TcpCommandRequest:applyMatch(macthId, payType, user_id, userName, userSex, usrPortrait, privilege)
	local data = {}
  	data[MATCH_ID] = ""..macthId
  	data[PAY_TYPE] = ""..payType
  	data[USER_ID] = ""..user_id
  	data[USER_NAME] = ""..userName
  	data[USER_SEX] = ""..userSex
  	data[PORTRAIT_URL] = ""..usrPortrait
  	data[PRIVILEGE] = 0+privilege
	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_APPLY_MATCH
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[退锦标赛]]
function TcpCommandRequest:cancelMatch(macthId, userId)
	local data = {}
  	data[MATCH_ID] = ""..macthId
  	data[USER_ID] = ""..userId

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_CANCEL
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:rebuy(userId, userName, tableId, type)
	local data = {}
  	data[USER_ID] = ""..userId
  	data[USER_NAME] = ""..userName
  	data[TABLE_ID] = ""..tableId
  	data[REBUY_MODE] = 1
  	data[REBUY_TYPE] = 0+type

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_REBUY
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

--[[Rush牌桌]]
function TcpCommandRequest:reqJoinRush(userId, userName, payType, ipDress, seatNum, bigBlind, buyChips)
	local data = {}
  	data[TABLE_ID] = "RUSH001#1373343833060000RUSH478"
  	data[USER_ID] = ""..userId
  	data[USER_NAME] = ""..userName
  	data[PAY_TYPE] = ""..payType
  	data[RUSH_CLIENT_IP] = ""..ipDress
  	data[SEAT_NUM] = 0+seatNum
  	data[BIG_BLIND] = 0.0+bigBlind
  	data[RUSH_CLIENT_BUY_CHIPS] = 0.0+buyChips

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_RUSH_JOIN_REQ
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_13, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:reqPlayerRush(userId)
	local data = {}
  	data[USER_ID] = ""..userId

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_RUSH_GET_PLAYER_REQ
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:reqGetTableInfoRush(rushPlayerId)
	local data = {}
  	data[TABLE_ID] = "RUSH001#1373343833060000RUSH478"
  	data[RUSH_PLAYER_ID] = ""..rushPlayerId

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_RUSH_GET_TABLE_INFO_REQ
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:reqCancelTrusteeRush(rushPlayerId, userId, tableId)
	local data = {}
  	data[TABLE_ID] = ""..tableId
  	data[RUSH_PLAYER_ID] = ""..rushPlayerId
  	data[USER_ID] = ""..userId
  	data[AUTO_BLIND_TYPE] = 0

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_RUSH_CANCEL_TRUSTEE_REQ
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:reqFastFoldRush(rushPlayerId, tableId)
	local data = {}
  	data[TABLE_ID] = ""..tableId
  	data[RUSH_PLAYER_ID] = ""..rushPlayerId

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_RUSH_FOLD_REQ
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:reqLeaveRoomRush(rushPlayerId, userId)
	local data = {}
  	data[TABLE_ID] = "RUSH001#1373343833060000RUSH478"
  	data[RUSH_PLAYER_ID] = ""..rushPlayerId
  	data[USER_ID] = ""..userId

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_RUSH_LEAVE_REQ
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:reqBuyinApplyAnswer(isAgree, tableId, userId, username, buyChips, orderId, payType,recData)
	local data = {}
  	data[CODE] = isAgree
  	data[TABLE_ID] = tableId
  	data[APPLY_UID] = userId
  	data[APPLY_UNAME] = username
  	data[BUY_CHIPS] = buyChips
  	data[ORDER_ID] = {orderId,""}
  	data[PAY_TYPE] = payType
  	data[USER_ID] =  myInfo.data.userId

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_APPLY_ANSWER
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack(),nil,recData)
end

function TcpCommandRequest:delayOperate(tableId, sequence)
	local data = {}
  	data[TABLE_ID] = tostring(tableId)
  	data[SEQUENCE] = tonumber(sequence)

  	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = APPLY_OPERATION_DELAY
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:applyPublicCard(tableId)
	local data = {}
  	data[TABLE_ID] = tostring(tableId)

  	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = APPLY_PUBLIC_CARD
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

function TcpCommandRequest:applyTrusteeshipProtect(tableId)
	local data = {}
  	data[TABLE_ID] = tostring(tableId)

  	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = TRUSTEESHIP_PROTECT
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_11, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end
-------------------------------------------------------


return TcpCommandRequest
