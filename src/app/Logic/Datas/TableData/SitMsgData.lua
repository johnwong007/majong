local SitMsgData = class("SitMsgData")

function SitMsgData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_sitNo = 0
	self.m_userId = ""
	self.m_userName = ""
	self.m_userChip = 0.0
	self.m_buyMaxChips = 0.0
	self.m_buyMinChips = 0.0
	self.m_userSex = ""
	self.imageURL = ""
	self.privilege = 0
end


function SitMsgData:parseJson(strJson)
	local jsonTable = strJson
	-- dump(jsonTable)
	if type(jsonTable) == "table" then
		self.m_code = tonumber(jsonTable[CODE]) or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""

		self.m_sitNo = tonumber(jsonTable[SEAT_NO]) or 0
		self.m_userId = jsonTable[USER_ID] or ""

		if TRUNK_VERSION == DEBAO_TRUNK then
			self.userName = revertPhoneNumber(tostring(jsonTable[USER_NAME]))
			if jsonTable[USER_SEX] then
				self.m_userSex = jsonTable[USER_SEX] or ""
			end
		else
			self.userName = jsonTable[QQ_NAME] or ""
			self.m_userSex = jsonTable[QQ_SEX] or ""
		end	
		if jsonTable[USER_CHIPS] then
			self.m_userChip = jsonTable[USER_CHIPS] or 0.0
		end
		if jsonTable[BUY_CHIPS_MAX] then
			self.m_buyMaxChips = jsonTable[BUY_CHIPS_MAX] or 0.0
		end
		if jsonTable[BUY_CHIPS_MIN] then
			self.m_buyMinChips = jsonTable[BUY_CHIPS_MIN] or 0.0
		end
		if jsonTable[HeadPic_URL] then
			self.imageURL = jsonTable[HeadPic_URL] or ""
		end
		if jsonTable[PRIVILEGE] then
			self.privilege = jsonTable[PRIVILEGE] or 0
		end
		self.buyinTimes = tonumber(jsonTable[BUYIN_TIMES])
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return SitMsgData