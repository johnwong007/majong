PushCommandRequest = {}

setmetatable(PushCommandRequest, {__index = cc.Ref})
PushCommandRequest.super = cc.Ref
PushCommandRequest.__cname = "PushCommandRequest"
PushCommandRequest.ctype = 2
PushCommandRequest.__index = PushCommandRequest

sharedPushCommandRequest = nil

function PushCommandRequest:getInstance()
	if sharedPushCommandRequest == nil then
		local instance = setmetatable({}, PushCommandRequest)
		instance.class = PushCommandRequest
		instance:ctor()
		sharedPushCommandRequest = instance
	end
	return sharedPushCommandRequest
end

function PushCommandRequest:ctor()
	normal_info_log("PushCommandRequest在DebaoPlatformLogin:dealLogin4VerisionResp调用 功能还需要完善")
end