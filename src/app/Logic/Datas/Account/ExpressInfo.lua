local ExpressInfo = class("ExpressInfo")

function ExpressInfo:ctor()
	self.uid = ""
    self.userName = ""
    self.userStatus = ""
    self.modTime = ""
    self.birthday = ""
	self.userRegtime = ""
    self.userSex = ""
    self.userCountry = ""
    self.userProvince = ""
    self.userCity = ""
    self.addressDetail = ""
    self.userPhoneNo = ""
    self.userIdCard = ""
    self.userQQ = ""
    self.wubaiName = ""
    self.adminName = ""
    self.isCheckAuth = ""
    self.userClub = ""
    self.isBind = ""
    self.regChannel = ""
    self.adminNote = ""
    self.remark = ""
    self.userGroup = ""
    self.userEmail = ""
    self.userTrueName = ""
end

function ExpressInfo:parseJson(strJson)
	local jsonTable = json.decode(strJson) 
	if type(jsonTable) == "table" then
            self.uid=jsonTable["2003"]
            self.userName = jsonTable["2004"]
            self.userStatus = jsonTable["4003"]
            self.modTime = jsonTable["4004"]
            self.birthday = jsonTable["4005"]
            self.userRegtime = jsonTable["4008"]
			self.userSex=jsonTable["4010"]
            self.userCountry=jsonTable["4011"]
            self.userProvince=jsonTable["4012"]
            self.userCity=jsonTable["4013"]
            self.addressDetail=jsonTable["4014"]
            self.userPhoneNo=jsonTable["4015"]
            self.userIdCard=jsonTable["4027"]
            self.userQQ=jsonTable["4043"]
            self.wubaiName=jsonTable["4060"]
            self.adminName=jsonTable["5009"]
            self.isCheckAuth=jsonTable["5054"]
            self.userClub=jsonTable["A114"]
            self.isBind=jsonTable["504B"]
            self.regChannel=jsonTable["401A"]
            self.adminNote=jsonTable["500A"]
            self.remark=jsonTable["500E"]
            self.userGroup=jsonTable["600F"]
            self.userEmail=jsonTable["400E"]
            self.userTrueName=jsonTable["400F"]

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return ExpressInfo