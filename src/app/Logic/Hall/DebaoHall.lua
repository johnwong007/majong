--[[DebaoHall与c++版本中的BaseHall功能相同]]
local myInfo = require("app.Model.Login.MyInfo")
require("app.Logic.Hall.HallViewDefine")

NO_DEFINE_GAME    			=0 --未定义
GOLD_TYPE    				=1 --金币场
SILVER_TYPE    				=2 --银币场
RAKEPOINT_TYPE   			=3 --积分场

NO_DEFINE_TABLE   			=0 --未定义
PRIMARY_TYPE    			=1 --初级
MIDDLE_TYPE   				=2 --中级
HIGH_TYPE   				=3 --高级
SUPER_TYPE  				=4 --大师
ALL_TYPE					=5 --全部
PRIVATE_TYPE    			=6 --私人房间

SITANDGO    				=0 --坐满即玩
TOURNEY    					=1 --定时开始


local DebaoHall = class("DebaoHall", function()
        return display.newNode()
    end)

function DebaoHall:ctor()
	self.tcpRequest = TcpCommandRequest:shareInstance()
	self.tcpRequest:addObserver(self)
	self.m_gameType = NO_DEFINE_GAME
	self.m_tableType = NO_DEFINE_TABLE

	self.myTableList = require("app.Logic.Datas.Lobby.ImmTableList"):new()
	self.baseHideType = ListShowType.ShowAll
	self.sequenceType = Sequence_CurNum
	self.sequenceUp = true
	self.m_bJoinTable = false

    self:setNodeEventEnabled(true)

    -- local eventCustom = cc.EventListenerCustom:create("RefreshPrivateHall", function(event)
    --         self:refreshHallView(event)
    --     end)
    -- cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(eventCustom, 12)
end

function DebaoHall:refreshHallView(event)
    self:getTableLists(self.m_gameType, self.m_tableType, self.m_sortString)
end

function DebaoHall:refreshHallViewDelay(dt)
    if self.isClubList then
        DBHttpRequest:priTableList(function(event) if self.httpResponse then self:httpResponse(event) end end, self.clubId, true)
    else
        self:getTableLists(self.m_gameType, self.m_tableType, self.m_sortString)
    end
    -- if self.m_refreshHVD then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_refreshHVD)
    --     self.m_refreshHVD = nil
    -- end
end

function DebaoHall:onNodeEvent(event)
    if event == "exit" then
        self:onExit()
    end
end

function DebaoHall:onEnterTransitionFinish()
    self.m_refreshHVD = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
            handler(self, self.refreshHallViewDelay), 10, false)
end

function DebaoHall:onExit()
    if self.m_refreshHVD then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_refreshHVD)
        self.m_refreshHVD = nil
    end
    self.tcpRequest:removeObserver(self)
    self.myTableList = nil
end

function DebaoHall:setHallCallback(callback)
	self.m_pCallbackUI = callback
end

function DebaoHall:enterHallRequest()
    DBHttpRequest:getAccountInfo(function(event) if self.httpResponse then self:httpResponse(event) end end)
    DBHttpRequest:getDebaoCoin(function(event) if self.httpResponse then self:httpResponse(event) end
            end, myInfo.data.Global_Token,myInfo.data.Global_Secret)

end

function DebaoHall:getBulletin()
    DBHttpRequest:getBulletin(function(event) if self.httpResponse then  self:httpResponse(event) end
            end, "L")
end

--[[上报点击情况]]
function DebaoHall:dataReport()
    DBHttpRequest:dataReport(function(event) if self.httpResponse then self:httpResponse(event) end
        end,89, 1, "")
end 

function DebaoHall:getClubTableLists(clubId)
    self.m_gameType = "ALL"
    self.m_tableType = PRIVATE_TYPE
    self.m_sortString = "ASC"
    self.isClubList = true
    self.clubId = clubId
    DBHttpRequest:priTableList(function(event) if self.httpResponse then self:httpResponse(event) end end, clubId, true)
end

function DebaoHall:getTableLists(gameType, tableType, sortString)
    self.m_gameType = gameType
    self.m_tableType = tableType 
    self.m_sortString = sortString

    if not self.m_gameType or not self.m_tableType or not self.m_sortString then
        return
    end

    local game_type=""
    local table_type=""
    local tableOwner = ""

    if gameType == GOLD_TYPE then
        game_type="GOLD"
    elseif gameType == SILVER_TYPE then
        game_type="SILVER"
    elseif gameType == RAKEPOINT_TYPE then
        game_type="RAKEPOINT"
    end

    if tableType == PRIMARY_TYPE then       --初级
            table_type="PRIMARY" --初级
            tableOwner = "all"
            self.m_bIsPrivate = false
    elseif tableType == MIDDLE_TYPE then    --中级
            table_type="MIDDLE" --中级
            tableOwner = "all"
            self.m_bIsPrivate = false
    elseif tableType == HIGH_TYPE then      --高级
            table_type="HIGH" --高级
            tableOwner = "all"
            self.m_bIsPrivate = false
    elseif tableType == SUPER_TYPE then     --大师
            table_type="SUPER" --大师
            tableOwner = "all"
            self.m_bIsPrivate = false
    elseif tableType == ALL_TYPE then       --全部
            table_type="" --全部
            tableOwner = "all"
            self.m_bIsPrivate = false
    elseif tableType == PRIVATE_TYPE then   --私人
            game_type = gameType
            table_type="0" --私人
            self.m_bIsPrivate = true
        DBHttpRequest:getDiyTableList(function(event) if self.httpResponse then self:httpResponse(event) end
            end,game_type,"",table_type)  
        return

    end
    DBHttpRequest:getImmTableList(function(event) if self.httpResponse then self:httpResponse(event) end
            end,game_type,table_type,"","",sortString,"","",tableOwner)   
