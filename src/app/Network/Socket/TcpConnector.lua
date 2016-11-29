--[[===================]]
-- 参考地址 http://www.cocoachina.com/bbs/read.php?tid-281270-page-1.html
local net = require("framework.cc.net.init")
local ByteArray = require("framework.cc.utils.ByteArray")
require("framework.cc.utils.bit")
require("app.Logic.Config.GlobalConfigDefine")
require("framework.cc.utils.bit")
require("app.Network.Socket.TcpCommandRequest")
local InfoUtil = require("app.Network.Socket.InfoUtil")
local myInfo = require("app.Model.Login.MyInfo")
local TcpCallBack 	= require("app.Network.Socket.TcpCallBack")
local TcpConnector = class("TcpConnector")
local instance = nil
local BODY_LEN = 4
local VERSION_LEN = 2
local RECONNECTNUM = 1 -- 断线／连接失败，重连最大次数
local CONNECTOUTTIME = 3 -- 连接超时

function TcpConnector:ctor()
	-- local time = net.SocketTCP.getTime()
	-- print("socket time:" .. time)

	-- self.m_basesocket = net.SocketTCP.new()
	-- self.m_basesocket :setName("TestSocketTcp")
	-- self.m_basesocket :setTickTime(1)
	-- self.m_basesocket :setReconnTime(6)
	-- self.m_basesocket :setConnFailTime(4)

	-- self.m_basesocket:addEventListener(net.SocketTCP.EVENT_DATA, self.receive)
	-- self.m_basesocket:addEventListener(net.SocketTCP.EVENT_CONNECTED, self.onStatus)
	-- self.m_basesocket:addEventListener(net.SocketTCP.EVENT_CLOSE, self.onClose)
	-- self.m_basesocket:addEventListener(net.SocketTCP.EVENT_CLOSED, self.onClosed)
	-- self.m_basesocket:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, self.onConnectFailure)
	self:onLuaSocketConnectClicked()	
	instance = self
	self._buf = ByteArray.new(ByteArray.ENDIAN_BIG)
	self.mReconnectTimes = 0		--重连次数
	self.m_observer = {}
	-- 当链接完全断开，需要新的Session
	self.m_schedulerPool = require("app.Tools.SchedulerPool").new()
end
--[[
	socket初始化连接
]]
function TcpConnector:onLuaSocketConnectClicked(ip,port)	
--dump(self._socket)
	ip = ip or string.gsub(myInfo.data.Global_ProxyIp,"http://","")
	port = port or myInfo.data.Global_ProxyPort
	if not self.m_basesocket then		
		-- print("网络初始化")	
		local time = net.SocketTCP.getTime()
		--print("socket time:" .. time)	
		self.m_basesocket = net.SocketTCP.new(ip,port,false)
		self.m_basesocket:setName("TestSocketTcp")
		-- self.m_basesocket :setTickTime(1)
		-- self.m_basesocket :setReconnTime(6)
		-- self.m_basesocket :setConnFailTime(4)

		self.m_basesocket:addEventListener(net.SocketTCP.EVENT_CONNECTED,   	handler(self,self.onStatus))
		self.m_basesocket:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
		self.m_basesocket:addEventListener(net.SocketTCP.EVENT_CLOSE, 			handler(self,self.onClose))
		self.m_basesocket:addEventListener(net.SocketTCP.EVENT_CLOSED,			handler(self, self.onClosed))		
		self.m_basesocket:addEventListener(net.SocketTCP.EVENT_DATA, 			handler(self,self.receive))
	end
	if not self.m_basesocket.isConnected then		
		if network.isInternetConnectionAvailable() then
		if ip == "" or port == "" then return end
		print("TcpConnector 开始网络连接")	
			CMPrintToScene("TcpConnector 开始网络连接")
			GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, 0)
		self.m_basesocket:connect(ip,port,false)	
			self:clearConnectSchedulerHandler()
			self.m_connectSchedulerHandler = self.m_schedulerPool:delayCall(handler(self, self.closeSocket), CONNECTOUTTIME)
		return self.m_basesocket.isConnected			
	else	
			GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, -1)
			self:reconnect()
		end		
	end
	return false
end
--[[socket监听函数]]
function TcpConnector:onStatus(__status)
	self:clearConnectSchedulerHandler()
	local event = cc.EventCustom:new(__status.name)
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
	if __status.name == "SOCKET_TCP_CONNECTED" then	
	--dump(__status.name)	
		print("TcpConnector 网络连接成功")
		CMPrintToScene("TcpConnector 网络连接成功")
		self.m_basesocket.isConnected = true
		self.mReconnectTimes = 0
		self:createGameSession()
	elseif __status.name == "SOCKET_TCP_CONNECT_FAILURE" then
		print("TcpConnector 网络连接失败")
		CMPrintToScene("TcpConnector 网络连接失败")
		GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, -1)
		self:reconnect()
	end
   
	return ret
