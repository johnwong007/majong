local GetServerId = class("GetServerId")

function GetServerId:ctor()
	self.serverId = 0
end

function GetServerId:parseJson(strJson)
	self.serverId = strJson+0
	return BIZ_PARS_JSON_SUCCESS
end


return GetServerId