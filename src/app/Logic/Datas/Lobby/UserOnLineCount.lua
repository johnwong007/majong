local UserOnLineCount = class("UserOnLineCount")

function UserOnLineCount:ctor()
	self.onLineCount = 0
end

function UserOnLineCount:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "number" then
		self.onLineCount = jsonTable
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return UserOnLineCount