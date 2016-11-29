local TableChatMessage = class("TableChatMessage")

function TableChatMessage:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_userId = ""
	self.m_userName = ""

	self.m_seatNo = -1
	self.m_content = ""
	self.chargeChips = 0.0  --表情扣的钱数
	self.chatType = ""  --类型：文字，表情
	self.isForFlash = false
end


function TableChatMessage:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE] or 0
		self.m_tableId = jsonTable[TABLE_ID] or ""
		self.m_userId = jsonTable[USER_ID] or ""
		self.userName = revertPhoneNumber(tostring(jsonTable[USER_NAME]))
		self.m_seatNo = jsonTable[SEAT_NO] or 0
		self.m_content = jsonTable[CONTENT] or ""
		if jsonTable[IMAGE_CHARG] then
			self.chargeChips = jsonTable[IMAGE_CHARG]+0.0
		end
		self.chatType = jsonTable[CHAT_TYPE] or ""
		self.isForFlash = ((chatType or "") == "ONLY_FLASH")
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TableChatMessage