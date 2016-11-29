
PlayerInfo = class("PlayerInfo")

function PlayerInfo:ctor()
	self.seatNO = 0 --座位编号
	self.userID = ""
	self.userName = ""
	self.userChips = 0.0
	self.isTrustee = false --是否托管
	self.playerStatus = 0
end

----------------------------------------------------------

tableInfo = class("tableInfo")

function tableInfo:ctor()
	self.bigBlind = 0
	self.seatNum = 0 --座位号
	self.playerSeatNO = 0 --当前玩家位置
end

----------------------------------------------------------
BoardInfo = class("BoardInfo")
sharedBoardInfo = nil

function BoardInfo:getInstance()
	if sharedBoardInfo == nil then
		local instance = setmetatable({}, BoardInfo)
		instance.class = BoardInfo
		instance:ctor()
		sharedBoardInfo = instance
	end
	return sharedBoardInfo
end

function BoardInfo:create(isSave)
	local boardInfo = BoardInfo:new()
	if isSave then
		boardInfo.uploadFlag=0
		boardInfo.clearFlag=0
		boardInfo.commandInfo = {}
	end
	return boardInfo
end

function BoardInfo:ctor()
	self.uploadFlag=0
	self.clearFlag=0
	self.commandInfo = {}
	self.replayTableInfo = tableInfo:new()
	self.playerInfoList = {}
	self.seatCount = 0
	self.postCommandString = ""
	self.tableInfo = ""
	self.handID = ""
	self.isReplay = 0
	self.replayCommandInfo = nil
end