end

function TcpConnector:clearConnectSchedulerHandler()
	if self.m_connectSchedulerHandler then
		self.m_schedulerPool:clearById(self.m_connectSchedulerHandler)
		self.m_connectSchedulerHandler = nil
	end
end

function TcpConnector:onClose(__event)
	print("TcpConnector 关闭tcp")
	CMPrintToScene("TcpConnector 关闭tcp")
	self:clearConnectSchedulerHandler()
	TcpCommandRequest:shareInstance():stopPing()
end

function TcpConnector:onClosed(__event)
	print("TcpConnector 网络连接已断开")
	CMPrintToScene("TcpConnector 网络连接已断开")
	self:clearConnectSchedulerHandler()
	TcpCommandRequest:shareInstance():stopPing()
	GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, -1)
	self:reconnect()
end

--[[
	socket重连处理：
		1、释放basesocket
		2、判断重连次数
		3、判断session是否过期（断线后会导致session过期，所以直接创建新的session）
]]
function TcpConnector:reconnect()
	if self.m_basesocket then
		self.m_basesocket:close()
		self.m_basesocket.isConnected = false
		-- self.m_basesocket = nil
	end
	if self.mReconnectTimes < RECONNECTNUM then
		self.mReconnectTimes = self.mReconnectTimes + 1
		print("TcpConnector 网络连接自动重连 " .. self.mReconnectTimes)
		CMPrintToScene("TcpConnector 网络连接自动重连 " .. self.mReconnectTimes)
		self:onLuaSocketConnectClicked()
	else
		print("TcpConnector 网络连接自动重连次数完毕")
		CMPrintToScene("TcpConnector 网络连接自动重连次数完毕")
		GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, -1)
		self:showInterConnect()
		if instance.m_observer then
			for i=1,#instance.m_observer do
				if instance.m_observer[i] and instance.m_observer[i].OnTcpMessage then
					instance.m_observer[i]:OnTcpMessage(COMMAND_SOCKET_CONNECTION_BREAK)
				end
			end
		end
	end
end

--[[重连检查session是否过期]]
function TcpConnector:checkGameSession()
	DBHttpRequest:checkGameSession(function(tableData,tag) self:httpResponse(tableData,tag) end)
end

--[[获取新的session]]
function TcpConnector:createGameSession()
	DBHttpRequest:createGameSession({function(tableData,tag)
			print("TcpConnector 创建session成功")
			CMPrintToScene("TcpConnector 创建session成功")
			if tableData then
				myInfo.data.userSession = tableData
				if self.m_basesocket and self.m_basesocket.isConnected then
					TcpCommandRequest:shareInstance():sendTencentInitPkg(myInfo.data.serverId,myInfo.data.Global_Openkey)
					TcpCommandRequest:shareInstance():startPing()
					if not CMIsNull(self.mNetworkErrorDialog) then
						CMClose(self.mNetworkErrorDialog)
						self.mNetworkErrorDialog = nil
					end
				else
					self:onLuaSocketConnectClicked()
				end
			else
				if self.m_basesocket and not self.m_basesocket.isConnected then
					self:showInterConnect()
				end
			end
		end,
		function(errorCode, tag, errorMessage)
			if self.m_basesocket and not self.m_basesocket.isConnected then
				self:showInterConnect()
			end
		end})
end

--[[
	网络回调
]]
function TcpConnector:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_CHECKGAMESESSION  then	
		if type(tableData) ~= "table" then 
			if self.m_basesocket and not self.m_basesocket.isConnected then
				self:showInterConnect()
			end
			return 
		end
		-- 0 表示过期1 表示正常		
		if tonumber(tableData["INFO"]["CODE"]) == 1 then
			self:onLuaSocketConnectClicked()
		else
			if GameSceneManager.mCurSceneType == GameSceneManager.AllScene.RoomViewManager then
				self:createGameSession()
			else
				require("app.GUI.setting.MoreMainLayer"):new():onMenuLogout()
			end
		end
	elseif tag == POST_COMMAND_CREATEGAMESESSION then
		if tableData then
			myInfo.data.userSession = tableData
			if self.m_basesocket and self.m_basesocket.isConnected then
				TcpCommandRequest:shareInstance():sendTencentInitPkg(myInfo.data.serverId,myInfo.data.Global_Openkey)
				TcpCommandRequest:shareInstance():startPing()
				if not CMIsNull(self.mNetworkErrorDialog) then
					CMClose(self.mNetworkErrorDialog)
					self.mNetworkErrorDialog = nil
				end
			else
				self:onLuaSocketConnectClicked()
			end
		else
			if self.m_basesocket and not self.m_basesocket.isConnected then
				self:showInterConnect()
			end
		end
	end
