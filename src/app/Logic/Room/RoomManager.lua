

local myInfo = require("app.Model.Login.MyInfo")
require("app.Logic.Room.RoomCallbackUI")
require("app.Logic.Datas.TableData.TableInfoResp")
require("app.Logic.Datas.TableData.ShowdownMSGData")

-- struct DebaoFastSitInfo
-- {
-- 	 bigBlind
-- 	std:: payType
-- 	std:: tableId
-- 	std:: money
    
-- }

local RoomManager = class("RoomManager", function()
		return display.newNode()
	end)

function RoomManager:ctor()
	
	self.m_isQuickStart=false
	self.m_reconnectCount=0
	self.m_pushServerReconnectCount=0
	self.m_quickSeatNum=-1
	self.m_boolIsRush = false

	TourneyGuideReceiver:sharedInstance():enableReceiver(false)

	self.tcpRequest = TcpCommandRequest:shareInstance()
	self.tcpRequest:addObserver(self)
	if not self.tcpRequest:isConnect() then
		self.tcpRequest:connectSocket(myInfo.data.Global_ProxyIp , myInfo.data.Global_ProxyPort)
	end
	self.m_RoomListDic = {}
	self.m_debaoFastInfo = {}
	self.m_debaoFastInfo.bigBlind = 0.0
	self.m_debaoFastInfo.payType = ""
	self.m_debaoFastInfo.tableId = ""
	self.m_debaoFastInfo.money = ""

   	DBHttpRequest:getActivityData(handler(self, self.httpResponse), "206", "", true)
	self:setNodeEventEnabled(true)
	self.m_schedulerPool = require("app.Tools.SchedulerPool").new()
end

function RoomManager:setEnterClubOrNot(value)
	self.enterClubOrNot = value
end

function RoomManager:onNodeEvent(event)
	if event == "exit" then
		self:onExit()
	end
end

function RoomManager:onExit()
		self.m_pCallbackUI = nil
		TourneyGuideReceiver:sharedInstance():enableReceiver(true)
		self.tcpRequest:removeObserver(self)
		self:clearRoom()
		self.m_RoomListDic = nil
end

function RoomManager:clearRoom()
	for key,room in pairs(self.m_RoomListDic) do
		if room then
			room:stopPrize()
		end
	end
end

function RoomManager:setRoomManagerCallback(callback)
	self.m_pCallbackUI = callback
end

function RoomManager:setIsRush(isRush)
	self.m_IsRush = isRush
end

function RoomManager:getRoom(tableId)
	local room = nil
	if self.m_RoomListDic and self.m_RoomListDic[tableId] then
		room = self.m_RoomListDic[tableId]
	end
	return room
end

function RoomManager:quickStart()
	-- dump("=========")
	if myInfo:getTotalChips() < myInfo.data.brokeMoney then --破产
		self.m_pCallbackUI:quickStartError_Callback(myInfo.data.payamount and QUICKSTART_ERROR or BANKRUPT_ERROR)
	else
		self.m_isQuickStart = true
		if TRUNK_VERSION == DEBAO_TRUNK then
			DBHttpRequest:quickStartNew(function(event) self:httpResponse(event)
            end)
		else
			DBHttpRequest:quickStart(function(event) self:httpResponse(event)
            end)
		end
	end
end

--[[进入房间]]
function RoomManager:enterRoomWithTableId(tableId, passWord)
	self.m_enterRoomTableId = tableId
	local userId = myInfo.data.userId
	if self.tcpRequest:isConnect() then
		if self.m_boolIsRush then
			self.tcpRequest:reqGetTableInfoRush(tableId)
		else
			self.tcpRequest:getTableInfo(tableId,userId)
		end
	else
		if self.tcpRequest:connectSocket(myInfo.data.Global_ProxyIp,
		 myInfo.data.Global_ProxyPort) then
			self.tcpRequest:sendTencentInitPkg(myInfo.data.serverId,myInfo.data.Global_Openkey)
		else
			--[[网络出错]]
			if self.m_pCallbackUI then
				self.m_pCallbackUI:networkException_Callback(NO_NETWORK)
			end
		end
	end
end

function RoomManager:enterRoomWithRushInfo(dataModel)
	-- dump("enterRoomWithRushInfo")
end

--[[进入撮合制房间]]
function RoomManager:enterRoomRandom(params)
	local bigBlind = params[BIG_BLIND]
	local payType = "GOLD"
	local tableId = params[GAME_ADDR].."#1362541720060002CASH188"
	local money = myInfo.data.totalChips
	self.m_debaoFastInfo.bigBlind = bigBlind
	self.m_debaoFastInfo.payType = payType
	self.m_debaoFastInfo.tableId = tableId
	self.m_debaoFastInfo.money = money
	-- dump("=======++++++==========")
	if self.tcpRequest:isConnect() then
		self.tcpRequest:fastSit(myInfo.data.userId,myInfo.data.userName,
            bigBlind,payType,tableId,money)
	end
	self.m_isQuickStart = true
end

--[[主站快速开始后进入房间]]
function RoomManager:quickEnterRoomFastSit(bigBlind, payType, tableId, money)
	self.m_debaoFastInfo.bigBlind = bigBlind
	self.m_debaoFastInfo.payType = payType
	self.m_debaoFastInfo.tableId = tableId
	self.m_debaoFastInfo.money = money
	-- dump("=======++++++==========")
	if self.tcpRequest:isConnect() then
		self.tcpRequest:fastSit(myInfo.data.userId,myInfo.data.userName,
            bigBlind,payType,tableId,money)
	end