function BoardInfo:parseJson(strJson)
	-- strJson = string.sub(strJson, 2, string.len(strJson)-1)
	-- local startPos = 1
	-- for i=1,string.len(strJson) do
	-- 	if string.sub(strJson,i,i)=="{" then
	-- 		startPos = i
	-- 		break
	-- 	end
	-- end
	-- if startPos<string.len(strJson) then
	-- 	strJson = string.sub(strJson,startPos)
	-- end
	strJson = string.gsub(strJson,"A_2" ,"0_2" )
	strJson = string.gsub(strJson,"A_3" ,"0_3" )
	strJson = string.gsub(strJson,"A_4" ,"0_4" )
	strJson = string.gsub(strJson,"A_5" ,"0_5" )
	strJson = string.gsub(strJson,"A_6" ,"0_6" )
	strJson = string.gsub(strJson,"A_7" ,"0_7" )
	strJson = string.gsub(strJson,"A_8" ,"0_8" )
	strJson = string.gsub(strJson,"A_9" ,"0_9" )
	strJson = string.gsub(strJson,"A_10" ,"0_10" )
	strJson = string.gsub(strJson,"A_J" ,"0_J" )
	strJson = string.gsub(strJson,"A_Q" ,"0_Q" )
	strJson = string.gsub(strJson,"A_K" ,"0_K" )
	strJson = string.gsub(strJson,"A_A" ,"0_A" )

	strJson = string.gsub(strJson,"B_2" ,"1_2" )
	strJson = string.gsub(strJson,"B_3" ,"1_3" )
	strJson = string.gsub(strJson,"B_4" ,"1_4" )
	strJson = string.gsub(strJson,"B_5" ,"1_5" )
	strJson = string.gsub(strJson,"B_6" ,"1_6" )
	strJson = string.gsub(strJson,"B_7" ,"1_7" )
	strJson = string.gsub(strJson,"B_8" ,"1_8" )
	strJson = string.gsub(strJson,"B_9" ,"1_9" )
	strJson = string.gsub(strJson,"B_10" ,"1_10" )
	strJson = string.gsub(strJson,"B_J" ,"1_J" )
	strJson = string.gsub(strJson,"B_Q" ,"1_Q" )
	strJson = string.gsub(strJson,"B_K" ,"1_K" )
	strJson = string.gsub(strJson,"B_A" ,"1_A" )

	strJson = string.gsub(strJson,"C_2" ,"2_2" )
	strJson = string.gsub(strJson,"C_3" ,"2_3" )
	strJson = string.gsub(strJson,"C_4" ,"2_4" )
	strJson = string.gsub(strJson,"C_5" ,"2_5" )
	strJson = string.gsub(strJson,"C_6" ,"2_6" )
	strJson = string.gsub(strJson,"C_7" ,"2_7" )
	strJson = string.gsub(strJson,"C_8" ,"2_8" )
	strJson = string.gsub(strJson,"C_9" ,"2_9" )
	strJson = string.gsub(strJson,"C_10" ,"2_10" )
	strJson = string.gsub(strJson,"C_J" ,"2_J" )
	strJson = string.gsub(strJson,"C_Q" ,"2_Q" )
	strJson = string.gsub(strJson,"C_K" ,"2_K" )
	strJson = string.gsub(strJson,"C_A" ,"2_A" )

	strJson = string.gsub(strJson,"D_2" ,"3_2" )
	strJson = string.gsub(strJson,"D_3" ,"3_3" )
	strJson = string.gsub(strJson,"D_4" ,"3_4" )
	strJson = string.gsub(strJson,"D_5" ,"3_5" )
	strJson = string.gsub(strJson,"D_6" ,"3_6" )
	strJson = string.gsub(strJson,"D_7" ,"3_7" )
	strJson = string.gsub(strJson,"D_8" ,"3_8" )
	strJson = string.gsub(strJson,"D_9" ,"3_9" )
	strJson = string.gsub(strJson,"D_10" ,"3_10" )
	strJson = string.gsub(strJson,"D_J" ,"3_J" )
	strJson = string.gsub(strJson,"D_Q" ,"3_Q" )
	strJson = string.gsub(strJson,"D_K" ,"3_K" )
	strJson = string.gsub(strJson,"D_A" ,"3_A" )
	-- strJson = string.gsub(strJson,"\\\"" ,"\"" )
	-- dump(strJson)

	local jsonTable = json.decode(strJson)
	-- dump(jsonTable)
	while type(jsonTable) == "string" do
		jsonTable = json.decode(jsonTable)
	end
	-- dump(type(jsonTable))
	if type(jsonTable) == "number" then
		self.code = jsonTable or 0
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	elseif type(jsonTable) == "table" then
		self.replayTableInfo.playerSeatNO = -1
		local playList = jsonTable[PLAYER_LIST_REPLAY]
		local t_Info = jsonTable[TABLE_INFO_REPLAY]
		local playerMyinfo = jsonTable[PLAYER_MYINFO]
		self.replayTableInfo.seatNum = t_Info[SEAT_NUM_REPLAY] or 0
		self.replayTableInfo.bigBlind = t_Info[BIG_BLIND_REPLAY] or 0
		if t_Info[SEAT_NO_REPLAY] then
			self.replayTableInfo.playerSeatNO = t_Info[SEAT_NO_REPLAY] or 0
		end
		if playerMyinfo and playerMyinfo[SEAT_NO_REPLAY] then
			self.replayTableInfo.playerSeatNO = playerMyinfo[SEAT_NO_REPLAY] or 0
		end

		for index=1,#playList do
			local info = clone(PlayerInfo)
			info.seatNO = playList[index][SEAT_NO_REPLAY] or 0
			info.userID = playList[index][USER_ID_REPLAY] or ""
			info.userName = playList[index][USER_NAME_REPLAY] or ""
			info.userChips = playList[index][USER_CHIPS_REPLAY] or 0.0
			info.isTrustee = playList[index][IS_TRUSTEE_REPLAY] or false
			info.playerStatus = playList[index][PLAYER_STATUS_REPLAY] or 0
			self.playerInfoList[#self.playerInfoList+1] = info
		end
		self.replayCommandInfo = jsonTable[MSG_ARRAY]
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end


return BoardInfo