local GetBulletin = class("GetBulletin")

function GetBulletin:ctor()
	self.bulletinStr = ""
end

function GetBulletin:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.code = ""
		if #jsonTable>0 then
			self.bulletinStr = jsonTable(#jsonTable)
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return GetBulletin