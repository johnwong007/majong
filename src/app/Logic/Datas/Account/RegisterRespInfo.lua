local RegisterRespInfo = class("RegisterRespInfo")

function RegisterRespInfo:ctor()
	self.responseCode = ""
    self.description = ""
    self.username = ""
    self.userId = ""
end

function RegisterRespInfo:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		
        self.responseCode = jsonTable[CODE]..""
        self.description = jsonTable[DSCRIPTION]..""
        self.userId = jsonTable[USER_ID]..""
        self.username = revertPhoneNumber(tostring(jsonTable[USER_NAME]))
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return RegisterRespInfo