local UserTicketItem = {
	ticketType = "",
	ticketMoney = "",
	ticketTime = "",
	ticketGroup = "",
	ticketNum = "",
	ticketId = "",
	ticketName = "",
}

local UserTicketListData = class("UserTicketListData")

function UserTicketListData:ctor()
	self.ticketList = {}
end

function UserTicketListData:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		for i=1,#jsonTable do
			local node = clone(UserTicketItem)
			node.ticketGroup = jsonTable[i][TICKET_GROUP]
			node.ticketId = jsonTable[i][TICKET_ID]
			node.ticketMoney = jsonTable[i][TICKET_MONEY]
			node.ticketName = jsonTable[i][TICKET_NAME]
			node.ticketNum = jsonTable[i][TICKET_NUM]
			node.ticketTime = jsonTable[i][TICKET_TIME]
			node.ticketType = jsonTable[i][TICKET_TYPE]
			self.ticketList[#self.ticketList+1] = node
		end
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return UserTicketListData