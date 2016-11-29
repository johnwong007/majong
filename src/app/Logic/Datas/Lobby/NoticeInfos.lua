NoticeInfoStruct = class("NoticeInfoStruct")

function NoticeInfoStruct:ctor()
	self.noticeTitle = ""
	self.noticeDate = ""
	self.noticeContent = ""
	self.is_every_msg = false
	self.typeId = ""
end

------------------------------------------------------

NoticeInfos = class("NoticeInfoStruct")

function NoticeInfos:ctor()
	self.list = {}
end

function NoticeInfos:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		for i=1,#jsonTable do
			local info = NoticeInfoStruct:new()
			info.noticeTitle = jsonTable[index][NOTICE_TITLE]
			info.noticeDate = jsonTable[index][NOTICE_DATE]
			info.noticeContent = jsonTable[index][NOTICE_CONTENT]
			if jsonTable[index][NOTICE_IS_PUBLIC]=="1" then
				info.is_every_msg = true
			else
				info.is_every_msg = false
			end
			info.typeId = jsonTable[index][NOTICE_TYPE]
			self.list[#self.list+1] = info
		end

		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return NoticeInfos