local RemoveConcern = class("RemoveConcern")

function RemoveConcern:ctor()
	self.isSuccess = 0
	self.userId = ""
	self.userName = ""
end


function RemoveConcern:parseJson(strJson)
	if strJson ~= "" then
		self.isSuccess = strJson == "true" and 1 or 0
		return  BIZ_PARS_JSON_SUCCESS
	else
		return BIZ_PARS_JSON_FAILED
	end
end

return RemoveConcern