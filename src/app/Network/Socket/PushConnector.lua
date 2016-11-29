--
-- Author: junjie
-- Date: 2016-02-23 13:55:27
--
local net = require("framework.cc.net.init")
local ByteArray = require("framework.cc.utils.ByteArray")
require("framework.cc.utils.bit")
require("app.Logic.Config.GlobalConfigDefine")
require("framework.cc.utils.bit")
require("app.Network.Socket.TcpCommandRequest")
local InfoUtil = require("app.Network.Socket.InfoUtil")
local myInfo = require("app.Model.Login.MyInfo")
local PushCallBack = require("app.Network.Socket.PushCallBack")
local PushConnector = class("PushConnector")
local instance = nil
local BODY_LEN = 4
local VERSION_LEN = 2
local LogClass= "PushConnector"
function PushConnector:ctor()
	instance = self
	self:onLuaSocketConnectClicked()	
	self._buf = ByteArray.new(ByteArray.ENDIAN_BIG)
	self.mReconnectTimes = 0		--重连次数
	self.m_observer = {}
	self.mIsReconnect    = true 	--是否重连
end
function PushConnector:onLuaSocketConnectClicked(ip,port)	
--dump(self._socket)
	ip = ip or string.gsub(g_PushServerIP,"http://","")
	port = port or g_PushServerPort
	-- dump(ip,port)
	if not self.m_basesocket then		
		print(LogClass.."网络初始化")	
		local time = net.SocketTCP.getTime()
		--print("socket time:" .. time)	
		self.m_basesocket = net.SocketTCP.new(ip,port,false)
		self.m_basesocket :setName("PushConnector")
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
		if ip == "" or port == "" then return end
		print(LogClass.."网络连接")	
		self.m_basesocket:connect(ip,port,false)	
		return self.m_basesocket.isConnected			
	else	
		-- self._socket:close()	
		-- print(self._socket.isConnected)	
		-- self._socket  = nil		
	end	
	return false
end
--[[socket监听函数]]
function PushConnector:onStatus(__status)
	 local event = cc.EventCustom:new(__status.name)
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
	if __status.name == "SOCKET_TCP_CONNECTED" then	
	--dump(__status.name)	
		print(LogClass.."连接成功")
		self.m_basesocket.isConnected = true
		self.mReconnectTimes 		  = 0
		self.mIsReconnect 			  = true
		PushCommandRequest:shareInstance():startPing()
	elseif __status.name == "SOCKET_TCP_CONNECT_FAILURE" then
		-- self.isConnected = false
		if (not self.m_basesocket or not self.m_basesocket.isConnected ) and self.mReconnectTimes < 3 then 
			print(LogClass.."正在重新连接。。"..self.mReconnectTimes)
			self.mReconnectTimes = self.mReconnectTimes + 1
			self:onLuaSocketConnectClicked()
		elseif self.mReconnectTimes == 3 then
			print(LogClass.."连接失败，弹出失败提示框")
			self.mReconnectTimes = self.mReconnectTimes + 1
		  --   local RewardLayer = require("app.Component.CMAlertDialog")
				-- CMOpen(RewardLayer, cc.Director:getInstance():getRunningScene(),{text = "网络连接异常，请检查网络是否正常后，再重试！",showType = 1,
				-- 	callOk = function () 
				-- 		local MoreMainLayer = require("app.GUI.setting.MoreMainLayer"):new()
				-- 		MoreMainLayer:onMenuLogout()
				-- 	end})
		end
	end
   
	return ret
end

function PushConnector:onClose(__event)
	print("PushConnector 主动断开网络连接")
end

function PushConnector:onClosed(__event)
	print("PushConnector断开网络连接")
	PushCommandRequest:shareInstance():stopPing()
	local instance = PushCommandRequest:shareInstance() 
	instance = nil
	--if  self.m_basesocket and self.m_basesocket.isConnected then	
	if  self.m_basesocket then
		--print("网络断开")
		self.m_basesocket:close()
		self.m_basesocket.isConnected = nil
		self.m_basesocket = nil
	end

	if not self.m_basesocket and self.mIsReconnect  then
		-- print("网络连接断开请求重新初始化！！！")
		self:onLuaSocketConnectClicked()		
		return
	end
end


function PushConnector:startSocketConnect(ip,port)
	if self.m_basesocket and self.m_basesocket.isConnected then
		return true
	else
		return self:onLuaSocketConnectClicked(ip,port)	
	end
	--return self.m_basesocket:connect(ip, port, false)
end
--[[主动断开连接]]
function PushConnector:closeSocket()
	-- self.m_basesocket:disconnect()
	-- self.m_basesocket:close()
	self.mIsReconnect = false
	--self.m_basesocket.isConnected = nil
	self:onClosed()
end

function PushConnector:isConnect()
	if not self.m_basesocket then 
		return false 
	end
	return self.m_basesocket.isConnected
end
function PushConnector:send(__data, __size)
	--print("send...")
	if not self.m_basesocket then
		print("网络连接断开请求重新初始化！！！")
		self:onLuaSocketConnectClicked()		
		return 
	end

	self.m_basesocket:send(__data, __size)
end
-- 接收数据
function PushConnector:receive(event)
	--dump("PushConnector:receive")
	--print("socket receive raw data:", cc.utils.ByteArray.toString(event.data, 16))
	--print("self._buf:getLen()= " .. self._buf:getLen())
	--print("receive")
	self._buf:setPos(self._buf:getLen()+1)
	self._buf:writeBuf(event.data)
	self._buf:setPos(1)

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
	    -- dump(data,"PushConnector")
	    PushCallBack:dealPushMessageResp(data)
	 -- 	if instance.m_observer then
		-- 	for i=1,#instance.m_observer do
		-- 		if instance.m_observer[i] and instance.m_observer[i].OnTcpMessage then
		-- 			instance.m_observer[i]:OnTcpMessage(finalCmd, data)
		-- 		end
		-- 	end
		-- end
	end
	if self._buf:getAvailable() <= 0 then
		self._buf = ByteArray.new(ByteArray.ENDIAN_BIG)
	else
		--写入缓存
		--some datas in buffer yet, write them to a new blank buffer.
		--printf("cache incomplete buff,len: %u, available: %u", self._buf:getLen(), self._buf:getAvailable())
		local __tmp = ByteArray.new(ByteArray.ENDIAN_BIG)
		self._buf:readBytes(__tmp, 1, self._buf:getAvailable())
		self._buf = __tmp
		--printf("tmp len: %u, availabl: %u", __tmp:getLen(), __tmp:getAvailable())
		--print("buf:", __tmp:toString())
	end

end

return PushConnector