end

--加入桌子
function RoomManager:reqMyJoinTable(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyJoinTable()
	end
end
--离开桌子
function RoomManager:reqMyLeaveTable(table_id, isConfirm, leaveType)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyLeaveTable(isConfirm, leaveType)
	end
end
--牌桌信息
function RoomManager:reqMyTableInfo(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyTableInfo()
	end
end
--玩家入座(点击座位坐下按钮)
function RoomManager:reqMySit(table_id,  seat_no)
	local room = self:getRoom(table_id)
	if room then
		room:reqMySit(seat_no)
	end
end

--自己坐下请求买入(购买框买入按钮)
function RoomManager:reqMyBuyChips(tableId, buyChips, isAutoAdd, isAddBuy)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyBuyChips(buyChips,isAutoAdd,isAddBuy)
	end
end
--补充筹码(点击补充筹码按钮)
function RoomManager:reqMyAddBuyChipDiaglog(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyAddBuyChipDiaglog()
	end
end
--快速充值(点击快速充值按钮)
function RoomManager:reqMyQuickCharge(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyQuickCharge()
	end
end

function RoomManager:reqMyRebuyDiaglog(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyRebuyDiaglog()
	end
end

function RoomManager:reqRebuy(tableId, type)
	local room = self:getRoom(tableId)
	if room then
		room:reqRebuy(type)
	end
end

function RoomManager:reqAddOn(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqAddOn()
	end
end

function RoomManager:reqGetUserTicketList()
	DBHttpRequest:getUserTicketList(function(event) self:httpResponse(event)
            end)
end


function RoomManager:reqUploadBoardInfo(tableId, boardInfo, boardName)
	local room = self:getRoom(tableId)
	if room then
		room:reqUploadBoardInfo()
	end
end


function RoomManager:reqMyBigBlind(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyBigBlind()
	end
	return -1.0
end

--玩家站起
function RoomManager:reqMySit_out(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMySit_out()
	end
end
--玩家看牌
function RoomManager:reqMyCheckPoker(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyCheckPoker()
	end
end
--玩家跟牌
function RoomManager:reqMyCallPocker(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyCallPocker()
	end
end
--玩家弃牌
function RoomManager:reqMyFoldPocker(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyFoldPocker()
	end
end
--获取预选操作类型
function RoomManager:reqMyPreOperateOpt(tableId, index)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyPreOperateOpt(index)
	end
end
--不回调直接获取自己的最大手牌类型
function RoomManager:reqMyBestCardsType(tableId, cardType)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyBestCardsType(cardType)
	end
end

function RoomManager:reqGamblingIsCarryOn(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqGamblingIsCarryOn()
	end
	return false
end
--玩家ALLIN
function RoomManager:reqMyAllIn(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyAllIn()
	end
end
--玩家加注
function RoomManager:reqMyRaise(table_id, bet_chips)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyRaise(bet_chips)
	end
end
--取消托管
function RoomManager:reqMyCancel(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyCancel()
	end
end
--玩家选择亮牌
function RoomManager:reqMyShowDown(table_id,  showDownType)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyShowDown(showDownType)
	end
end
--设置自动缴纳盲注类型
function RoomManager:reqMySetAutoBlind(table_id, autoBlindType)
	local room = self:getRoom(table_id)
	if room then
		room:reqMySetAutoBlind(autoBlindType)
	end
end
--加入等候名单
function RoomManager:reqMyJoinQueue(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyJoinQueue()
	end
end
--取消加入等候名单
function RoomManager:reqMyQuitQueue(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyQuitQueue()
	end
end
--继续保持围观
function RoomManager:reqMyKeepTable(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqMyKeepTable()
	end
end
-- 发送聊天信息
function RoomManager:reqMyTableChat(tableId, content, chatType)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyTableChat(content,chatType)
	end
end
--加好友
function RoomManager:reqApplyFriend(tableId,  seatId)
	local room = self:getRoom(tableId)
	if room then
		room:reqApplyFriend(seatId)
	end
end

--同意加为好友
function RoomManager:reqAgreeAddFriend(tableId,  userId,  userName,  isAgree)
	local room = self:getRoom(tableId)
	if room then
		room:reqAgreeAddFriend(userId, userName,isAgree)
	end
end
--退出锦标赛
function RoomManager:reqQuitTourney(tableId)
	self.tcpRequest:quitTourney(tableId, myInfo.data.userId)
end

--[[Rush牌桌]]
function RoomManager:reqBuyChip_Rush(table_id, buyChips)
	local room = self:getRoom(table_id)
	if room then
		room:reqBuyChip_Rush(buyChips)
	end
end
function RoomManager:reqFastFold_Rush(table_id)
	local room = self:getRoom(table_id)
	if room then
		room:reqFastFold_Rush()
	end
end

function RoomManager:addOrRemoveConcern(tableId,  seatNo,  bAdd)
	local room = self:getRoom(tableId)
	if room then
		room:addOrRemoveConcern(seatNo, bAdd, this)
	end
end

function RoomManager:showChatOrEmotion(tableId,  isChat)
	local room = self:getRoom(tableId)
	if room then
		room:showChatOrEmotion(isChat)
	end
end

function RoomManager:reqSingUpPkMatch()
	--默认先用门票报名

	DBHttpRequest:applySngPK(function(event) self:httpResponse(event)
            end, true)
	DBHttpRequest:applySngPK(function(event) self:httpResponse(event)
            end, false)
end

function RoomManager:reqApplyMatch(matchId)
	DBHttpRequest:applyMatch(function(event) self:httpResponse(event)
            end, matchId, true, true)
end

--设置是否是第一圈
function RoomManager:setIsFirstRound(tableId, isFirstRound)
	local room = self:getRoom(tableId)
	if room then
		room:setIsFirstRound(isFirstRound)
	end
end

--[[申请延时]]
function RoomManager:reqMyOperateDelay(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqMyOperateDelay()
	end
end

--[[申请追看公共牌]]
function RoomManager:reqApplyPublicCard(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqApplyPublicCard()
	end
end

--[[申请留座延时]]
function RoomManager:reqLeaveSitProtect(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqLeaveSitProtect()
	end
end

--[[朋友局 申请续时]]
function RoomManager:reqOvertime(tableId)
	local room = self:getRoom(tableId)
	if room then
		room:reqOvertime()
	end
end

--[[http请求返回]]
----------------------------------------------------------
function RoomManager:httpResponse(event)

    local ok = (event.name == "completed")
    local request = event.request
 	if event.name == "failed" then
	   GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
    end
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- pr(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- pr(code)
        return
    end
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
    -- self:dealLoginResp(request:getResponse())
    self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

end

function RoomManager:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_QUICKSTART then
		normal_info_log("POST_COMMAND_QUICKSTART待完善")
	elseif tag == POST_COMMAND_GetActivityData then
		local var = json.decode(content)
		dump(var, "icccccccccccccc a bug in here, then can't sit down")
		local time = var["LIST"][1]["LEFT_TIMES"]+0
		UserDefaultSetting:getInstance():setFreeGoldTimes(time)
	elseif tag == POST_COMMAND_QUICKSTART_NEW then
		local data = require("app.Logic.Datas.Lobby.QuickStartNew"):new()
		if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
			-- dump(data.code)
			if data.code=="" then
				-- dump("=================")
				local tableId = data.gameAddr.."#1362541720060002CASH188"
				self.m_quickSeatNum = -1
				self:quickEnterRoomFastSit(data.bigBlind,data.payType,tableId,data.money)
			elseif data.code == -1 or data.code == "-1" then
				if self.m_pCallbackUI then
					--[[破产提示]]
					self.m_pCallbackUI:quickStartError_Callback(myInfo.data.payamount>0 and QUICKSTART_ERROR or BANKRUPT_ERROR)
				end
			else
				if self.m_pCallbackUI then
					--[[快速找位失败]]
					self.m_pCallbackUI:networkException_Callback(QUICKSTART_ERROR)
				end
			end
		else
			if self.m_pCallbackUI then
				--[[快速找位失败]]
				self.m_pCallbackUI:networkException_Callback(QUICKSTART_ERROR)
			end
		end
	end
end
----------------------------------------------------------
function RoomManager:handleBoardInfo(command, strJson)
	local dataStr = strJson
	if type(strJson) == "table" then
		dataStr = json.encode(strJson)
	end
	if type(dataStr)~="string" then
		dataStr = ""
	end
	if command == COMMAND_HAND_START_MSG then
        BoardInfo:getInstance().commandInfo = nil
        BoardInfo:getInstance().commandInfo = {}
        BoardInfo:getInstance().postCommandString = nil
        BoardInfo:getInstance().postCommandString = ""
        BoardInfo:getInstance().uploadFlag=1
    elseif command == COMMAND_HAND_FINISH_MSG then
		if BoardInfo:getInstance().clearFlag==1 then
			BoardInfo:getInstance().clearFlag=0
			local room = require("app.Logic.Room.BaseRoom"):new()
			room:initData(BoardInfo:getInstance().seatCount)
			room:reqUploadBoardInfo()
		end
	end
	
	if BoardInfo:getInstance().uploadFlag==1 then
		if string.len(dataStr)>0 and command == COMMAND_HAND_START_MSG then
			BoardInfo:getInstance().tableInfo = clone(dataStr)
			-- dump(dataStr)
		elseif string.len(dataStr)>0 and command~=COMMAND_PUSH_MSG and command~=PING 
			and command~=COMMAND_WAIT_FOR_MSG and command~=COMMAND_PING_RESP then
			local saveStr = ""
			saveStr = saveStr..command
			local str = ""
			str = "\"17\":\""..saveStr.."\","
			local tmp = "{"..str..string.sub(dataStr, 2)
			BoardInfo:getInstance().commandInfo[#BoardInfo:getInstance().commandInfo+1] = tmp
		end
	end
end

--[[tcp请求返回]]
----------------------------------------------------------
function RoomManager:OnTcpMessage(command, strJson)
	--[[正常进房间的玩牌逻辑处理]]
	
	-- normal_info_log("RoomManager:OnTcpMessage收到socket消息")
	-- print(string.format("0X%08X",""..command))
	self:handleBoardInfo(command, strJson)

	if command == COMMAND_TABLE_WAIT_MSG then

		self:dealHandsByHands(strJson)

	elseif command == COMMAND_TABLE_JOIN_RESP then

	elseif command == COMMAND_TABLE_INFO_RESP then
		
		self:dealTableInfoResp(strJson)

	elseif command == COMMAND_TABLE_LEAVE_RESP then

		self:dealTableLeaveResp(strJson)

	elseif command == COMMAND_CANCEL_TRUSTEESHIP_MSG then

		self:dealCancelTrusteeShipResp(strJson)
	
	elseif command == COMMAND_SHOWDOWN_REQ then

		self:dealShowDownResp(strJson)
	
	elseif command == COMMAND_POCKET_CARD then

		self:dealPocketCardResp(strJson)	

	elseif command == COMMAND_SIT_MSG then

		self:dealSitResp(strJson)	

	elseif command == COMMAND_SIT_OUT_MSG then

		self:dealSitOutResp(strJson)	--[[离桌消息不处理  直接按离桌就离开]]

	elseif command == COMMAND_CALL_MSG then

		self:dealCallResp(strJson)
	
	elseif command == COMMAND_RAISE_MSG then

		self:dealRaiseResp(strJson)
	
	elseif command == COMMAND_FOLD_MSG then

		self:dealFoldResp(strJson)
	
	elseif command == COMMAND_CHECK_MSG then

		self:dealCheckResp(strJson)
	
	elseif command == COMMAND_ALL_IN_MSG then

		self:dealAllInResp(strJson)

	elseif command == COMMAND_WAIT_FOR_MSG then

		self:dealWaitForMsgResp(strJson)
	
	elseif command == COMMAND_HAND_START_MSG then

		self:dealHandStartResp(strJson)
	
	elseif command == COMMAND_FLOP_CARD_MSG then

		self:dealFlopCardsResp(strJson)
	
	elseif command == COMMAND_TURN_CARD_MSG then

		self:dealTurnCardResp(strJson)
	
	elseif command == COMMAND_RIVER_CARD_MSG then

		self:dealRiverCardResp(strJson)
	
	elseif command == COMMAND_SHOWDOWN_MSG then

		self:dealShowDownMsgResp(strJson)	

	elseif command == COMMAND_POT_MSG then

		self:dealPotResp(strJson)
	
	elseif command == COMMAND_PRIZE_MSG then

		self:dealPrizeMsgResp(strJson)
	
	elseif command == COMMAND_TABLE_CHAT_MSG then

		self:dealChatMsgResp(strJson)	

	elseif command == COMMAND_TABLE_BLIND_MSG then

		self:dealTableBlindResp(strJson)	

	elseif command == COMMAND_TABLE_ANTE_MSG then

		self:dealTableAnteResp(strJson)
	
	elseif command == COMMAND_TABLE_BUTTON_MSG then

		self:dealTableDealerResp(strJson)
	
	elseif command == COMMAND_TRUSTEESHIP_MSG then

		

	elseif command == COMMAND_PLAYER_TIMEOUT_MSG then

		self:dealPlayerTimeoutResp(strJson)
	
	elseif command == COMMAND_TABLE_RAKE_BF_FLOP_MSG then

		self:dealTableRakeBfFlopResp(strJson)
	
	elseif command == COMMAND_BUY_CHIPS_MSG then

		self:dealBuyChipsResp(strJson)	

	elseif command == COMMAND_BUY_RESP then--[[腾讯版买入]]

		self:dealBuyChipsTcpResp(strJson)

	elseif command == COMMAND_NEW_BUY_REQ then--[[腾讯版新买入]]

		self:dealBuyChipsTcpResp(strJson)
	
	elseif command == COMMAND_ELIMINATED_MSG then

		self:dealOutCompetitionByEliminationResp(strJson)
	
	elseif command == COMMAND_HAND_FINISH_MSG then --[[结束手牌]]

		self:dealHandFinishResp(strJson)
	
	elseif command == COMMAND_TABLE_GUIDE then--[[通知进入锦标赛]]
		-- dump("通知进入锦标赛")

		self:dealTableGuideResp(strJson)
	
	elseif command == COMMAND_TOURNEY_QUIT_RESP then--[[退出锦标赛响应]]

		self:dealTableLeaveResp(strJson)
	
	--[[断线重连处理]]
	elseif command == COMMAND_SOCKET_CONNECTION_BREAK then

		self:dealNetBreakdown(strJson)
	
	elseif command == COMMAND_CONNECT_RESP then

		self:dealConnectSuccessResp(strJson)

	elseif command == COMMAND_PUSH_MSG then

		self:dealPushMessage(strJson)	

	elseif command == COMMAND_FAST_SIT_RESP then

		self:dealFastSitResp(strJson)	

	elseif command == COMMOND_PUSH_CONNECTION_BREAK then

		self:dealPushServerBreakdown(strJson)	

	elseif command == COMMAND_PASSIVE_REBUY_REQ then

		self:dealPassiveRebuyReq(strJson)

	elseif command == COMMAND_REBUY_RESP then

		self:dealRebuyResp(strJson)	

	elseif command == COMMAND_REMIND_USER_TABLE_WILL_DESTROY then

		self:dealRemindUserTableWillDestroy(strJson)	

	elseif command == COMMAND_REMIND_USER_TABLE_CARD_DESTROY then

		self:dealRemindUserTableCardDestroy(strJson)	

	elseif command == COMMAND_TABLE_DESTROY_MSG then

		self:dealTableDestroy(strJson)

	elseif command == COMMAND_PKOUT_MESSAGE then

		self:dealPkOutMessage(strJson)
	
	--[[Rush桌消息]]
	elseif command == COMMAND_RUSH_JOIN_RESP then

		self:dealMyInfo_Rush(strJson)
	
	elseif command == COMMAND_RUSH_BUY_RESP then

		self:dealPreBuyChip_Rush(strJson)
	
	elseif command == COMMAND_RUSH_PRE_BUY_RESP then

		self:dealPreBuyChip_Rush(strJson)

	elseif command == COMMAND_RUSH_FOLD_RESP then

		self:dealFastFold_Rush(strJson)

	elseif command == COMMAND_RUSH_LEAVE_RESP then

		self:dealTableLeaveResp(strJson)

	elseif command == COMMAND_RUSH_CANCEL_TRUSTEE_RESP then

		self:dealCancelTrustee_Rush(strJson)
	
	elseif command == COMMAND_RUSH_GET_TABLE_INFO_RESP then

		self:dealGetTableInfo_Rush(strJson)
	
	elseif command == COMMAND_RUSH_TRUSTEE_TIME_OUT then

		self:dealForceLeaveRoom_Rush(strJson)

	elseif command == COMMAND_RUSH_BUY_CHIPS_TIME_OUT then

		self:dealForceLeaveRoom_Rush(strJson)
	
	elseif command == COMMAND_TABLE_ADDON_MSG then

		--[[addon弹窗]]
		-- normal_info_log("=========ADDON消息========")
		self:dealAddOn(strJson)
	
	elseif command == COMMAND_ADDON_FINISH_RESP then

		-- normal_info_log("=======ADDONRESP消息========\n%s\n===========================",json.encode(strJson))
		-- self:dealGetMyRushResp(strJson)

	elseif command == COMMAND_PRE_BUY_CHIPS_MSG then

		-- normal_info_log("==========等候AddOn===============")
		self:dealTableWaitAddOn(strJson)

	elseif  command == COMMAND_PUNISH_BLIND_TO_BET then
		-- print("COMMAND_PUNISH_BLIND_TO_BET")
		-- dump(json.decode(strJson))
	elseif  command == COMMAND_PUNISH_BLIND_NO_BET then
		-- print("COMMAND_PUNISH_BLIND_NO_BET")
		-- dump(json.decode(strJson))
	elseif command == APPLY_OPERATION_DELAY_RESP then
		
	elseif command == APPLY_PUBLIC_CARD_RESP then
		self:dealApplyPublicCardResp(strJson)
	elseif command == USER_OPERATE_DELAY_MSG then
		self:dealUserOperateDelayResp(strJson)
	elseif command == TRUSTEESHIP_PROTECT_RESP then
		self:dealTrusteeshipProtectResp(strJson)
	elseif command == COMMAND_APPLY_ROOM_DELAY_RESP then
		self:dealApplyRoomDelayResp(strJson)
	elseif command == COMMAND_ROOM_DELAY_BRO then
		self:dealApplyRoomDelayBroadcast(strJson)
	end
end

function RoomManager:dealApplyRoomDelayResp(strJson)
	local data = require("app.Logic.Datas.TableData.RoomDelayData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealApplyRoomDelayResp(data)
		end
	end
end

function RoomManager:dealApplyRoomDelayBroadcast(strJson)
	local data = require("app.Logic.Datas.TableData.RoomDelayBroData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealApplyRoomDelayBroadcast(data)
		end
	end
end

function RoomManager:dealApplyPublicCardResp(strJson)
    local data = require("app.Logic.Datas.TableData.ApplyPublicCard"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealApplyPublicCardResp(data)
		end
	end
end

function RoomManager:dealUserOperateDelayResp(strJson)
    local data = require("app.Logic.Datas.TableData.UserOperateDelay"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealUserOperateDelayResp(data)
		end
	end
end

function RoomManager:dealTrusteeshipProtectResp(strJson)
    local data = require("app.Logic.Datas.TableData.TrusteeshipProtect"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealTrusteeshipProtectResp(data)
		end
	end
end

function RoomManager:dealHandsByHands(strJson)
    local data = require("app.Logic.Datas.TableData.HandsByHandsData"):new()

    if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
        if data.isRebuy=="HBH" then
            self.m_pCallbackUI:showStartNextHand(data.tableId, "比赛目前处于同时发牌状态", true)
        elseif data.isRebuy == "DAM" then
            self.m_pCallbackUI:showStartNextHand(data.tableId, "牌局尚未开始，请稍等", true)
        end
    end
end

function RoomManager:dealTableInfoResp(strJson)
	-- normal_info_log("RoomManager:dealTableInfoResp")
	
	local data = TableInfoResp:new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS and data.m_code == 10000 then
		self.m_enterRoomTableId = data.currentTableInfo.tableId
		if self.m_enterRoomTableId and string.len(self.m_enterRoomTableId)<=0 then
			return
		end
		if self.m_pCallbackUI then
			local isRush = false
			if data.currentTableInfo.tableType == "SITANDGO" and data.currentTableInfo.playType=="SNG_PK" then
				isRush = true
			end
			self.m_pCallbackUI:createRoomView_Callback(self.m_enterRoomTableId,
                data.currentTableInfo.seatNum,self.m_isQuickStart,isRush,nil, data.currentTableInfo.tableOwner)--创建房间	
		end
		-- data.currentTableInfo.tableType = "SITANDGO"
		-- dump(data.currentTableInfo.tableType)

		-- 断线重连状态，清理房间资源，重新创建
		if self.m_RoomListDic[self.m_enterRoomTableId] then
			self.m_RoomListDic[self.m_enterRoomTableId]:removeFromParent()
			self.m_RoomListDic[self.m_enterRoomTableId] = nil
		end

		if data.currentTableInfo.tableType == "CASH" then
			local room = require("app.Logic.Room.CashRoom"):create(data.currentTableInfo.seatNum)
			room:addTo(self)
			room.m_isQuickStart = self.m_isQuickStart
			room:setRoomCallback(self.m_pCallbackUI)
			room:setEnterClubOrNot(self.enterClubOrNot)
			room:dealTableInfoResp(data)
			self.m_RoomListDic[self.m_enterRoomTableId] = room
			if self.m_isQuickStart and self.m_quickSeatNum>=0 then --[[快速开始坐下]]
				room:reqMySit(self.m_quickSeatNum)
			end
			room:startPushServer()--[[启动推送服务器]]
		elseif data.currentTableInfo.tableType == "SITANDGO" then
			local room = require("app.Logic.Room.SngRoom"):create(data.currentTableInfo.seatNum)
			room:addTo(self)
			room.m_isQuickStart = false
			room:setRoomCallback(self.m_pCallbackUI)
			room:dealTableInfoResp(data)
			self.m_RoomListDic[self.m_enterRoomTableId] = room
		elseif data.currentTableInfo.tableType == "TOURNEY" then
			local room = nil
			if not data.currentTableInfo.isRebuy then
				room = require("app.Logic.Room.TourneyRoom"):create(data.currentTableInfo.seatNum)
			else
				room = require("app.Logic.Room.RebuyRoom"):create(data.currentTableInfo.seatNum)
			end
			room:addTo(self)
			room.m_isQuickStart = false
			room:setRoomCallback(self.m_pCallbackUI)
			room:dealTableInfoResp(data)
			self.m_RoomListDic[self.m_enterRoomTableId] = room
		end

		if self.m_pCallbackUI then
			self.m_pCallbackUI:showRoomLoadingView(false)--显示房间
		end
	elseif data and data.m_code == -12001 then
		if self.m_pCallbackUI then
			self.m_pCallbackUI:networkException_Callback(QUICKSTART_ERROR)
		end
	else
		if self.m_pCallbackUI then
			self.m_pCallbackUI:networkException_Callback(TABLEID_NOEXIST)
		end
	end
	self.m_isQuickStart = false
end

function RoomManager:dealWaitForMsgResp(strJson)
	local data = require("app.Logic.Datas.TableData.WaitForMSGData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealWaitForMsgResp(data)
		end
	end
end

function RoomManager:dealCancelTrusteeShipResp(strJson)
	local data = require("app.Logic.Datas.TableData.CancelTrusteeshipData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealCancelTrusteeShipResp(data)
		end
	end
end

function RoomManager:dealShowDownResp(strJson)
	local data = require("app.Logic.Datas.TableData.ShowdownRespData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealShowDownResp(data)
		end
	end
end

function RoomManager:dealPocketCardResp(strJson)
	local data = require("app.Logic.Datas.TableData.PocketCardData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealPocketCardResp(data)
		end
	end
end

function RoomManager:dealSitResp(strJson)
	local data = require("app.Logic.Datas.TableData.SitMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealSitResp(data)
		end
	end
end

function RoomManager:dealSitOutResp(strJson)
	-- normal_info_log("RoomManager:dealSitOutResp")
	local data = require("app.Logic.Datas.TableData.SitOutMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealSitOutResp(data)
		end
	end
end

function RoomManager:dealCallResp(strJson)
	local data = require("app.Logic.Datas.TableData.CallMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealCallResp(data)
		end
	end
end

function RoomManager:dealRaiseResp(strJson)
	local data = require("app.Logic.Datas.TableData.RaiseMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealRaiseResp(data)
		end
	end
end

function RoomManager:dealFoldResp(strJson)
	local data = require("app.Logic.Datas.TableData.FoldMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealFoldResp(data)
		end
	end
end

function RoomManager:dealCheckResp(strJson)
	local data = require("app.Logic.Datas.TableData.CheckMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealCheckResp(data)
		end
	end
end

function RoomManager:dealAllInResp(strJson)
	local data = require("app.Logic.Datas.TableData.AllinMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealAllInResp(data)
		end
	end
end

function RoomManager:dealHandStartResp(strJson)
	local data = require("app.Logic.Datas.TableData.TableInfoResp"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.tableId)
		if room then
			room:dealHandStartResp(data)
		end
	end
end

function RoomManager:dealFlopCardsResp(strJson)
	local data = require("app.Logic.Datas.TableData.FlopCardMSGData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealFlopCardsResp(data)
		end
	end
end

function RoomManager:dealTurnCardResp(strJson)
	local data = require("app.Logic.Datas.TableData.TurnCardData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealTurnCardResp(data)
		end
	end
end

function RoomManager:dealRiverCardResp(strJson)
	local data = require("app.Logic.Datas.TableData.RiverCardMSGData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealRiverCardResp(data)
		end
	end
end

function RoomManager:dealShowDownMsgResp(strJson)
	local data = ShowdownMSGData:new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealShowDownMsgResp(data)
		end
	end
end

function RoomManager:dealPotResp(strJson)
	local data = require("app.Logic.Datas.TableData.PotMSGData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealPotResp(data)
		end
	end
end

function RoomManager:dealPrizeMsgResp(strJson)
	local data = require("app.Logic.Datas.TableData.PrizeMSGData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealPrizeMsgResp(data)
		end
	end
end

function RoomManager:dealChatMsgResp(strJson)
	local data = require("app.Logic.Datas.TableData.TableChatMessage"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(self.m_enterRoomTableId)
		if room then
			room:dealChatMsgResp(data)
		end
	end
end

function RoomManager:dealTableBlindResp(strJson)
	local data = require("app.Logic.Datas.TableData.TableBlindMsgInfo"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.tableId)
		if room then
			room:dealTableBlindResp(data)
		end
	end
end

function RoomManager:dealTableAnteResp(strJson)
	local data = require("app.Logic.Datas.TableData.TableAnteMSGData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealTableAnteResp(data)
		end
	end
end

function RoomManager:dealTableDealerResp(strJson)
	local data = require("app.Logic.Datas.TableData.TableButtonMSGData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealTableDealerResp(data)
		end
	end
end

function RoomManager:dealPlayerTimeoutResp(strJson)
	local data = require("app.Logic.Datas.TableData.PlayerTimeoutMSGData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealPlayerTimeoutResp(data)
		end
	end
end

function RoomManager:dealTableRakeBfFlopResp(strJson)
	local data = require("app.Logic.Datas.TableData.TableRakeBfFlopMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealTableRakeBfFlopResp(data)
		end
	end
end

function RoomManager:dealBuyChipsResp(strJson)
	local data = require("app.Logic.Datas.TableData.BuyChipsMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealBuyChipsResp(data)
		end
	end
end

function RoomManager:dealBuyChipsTcpResp(strJson)
	local data = require("app.Logic.Datas.TableData.BuyChipsTcpResp"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealBuyChipsTcpResp(data)
		end
	end
end

function RoomManager:dealOutCompetitionByEliminationResp(strJson)
	local data = require("app.Logic.Datas.TableData.EliminatedData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		-- dump(data.tableId)
		local room = self:getRoom(data.tableId)
		if room then
			room:dealOutCompetitionByEliminationResp(data)
		end
	end
end

function RoomManager:dealHandFinishResp(strJson)
	local data = require("app.Logic.Datas.TableData.HandFinishMsgData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealHandFinishResp(data)
		end
	end
end

function RoomManager:dealTableGuideResp(strJson)
	--[[此处需要区分是初次引导进入牌桌还是锦标赛并桌]]
	-- dump("====RoomManager:dealTableGuideResp====")
	if not self.m_pCallbackUI then 
		return
	end
	local data = require("app.Logic.Datas.TableData.TableGuide"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
	-- dump("====BIZ_PARS_JSON_SUCCESS====")
		--此处判断规则依赖服务器实现比赛和比赛间无关联，每场比赛开始时fromtableid和tableid都是要进入比赛的id
		--逻辑上需要优化为根据matchid判断，
		self.m_matchId = data.matchId
		
		local room = self:getRoom(data.fromTableId)
		if room then
			room:stopPrize()
			--存在牌桌说明正在锦标赛中 此时是并桌处理
			if self.m_pCallbackUI then
				self.m_pCallbackUI:MergerTourneyRoom(data.fromTableId,data.tableId,data.matchName)
			end
		else
			if self.m_pCallbackUI then
				self.m_pCallbackUI:showEnterTourneyRoomPrompt(data.fromTableId,data.tableId,data.matchName)
			end
		end
	end
	data = nil
end

function RoomManager:dealNetBreakdown(strJson)

	-- normal_info_log("socket connect break!!!!!")
	-- self.tcpRequest:closeConnect()
 --    self.m_reconnectCount = self.m_reconnectCount+1
	-- if self.m_reconnectCount>3 then
	-- 	if self.m_pCallbackUI then
	-- 		self.m_pCallbackUI:networkException_Callback(NO_NETWORK)
	-- 	end
	-- 	return
	-- end
	local room = self:getRoom(self.m_enterRoomTableId)
	if room then
		room:stopPrize()
    end

	-- DBHttpRequest:getServerPort(handler(self, self.httpResponse),myInfo:getServerPort(),currentVersion())--请求更新serverPort
end

function RoomManager:dealConnectSuccessResp(strJson)
	if not self.m_pCallbackUI then
		return
	end
    
	local data = require("app.Logic.Datas.Lobby.ConnectRespData"):new()
	if data:parseJson(strJson)==BIZ_PARS_JSON_FAILED then
		self.m_pCallbackUI:networkException_Callback(DATA_ERROR)
		self.tcpRequest:closeConnect()
		data = nil
		return
	end
	local code = data.m_code+0
	data = nil
    
	if code == 10000 then
		self.tcpRequest:startPing()
		self.m_reconnectCount = 0
		if not self.m_enterRoomTableId then
			self:quickEnterRoomFastSit(self.m_debaoFastInfo.bigBlind,self.m_debaoFastInfo.payType,
				self.m_debaoFastInfo.tableId,self.m_debaoFastInfo.money)
		else
			self:enterRoomWithTableId(self.m_enterRoomTableId) --登录成功正在进入主界面
        end
	elseif code == -10004 then
		self.m_pCallbackUI:networkException_Callback(ACCOUNT_EXCEPTION) --进入房间失败，退出到登录页面//您的帐号登录异常，请重新登录
		if self.tcpRequest:isConnect() then
			self.tcpRequest:closeConnect()
		end
	else
		self.m_pCallbackUI:networkException_Callback(OTHER_ERROR)--进入房间失败，退出到大厅
		if self.tcpRequest:isConnect() then
			self.tcpRequest:closeConnect()
		end
	end
end

function RoomManager:dealPushMessage(strJson)
end

function RoomManager:dealFastSitResp(strJson)
	self:dealTableInfoResp(strJson)
end

function RoomManager:dealPushServerBreakdown(strJson)
	local room = self:getRoom(self.m_enterRoomTableId)
	if room then
		room:closePushServer() --清理前一次推送服务器的连接
		self.m_pushServerReconnectCount = self.m_pushServerReconnectCount+1
		if self.m_pushServerReconnectCount<4 then
			room:startPushServer() --重新连接推送服务器
		end
	end
end

function RoomManager:dealPassiveRebuyReq(strJson)
	local data = require("app.Logic.Datas.TableData.PassiveRebuyReq"):new()
	if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.m_tableId)
		if room then
			room:dealPassiveRebuyReq(data)
		end
	end
	data = nil
end

function RoomManager:dealRebuyResp(strJson)
	local data = require("app.Logic.Datas.TableData.RebuyInfo"):new()
	if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.tableId)
		if room then
			room:dealRebuyResp(data)
		end
	end
	data = nil
end

function RoomManager:dealRemindUserTableWillDestroy(strJson)
	local data = require("app.Logic.Datas.TableData.RemindUserTableDestroy"):new()
	if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
		if data.nCode > 0 then
			local room = self:getRoom(data.tableId)

			if room then
				data.message = Lang_Remind_User_Table_Will_Destroy
				room:dealRemindUserTableDestroy(data)
			end
		end
	end
	data = nil
end

function RoomManager:dealRemindUserTableCardDestroy(strJson)
	local data = require("app.Logic.Datas.TableData.RemindUserTableDestroy"):new()
	if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
		if data.nCode > 0 then
			local room = self:getRoom(data.tableId)

			if room then
				data.message = Lang_Remind_User_Table_Card_Destroy
				room:dealRemindUserTableDestroy(data)
			end
		end
	end
	data = nil
end

function RoomManager:dealTableDestroy(strJson)
	local data = require("app.Logic.Datas.TableData.TableDestroyMsg"):new()
	if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
		local room = self:getRoom(data.tableId)
		if room then
			room:dealTableDestroy(data)
		end
	end
	data = nil
end
function RoomManager:dealPkOutMessage(strJson)
end
function RoomManager:dealMyInfo_Rush(strJson)
end
function RoomManager:dealPreBuyChip_Rush(strJson)
end
function RoomManager:dealFastFold_Rush(strJson)
end

function RoomManager:dealTableLeaveResp(strJson)
	
	local data = require("app.Logic.Datas.TableData.TableLeaveRespData"):new()
	if(data:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS) then
		local room = self:getRoom(data.m_tableId)
		if(room) then
			room:dealTableLeaveResp(data)
		end
	end
end

function RoomManager:dealCancelTrustee_Rush(strJson)
end
function RoomManager:dealGetTableInfo_Rush(strJson)
end
function RoomManager:dealForceLeaveRoom_Rush(strJson)
end
function RoomManager:dealAddOn(strJson)
	local data = require("app.Logic.Datas.TableData.AddOnInfo"):new()
    if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
        self.m_pCallbackUI:showStartNextHand(data.tableId, "正在进行最终加码，请耐心等待！", false)
        local room = self:getRoom(data.tableId)
        if room then
            room:reqMyAddOnDiaglog(data.addOnTime)
        end
    end
end

function RoomManager:dealAddOnResp(strJson)
	local data = require("app.Logic.Datas.TableData.AddOnInfo"):new()
    if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
        if data.code == 10000 then
            self.m_pCallbackUI:showStartNextHand(data.tableId, "最终加码成功，祝您游戏愉快！", true)
        elseif data.code == -13011 then
            self.m_pCallbackUI:showStartNextHand(data.tableId, "加码时段已结束", true)
        elseif data.code == -11052 then
            self.m_pCallbackUI:showStartNextHand(data.tableId, "请勿重复加码", true)
        elseif data.code == -4 then
            self.m_pCallbackUI:showStartNextHand(data.tableId, "玩家牌桌上筹码不符合加码购买条件", true)
        elseif data.code == -11051 then
            self.m_pCallbackUI:showStartNextHand(data.tableId, "重购失败！玩家达到最大加码次数", true)
        elseif data.code == -13001 then
            self.m_pCallbackUI:showStartNextHand(data.tableId, "用户余额不足", true)
        else
            self.m_pCallbackUI:showStartNextHand(data.tableId, "系统异常", true)
        end
    end
end

function RoomManager:dealTableWaitAddOn(strJson)
	local data = require("app.Logic.Datas.TableData.AddOnInfo"):new()
    if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
       	self.m_pCallbackUI:showStartNextHand(data.tableId, "所有牌桌在此局结束后将开始最终加码", true)
    end
end

function RoomManager:registerRongYun(callback)
	if not GIsConnectRCToken then
		self.m_registerRongYunHandle = self.m_schedulerPool:delayCall(handler(self, function() 
	        HttpClient:getRCToken({
	            function(tableData,tag)
	                if tableData.code == 200 then
	                    local rcData = {["AppKey"]= "8luwapkvuz8jl",["Token"]= tableData.token,
	                    ["UserId"]=myInfo.data.userId,["Username"]=myInfo.data.userName,["UserPotraitUri"]=myInfo.data.userPotraitUri}
	                    QManagerPlatform:initRongCloud(rcData)
	                    GIsConnectRCToken = true
	                end
	                callback()
	            end, 
	            function(code, tag)
	            	callback()
	            end},
	            myInfo.data.userId,myInfo.data.userName,myInfo.data.userPotraitUri)
		end),0.05)
	else
		callback()
	end
end

function RoomManager:onCleanup()
	self.m_schedulerPool:clearById(self.m_registerRongYunHandle) 
	self.m_registerRongYunHandle = nil
end

----------------------------------------------------------

return RoomManager