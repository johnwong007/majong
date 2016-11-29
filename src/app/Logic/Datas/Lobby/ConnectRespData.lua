local ConnectRespData = class("ConnectRespData")

function ConnectRespData:ctor()
	self.m_code = ""
end

function ConnectRespData:parseJson(strJson)
	if strJson then
		self.m_code = strJson[CODE]
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return ConnectRespData