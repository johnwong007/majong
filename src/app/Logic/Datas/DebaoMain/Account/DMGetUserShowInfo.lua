local DMGetUserShowInfo = class("DMGetUserShowInfo")

function DMGetUserShowInfo:ctor()
	self.userId = ""
	self.userPortrait = ""
	self.userRegTime = ""
	self.userSex = ""
	self.userExperience = ""
	self.userLevel = ""
	self.userQQ = ""
	self.userEmail = ""
	self.userName = ""
	self.userPhone = ""
end

function DMGetUserShowInfo:parseJson(strJson, needDecode)
	local jsonTable = strJson
	if needDecode ~= false then
		jsonTable = json.decode(strJson)
	end 
	
	if type(jsonTable) == "table" then
		self.userId = jsonTable[USER_ID]
		self.userPortrait = jsonTable[USER_PORTRAIT]
		self.userRegTime = jsonTable[USER_REGTIME]
		self.userSex = jsonTable[USER_SEX]
		self.userExperience = jsonTable[USER_EXPERIENCE]
		self.userLevel = jsonTable[USER_LEVEL]
		self.userQQ = jsonTable[USER_QQ]
		self.userEmail = jsonTable[USER_EMAIL]
		self.userName = revertPhoneNumber(tostring(jsonTable[USER_NAME]))
		self.userPhone = jsonTable[USER_PHONE_NUMBER]
		self.userClubId = jsonTable['A100']
		self.userClubName = jsonTable['A101']
		self.parsResult = BIZ_PARS_JSON_SUCCESS

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return DMGetUserShowInfo