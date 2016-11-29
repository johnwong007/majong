TABLE_RAKE_BF_FLOP_MSG_RAKE_INFO_BF_FLOP = class("TABLE_RAKE_BF_FLOP_MSG_RAKE_INFO_BF_FLOP")


function TABLE_RAKE_BF_FLOP_MSG_RAKE_INFO_BF_FLOP:ctor()
	self.m_seatNo = 0
	self.m_rakeChipsBfFlop = 0.0
	self.m_userId = ""
	self.m_userChips = 0.0
end
-------------------------------------------------------------------
--[[17发送玩家抽水信息 (现金桌，可能有)]]
local TableRakeBfFlopMsgData = class("TableRakeBfFlopMsgData")

function TableRakeBfFlopMsgData:ctor()
	self.m_code = 0
	self.m_tableId = ""
	self.m_rakeInfoBfFlop = {}
end

--[[17发送玩家抽水信息 (现金桌，可能有)]]
function TableRakeBfFlopMsgData:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		self.m_code = jsonTable[CODE]+0
		self.m_tableId = jsonTable[TABLE_ID]..""

		self.m_rakeInfoBfFlop = {}
		local varTable = jsonTable[RAKE_INFO_BF_FLOP]
		for index=1,#varTable do
			local childVar= varTable[index]
			local rakeBfFlop = TABLE_RAKE_BF_FLOP_MSG_RAKE_INFO_BF_FLOP:new()
			rakeBfFlop.m_seatNo = tonumber(childVar[SEAT_NO])
			rakeBfFlop.m_rakeChipsBfFlop = childVar[RAKE_CHIPS_BF_FLOP]
			rakeBfFlop.m_userId = childVar[USER_ID]
			rakeBfFlop.m_userChips = childVar[USER_CHIPS]
			self.m_rakeInfoBfFlop[index] = rakeBfFlop
		end
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return TableRakeBfFlopMsgData