require("app.Network.Http.DBHttpRequest")
require("app.Network.Socket.TcpCommandRequest")
myInfo = require("app.Model.Login.MyInfo")
cc.utils 				= require("framework.cc.utils.init")
local net 	= require("framework.cc.net.init")
local PacketBuffer = require("app.Network.Socket.PacketBuffer")
local Protocol = require("app.Network.Socket.Protocol")
local ByteArray = require("framework.cc.utils.ByteArray")

local MainScene = class("MainScene", function()
	return display.newScene("MainScene")
	end)

function MainScene.create()
	local scene = MainScene.new()
	print("123222")
    -- scene:addChild(require("GUI.ccb.MainLayer"):new())
    return scene
end

function MainScene:ctor()


	nameLabel = cc.ui.UILabel.new({
		UILabelType = 2, text = "Debao", size = 64})
	:align(display.CENTER, display.cx, display.cy)
	:addTo(self)

	DBHttpRequest:DBHttpLogin(function(event) self:httpResponse(event)
		end, "holylee882", "123456", "", "DEBAO", DBVersion, "", "", "")--线下	

	-- DBHttpLogin(function(event) self:httpResponse(event)
	-- 	end, "zybb87", "q12345", "", "DEBAO", DBVersion, "", "", "")	--线上 

	self.tcpCmdRequest = TcpCommandRequest.shareInstance()
	self.tcpCmdRequest:addObserver(self)
	self.tcpCmdRequest:connectSocket("192.168.0.252", 30003)	--线下	
	-- self.tcpCmdRequest:connectSocket("119.147.211.227", 80)	--线上 
end		

function MainScene:httpResponse(event)
	local request = event.request

	if event.name == "completed" then
		if request:getResponseStatusCode() ~= 200 then
				-- todo 这里获取服务器返回不是200的情况
			else
				-- local loginResp = json.decode(request:getResponseString())
				-- DBLog(request:getResponseString())
				self:dealLoginResp(request:getResponseString())
				
			end	
			elseif event.name ~= "progress" then
-- 这里获取超时/网络错误


	end

end

function MainScene:dealLoginResp(content)
	local data = myInfo:getData(content)
	-- 解析成功
	if data then
		DBLog(data.username,"<------")
		DBLog(data.userSession,"<------")
		nameLabel:setString(data.username)
	end
end


function MainScene:onEnter()
end

function MainScene:onExit()

end

function MainScene:dealLoginResp(content)
	local data = myInfo:getData(content)
	-- 解析成功
	if data then
		DBLog(data.username,"<------")
		nameLabel:setString(data.username)
	end
end

function MainScene:onStatus(__event)
	if __event then
		-- self.sendData("0x3131","")
		self.tcpCmdRequest:sendPing()
	end
	
end

function MainScene:onClose(__event)
	DBLog("2222222")
	DBLog("socket status:", __event.name)
end

function MainScene:onClosed(__event)
	DBLog("3333333")
	DBLog("socket status:", __event.name)
end

function MainScene:onConnectFailure(__event)
	DBLog("4444444")
	DBLog("socket status: %s", __event.name)
end

function MainScene:onData(__event)
	DBLog("5555555")
	print(__event.data)
	print("socket receive raw data:", cc.utils.ByteArray.toString(__event.data, 10))
	local __ba = ByteArray.new(ByteArray.ENDIAN_BIG)
	__ba:writeBuf(__event.data)	
	__ba:setPos(1)
	local bufferLen = __ba:readInt()
	local command = __ba:readInt()
	print("bufferLen:", bufferLen)
	print("")
	local __msgs = self._buf:parsePackets(__event.data)
	local __msg = nil
	for i=1,#__msgs do
		__msg = __msgs[i]
		-- dump(__msg)
	end
end

return MainScene