end

function DebaoHall:hideRoom(hideType)
    self.baseHideType = hideType
    if self.m_pCallbackUI and self.myTableList 
        and self.myTableList.tableList and #self.myTableList.tableList>0 then
        self.myTableList:sortList(self.sequenceType,self.baseHideType,self.sequenceUp)
        self.m_pCallbackUI:showTableListNew(self.myTableList)
    end
end

function DebaoHall:hideRoomNew(hideType)
    self.baseHideType = hideType
    if self.m_pCallbackUI and self.myTableList
        and self.myTableList.tableList and #self.myTableList.tableList>0 then
        self.myTableList:sortListNew(self.sequenceType,self.baseHideType,self.sequenceUp)
        self.m_pCallbackUI:showTableListNew(self.myTableList)
    end
end

--[[http请求返回]]
----------------------------------------------------------
function DebaoHall:httpResponse(event)

    local ok = (event.name == "completed")
    local request = event.request
 
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- print(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- print(code)
        return
    end
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
    -- self:dealLoginResp(request:getResponseString())
    self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

end

function DebaoHall:onHttpResponse(tag, content, state)
	-- if(state != ehttpSuccess)
	-- {
	-- 	if (tag == POST_COMMAND_GETUSERTABLELIST)
	-- 	{
	-- 		m_pCallbackUI->showAlertEnterChampion(NULL, 0)
	-- 		return
	-- 	}
	-- 	string errorMsg = state==ehttpNoNetwork?Lang_NO_NETWORK:Lang_REQUEST_DATA_ERROR
	-- 	if(m_pCallbackUI)
	-- 		m_pCallbackUI->showError_Callback(errorMsg)
	-- 	return
	-- }
    if tag == POST_COMMAND_GETIMMTABLELISTNEW then
    	self:dealTableListKindsData(content)
    elseif tag == POST_COMMAND_GETIMMTABLELIST then
        self:dealTableListData(content)
    elseif tag == POST_COMMAND_GETACCOUNTINFO then
        self:dealGetAccountInfo(content)
    elseif tag == POST_COMMAND_CHAMPIONSHIPLIST then
        self:dealChampionShipData(content)
    elseif tag == POST_COMMAND_GETMATCHLIST then
        self:dealChampionShipData(content)
    elseif tag == POST_COMMAND_APPLYMATCH then
        self:dealApplyMatch(content)
    elseif tag == POST_COMMAND_GETUSERTABLELIST then
        self:dealUserTableList(content)
    elseif tag == POST_COMMAND_GETDEBAOCOIN then
        self:dealGetDebaoCoin(content)
    elseif tag == POST_COMMAND_GETBULLETIN then
        self:dealGetBulletin(content)
    elseif tag == POST_COMMAND_GET_DiyTableIdByFid then
        self:dealGetDiyTableIdByFid(content)
    elseif tag == POST_COMMAND_GET_ApplyDiyMatch then
        self:dealApplyDiyMatch(content)
    elseif tag == POST_COMMAND_GET_priTableList then
        self:dealClubTableListData(content)
    elseif tag == POST_COMMAND_TABLELEVEL_TO_GAMEADDR then
        self:dealTableLevelToGameAddr(content)
    end
end

function DebaoHall:dealTableLevelToGameAddr(strJson)
    local jsonTable = json.decode(strJson)
    local bigblind = tonumber(jsonTable[BIG_BLIND])
    local tableId = tostring(jsonTable[GAME_ADDR])
    jsonTable["random"] = true
    jsonTable.m_isFromMainPage = true
    self.m_pCallbackUI:enterRoom(jsonTable)
end

function DebaoHall:dealApplyDiyMatch(content)
    local code = tonumber(content)
    local msg = ""
    local isSuc = false
    -- dump(code)
    if (code and code == 0) or (code and code == 1) then
        msg = "恭喜您报名成功！"
        isSuc = true
    elseif code and code == -3 then 
        msg = "您已经报名该赛事!"
    elseif code and code == -5 then  
        msg = "报名已超过人数限制" 
    else
        msg = "报名失败！"
    end
    self.m_pCallbackUI:showTip(msg)
end

function DebaoHall:dealGetDiyTableIdByFid(content)
   local data = require("app.Logic.Datas.Lobby.JoinTableInfo"):new()
    if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
        if data.tableId == nil or data.tableId == "nil" then
            if self.m_pCallbackUI then
                self.m_pCallbackUI:showHint("房间不存在！")
            end
        elseif data.tableStatus == "CLOSED" then
            if self.m_pCallbackUI then
                self.m_pCallbackUI:showHint("房间已关闭")
            end
        else
            self.m_pCallbackUI:searchRoomCallback(data)
        end
    else
        if self.m_pCallbackUI then
            self.m_pCallbackUI:showHint("房间不存在！")
        end
    end
end

function DebaoHall:dealTableListKindsData(content)
    print("DebaoHall:dealTableListKindsData")
end

function DebaoHall:dealClubTableListData(content)
    self.myTableList = nil
    self.myTableList = require("app.Logic.Datas.Lobby.ImmClubTableList"):new()
    self.myTableList.isPrivate = self.m_bIsPrivate

    if self.myTableList:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
        self.m_pCallbackUI:showTableListNew(self.myTableList)
    end
end

function DebaoHall:dealTableListData(content)
    self.myTableList = nil
    self.myTableList = require("app.Logic.Datas.Lobby.ImmTableList"):new()
    self.myTableList.isPrivate = self.m_bIsPrivate
    if self.myTableList:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
        self.myTableList:sortList(self.sequenceType,self.baseHideType,self.sequenceUp)
        self.m_pCallbackUI:showTableListNew(self.myTableList)
    end
end

function DebaoHall:dealGetAccountInfo(content)
   local data = require("app.Logic.Datas.Account.AccountInfo"):new()
    if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS and data.code == "" then
        myInfo.data.totalChips = data.silverBalance
        myInfo.data.diamondBalance = data.diamondBalance
        myInfo.data.userDebaoDiamond = data.pointBalance
        if self.m_pCallbackUI then
            self.m_pCallbackUI:refreshMySilverCoin()
        end
    end
end

function DebaoHall:dealChampionShipData(content)
   
    print("DebaoHall:dealChampionShipData")
end

function DebaoHall:dealApplyMatch(content)
   
    print("DebaoHall:dealApplyMatch")
end

function DebaoHall:dealUserTableList(content)
   
    print("DebaoHall:dealUserTableList")
end

function DebaoHall:dealGetDebaoCoin(content)
    local userDebaoCoin = require("app.Logic.Datas.pay.DebaoCoin"):new()
    if userDebaoCoin:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
        print("userDebaoCoin:parsJson(content)==BIZ_PARS_JSON_SUCCESS")
    end
end

function DebaoHall:dealGetBulletin(content)
    local data = require("app.Logic.Datas.Others.GetBulletin"):new()
    if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS and data.code == "" then
        local bulletinStr = data.bulletinStr
        self.m_pCallbackUI:showBulletin(bulletinStr)
    end
end

function DebaoHall:joinTable(tableId, password, playType)
    password = password or ""
    if type(playType)=="string" and playType == "SNG" then
        DBHttpRequest:applyDiyMatch(handler(self, self.httpResponse), tableId, password, true)
        return 
    end
    if tableId then
        self.tcpRequest:joinTable(tableId, password)
        self.m_bJoinTable = true
    end
end

function DebaoHall:tableLevelToGameAddr(bigblind, smallblind)
    DBHttpRequest:tableLevelToGameAddr(handler(self, self.httpResponse), bigblind, smallblind)
end

----------------------------------------------------------
--[[socket请求返回]]
----------------------------------------------------------
function DebaoHall:OnTcpMessage(command, strJson)
    if command == COMMAND_PING_RESP then --[[心跳包]]
        
    elseif command == COMMAND_TABLE_GUIDE then --[[通知进入锦标赛]]
        
    elseif command == COMMAND_APPLY_MATCH_RESP then
        self:dealApplyMatchResp(strJson)
    elseif command == COMMAND_CANCEL_RESP then
        self:dealCancelMatchResp(strJson)
    elseif command == COMMAND_TABLE_JOIN_RESP then
        self:dealTableJoinResp(strJson)
    elseif command == COMMAND_RUSH_JOIN_RESP then
        self:dealRushJoinResp(strJson)
    else
    end
end

function DebaoHall:dealTableJoinResp(strJson)
    if not self.m_bJoinTable then
        return
    end

    local data = require("app.Logic.Datas.TableData.JoinTableMsgData"):new()
    if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
        --[[加入牌桌成功返回]]
        if data.nCode == 10000 or data.nCode == -11010 then
            --[[
            10000  : 成功
            -11010 :已经在牌桌内
            ]]
            if self.m_pCallbackUI then
                self.m_pCallbackUI:enterRoomFromTableId(data.tableId)
            end
        elseif data.nCode == -11070 then
            --[[密码错误]]

            local text = "对不起你输入的密码有误，\n请重新输入"
            local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = false})
            CMOpen(CMToolTipView,cc.Director:getInstance():getRunningScene())
        else

        end
    else
    --[[加入牌桌出错]]
        
    end
    self.m_bJoinTable = false
end
----------------------------------------------------------


function DebaoHall:getDiyTableIdByFid(id)
    DBHttpRequest:getDiyTableIdByFid(function(event) if self.httpResponse then self:httpResponse(event) end
            end,id,true) 
end

return DebaoHall