end

--[[
	显示网络中断提示框
]]
function TcpConnector:showInterConnect(isLoginOut)
	GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, -1)
	print("TcpConnector 网络连接异常弹窗")
	CMPrintToScene("TcpConnector 网络连接异常弹窗")
	
	local CMAlertDialog = require("app.Component.CMAlertDialog")
	if GameSceneManager.mCurSceneType == GameSceneManager.AllScene.RoomViewManager then
		if not CMIsNull(self.mNetworkErrorDialog) then
			self.mNetworkErrorDialog.mBtnOk:setButtonEnabled(true)
			return
		end
		self.mNetworkErrorDialog = CMAlertDialog.new({
			text = "您的网络很不给力哦，请等网络好点的时候再试试！",
			showType = CMAlertDialog.ShowAll,
			okText = "重连",
			cancelText = "取消",
			showClose = 0,
			autoClose = false,
			callOk = function()
				GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, 0)
				self.mNetworkErrorDialog.mBtnOk:setButtonEnabled(false)
				self:onLuaSocketConnectClicked()
			end,
			callCancle = function()
				GIsClose = false
				CMClose(self.mNetworkErrorDialog)
				self.mNetworkErrorDialog = nil
				require("app.GUI.setting.MoreMainLayer"):new():onMenuLogout()
			end,
			})
		self.mNetworkErrorDialog:create()
		self.mNetworkErrorDialog.mBtnOk:setButtonLabel("disabled",cc.ui.UILabel.new({
	    color = cc.c3b(161, 184, 229),
	    text = "正在重连...",
	    size = 28,
	    font = "FZZCHJW--GB1-0",
		}) )
		self.mNetworkErrorDialog.mBtnOk:setButtonEnabled(true)
	else
		if not CMIsNull(self.mNetworkErrorDialog) then
			CMClose(self.mNetworkErrorDialog)
			self.mNetworkErrorDialog = nil
		end
		self.mNetworkErrorDialog = CMAlertDialog.new({
			text = "您的网络很不给力哦，请等网络好点的时候再试试！",
			showType = CMAlertDialog.ShowOk,
			okText = "确定",
			showClose = 0,
			callOk = function()
				CMClose(self.RewardLayer)
				self.RewardLayer = nil
			end,})   
		self.mNetworkErrorDialog:create()
	end
	GameSceneManager:getCurScene():addChild(self.mNetworkErrorDialog,10)
end

--[[
	socket开始连接
]]
function TcpConnector:animInterConnect(flag)
	if self.mNetworkErrorDialog and self.mNetworkErrorDialog.mBtnOk then
		if flag then
			return true
		else
			return self:onLuaSocketConnectClicked(ip,port)	
		end
	end
end

--[[
	显示http网络中断提示框
]]
function TcpConnector:showInterHttpConnect()
	if CMIsNull(self.mNetworkErrorDialog) then
		local CMAlertDialog = require("app.Component.CMAlertDialog")
		self.mNetworkErrorDialog = CMAlertDialog.new({
			text = "网络连接异常，请检查网络是否正常，稍后再试！",
			showType = CMAlertDialog.ShowOk,
			okText = "确定",
			showClose = 0,
			callOk = function()
				CMClose(self.RewardLayer)
				self.RewardLayer = nil
			end,})   
		self.mNetworkErrorDialog:create()
		GameSceneManager:getCurScene():addChild(self.mNetworkErrorDialog,10)
	end
end

--[[
	socket开始连接
]]
function TcpConnector:startSocketConnect(ip,port)
	if self.m_basesocket and self.m_basesocket.isConnected then
		return true
	else
		return self:onLuaSocketConnectClicked(ip,port)	
	end
	--return self.m_basesocket:connect(ip, port, false)
end

--[[主动断开连接]]
function TcpConnector:closeSocket(resetReconnectNum)
	print("TcpConnector 主动断开连接")
	CMPrintToScene("TcpConnector 主动断开连接")
	if resetReconnectNum ~= false then
		self.mReconnectTimes = RECONNECTNUM
	end
	if self.m_basesocket then
		self.m_basesocket:disconnect()
	end
end

function TcpConnector:isConnect()
	if not self.m_basesocket then 
		return false 
	end
	return self.m_basesocket.isConnected
end

