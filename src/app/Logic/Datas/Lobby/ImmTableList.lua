local myInfo = require("app.Model.Login.MyInfo")
local ImmTableList = class("ImmTableList")
function ImmTableList:ctor()
end

function ImmTableList:parseJson(strJson)
  if self.isPrivate then
    return self:parseJsonNew(strJson)
  end
	local jsonTable = json.decode(strJson)
  -- dump(jsonTable)
	if type(jsonTable) == "table" then
		--[[保存牌桌信息的table初始化]]
		----------------------------------
    self.tableList = nil
		self.tableList = {}
		for i = 1,#jsonTable,1 do
			self.tableList[i] = {}
		end
		self.indexSFullSEmtyList =  {}--显示满员、显示空桌
		self.indexSFullHEmtyList =  {}--显示满员
		self.indexHFullHEmtyList =  {}--都不显示
		self.indexHFullSEmtyList =  {}--显示空桌
		self.indexSixSeatList = {}--六人桌
		self.indexNineSeatList = {}--九人桌

    self.indexShowAllList = {}
    self.indexHideSixList = {}
    self.indexHideNineList = {}
    self.indexHideEmptyList = {}
    self.indexHideEmptyHideSixList = {}
    self.indexHideEmptyHideNineList = {}
    self.indexHideFullList = {}
    self.indexHideFullHideSixList = {}
    self.indexHideFullHideNineList = {}
    self.indexHideEmptyHideFullList = {}
    self.indexHideEmptyHideFullHideSixList = {}
    self.indexHideEmptyHideFullHideNineList = {}
		----------------------------------
		for i = 1,#jsonTable,1 do
            local index = i
			self.tableList[i].tableId = jsonTable[i][TABLE_ID]
			self.tableList[i].gameSpeed = jsonTable[i][GAME_SPEED]
			self.tableList[i].tableName = jsonTable[i][TABLE_NAME]
			self.tableList[i].seatNum = jsonTable[i][SEAT_NUM]
			self.tableList[i].smallBlind = jsonTable[i][SMALL_BLIND]
			self.tableList[i].buyChipsMin = jsonTable[i][BUY_CHIPS_MIN]
			self.tableList[i].butChipsMax = jsonTable[i][BUY_CHIPS_MAX]
			self.tableList[i].curUnum = jsonTable[i][CUR_UNUM]
			self.tableList[i].waittingUnum = jsonTable[i][WAITING_UNUM]
			self.tableList[i].bigBlind = jsonTable[i][BIG_BLIND]
			self.tableList[i].password = jsonTable[i][PASSWORD]
			self.tableList[i].tableOwner = jsonTable[i][TABLE_OWNER]
            self.tableList[i].listType = jsonTable[i][HALL_LIST_TYPE]
            
            if not self.isPrivate then
            	local seatNumInt = self.tableList[i].seatNum+0
                local curUnumInt = self.tableList[i].curUnum+0
                self.indexSFullSEmtyList[#self.indexSFullSEmtyList+1] = index
                if curUnumInt > seatNumInt-1 then
              	   self.indexSFullHEmtyList[#self.indexSFullHEmtyList+1] = index
                end
                if curUnumInt > 1 and curUnumInt < seatNumInt then
              	   self.indexHFullHEmtyList[#self.indexHFullHEmtyList+1] = index
                end
                if curUnumInt<1 then
              	   self.indexHFullSEmtyList[#self.indexHFullSEmtyList+1] = index
                end
                --六人桌
                if seatNumInt > 5 and seatNumInt < 7 then
                   self.indexSixSeatList[#self.indexSixSeatList+1] = index
                end
                --九人桌
                if seatNumInt > 8 and seatNumInt < 10 then
                   self.indexNineSeatList[#self.indexNineSeatList+1] = index
                end
                -------------------------------------------------------
                --[[显示所有]]
                self.indexShowAllList[#self.indexShowAllList+1] = index 
                --[[隐藏6人]]
                if seatNumInt < 6 or seatNumInt > 6 then
                  self.indexHideSixList[#self.indexHideSixList+1] = index
                end
                --[[隐藏9人]]
                if seatNumInt < 9 or seatNumInt > 9 then
                  self.indexHideNineList[#self.indexHideNineList+1] = index
                end
                --[[隐藏空桌]]
                if curUnumInt > 0 then
                  self.indexHideEmptyList[#self.indexHideEmptyList+1] = index
                end
                --[[隐藏空桌、6人]]
                if curUnumInt > 0 and (seatNumInt < 6 or seatNumInt > 6) then
                  self.indexHideEmptyHideSixList[#self.indexHideEmptyHideSixList+1] = index
                end
                --[[隐藏空桌、9人]]
                if curUnumInt > 0 and (seatNumInt < 9 or seatNumInt > 9) then
                  self.indexHideEmptyHideNineList[#self.indexHideEmptyHideNineList+1] = index
                end

                --[[隐藏满员]]
                if curUnumInt < seatNumInt then
                  self.indexHideFullList[#self.indexHideFullList+1] = index
                end

                --[[隐藏满员、6人]]
                if curUnumInt < seatNumInt and (seatNumInt < 6 or seatNumInt > 6) then
                  self.indexHideFullHideSixList[#self.indexHideFullHideSixList+1] = index
                end

                --[[隐藏满员、9人]]
                if curUnumInt < seatNumInt and (seatNumInt < 9 or seatNumInt > 9) then
                  self.indexHideFullHideNineList[#self.indexHideFullHideNineList+1] = index
                end

                --[[隐藏空桌、满员]]
                if curUnumInt < seatNumInt and curUnumInt > 0 then
                  self.indexHideEmptyHideFullList[#self.indexHideEmptyHideFullList+1] = index
                end

                --[[隐藏空桌、满员、6人]]
                if curUnumInt < seatNumInt and curUnumInt > 0 and (seatNumInt < 6 or seatNumInt > 6) then
                  self.indexHideEmptyHideFullHideSixList[#self.indexHideEmptyHideFullHideSixList+1] = index
                end

                --[[隐藏空桌、满员、9人]]
                if curUnumInt < seatNumInt and curUnumInt > 0 and (seatNumInt < 9 or seatNumInt > 9) then
                  self.indexHideEmptyHideFullHideNineList[#self.indexHideEmptyHideFullHideNineList+1] = index
                end
                -------------------------------------------------------
            elseif self.tableList[i].tableOwner ~= "sys" then
             
            	local seatNumInt = self.tableList[i].seatNum+0
                local curUnumInt = self.tableList[i].curUnum+0
                self.indexSFullSEmtyList[#self.indexSFullSEmtyList+1] = index
                if curUnumInt > seatNumInt-1 then
                   self.indexSFullHEmtyList[#self.indexSFullHEmtyList+1] = index
                end
                if curUnumInt > 1 and curUnumInt < seatNumInt then
                   self.indexHFullHEmtyList[#self.indexHFullHEmtyList+1] = index
                end
                if curUnumInt<1 then
                   self.indexHFullSEmtyList[#self.indexHFullSEmtyList+1] = index
                end
                --六人桌
                if seatNumInt > 5 and seatNumInt < 7 then
                   self.indexSixSeatList[#self.indexSixSeatList+1] = index
                end
                --九人桌
                if seatNumInt > 8 and seatNumInt < 10 then
                   self.indexNineSeatList[#self.indexNineSeatList+1] = index
                end

                -------------------------------------------------------
                --[[显示所有]]
                self.indexShowAllList[#self.indexShowAllList+1] = index 
                --[[隐藏6人]]
                if seatNumInt < 6 and seatNumInt > 6 then
                  self.indexHideSixList[#self.indexHideSixList+1] = index
                end
                --[[隐藏9人]]
                if seatNumInt < 9 and seatNumInt > 9 then
                  self.indexHideNineList[#self.indexHideNineList+1] = index
                end
                --[[隐藏空桌]]
                if curUnumInt > 0 then
                  self.indexHideEmptyList[#self.indexHideEmptyList+1] = index
                end
                --[[隐藏空桌、6人]]
                if curUnumInt > 0 and seatNumInt < 6 and seatNumInt > 6 then
                  self.indexHideEmptyHideSixList[#self.indexHideEmptyHideSixList+1] = index
                end
                --[[隐藏空桌、9人]]
                if curUnumInt > 0 and seatNumInt < 9 and seatNumInt > 9 then
                  self.indexHideEmptyHideNineList[#self.indexHideEmptyHideNineList+1] = index
                end

                --[[隐藏满员]]
                if curUnumInt < seatNumInt then
                  self.indexHideFullList[#self.indexHideFullList+1] = index
                end

                --[[隐藏满员、6人]]
                if curUnumInt < seatNumInt and seatNumInt < 6 and seatNumInt > 6 then
                  self.indexHideFullHideSixList[#self.indexHideFullHideSixList+1] = index
                end

                --[[隐藏满员、9人]]
                if curUnumInt < seatNumInt and seatNumInt < 9 and seatNumInt > 9 then
                  self.indexHideFullHideNineList[#self.indexHideFullHideNineList+1] = index
                end

                --[[隐藏空桌、满员]]
                if curUnumInt < seatNumInt and curUnumInt > 0 then
                  self.indexHideEmptyHideFullList[#self.indexHideEmptyHideFullList+1] = index
                end

                --[[隐藏空桌、满员、6人]]
                if curUnumInt < seatNumInt and curUnumInt > 0 and seatNumInt < 6 and seatNumInt > 6 then
                  self.indexHideEmptyHideFullHideSixList[#self.indexHideEmptyHideFullHideSixList+1] = index
                end

                --[[隐藏空桌、满员、9人]]
                if curUnumInt < seatNumInt and curUnumInt > 0 and seatNumInt < 9 and seatNumInt > 9 then
                  self.indexHideEmptyHideFullHideNineList[#self.indexHideEmptyHideFullHideNineList+1] = index
                end
                -------------------------------------------------------

            end

		end
            
        local sbList = {}
        if #self.tableList>0 and self.tableList[1].listType == "PRIMARY" then
            for i = 1,#self.tableList,1 do
            	sbList[i] = self.tableList[i].smallBlind
            end
        end

            if #self.tableList>0 and self.tableList[1].listType == "PRIMARY" then
                self:randomMatching()
            end
        
        if #sbList>0 then
           	table.sort(sbList)
       		myInfo.data.leastSB = sbList[#sbList]
        end
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

function ImmTableList:randomMatching()
  if self.isPrivate then
    return
  end
  local removelist = {}
  local newTableList = {}
  for index=1,#self.tableList do
    local flag = false
    for i=1,#newTableList do
      if self.tableList[index].smallBlind==self.tableList[newTableList[i]].smallBlind then
        flag = true
        self.tableList[newTableList[i]].curUnum = self.tableList[newTableList[i]].curUnum+self.tableList[index].curUnum
        break
      end
    end
    if flag==false then
      newTableList[#newTableList+1]=index
    else
      removelist[#removelist+1]=index
    end
  end

  for i=#removelist,1,-1 do
    table.remove(self.tableList, removelist[i])
  end
    self.indexShowAllList = {}
    self.indexHideSixList = {}
    self.indexHideNineList = {}
    self.indexHideEmptyList = {}
    self.indexHideEmptyHideSixList = {}
    self.indexHideEmptyHideNineList = {}
    self.indexHideFullList = {}
    self.indexHideFullHideSixList = {}
    self.indexHideFullHideNineList = {}
    self.indexHideEmptyHideFullList = {}
    self.indexHideEmptyHideFullHideSixList = {}
    self.indexHideEmptyHideFullHideNineList = {}
  for index=1,#self.tableList do
    if tonumber(self.tableList[index].smallBlind)<25 then
        self.tableList[index].tableName = "新手入门"
    elseif tonumber(self.tableList[index].smallBlind)<100 then
        self.tableList[index].tableName = "初入德州"
        math.randomseed(tostring(os.time()):reverse():sub(1, 6))    
        local k = math.random(1,3)
        self.tableList[index].curUnum = 100+self.tableList[index].curUnum*k
    elseif tonumber(self.tableList[index].smallBlind)<200 then 
        self.tableList[index].tableName = "小试身手"
    else
        self.tableList[index].tableName = "入门桌"
    end
    self.indexShowAllList[index] = index
    self.indexHideSixList[index] = index
    self.indexHideNineList[index] = index
    self.indexHideEmptyList[index] = index
    self.indexHideEmptyHideSixList[index] = index
    self.indexHideEmptyHideNineList[index] = index
    self.indexHideFullList[index] = index
    self.indexHideFullHideSixList[index] = index
    self.indexHideFullHideNineList[index] = index
    self.indexHideEmptyHideFullList[index] = index
    self.indexHideEmptyHideFullHideSixList[index] = index
    self.indexHideEmptyHideFullHideNineList[index] = index
  end
end

function ImmTableList:parseJsonNew(strJson)
  local jsonTable = json.decode(strJson)
  local request_type = jsonTable[LIST_REQUEST_TYPE]
  jsonTable = jsonTable[LIST_DATA]
  -- dump(jsonTable)
  if type(jsonTable) == "table" then
      
    ----------------------------------
    self.tableList = nil
    self.tableList = {}
    for i = #jsonTable,1,-1 do
        if jsonTable[i][PLAY_TYPE]=="SNG" and NEED_SNG==false then
            table.remove(jsonTable, i)
        end
    end
    for i = 1,#jsonTable,1 do
      self.tableList[i] = {}
    end
    self.indexSFullSEmtyList =  {}--显示满员、显示空桌
    self.indexSFullHEmtyList =  {}--显示满员
    self.indexHFullHEmtyList =  {}--都不显示
    self.indexHFullSEmtyList =  {}--显示空桌
    self.indexSixSeatList = {}--六人桌
    self.indexNineSeatList = {}--九人桌

    self.indexShowAllList = {}
    self.indexHideSixList = {}
    self.indexHideNineList = {}
    self.indexHideEmptyList = {}
    self.indexHideEmptyHideSixList = {}
    self.indexHideEmptyHideNineList = {}
    self.indexHideFullList = {}
    self.indexHideFullHideSixList = {}
    self.indexHideFullHideNineList = {}
    self.indexHideEmptyHideFullList = {}
    self.indexHideEmptyHideFullHideSixList = {}
    self.indexHideEmptyHideFullHideNineList = {}
    ----------------------------------
    for i = 1,#jsonTable,1 do
        local index = i
        self.tableList[i].tableId = jsonTable[i][TABLE_ID]
        self.tableList[i].gameSpeed = jsonTable[i][GAME_SPEED]
        self.tableList[i].tableName = jsonTable[i][TABLE_NAME]
        self.tableList[i].seatNum = jsonTable[i][SEAT_NUM]
        self.tableList[i].smallBlind = jsonTable[i][SMALL_BLIND]
        self.tableList[i].buyChipsMin = jsonTable[i][BUY_CHIPS_MIN]
        self.tableList[i].butChipsMax = jsonTable[i][BUY_CHIPS_MAX]
        self.tableList[i].curUnum = jsonTable[i][CUR_UNUM]
        self.tableList[i].waittingUnum = jsonTable[i][WAITING_UNUM]
        self.tableList[i].bigBlind = jsonTable[i][BIG_BLIND]
        self.tableList[i].password = jsonTable[i][PASSWORD]
        self.tableList[i].tableOwner = jsonTable[i][TABLE_OWNER]
        self.tableList[i].listType = jsonTable[i][HALL_LIST_TYPE]
        self.tableList[i].playType = jsonTable[i][PLAY_TYPE]

        if jsonTable[i][PLAY_TYPE]=="SNG" or jsonTable[i][PLAY_TYPE]=="MTT" then
            self.tableList[i].initChips = jsonTable[i][INIT_CHIPS]
            self.tableList[i].password = jsonTable[i][PASSWORD]
            self.tableList[i].applyList = jsonTable[i]["APPLY_LIST"]
            self.tableList[i].ownerId = jsonTable[i]["OWNER_ID"]
            self.tableList[i].seatNum = jsonTable[i]["SEATS"]
            self.tableList[i].uniqKey = jsonTable[i]["UNIQ_KEY"]
            self.tableList[i].upSeconds = jsonTable[i]["UP_SECONDS"]
            self.tableList[i].buyChipsMin = jsonTable[i]["301A"]
            self.tableList[i].smallBlind = jsonTable[i]["301A"]
            self.tableList[i].bigBlind = jsonTable[i]["301A"]*2
            self.tableList[i].butChipsMax = jsonTable[i]["301A"]*10
            local num = 0
            for j=1,string.len(self.tableList[i].applyList) do
              if string.sub(self.tableList[i].applyList, j,j) == ":" then
                num = num+1
              end
            end
            self.tableList[i].curUnum = num
            self.tableList[i].curUnum = tonumber(jsonTable[i][CUR_UNUM])
        end
        if self.tableList[i].seatNum then
        
        local seatNumInt = self.tableList[i].seatNum+0
          local curUnumInt = self.tableList[i].curUnum+0
          self.indexSFullSEmtyList[#self.indexSFullSEmtyList+1] = index
          if curUnumInt > seatNumInt-1 then
             self.indexSFullHEmtyList[#self.indexSFullHEmtyList+1] = index
          end
          if curUnumInt > 1 and curUnumInt < seatNumInt then
             self.indexHFullHEmtyList[#self.indexHFullHEmtyList+1] = index
          end
          if curUnumInt<1 then
             self.indexHFullSEmtyList[#self.indexHFullSEmtyList+1] = index
          end
          --六人桌
          if seatNumInt > 5 and seatNumInt < 7 then
             self.indexSixSeatList[#self.indexSixSeatList+1] = index
          end
          --九人桌
          if seatNumInt > 8 and seatNumInt < 10 then
             self.indexNineSeatList[#self.indexNineSeatList+1] = index
          end
          -------------------------------------------------------
          --[[显示所有]]
          self.indexShowAllList[#self.indexShowAllList+1] = index 
          --[[隐藏6人]]
          if seatNumInt < 6 or seatNumInt > 6 then
            self.indexHideSixList[#self.indexHideSixList+1] = index
          end
          --[[隐藏9人]]
          if seatNumInt < 9 or seatNumInt > 9 then
            self.indexHideNineList[#self.indexHideNineList+1] = index
          end
          --[[隐藏空桌]]
          if curUnumInt > 0 then
            self.indexHideEmptyList[#self.indexHideEmptyList+1] = index
          end
          --[[隐藏空桌、6人]]
          if curUnumInt > 0 and (seatNumInt < 6 or seatNumInt > 6) then
            self.indexHideEmptyHideSixList[#self.indexHideEmptyHideSixList+1] = index
          end
          --[[隐藏空桌、9人]]
          if curUnumInt > 0 and (seatNumInt < 9 or seatNumInt > 9) then
            self.indexHideEmptyHideNineList[#self.indexHideEmptyHideNineList+1] = index
          end

          --[[隐藏满员]]
          if curUnumInt < seatNumInt then
            self.indexHideFullList[#self.indexHideFullList+1] = index
          end

          --[[隐藏满员、6人]]
          if curUnumInt < seatNumInt and (seatNumInt < 6 or seatNumInt > 6) then
            self.indexHideFullHideSixList[#self.indexHideFullHideSixList+1] = index
          end

          --[[隐藏满员、9人]]
          if curUnumInt < seatNumInt and (seatNumInt < 9 or seatNumInt > 9) then
            self.indexHideFullHideNineList[#self.indexHideFullHideNineList+1] = index
          end

          --[[隐藏空桌、满员]]
          if curUnumInt < seatNumInt and curUnumInt > 0 then
            self.indexHideEmptyHideFullList[#self.indexHideEmptyHideFullList+1] = index
          end

          --[[隐藏空桌、满员、6人]]
          if curUnumInt < seatNumInt and curUnumInt > 0 and (seatNumInt < 6 or seatNumInt > 6) then
            self.indexHideEmptyHideFullHideSixList[#self.indexHideEmptyHideFullHideSixList+1] = index
          end

          --[[隐藏空桌、满员、9人]]
          if curUnumInt < seatNumInt and curUnumInt > 0 and (seatNumInt < 9 or seatNumInt > 9) then
            self.indexHideEmptyHideFullHideNineList[#self.indexHideEmptyHideFullHideNineList+1] = index
          end
        end
          ------------------------------------------------------
    end

    -- dump(self.indexShowAllList)  
    -- dump(self.indexHideSixList)  
    -- dump(self.indexHideNineList)  
    -- dump(self.indexHideEmptyList)  
    -- dump(self.indexHideEmptyHideSixList)  
    -- dump(self.indexHideEmptyHideNineList)  
    -- dump(self.indexHideFullList)  
    -- dump(self.indexHideFullHideSixList)  
    -- dump(self.indexHideFullHideNineList)  
    -- dump(self.indexHideEmptyHideFullList)  
    -- dump(self.indexHideEmptyHideFullHideSixList)  
    -- dump(self.indexHideEmptyHideFullHideNineList)  
        local sbList = {}
        if #self.tableList>0 and self.tableList[1].listType == "PRIMARY" then
            for i = 1,#self.tableList,1 do
              sbList[i] = self.tableList[i].smallBlind
            end
        end
        
        if #sbList>0 then
            table.sort(sbList)
          myInfo.data.leastSB = sbList[#sbList]
        end
    return BIZ_PARS_JSON_SUCCESS
  end
  return BIZ_PARS_JSON_FAILED
end

--[[给牌桌数据排序]]
--------------------------------------------------------------------------
function ImmTableList:sortList(sequenceType, hideRoomType, orderType)	
    self:sortListNew(sequenceType, hideRoomType, orderType)
  --   self.nowIndexList = {}
		-- if hideRoomType == Hide_All then
  --           self.nowIndexList = table.copy(self.indexHFullHEmtyList)
		-- elseif hideRoomType == Hide_FullShow_Empty then
  --           self.nowIndexList = table.copy(self.indexHFullSEmtyList)
		-- elseif hideRoomType == Show_FullHide_Empty then
  --           self.nowIndexList = table.copy(self.indexSFullHEmtyList)
		-- elseif hideRoomType == Show_All then
  --           self.nowIndexList = table.copy(self.indexSFullSEmtyList)
		-- elseif hideRoomType == show_sixSeat then
  --     dump(self.indexSixSeatList)
  --           self.nowIndexList = table.copy(self.indexSixSeatList)
		-- elseif hideRoomType == show_nineSeat then
  --     dump(self.indexNineSeatList)
  --           self.nowIndexList = table.copy(self.indexNineSeatList)
  --       end
		-- self:exchangeList(sequenceType,orderType)
end
--[[给牌桌数据排序]]
--------------------------------------------------------------------------
function ImmTableList:sortListNew(sequenceType, hideRoomType, orderType) 
    self.nowIndexList = {}
    if hideRoomType == ListShowType.ShowAll then
        self.nowIndexList = table.copy(self.indexShowAllList)
    elseif hideRoomType == ListShowType.HideSix then
        self.nowIndexList = table.copy(self.indexHideSixList)
    elseif hideRoomType == ListShowType.HideNine then
        self.nowIndexList = table.copy(self.indexHideNineList)
    elseif hideRoomType == ListShowType.HideEmpty then
        self.nowIndexList = table.copy(self.indexHideEmptyList)
    elseif hideRoomType == ListShowType.HideEmptyHideSix then
        self.nowIndexList = table.copy(self.indexHideEmptyHideSixList)
    elseif hideRoomType == ListShowType.HideEmptyHideNine then
        self.nowIndexList = table.copy(self.indexHideEmptyHideNineList)
    elseif hideRoomType == ListShowType.HideFull then
        self.nowIndexList = table.copy(self.indexHideFullList)
    elseif hideRoomType == ListShowType.HideFullHideSix then
        self.nowIndexList = table.copy(self.indexHideFullHideSixList)
    elseif hideRoomType == ListShowType.HideFullHideNine then
        self.nowIndexList = table.copy(self.indexHideFullHideNineList)
    elseif hideRoomType == ListShowType.HideEmptyHideFull then
        self.nowIndexList = table.copy(self.indexHideEmptyHideFullList)
    elseif hideRoomType == ListShowType.HideEmptyHideFullHideSix then
        self.nowIndexList = table.copy(self.indexHideEmptyHideFullHideSixList)
    elseif hideRoomType == ListShowType.HideEmptyHideFullHideNine then
        self.nowIndexList = table.copy(self.indexHideEmptyHideFullHideNineList)
    end
    self:exchangeList(sequenceType,orderType)
    self:exchangeListMyTable()
end

function ImmTableList:exchangeList(sequenceType, orderType)
	if sequenceType == Sequence_CurNum then
       	self:exchangeListCurNum(orderType)
    elseif sequenceType == Sequence_Buy then
        self:exchangeListBuyChips(orderType)
    end
end

function ImmTableList:exchangeListCurNum(orderType)
	table.sort(self.nowIndexList, function(a,b)
            local compareNum1 = math.floor(self.tableList[a].curUnum)
            local compareNum2 = math.floor(self.tableList[b].curUnum)
            local compareNum3 = math.floor(self.tableList[a].buyChipsMin)
            local compareNum4 = math.floor(self.tableList[b].buyChipsMin)
            if compareNum1~=compareNum2 then
			     if orderType then
				    return compareNum1>compareNum2
			     else
				    return compareNum1<compareNum2
			     end
            else
                 if orderType then
                    return compareNum3>compareNum4
                 else
                    return compareNum3<compareNum4
                 end
            end
		end)
end

function ImmTableList:exchangeListBuyChips(orderType)
    table.sort(self.nowIndexList, function(a,b)
            local compareNum1 = math.floor(self.tableList[a].curUnum)
            local compareNum2 = math.floor(self.tableList[b].curUnum)
            local compareNum3 = math.floor(self.tableList[a].buyChipsMin)
            local compareNum4 = math.floor(self.tableList[b].buyChipsMin)
            if compareNum3~=compareNum4 then
                 if orderType then
                    return compareNum3>compareNum4
                 else
                    return compareNum3<compareNum4
                 end
            else
                 if orderType then
                    return compareNum1>compareNum2
                 else
                    return compareNum1<compareNum2
                 end
            end
        end)
end

function ImmTableList:exchangeListMyTable()
    local tmpIndexList = {}
    for i=1,#self.nowIndexList do
        local value = tonumber(self.tableList[self.nowIndexList[i]].tableOwner)==tonumber(myInfo.data.userId)
        if value then
          table.insert(tmpIndexList, 1, self.nowIndexList[i])
        else
          table.insert(tmpIndexList, #tmpIndexList+1, self.nowIndexList[i])
        end
    end
    self.nowIndexList = nil
    self.nowIndexList = tmpIndexList
end
--------------------------------------------------------------------------
return ImmTableList