local FacesData = class("FacesData")

function FacesData:ctor()
	self.picUrl = ""
	self.version = ""
end

function FacesData:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.picUrl = jsonTable[PICTURE_URL]
		self.version = jsonTable[VERSION]
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		if SERVER_ENVIROMENT == ENVIROMENT_TEST then
			self.picUrl = "http://cache.debao.com/style/images/phone/face.zip"
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return FacesData