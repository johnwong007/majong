local GetLoginConfig = class("GetLoginConfig")

function GetLoginConfig:ctor()
	self.splashUrl = ""
	self.tencent_flag = false
	self.esun_flag = false

	self.updateUrl = ""
	self.newVersion = ""
	self.versionDesc = ""
	self.bForceUpdate = false
end

function GetLoginConfig:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.code = ""
        local loginCtrl = jsonTable["LOGIN"]
		self.tencent_flag = (loginCtrl["QQ"]+0)==0 and false or true
		self.esun_flag = (loginCtrl["500WAN"]+0)==0 and false or true
            
		local splash = var["SPLASH"]
		self.splashUrl = splash[PICTURE_URL]..""


		local updateTable = var["UPDATE"]
		if updateTable and type(updateTable)=="table" then
			self.updateUrl = updateTable["url"]..""
			self.newVersion = updateTable["version"]..""
			self.bForceUpdate = (updateTable["force"]+0)==0 and false or true
			if updateTable["desc"] and type(updateTable["desc"])=="table" then
				for index = 0,#updateTable["desc"] do
					if index == #updateTable["desc"] then
						self.versionDesc = self.versionDesc..updateTable["desc"][index]
					else
						self.versionDesc = self.versionDesc..updateTable["desc"][index].."\n"
					end
				end
			end
			parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

end

return GetLoginConfig