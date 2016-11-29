local PriTableUserList = class("PriTableUserList")

function PriTableUserList:ctor()
	self.code = 0
	self.num = 0
	self.msg = ""
	self.userList = {}
end

function PriTableUserList:parseJson(strJson)
	local jsonTable = strJson
	-- dump(jsonTable)
	if type(jsonTable) == "table" then
		self.code  = jsonTable["CODE"]
		self.num = jsonTable["INFO"]["num"]
		self.msg = jsonTable["MSG"]
		local list = jsonTable["LIST"]
		if list and #list>0 then
			for i=1,#list do
				local data = {}
				data["userId"] = tostring(list[i]["2003"])
				data["name"] = tostring(list[i]["2004"])
				data["chips"] = tonumber(list[i]["BUYIN_COUNT"])
				data["profit"] = tonumber(list[i]["WIN_COUNT"])
				local tag = false
				for j=1,#self.userList do
					if data["profit"] > self.userList[j]["profit"] then
						table.insert(self.userList, j, data)
						tag = true
						break
					end
				end
				if tag == false then
					self.userList[#self.userList+1] = data
				end
			end
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return PriTableUserList