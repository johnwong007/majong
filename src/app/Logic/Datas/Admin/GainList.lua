local GainInfo = 
{
	prizeBeginRandk = 0,
	prizeEndRank = 0,
	goodsId = "",
	adminName = "",
	adminNote = "",
	gainType = "",
	gainDesc = "",
	gainNum = 0.0,
	gainId = "",
	gainName = "",
	goodsName = ""
}

local GainList = class("GainList")

function GainList:ctor()
	self.gainInfoList = {}
end

function GainList:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.gainInfoList = nil
		self.gainInfoList = {}
		for i=1,#jsonTable do
		    local node = clone(GainInfo)
			node.prizeBeginRandk =jsonTable[i][PRIZE_BEGIN_RANK]+0
			node.prizeEndRank = jsonTable[i][PRIZE_END_RANK]+0
			node.goodsId = jsonTable[i][GOODS_ID]..""
			node.adminName = jsonTable[i][ADMIN_NAME]..""
			node.adminNote = jsonTable[i][ADMIN_NOTE]..""
			node.gainType = jsonTable[i][GAIN_TYPE]..""
			node.gainDesc = jsonTable[i][GAIN_DESC]..""
			node.gainNum = jsonTable[i][GAIN_NUM]+0.0
			node.gainId = jsonTable[i][GAIN_ID]..""
			node.gainName = jsonTable[i][GAIN_NAME]..""
			node.goodsName = jsonTable[i][GOODS_NAME]..""
			self.gainInfoList[#self.gainInfoList+1] = node
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return GainList