function TcpConnector:send(__data, __size,recData)
	if not self.m_basesocket then
		self:onLuaSocketConnectClicked()		
		return 
	end
	
	--注册回调Layer
	if type(recData) == "table" then 
		QManagerListener:Attach(recData)
	end
	self.m_basesocket:send(__data, __size)
end

-- 接收数据
function TcpConnector:receive(event)
	if not CMIsNull(self.mNetworkErrorDialog) then
		CMClose(self.mNetworkErrorDialog)
		self.mNetworkErrorDialog = nil
	end
	-- print("socket receive raw data:", cc.utils.ByteArray.toString(event.data, 16))
	--print("self._buf:getLen()= " .. self._buf:getLen())
	--print("receive")
	self._buf:setPos(self._buf:getLen()+1)
	self._buf:writeBuf(event.data)
	self._buf:setPos(1)
--[[	
--粘包测试构造
	local __tmp = ByteArray.new(ByteArray.ENDIAN_BIG)
	self._buf:readBytes(__tmp, 1,5)
	self._buf = __tmp
	printf("tmp len: %u, availabl: %u", __tmp:getLen(), __tmp:getAvailable())

	print("self._buf:getBytes()= " , cc.utils.ByteArray.toString(self._buf:getBytes(1,6)))
	print("self._buf:getLen()= " .. self._buf:getLen())
	self._buf:setPos(1)
]]--

	local __preLen = BODY_LEN + VERSION_LEN
	while self._buf:getAvailable() >= __preLen do
		local bufferLen = self._buf:readUInt()
		if bufferLen == 0 then
			break
		end
		if self._buf:getAvailable() < bufferLen then 
			-- restore the position to the head of data, behind while loop, 
			-- we will save this incomplete buffer in a new buffer,
			-- and wait next parsePackets performation.
			--printf("received data is not enough, waiting... need %u, get %u", bufferLen, self._buf:getAvailable())
			--print("PacketBuffer:parsePackets buf:", self._buf:toString())
			self._buf:setPos(self._buf:getPos() - BODY_LEN)
			break 
		end

		local version = self._buf:readUShort() 		
		local cmd = self._buf:readUInt()
		local buffer = self._buf:readStringBytes(bufferLen - __preLen)
		local finalCmd,finalBuffer = decryptPkg(bufferLen, version, buffer, bufferLen-6, cmd)
	 	local data = json.decode(finalBuffer)
	    -- dump(data, string.format("TcpConnector, iccccc receive cmd:%#x", finalCmd))
	   
	 	if instance.m_observer then
			for i=1,#instance.m_observer do
				if instance.m_observer[i] and instance.m_observer[i].OnTcpMessage then
					instance.m_observer[i]:OnTcpMessage(finalCmd, data)
				end
			end
		end
		if not data or data == "" then
			data = data or {}
		end
		data.layerID = cmd
		if cmd == COMMAND_PING_RESP then 			--心跳包不处理
			local strength = GV.CMDataProxy:getData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH) or 0
			if strength == 0 then
				GV.CMDataProxy:setData(GV.CMDataProxy.DATA_KEYS.SIGNAL_STRENGTH, 3)
			end
			TcpCommandRequest:shareInstance():onPingReceive()
		else
		    -- dump(data,cmd)
			TcpCallBack:onTcpCallBack(data) 			--缓存修改
	 		QManagerListener:Notify(data)				--UI刷新
		end
		
	end
	if self._buf:getAvailable() <= 0 then
		self._buf = ByteArray.new(ByteArray.ENDIAN_BIG)
	else
		--写入缓存
		--some datas in buffer yet, write them to a new blank buffer.
		-- printf("cache incomplete buff,len: %u, available: %u", self._buf:getLen(), self._buf:getAvailable())
		local __tmp = ByteArray.new(ByteArray.ENDIAN_BIG)
		self._buf:readBytes(__tmp, 1, self._buf:getAvailable())
		self._buf = __tmp
		--printf("tmp len: %u, availabl: %u", __tmp:getLen(), __tmp:getAvailable())
		--print("buf:", __tmp:toString())
	end
