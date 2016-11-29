
local ByteArray = require("framework.cc.utils.ByteArray") 
local Protocol = require("app.Network.Socket.Protocol")

local net 	= require("framework.cc.net.init")
cc.utils 				= require("framework.cc.utils.init")
local PacketBuffer = require("app.Network.Socket.PacketBuffer")

local myInfo = require("app.Model.Login.MyInfo")
require("socket")

require("framework.functions")

PushCommandRequest = class("PushCommandRequest")
sharedPushCommandRequest = nil
function PushCommandRequest:ctor()
	self.m_tcpConnector = require("app.Network.Socket.PushConnector"):new()
end

function PushCommandRequest:shareInstance()
	if sharedPushCommandRequest == nil then
   		local instance = setmetatable({}, PushCommandRequest)
		instance.class = PushCommandRequest
		instance:ctor()
		sharedPushCommandRequest = instance
	end
	return sharedPushCommandRequest
end

function PushCommandRequest:addObserver(observer)
	self.m_tcpConnector:addObserver(observer)
end

function PushCommandRequest:removeObserver(observer)
	self.m_tcpConnector:removeObserver(observer)
end

function PushCommandRequest:closeConnect()
	self:stopPing()
	self.m_tcpConnector:closeSocket()
end

function PushCommandRequest:isConnect()
	return self.m_tcpConnector:isConnect()
end

function PushCommandRequest:connectSocket(ip,port)
	return self.m_tcpConnector:startSocketConnect(ip, port)
end

function PushCommandRequest:startPing()
	if self.pingScriptEntry == nil then
		local sharedScheduler = cc.Director:getInstance():getScheduler()
		self.pingScriptEntry = sharedScheduler:scheduleScriptFunc(handler(self,self.sendPing), TCP_PING_TIME, false)
	end
end

function PushCommandRequest:stopPing()
	if self.pingScriptEntry then
		local sharedScheduler = cc.Director:getInstance():getScheduler()
		sharedScheduler:unscheduleScriptEntry(self.pingScriptEntry)
		self.pingScriptEntry = nil
	end
end

-- function PushCommandRequest:sendPing(t)
-- 	if not sharedPushCommandRequest:isConnect() then
-- 		local sharedScheduler = cc.Director:getInstance():getScheduler()
-- 		sharedScheduler:unscheduleScriptEntry(sharedPushCommandRequest.pingScriptEntry)
-- 		sharedPushCommandRequest.pingScriptEntry = nil
-- 		return
-- 	end
-- 	print("PushCommandRequest···sendPing")
-- 	local buffer = ""
-- 	buffer = string.gsub(buffer, "\\", "")
-- 	local bufferLen = string.len(buffer)
--   	local cmd = PING
--   	cmd = 1
--   	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_13, buffer, bufferLen, cmd)
-- 	finalBuffer:setPos(1)
	
--  	self.m_tcpConnector:send(finalBuffer:getPack())
-- end
function PushCommandRequest:sendPing(t)
 	--print("PushCommandRequest···sendPing")
	self:reportUserID()
end

function PushCommandRequest:reportUserID(userID, version)
	local data = {}
	data["uid"] = myInfo.data.userId --userID
	data["ver"] = DBVersion  --version

	local buffer = json.encode(data)
	buffer = string.gsub(buffer, "\\", "")
	
	local bufferLen = string.len(buffer)
  	local cmd = COMMAND_PUSH_REPORT_USERID
  	local finalBuffer = encryptPkg(SENDPKG_BUFFER_LENGTH, VERSION_10, buffer, bufferLen, cmd)
	self.m_tcpConnector:send(finalBuffer:getPack())
end

return PushCommandRequest

