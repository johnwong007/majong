local GetLoginControl = class("GetLoginControl")

function GetLoginControl:ctor()
	self.tencent_flag = false
	self.esun_flag = false
end

function GetLoginControl:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.code = ""
		self.tencent_flag = (jsonTable["QQ"]+0)==0 and false or true
		self.esun_flag = (jsonTable["500WAN"]+0)==0 and false or true
		return BIZ_PARS_JSON_SUCCESS
	elseif type(jsonTable) == "number" then
        self.code = jsonTable+0.0
        self.parsResult = BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return GetLoginControl