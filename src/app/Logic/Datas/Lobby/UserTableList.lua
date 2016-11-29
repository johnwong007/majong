UserListEach = class("UserListEach")

function UserListEach:ctor()
	self.tableId = ""
	self.tabletype = ""
end

-------------------------------------------------------------
UserTableList = class("UserTableList")

function UserTableList:ctor()
	self.listUser = {}
end


function UserTableList:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		for index=1,#jsonTable do
			local tmp = UserListEach:new()
			tmp.tableId = jsonTable[index][TABLE_ID]
			tmp.tabletype = jsonTable[index][TABLE_TYPE]
			self.listUser[#self.listUser+1] = tmp
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end