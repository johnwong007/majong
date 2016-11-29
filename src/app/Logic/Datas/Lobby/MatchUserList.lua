local MatchUserInfo = {
	userId = "",
	userName = "",
	userChips = 0.0,
	playerStatus = "",
	birthdaty = ""
}

local MatchUserList = class("MatchUserList")

function MatchUserList:ctor()
	self.matchUserList = {}
end


function MatchUserList:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then

		for i=1,#jsonTable do
			local player = clone(MatchUserInfo)
			player.userId = jsonTable[i][USER_ID]
			player.userName = revertPhoneNumber(tostring(jsonTable[i][USER_NAME]))
			player.userChips = tonumber(jsonTable[i][USER_CHIPS])
			player.playerStatus = jsonTable[i][PLAYER_STATUS]
			player.birthdaty = jsonTable[i][BIRTHDAY]
			self.matchUserList[#self.matchUserList+1] = player
		end

		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return MatchUserList