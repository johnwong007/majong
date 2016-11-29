local myInfo = require("app.Model.Login.MyInfo")
local ImmClubTableList = class("ImmClubTableList")

function ImmClubTableList:ctor()
end

function ImmClubTableList:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if jsonTable then
		self.code = tonumber(jsonTable["CODE"]) or 0
		self.info = jsonTable["INFO"] or {}
		self.msg = tostring(jsonTable["MSG"]) or ""

		self.tableList = {}
		self.nowIndexList = {}
		local list = jsonTable["LIST"] or {}
	    for i = 1,#list,1 do
	      	self.tableList[i] = {}
	    end
		for i = 1,#list,1 do	
	        self.tableList[i].tableId = tostring(list[i][TABLE_ID]) or ""
	        self.tableList[i].tableType = tostring(list[i][TABLE_TYPE]) or ""
	        self.tableList[i].tableName = tostring(list[i][TABLE_NAME]) or ""
	        self.tableList[i].smallBlind = tonumber(list[i][SMALL_BLIND]) or 0.0
	        self.tableList[i].bigBlind = tonumber(list[i][BIG_BLIND]) or 0.0
	        self.tableList[i].startTime = tostring(list[i][START_TIME]) or ""
	        self.tableList[i].endTime = tostring(list[i][END_TIME]) or ""
	        self.tableList[i].payType = tostring(list[i][PAY_TYPE]) or ""

	        self.tableList[i].roomNum = tonumber(list[i]["ROOM_NUM"]) or 0
	        self.tableList[i].totalBuyin = tonumber(list[i]["TOTAL_BUYIN"]) or 0
	        self.tableList[i].totalHands = tonumber(list[i]["TOTAL_HANDS"]) or 0


	        self.tableList[i].tableId = tostring(list[i][TABLE_ID]) or ""
	        self.tableList[i].gameSpeed = tonumber(list[i][GAME_SPEED]) or 0
	        self.tableList[i].tableName = tostring(list[i][TABLE_NAME]) or ""
	        self.tableList[i].seatNum = tonumber(list[i][SEAT_NUM]) or 0
	        self.tableList[i].smallBlind = tonumber(list[i][SMALL_BLIND]) or 0.0
	        self.tableList[i].buyChipsMin = tonumber(list[i][BUY_CHIPS_MIN]) or 0.0
	        self.tableList[i].butChipsMax = tonumber(list[i][BUY_CHIPS_MAX]) or 0.0
	        self.tableList[i].curUnum = tonumber(list[i][CUR_UNUM]) or 0
	        self.tableList[i].waittingUnum = tonumber(list[i][WAITING_UNUM]) or 0
	        self.tableList[i].bigBlind = tonumber(list[i][BIG_BLIND]) or 0.0
	        self.tableList[i].password = tostring(list[i][PASSWORD]) or ""
	        self.tableList[i].tableOwner = tostring(list[i][TABLE_OWNER]) or ""
	        self.tableList[i].listType = list[i][HALL_LIST_TYPE]
	        self.tableList[i].playType = tostring(list[i][PLAY_TYPE])

	        if list[i][PLAY_TYPE]=="SNG" then
	            self.tableList[i].initChips = tonumber(list[i][INIT_CHIPS]) or 0.0
	            self.tableList[i].password = tostring(list[i][PASSWORD]) or ""
	            self.tableList[i].applyList = tostring(list[i]["APPLY_LIST"]) or ""
	            self.tableList[i].ownerId = tostring(list[i]["OWNER_ID"]) or ""
	            self.tableList[i].seatNum = tonumber(list[i]["SEATS"]) or 0
	            self.tableList[i].uniqKey = tostring(list[i]["UNIQ_KEY"]) or ""
	            self.tableList[i].upSeconds = tostring(list[i]["UP_SECONDS"]) or ""
	            self.tableList[i].buyChipsMin = tonumber(list[i]["301A"]) or 0.0
	            self.tableList[i].smallBlind = tonumber(list[i]["301A"]) or 0.0
	            self.tableList[i].bigBlind = tonumber(list[i]["301A"]*2) or 0.0
	            self.tableList[i].butChipsMax = tonumber(list[i]["301A"]*10) or 0.0
	            local num = 0
	            for j=1,string.len(self.tableList[i].applyList) do
	              if string.sub(self.tableList[i].applyList, j,j) == ":" then
	                num = num+1
	              end
	            end
	            self.tableList[i].curUnum = num
	        end

        	self.nowIndexList[#self.nowIndexList+1] = i
		end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return ImmClubTableList