--[[	
--粘包测试拼接
	print("self._buf:getPos()",self._buf:getPos())
	self._buf:setPos(self._buf:getLen()+1)
	local _,lens = cc.utils.ByteArray.toString(event.data, 16)
	local tempBuf = ByteArray.new(ByteArray.ENDIAN_BIG)
	tempBuf:writeBuf(event.data)
	tempBuf:setPos(7)
	local __tmp = ByteArray.new(ByteArray.ENDIAN_BIG)
	tempBuf:readBytes(__tmp, 1,lens-7)
	tempBuf = __tmp
	print("self._buf:getPos()",self._buf:getPos())
	self._buf:writeBuf(__tmp:getBytes())
	print("buf:", __tmp:toString())
	print("self._buf:getBytes()= " , cc.utils.ByteArray.toString(self._buf:getBytes()))
]]--
end
-- 接收数据
-- function TcpConnector:receive(event)
-- 	--print("socket receive raw data:", cc.utils.ByteArray.toString(event.data, 16))
-- 	local ba = ByteArray.new(ByteArray.ENDIAN_BIG)	
-- 	ba:writeBuf(event.data)
-- 	ba:setPos(1)
-- 	-- print("ba:getLen()==================>"..ba:getLen())
-- 	-- print("ba:readUInt()==================>"..ba:readUInt()+4)
-- 	-- ba:setPos(1)
-- 	local totalBufferLen = ba:getLen()
-- 	local currentBufferPos = 1
-- 	while true do
-- 		local bufferLen = ba:readUInt()
-- 		local version = ba:readUShort()
-- 		local cmd = ba:readUInt()
-- 		local buffer = ba:readStringBytes(bufferLen-6)
-- 		local finalCmd,finalBuffer = decryptPkg(bufferLen, version, buffer, bufferLen-6, cmd)
-- 		local data = json.decode(finalBuffer)
-- 		dump(data,finalCmd)
-- 		-- print(string.format("finalCmd =========================>0X%08X",""..finalCmd))
-- 		if instance.m_observer then
-- 			for i=1,#instance.m_observer do
-- 				if instance.m_observer[i] then
-- 					instance.m_observer[i]:OnTcpMessage(finalCmd, data)
-- 				end
-- 			end
-- 		end
-- 		currentBufferPos = currentBufferPos+bufferLen+3
-- 		if currentBufferPos>=totalBufferLen then
-- 			break
-- 		end

-- 		currentBufferPos=currentBufferPos+1
-- 		ba:setPos(currentBufferPos)
-- 	end
-- 	-- ba:writeBuf(event.data)
--  -- 	ba:setPos(1)
-- 	-- --  有连包的情况，所以要读取数据
--  -- 	while ba:getAvailable() <= ba:getLen() do 
--  -- 		TcpConnector.decodeData(ba)
--  -- 		if ba:getAvailable() == 0 then
--  -- 			break
--  -- 		end
--  -- 	end
-- end

