
--[[**************c++ GlobalConfigDefine.h中定义*****************--]]
BUFF_LEN 					= 10240             --缓冲区域大小
SENDPKG_BUFFER_LENGTH 		= 8000  			--发送包缓冲区长度
TCP_PING_TIME 				= 3.0
TCP_PING_TIMEOUT 			= 1					--心跳包超时
TCP_PING_TIMECOUNT 			= 2					--超时次数
---------------------------------------

Package = class("Package")

function Package:ctor()
	self.len = 0
	self.version = 0
	self.instruct = 0
	self.data=""
end

return Package