function TcpConnector:addObserver(observer)
	if self.m_observer==nil then
		self.m_observer = {}
	end
	self.m_observer[#self.m_observer+1] = observer
end

function TcpConnector:removeObserver(observer)
	local tmpObserver = {}
	for i=1,#instance.m_observer do
		if instance.m_observer[i] == observer then
			instance.m_observer[i] = nil
		else
			tmpObserver[#tmpObserver+1] = instance.m_observer[i]
		end
	end

	instance.m_observer = nil
	instance.m_observer = tmpObserver
end

--[[=============================================以下为加密解密算法=============================================]]
local RC4LENGTH = 256
local rc4_state_data = {x = 0,y = 0; m = {}}

local function getRc4_pwd()
	local uid = myInfo.data.userId
	local session = myInfo.data.userSession
	return uid..session
end

local function rc4_setup(s, key, length)
	
	local i=0
	local j=0
	local k=0
	local a=0
    
	s.x = 0
	s.y = 0
    for i = 0,255 do
    	s.m[i] = i
    end
    
	j = 0
	k = 1
	for i = 0,255 do
		a = s.m[i]
		j = j + a + string.byte(key, k)
		j = j%256
		s.m[i] = s.m[j]
		s.m[j] = a
		k = k+1
		if k > length then
			k = 1
		end
	end
end

local function rc4_encrypt(s, data, length)
	local i = 1
	local a = 1
	local b = 1
	local x = s.x
	local y = s.y
	local m = s.m

    local result = {}
    for i = 0,length-1,1 do
    	x = x + 1
    	x = x%256
		a = m[x]
		y = y + a
    	y = y%256
		m[x] = m[y]
		b = m[y]
		m[y] = a
		local tmp = a + b
		tmp = tmp%256
		result[i] = bit.bxor(data[i+1], m[tmp])
    end
	s.x = x
	s.y = y
	return result
end

function decryptPkg(bufferLen, version, data, data_size, type)
	--print(bufferLen.."/".. version.."/".. data.."/".. data_size.."/".. type)
 	local pkgout = Package:new()
 	pkgout.version = version
 	pkgout.instruct = type
 	pkgout.data = data
	-- 创建一个ByteArray
 	local buffout = ByteArray.new(ByteArray.ENDIAN_BIG)
	-- 不要忘了，lua数组是1基的。而且函数名称比 position 短
 	buffout:setPos(1)
	if version == VERSION_10 then
		return type,data
	elseif version == VERSION_11 then
		local cmd_json = ByteArray.new(ByteArray.ENDIAN_BIG)
 		cmd_json:writeUInt(pkgout.instruct)
 		cmd_json:writeStringBytes(pkgout.data)
 		--全部加密
 		local sa = rc4_state_data
		sa.x=0
		sa.y=0
 		for i = 1,RC4LENGTH,1 do
 			sa.m[i] = 0
 		end
 		local rc4_pwd = getRc4_pwd()
		rc4_setup(sa , rc4_pwd, string.len(rc4_pwd))
		local cmd_json_str = cmd_json:getPack()
		local cmd_json_str_data = {}
		for i=1,data_size + 4 do
			cmd_json_str_data[i] = string.byte(cmd_json_str, i)
		end
		local result = rc4_encrypt(sa , cmd_json_str_data, data_size + 4)
 		for i = 0,(data_size + 4 -1) do
 			buffout:writeByte(result[i])
 		end
 		buffout:setPos(1)
		local cmd = buffout:readUInt()
		local buffer = buffout:readStringBytes(data_size)
		return cmd,buffer
	elseif version == VERSION_13 then 
		local cmd_json = ByteArray.new(ByteArray.ENDIAN_BIG)
 		cmd_json:writeUInt(type)
 		cmd_json:writeStringBytes(data)
 		--全部解密
 		local sa = rc4_state_data
		sa.x=0
		sa.y=0
 		for i = 1,RC4LENGTH,1 do
 			sa.m[i] = 0
 		end
 		local rc4_pwd = getRc4_pwd()
		rc4_setup(sa , rc4_pwd, string.len(rc4_pwd))
		local cmd_json_str = cmd_json:getPack()
		local cmd_json_str_data = {}
		for i=1,data_size + 4 do
			cmd_json_str_data[i] = string.byte(cmd_json_str, i)
		end
		local result = rc4_encrypt(sa , cmd_json_str_data, data_size + 4)
 		for i = 0,(data_size + 4 -1) do
 			buffout:writeByte(result[i])
 		end
		
 		local zip=require("zlib")
        local uncompress=zip.inflate()
        local inflated,eof,bytes_in,bytes_out=uncompress(buffout:getPack(),'finish') 

		local finalBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
		for i=1,#inflated do
			local tmpByte = string.byte(inflated, i)
			finalBuffer:writeByte(tmpByte)
		end
		finalBuffer:setPos(1)
		local cmd = finalBuffer:readUInt()
		local buffer = finalBuffer:readStringBytes(#inflated-4)
		return cmd,buffer
	end

end

function encryptPkg(buff_size, version, data, data_size, type)
	--write log
	-- socket_send_log(type, data)
	print(string.format("TcpConnector, iccccc send cmd:%#x " , type), data)
	local total_pkt_size = 0
 	local pkglen = data_size+10
 	if buff_size<pkglen then
 		return nil
 	end

 	local pkgout = Package:new()
 	pkgout.version = version
 	pkgout.instruct = type
 	pkgout.data = data

	-- 创建一个ByteArray
 	local buffout = ByteArray.new(ByteArray.ENDIAN_BIG)
	-- 不要忘了，lua数组是1基的。而且函数名称比 position 短
 	buffout:setPos(1)

 	if version == VERSION_10 then
 		----方法一
 	-- 	local bufferLen = data_size+6
 	-- 	local __pack1 = string.pack(">I", bufferLen)
 	-- 	local __pack2 = string.pack(">HI", version, type)
 	-- 	local __pack3 = string.pack(">A", data)
		-- buffout:writeBuf(__pack1)
		-- buffout:writeBuf(__pack2)
		-- buffout:writeBuf(__pack3)
 	-- 	return buffout

		----方法二
 		local bufferLen = data_size+6
 		buffout:writeUInt(bufferLen)
 		buffout:writeUShort(version)
 		buffout:writeUInt(type)
 		buffout:writeStringBytes(data)
 		return buffout

 	elseif version == VERSION_11 then
 		-- if data_size>0 then
 		if true then
 			local cmd_json = ByteArray.new(ByteArray.ENDIAN_BIG)
 			cmd_json:writeUInt(pkgout.instruct)
 			cmd_json:writeStringBytes(pkgout.data)
 		
 			--全部加密
 			local sa = rc4_state_data
			sa.x=0
			sa.y=0
 			for i = 1,RC4LENGTH,1 do
 				sa.m[i] = 0
 			end
 			-- local rc4_pwd = "6224NzJkY2Q4Y2FlOTE1Y2E2OWZjMDI0MzZlZTFlNzFiYzg=22134322"
 			local rc4_pwd = getRc4_pwd()
			rc4_setup(sa , rc4_pwd, string.len(rc4_pwd))
			local cmd_json_str = cmd_json:getPack()
			local cmd_json_str_data = {}
			for i=1,data_size + 4 do
				cmd_json_str_data[i] = string.byte(cmd_json_str, i)
			end
			local result = rc4_encrypt(sa , cmd_json_str_data, data_size + 4)
 			local bufferLen = data_size+6
 			buffout:writeUInt(bufferLen)
 			buffout:writeUShort(version)
 			for i = 0,(data_size + 4 -1) do
 				buffout:writeByte(result[i])
 			end
 			return buffout
 		else

 		end

 	elseif version == VERSION_13 then
 		local cmd_json = ByteArray.new(ByteArray.ENDIAN_BIG)
 		cmd_json:writeUInt(pkgout.instruct)
 		cmd_json:writeStringBytes(pkgout.data)
		local cmd_json_str = cmd_json:getPack()
 		local zip=require("zlib")
        local compress=zip.deflate()
        local deflated, eof, bytes_in,bytes_out = compress(cmd_json_str,'finish')
        if eof == true then
        	--全部加密
 			local sa = rc4_state_data
			sa.x=0
			sa.y=0
 			for i = 1,RC4LENGTH,1 do
 				sa.m[i] = 0
 			end
 			-- local rc4_pwd = "6224NzJkY2Q4Y2FlOTE1Y2E2OWZjMDI0MzZlZTFlNzFiYzg=22134322"
 			local rc4_pwd = getRc4_pwd()
			rc4_setup(sa , rc4_pwd, string.len(rc4_pwd))
			local cmd_json_str_data = {}
			for i=1,#deflated do
				cmd_json_str_data[i] = string.byte(deflated, i)
			end
			local result = rc4_encrypt(sa , cmd_json_str_data, #deflated)
 			local bufferLen = bytes_out+2
 			buffout:writeUInt(bufferLen)
 			buffout:writeUShort(version)
 			for i = 0,(bytes_out-1) do
 				buffout:writeByte(result[i])
 			end
 			return buffout
        end
 	end
end

local function stringto16(pl)
	
end

local function addTencentHeader(dataBody)
	
end

local function buildTencentPkg(dataBody,serverId,openUserId)
	
end

local function createTencentPackage(packageFlag,cpID,gameID,SvrID,openIDLen,openID,optionLen,optionData,ourPkgLen,ourPkg,txPkgLen,txPkg)
	
end

--[[网上加密解密参考]]
-----------------------------------------------------------------------------------------------------------------
-- function TcpConnector:sendData(__msgid, __data)
	
-- 	print(type(__msgid))
-- 	local _ba = TcpConnector.encodeData(__msgid, __data)
-- 	print("TcpConnector:sendData _ba:", _ba:getLen())
-- 	if not _ba then
-- 		print("发送数据出错了..", __msgid)
-- 		return
-- 	end
-- 	_ba:setPos(1)
-- 	local byteList = {}
-- 	local byteCount = 0
-- 	-- 把数据读出来，加密
-- 	for i = 1, #_ba._buf do
-- 		local tmpBit = string.byte(_ba:readRawByte())
-- 		byteCount = byteCount+tmpBit
-- 		-- tmpBit = bit.band(tmpBit+80, 255)
-- 		-- tmpBit = bit.band(bit.bnot(bit.band(tmpBit, 255)), 255)
-- 		byteList[i] = tmpBit
-- 	end
-- 	byteCount = byteCount % 256
-- 	--  最后再组成新的ByteArray
-- 	local result = ByteArray.new(ByteArray.ENDIAN_BIG)
-- 	result:writeInt(_ba:getLen()+6)
-- 	result:writeShort(VERSION_10)
-- 	for i = 1, #byteList do
-- 		result:writeByte(byteList[i])
-- 	end

-- 	-- 把数据发送给服务器
-- 	self.m_basesocket:send(result:getPack())
-- end

-- function TcpConnector.encodeData(__msgid, __data)
-- 	if __msgid then
-- 		local ba = ByteArray.new(ByteArray.ENDIAN_BIG)
-- 		local fmt = InfoUtil:getSendMsgFmt(__msgid)	-- 此处为读取消息格式 看下面的MessageType里面会有定义
-- 		-- ba:writeStringUShort("token")	-- 此处为用户token,没有就为""，此处可以判断用户是否重新登陆啊等等.......
-- 		for i = 1,#fmt do
-- 			TcpConnector.writeData(ba, fmt[i], __data)
-- 		end
-- 		local baLength = ba:getLen()
-- 		local bt = ByteArray.new(ByteArray.ENDIAN_BIG)
-- 		-- bt:writeShort(baLength+4)
-- 		bt:writeInt(__msgid)
-- 		bt:writeBytes(ba)
-- 		return bt
-- 	end
-- end

-- -- write 数据
-- function TcpConnector.writeData(ba, msg_type, data)
-- 	local key = msg_type.key
-- 	-- print("TcpConnector.writeData", "key", key)
-- 	if key and data[key] then
-- 		local _type = msg_type["fmt"]
-- 		if type(_type) == "string" then
-- 			if _type == "string" then
-- 				ba:writeStringUShort(data[key])
-- 			elseif _type == "number" then
-- 				ba:writeLuaNumber(data[key])
-- 			elseif _type == "int" then
-- 				ba:writeInt(data[key])
-- 			elseif _type == "short" then
-- 				ba:writeShort(data[key])
-- 			end
-- 		else
-- 			-- ba:writeShort(#data[key])
-- 			for k,v in pairs(data[key]) do
-- 				for i = 1, #_type do
-- 					TcpConnector.writeData(ba,_type[i], v)
-- 				end
-- 			end
-- 		end
-- 	else
--  		print("找不到对应的 key",msg_type.key,msg_type,data)
-- 	end
-- end


-- -- 消息数据解析
-- function TcpConnector.decodeData(ba)
--  	local len = ba:readShort() -- 读数据总长度
--  	local total = ba:readByte() -- 一个用于验证的数子
--  	local byteList = {}
--  	local tmpTotal = 0
--  	for i=1,len - 3 do  -- 去除前两个长度
--  		local tmpBit = ba:readByte()
--  		local enByte = TcpConnector.decodeByte(tmpBit)
--  		tmpTotal = tmpTotal + enByte
--  		byteList[i] = enByte
--  	end
 
 
--  	local result = ByteArray.new(ByteArray.ENDIAN_BIG)
--  	for i=1,#byteList do
--  		result:writeRawByte(string.char(byteList[i]))
--  	end
--  	result:setPos(1)
--  	if (tmpTotal % 256) == total then
--  		TcpConnector.decodeMsg(result)
--  	else
--  		print("TcpConnector.decodeData  total   error")
--  	end
-- end

-- -- 根据格式解析数据
-- function TcpConnector.decodeMsg(byteArray)
--  	local rData = {}
--  	local len = byteArray:readShort()
--  	local msgid = byteArray:readShort()
--  	local roleString = byteArray:readStringUShort()
--  	local fmt = InfoUtil:getMsgFmt(msgid)
--  	for i=1,#fmt do
--  		TcpConnector.readData(byteArray,fmt[i],rData)
--  	end
--  	if rData["result"] ~= 0 then
--  		print("result  handler is here  ",rData[key])
--  		return
--  	else
--  		-- NetManager:receiveMsg(msgid,rData)
--  	end
-- end

-- -- readData
-- function TcpConnector.readData( ba,msg_type,data)
--  	local key = msg_type.key
--  	if key then
--  		data[key] = data[key] or {}
--  		local _type = msg_type["fmt"]
--  		if type(_type) == "string" then
--  			if _type == "string" then
--  				data[key] = ba:readStringUShort()
--  			elseif _type == "number" then
--  				data[key] = ba:readLuaNumber()
--  			elseif _type == "int" then
--  				data[key] = ba:readInt()
--  			elseif _type == "short" then
--  				data[key] = ba:readShort()
--  			end
 
 
--  			if key == "result" then  -- 当结果不为零的时候，说明有错误
  
--  				if data[key] ~= 0 then
--  					print("result  handler is here  ",data[key])
--  				return
--  				end
--  			end
 
 
--  		else
--  			local _len = ba:readShort() -- 读取数组长度
--  			for i=1,_len do
--  				local tmp = {}
--  				for j=1,#_type do
--  					TcpConnector.readData(ba,_type[j],tmp)
--  				end
--  				table.insert(data[key],tmp)
--  			end
--   		end
--  	else
--  		print("找不到对应的 key  TcpConnector.readData",msg_type.key,msg_type,data)
--  	end
-- end

-- -- 数据解密
-- function TcpConnector.decodeByte(byte)
--  	local tmp = bit.band(bit.bnot(bit.band(byte,255)),255)
--  	tmp = bit.band((tmp + 256 - 80),255)
--  	return tmp
-- end

-----------------------------------------------------------------------------------------------------------------

return TcpConnector