local scheduler = require("framework.scheduler")
local RoomView = require("app.GUI.RoomView")
local GameLayerManager  = require("app.GUI.GameLayerManager")
local PLAY_DELAY_TIME = 1

global_replay_view = nil
local ReplayView = class("ReplayView", function()
	return RoomView:new()
end)

function ReplayView:create(fid)
	local view = ReplayView:new()
	view:resetRoomView("",9)
	view:initReplayView()
	view:setFid(fid)

	view.m_backBtn:setButtonImage("normal", "back.png")
	view.m_backBtn:setButtonImage("pressed", "back1.png")
	view.m_backBtn:setButtonImage("disabled", "back1.png")
	return view
end

function ReplayView:setBackView(view)
	self.mBackView = view
end

function ReplayView:setFid(fid)
	self.m_fid = fid
end

function ReplayView:ctor()
	self.sBlind_NO = 0
	self.bBlind_NO = 0
	self.playerSeat = 0
	self.m_isReplay = false

	self.m_replayButton = cc.ui.UIPushButton.new({normal=s_room_replayN,pressed=s_room_replayS,disabled=s_room_replayS})
		:align(display.RIGHT_BOTTOM, display.width-20, 20)
		:addTo(self, kZOperateBoard)
		:onButtonClicked(handler(self,self.replayClick))
	self.m_replayButton:setVisible(false)

	self.m_shareButton = cc.ui.UIPushButton.new({normal=s_room_shareN,pressed=s_room_shareS,disabled=s_room_shareS})
		:align(display.RIGHT_UP, display.width-80, display.height-40)
		:addTo(self, kZOperateBoard)
		:onButtonClicked(handler(self,self.shareToWechat))

	self:setNodeEventEnabled(true)
end

function ReplayView:onNodeEvent(event)
    if event == "enter" then
    	self:onEnter(event)
    elseif event == "exit" then
    	self:exit(event)
    end
end

function ReplayView:play()
	self.m_uploadBoardInfoButton:setVisible(false)
    if self.m_chatBtn then
   		self.m_chatBtn:setVisible(false)
    end
    if self.m_picBtn then
   		self.m_picBtn:setVisible(false)
    end
    if self.m_chatAndPicBtn then
   		self.m_chatAndPicBtn:setVisible(false)
    end
	schId_beginHR = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.beginHTTPRequest), 1, false)
end

function ReplayView:beginHTTPRequest(dt)
	DBHttpRequest:getBoardInfo(handler(self, self.httpResponse), self.m_fid)

	if schId_beginHR then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schId_beginHR)
		schId_beginHR = nil
	end
end

function ReplayView:startPlay()
	io.writefile(device.writablePath.."debug.txt", json.encode(self.m_boardInfo.replayCommandInfo))
	--    入座
	self.m_playList = {}
    
	self:clearRoomViewAllElement_Callback()
    
	self.playerSeat = self.m_boardInfo.replayTableInfo.playerSeatNO

    local seatList = {0,1,2,3,4,5,6,7,8}
	local listSize = #seatList

	for i=1,#self.m_boardInfo.playerInfoList do
		local isMyself = false
		if self.m_boardInfo.playerInfoList[i].userID==MyInfo.data.userId then
			-- self.m_boardInfo.playerInfoList[i].userID = 0
			self.m_myInfoIndex = i
			isMyself = true
		end
		self:playerSit_Callback(isMyself,self.m_boardInfo.playerInfoList[i].seatNO,self.m_boardInfo.playerInfoList[i].userName,"","",
			self.m_boardInfo.playerInfoList[i].userID,0,false,true)

		for j=1,listSize do
			if seatList[j]==self.m_boardInfo.playerInfoList[i].seatNO then
				table.remove(seatList, j)
				listSize=listSize-1
				break
			end
		end
		self:playerChipsUpdate_Callback(self.m_boardInfo.playerInfoList[i].seatNO,0,0,self.m_boardInfo.playerInfoList[i].userChips)
		if (self.m_boardInfo.playerInfoList[i].isTrustee) then 
			self:playerTimeout(false,self.m_boardInfo.playerInfoList[i].seatNO)
		end
	end	

	if not self.m_isReplay then
		for i=1,listSize do
			--        隐藏座位
			--        self:setPlayerClickable(i,false)
			local player = self:findPlayerBySeatId(seatList[i])
			player:setVisiable(false)
			player:setClickable(false)
		end

		self:rotateAllSeats_Callback(self.m_boardInfo.playerInfoList[self.m_myInfoIndex].seatNO)
	end
    	
    local mf = "设置庄家位"
	--    开始读指令
	for i=1,#self.m_boardInfo.replayCommandInfo do
		-- if true then break end
		if self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_TABLE_BUTTON_MSG then
			self:updateDealerPos_Callback(self.m_boardInfo.replayCommandInfo[i][BUTTON_NO_REPLAY],false)
			self.sBlind_NO = self.m_boardInfo.replayCommandInfo[i][SBLIND_NO_REPLAY]
			self.bBlind_NO = self.m_boardInfo.replayCommandInfo[i][BBLIND_NO_REPLAY]
            
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_TABLE_ANTE_MSG then
			--      前注
			for k=1,#self.m_boardInfo.replayCommandInfo[i][ANTE_INFO_REPLAY] do
				local chipsInfo = {}
				local seatNO = self.m_boardInfo.replayCommandInfo[i][ANTE_INFO_REPLAY][k][SEAT_NO_REPLAY]..""
				local roundChips = "0"
				local userChips = self.m_boardInfo.replayCommandInfo[i][ANTE_INFO_REPLAY][k][USER_CHIPS_REPLAY]..""
				local seat_NO = seatNO..""
				chipsInfo[#chipsInfo+1]=seat_NO
                
				local round_Chips = roundChips
				chipsInfo[#chipsInfo+1]=round_Chips
                
				local user_Chips = userChips
				chipsInfo[#chipsInfo+1]=user_Chips
                
				self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME/3), cc.CallFunc:create(handler(self, self.stepPlayerChips), chipsInfo))
			end
			local potNum = "0"
			local index = "0"
			local potChips = self.m_boardInfo.replayCommandInfo[i][TOTAL_POT_REPLAY]..""
			local publicPots = {}
            
			local potNumStr = potNum..""
			publicPots[#publicPots+1]=potNumStr
            
			local indexStr = index..""
			publicPots[#publicPots+1]=indexStr
            
			local potChipsStr = potChips..""
			publicPots[#publicPots+1]=potChipsStr
            
			self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepPublicPots), publicPots))
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_POT_MSG then
			--            根据POT_INFO_REPLAY划分几个奖池
			for j=1,#self.m_boardInfo.replayCommandInfo[i][POT_INFO_REPLAY] do
				local potNum = "0"
				local index = ""..(j-1)
				local potChips = self.m_boardInfo.replayCommandInfo[i][POT_INFO_REPLAY][j]..""
				local publicPots = {}
                
				local potNumStr = potNum
				publicPots[#publicPots+1] = potNumStr
                
				local indexStr = index
				publicPots[#publicPots+1] = indexStr
                
				local potChipsStr = potChips
				publicPots[#publicPots+1] = potChipsStr

				self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME/3), cc.CallFunc:create(handler(self, self.stepPublicPots), publicPots))
				
			end
            
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_TABLE_BLIND_MSG then
		
			for l=1,#self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY] do
                
				local roundChips=0
				local seatNOP
				if self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][NEW_BLIND_CHIPS_REPLAY]
					and self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][NEW_BLIND_CHIPS_REPLAY]>0 then
                    
					roundChips = self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][NEW_BLIND_CHIPS_REPLAY]+0.0
                    
					seatNOP = self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][SEAT_NO_REPLAY]..""
				elseif self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][PUNISH_BLIND_CHIPS_REPLAY]
					and self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][PUNISH_BLIND_CHIPS_REPLAY]>0 then
                    
					roundChips=self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][PUNISH_BLIND_CHIPS_REPLAY]+0.0
                    
					seatNOP = self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][SEAT_NO_REPLAY]..""
				elseif self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][SMALL_BLIND_REPLAY]
					and self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][SMALL_BLIND_REPLAY]>0 then
                    
					roundChips = self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][SMALL_BLIND_REPLAY]+0.0
                    
					seatNOP = self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][SBLIND_NO_REPLAY]..""
                    
				elseif self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][BIG_BLIND_REPLAY]
					and self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][BIG_BLIND_REPLAY]>0 then
                    
					roundChips = self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][BIG_BLIND_REPLAY]+0.0
                    
					seatNOP = self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][BBLIND_NO_REPLAY]..""
				end
                
				local chipsInfoP = {}
                
				local roundChipsP = roundChips..""
				local userChipsP = self.m_boardInfo.replayCommandInfo[i][BLIND_INFO_REPLAY][l][USER_CHIPS_REPLAY]..""
                
				local seat_NOP = seatNOP..""
				chipsInfoP[#chipsInfoP+1] = seat_NOP
                
				local round_ChipsP = roundChipsP..""
				chipsInfoP[#chipsInfoP+1] = round_ChipsP
                
				local user_ChipsP = userChipsP..""
				chipsInfoP[#chipsInfoP+1] = user_ChipsP
                
				self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME/3), cc.CallFunc:create(handler(self, self.stepPlayerChips), chipsInfoP))
				
			end
            
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_TABLE_RAKE_BF_FLOP_MSG then
			--            抽水
			for m=1,#self.m_boardInfo.replayCommandInfo[i][RAKE_INFO_BF_FLOP_REPLAY] do 
				local chipsInfo = {}
				local seatNO = self.m_boardInfo.replayCommandInfo[i][RAKE_INFO_BF_FLOP_REPLAY][m][SEAT_NO_REPLAY]..""
				local roundChips = "0"
				local userChips = self.m_boardInfo.replayCommandInfo[i][RAKE_INFO_BF_FLOP_REPLAY][m][USER_CHIPS_REPLAY]..""
                
				local seat_NO = seatNO..""
				chipsInfo[#chipsInfo+1]=seat_NO

				local round_Chips = roundChips..""
				chipsInfo[#chipsInfo+1] = round_Chips
                
				local user_Chips = userChips..""
				chipsInfo[#chipsInfo+1] = user_Chips
                
				self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME/2), cc.CallFunc:create(handler(self, self.stepPlayerChips), chipsInfo))
				
			end
            
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_POCKET_CARD then
			--            发两张牌,不用size的原因是旁观状态会传空数组
			for n=0,1 do
				for q=1,#self.m_boardInfo.playerInfoList do
					if not self.m_boardInfo.playerInfoList[q].isTrustee then
						--                       非托管状态
						if self.m_boardInfo.playerInfoList[q].seatNO == self.playerSeat then
							--                        发自己
							local cardInfo = {}
							local seatNO = self.playerSeat..""
							local cardNum = n..""
							local cardStr = self.m_boardInfo.replayCommandInfo[i][POCKET_CARDS_REPLAY][n+1]
							-- dump(cardStr)
							if cardStr==nil then
								cardStr = ""
							end
                            
							local seat_NO = seatNO..""
							cardInfo[#cardInfo+1]=seat_NO
                            
							local card_Num = cardNum..""
							cardInfo[#cardInfo+1]=card_Num
                            
							local card_Str = cardStr..""
							cardInfo[#cardInfo+1]=card_Str
                           
							self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME/2), cc.CallFunc:create(handler(self, self.stepPlayerCards), cardInfo))
							
						else
							--                        发别人
							local cardInfo = {}
							local seatNO = self.m_boardInfo.playerInfoList[q].seatNO..""
							local cardNum = n..""
							local cardStr = ""
                            
							local seat_NO = seatNO..""
							cardInfo[#cardInfo+1]=seat_NO
                            
							local card_Num = cardNum..""
							cardInfo[#cardInfo+1]=card_Num
                            
							local card_Str = cardStr..""
							cardInfo[#cardInfo+1]=card_Str
                            
							self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME/2), cc.CallFunc:create(handler(self, self.stepPlayerCards), cardInfo))
							
						end
					end
				end
			end
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_CHECK_MSG then
			local seat = self.m_boardInfo.replayCommandInfo[i][SEAT_NO_REPLAY]..""
			local seatNo = seat..""
			
			self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepCheck), {seatNo}))
			
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_FOLD_MSG then
			local seat = self.m_boardInfo.replayCommandInfo[i][SEAT_NO_REPLAY]..""
			local seatNo = seat..""
            
			self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepFold), {seatNo}))
			
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_CALL_MSG then
			local callInfo = {}
			local seatNO = self.m_boardInfo.replayCommandInfo[i][SEAT_NO_REPLAY]..""
			local callChips = self.m_boardInfo.replayCommandInfo[i][BET_CHIPS_REPLAY]..""
			local userChips = self.m_boardInfo.replayCommandInfo[i][USER_CHIPS_REPLAY]..""
            
			local seat_No = seatNO..""
			callInfo[#callInfo+1]=seat_No
            
			local call_Chips = callChips..""
			callInfo[#callInfo+1]=call_Chips
            
			local user_Chips = userChips..""
			callInfo[#callInfo+1]=user_Chips
            
			self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepCall), callInfo))
			
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_RAISE_MSG then
			local raiseInfo = {}
			local seatNO = self.m_boardInfo.replayCommandInfo[i][SEAT_NO_REPLAY]..""
			local callChips = self.m_boardInfo.replayCommandInfo[i][BET_CHIPS_REPLAY]..""
			local userChips = self.m_boardInfo.replayCommandInfo[i][USER_CHIPS_REPLAY]..""
            
			local seat_No = seatNO
			raiseInfo[#raiseInfo+1] = seat_No
            
			local call_Chips = callChips..""
			raiseInfo[#raiseInfo+1] = call_Chips
            
			local user_Chips = userChips..""
			raiseInfo[#raiseInfo+1] = user_Chips
            
			self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepRaise), raiseInfo))
			
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_ALL_IN_MSG then
            
			local allInInfo = {}
			local seatNO = self.m_boardInfo.replayCommandInfo[i][SEAT_NO_REPLAY]..""
			local callChips = self.m_boardInfo.replayCommandInfo[i][BET_CHIPS_REPLAY]..""
			local userChips = self.m_boardInfo.replayCommandInfo[i][USER_CHIPS_REPLAY]..""
            
			local seat_No = seatNO..""
			allInInfo[#allInInfo+1] = seat_No
            
			local call_Chips = callChips
			allInInfo[#allInInfo+1] = call_Chips
            
			local user_Chips = userChips..""
			allInInfo[#allInInfo+1] = user_Chips
            
			self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepAllIn), allInInfo))
			
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_FLOP_CARD_MSG then
			for o=1,#self.m_boardInfo.replayCommandInfo[i][COMMUNITY_CARDS_REPLAY] do
				local publicCards = {}
                
				local cardIdx = o..""
				local cardInfo = self.m_boardInfo.replayCommandInfo[i][COMMUNITY_CARDS_REPLAY][o]..""
                
				local cardIndex = (cardIdx-1)..""
				publicCards[#publicCards+1] = cardIndex
                
				local card_Info = cardInfo..""
				publicCards[#publicCards+1] = card_Info
                
				self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepFlop), publicCards))
			
			end
            
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_TURN_CARD_MSG then
			for p=1,#self.m_boardInfo.replayCommandInfo[i][COMMUNITY_CARDS_REPLAY] do
				local publicCards = {}
                
				local cardIdx = (p+3-1)..""
				local cardInfo = self.m_boardInfo.replayCommandInfo[i][COMMUNITY_CARDS_REPLAY][p]..""
                
				local cardIndex = cardIdx..""
				publicCards[#publicCards+1] = cardIndex
                
				local card_Info = cardInfo..""
				publicCards[#publicCards+1] = card_Info
                
				self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepTurn), publicCards))
				
			end
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_RIVER_CARD_MSG then
			for p=1,#self.m_boardInfo.replayCommandInfo[i][COMMUNITY_CARDS_REPLAY] do
				local publicCards = {}
                
				local cardIdx = (p+4-1)..""
				local cardInfo = self.m_boardInfo.replayCommandInfo[i][COMMUNITY_CARDS_REPLAY][p]..""
                
				local cardIndex = cardIdx..""
				publicCards[#publicCards+1] = cardIndex
                
				local card_Info = cardInfo..""
				publicCards[#publicCards+1] = card_Info
                
				self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepRiver), publicCards))
				
			end
            
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_SHOWDOWN_MSG then
			dump(self.m_boardInfo.replayCommandInfo[i][CARD_LIST_REPLAY])
			for q=1,#self.m_boardInfo.replayCommandInfo[i][CARD_LIST_REPLAY] do
				local showdownInfo = {}
				local poker1
				local poker2
				local seatID = self.m_boardInfo.replayCommandInfo[i][CARD_LIST_REPLAY][q][SEAT_NO_REPLAY]..""
                
				if self.m_boardInfo.replayCommandInfo[i][CARD_LIST_REPLAY][q][POCKET_CARDS_REPLAY] and 
					#self.m_boardInfo.replayCommandInfo[i][CARD_LIST_REPLAY][q][POCKET_CARDS_REPLAY]>0 then 
					poker1 =self.m_boardInfo.replayCommandInfo[i][CARD_LIST_REPLAY][q][POCKET_CARDS_REPLAY][1]..""
					poker2 =self.m_boardInfo.replayCommandInfo[i][CARD_LIST_REPLAY][q][POCKET_CARDS_REPLAY][2]..""
				else
					poker1=""
					poker2=""
				end
                
				local seat_ID = seatID..""
				showdownInfo[#showdownInfo+1] = seat_ID
                
				local poker_1 = poker1..""
				showdownInfo[#showdownInfo+1] = poker_1
                
				local poker_2 = poker2..""
				showdownInfo[#showdownInfo+1] = poker_2
                if poker1 and poker2 and poker1~="" and poker2~="" then
					self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepShowdown), showdownInfo))
				end
			end
		elseif self.m_boardInfo.replayCommandInfo[i][MSG_COMMAND_ID]==REPLAY_PRIZE_MSG then
			for t=1,#self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY] do
			 
				local potNum = #self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY]
                
				local prizeInfo = {}
                
				local seatNO = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][SEAT_NO_REPLAY]..""
                
				local userChips = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][USER_CHIPS_REPLAY]..""
				local cardType = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][CARD_TYPE_REPLAY]..""
                
				local winChips = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][WIN_CHIPS_REPLAY]..""
                
                
				local pot_Num = potNum..""
				prizeInfo[#prizeInfo+1] = pot_Num
                
				local fromPot = t..""
				prizeInfo[#prizeInfo+1] = fromPot
                
				local seat_NO = seatNO..""
				prizeInfo[#prizeInfo+1] = seat_NO
                
				local user_Chips = userChips..""
				prizeInfo[#prizeInfo+1] = user_Chips
                
				local card_Type = cardType..""
				prizeInfo[#prizeInfo+1] = card_Type
                
				local win_Chips = winChips..""
				prizeInfo[#prizeInfo+1] = win_Chips
                
				local maxCardInfo = {}
                
				if self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][MAX_CARD_REPLAY] and
					#self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][MAX_CARD_REPLAY]>0 then 
					local maxCard1 = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][MAX_CARD_REPLAY][1]..""
					local maxCard2 = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][MAX_CARD_REPLAY][2]..""
					local maxCard3 = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][MAX_CARD_REPLAY][3]..""
					local maxCard4 = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][MAX_CARD_REPLAY][4]..""
					local maxCard5 = self.m_boardInfo.replayCommandInfo[i][PRIZE_LIST_REPLAY][t][1][MAX_CARD_REPLAY][5]..""
					local max_Card1 = maxCard1..""
					maxCardInfo[#maxCardInfo+1] = max_Card1
                    
					local max_Card2 = maxCard2..""
					maxCardInfo[#maxCardInfo+1] = max_Card2
                    
					local max_Card3 = maxCard3..""
					maxCardInfo[#maxCardInfo+1] = max_Card3
                    
					local max_Card4 = maxCard4..""
					maxCardInfo[#maxCardInfo+1] = max_Card4
                    
					local max_Card5 = maxCard5
					maxCardInfo[#maxCardInfo+1] = max_Card5
                    
					prizeInfo[#prizeInfo+1] = maxCardInfo
				end
                
				self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME), cc.CallFunc:create(handler(self, self.stepPrizePots), prizeInfo))
				
			end
		end
	end
	--    执行播放
	self.m_playList[#self.m_playList+1] = cc.Sequence:create(cc.DelayTime:create(PLAY_DELAY_TIME/5), cc.CallFunc:create(handler(self, self.showPlayButton)))
	self:runAction(cc.Sequence:create(self.m_playList))
end

function ReplayView:shareToWechat(event)
	local pSender = event.target
	local url
	if SERVER_ENVIROMENT == ENVIROMENT_TEST then
		url = "http://debao.boss.com/index.php?act=video&mod=getmobilevideo&fid="..self.m_fid
	elseif SERVER_ENVIROMENT == ENVIROMENT_NORMAL then
		url = "http://www.debao.com/index.php?act=video&mod=getmobilevideo&fid="..self.m_fid
	end
	local data       = {title = "分享到微信",
		content = "我在#德堡德州扑克#的一场精彩牌局", "我在#德堡扑克#中录制的一场精彩牌局,小伙伴们快来围观~~~",
		nType = 1,
		url = url}
	QManagerPlatform:shareToWeChat(data) 
	-- QManagerPlatform:shareToWeChat("我在#德堡扑克#的一场精彩牌局", "我在#德堡扑克#中录制的一场精彩牌局,小伙伴们快来围观~~~", 1, url)
end

function ReplayView:replayClick(event)
	local pSender = event.target
    
	self:clearAllPlayerCards_Callback(0.5)
	local showDownView = self:getChildByTag(400)
	if showDownView then
	
		showDownView:getParent():removeChild(showDownView, true)
		showDownView = nil
	end
    
	-----------------
	if self.m_allPotLayer then
		self.m_allPotLayer:clearPots()
	end
	-----------------
	for i=1,#self.m_pPlayerChip do
	
		local pNode = self.m_pPlayerChip[i]
		if pNode then 
			pNode:getParent():removeChild(pNode, true)
		end
	end
	self.m_pPlayerChip = nil
	self.m_pPlayerChip = {}
    
	----------------
	if self.m_operateBoard then
	
		self.m_operateBoard:hideAll()
		--self.m_newerGuideLayer:swithAdvanceHint(-1)
	end
    
	--/-------------------------------------------
	if self.m_pStartNextHand then
	
		self.m_pStartNextHand:setVisible(false)
	end
    
	--/-------------------------------------------
	self:showNewerGuideStage(kNewGuideStageNone)
	self.m_dealerSprite:setVisible(false)
    
	self.m_replayButton:setVisible(false)
	self:stopAllActions()
	-- self:runAction(cc.Sequence:create(self.m_playList))
	self.m_playList = nil 
	self.m_playList = {}
	self.m_isReplay = true
	self:startPlay()
end

function ReplayView:showPlayButton()
	self.m_replayButton:setVisible(true)
end
--    设置用户筹码数(包括当前手中筹码,和所下筹码[包含盲注]
function ReplayView:stepPlayerChips(node, obj)
	local chipsInfo = obj
	local seat_NO = chipsInfo[1]
	local round_Chips = chipsInfo[2]
	local user_Chips = chipsInfo[3]
    
	self:playerChipsUpdate_Callback(seat_NO+0, 0, round_Chips+0.0, user_Chips+0.0)
end
--    设置底池
function ReplayView:stepPublicPots(node, obj)
	local publicPots = obj
	local potNumStr = publicPots[1]
	local indexStr = publicPots[2]
	local potChipsStr = publicPots[3]
    
	self:updatePublicPots_Callback(potNumStr+0, indexStr+0, potChipsStr+0,false)
end

function ReplayView:stepPlayerCards(node, obj)
	local chipsInfo = obj
	local seat_NO = chipsInfo[1]
	local card_Num = chipsInfo[2]
	local card_Str = chipsInfo[3]
	self:dispatchPlayerCards_Callback(seat_NO+0, card_Num+0,0.2 * 1,card_Str)
end

function ReplayView:stepCheck(node, obj)
	local seat = obj
    local isMyself = self.playerSeat==tonumber(seat[1])
	self:playerCheck_Callback(isMyself, seat[1])
end

function ReplayView:stepFold(node, obj)
	local seat = obj
	local seatID = seat[1]
	if tonumber(seatID) == self.playerSeat then
		self:playerFold_Callback(true, false, seatID)
	else
		self:playerFold_Callback(false, false, seatID)
	end
end

function ReplayView:stepCall(node, obj)
	local callInfo = obj
    
	local seat_No = callInfo[1]
	local call_Chips = callInfo[2]
	local user_Chips = callInfo[3]
    local isMyself = self.playerSeat==tonumber(seat_No)
	self:playerCall_Callback(isMyself, seat_No+0, call_Chips+0.0, 0, user_Chips+0.0)
end

function ReplayView:stepRaise(node, obj)
	local callInfo = obj
    
	local seat_No = callInfo[1]
	local call_Chips = callInfo[2]
	local user_Chips = callInfo[3]
    local isMyself = self.playerSeat==tonumber(seat_No)
	self:playerRaise_Callback(isMyself, seat_No+0, call_Chips+0.0, 0, user_Chips+0.0)
end

function ReplayView:stepAllIn(node, obj)
	local callInfo = obj
    
	local seat_No = callInfo[1]
	local call_Chips = callInfo[2]
	local user_Chips = callInfo[3]
    local isMyself = self.playerSeat==tonumber(seat_No)
	self:playerAllin_Callback(isMyself, seat_No+0, call_Chips+0.0, 0, user_Chips+0.0)
end

function ReplayView:stepFlop(node, obj)
	local publicCards = obj
    
	local cardIndex = publicCards[1]
	local cardInfo = publicCards[2]
    
	self:showPublicCard_Callback(cardIndex+0, cardInfo)
end

function ReplayView:stepTurn(node, obj)
	local publicCards = obj
    
	local cardIndex = publicCards[1]
	local cardInfo = publicCards[2]
    
	self:showPublicCard_Callback(cardIndex+0, cardInfo)
end

function ReplayView:stepRiver(node, obj)
	local publicCards = obj
    
	local cardIndex = publicCards[1]
	local cardInfo = publicCards[2]
    
	self:showPublicCard_Callback(cardIndex+0, cardInfo)
end

function ReplayView:stepShowdown(node, obj)
	local showdownInfo =obj
	local seatID = showdownInfo[1]
	local poker1 = showdownInfo[2]
	local poker2 = showdownInfo[3]
	self:showPlayerCards_Callback(seatID+0, poker1, poker2, true)
end

function ReplayView:stepPrizePots(node, obj)
	local prizeInfo = obj
	local pot_Num = prizeInfo[1]
	local fromPot = prizeInfo[2]
	local seat_NO = prizeInfo[3]
	local user_Chips = prizeInfo[4]
	local card_Type = prizeInfo[5]
	local win_Chips = prizeInfo[6]
    
	local seatNO = seat_NO
	local maxCard = {}
	for i=1,#prizeInfo do
		local maxCardInfo = prizeInfo[7]
		if type(maxCardInfo)=="table" then
			for k=1,#maxCardInfo do
				local card  = maxCardInfo[k]
				maxCard[#maxCard+1]=card
			end
		end
	end
    
    
	local from_Pot = pot_Num-fromPot-1
    
	if (seatNO==self.playerSeat) then
		self:updatePrizePots_Callback(true, pot_Num, from_Pot, seatNO, win_Chips, 0, card_Type, maxCard)
	else
        
		self:updatePrizePots_Callback(false, pot_Num,from_Pot, seatNO, win_Chips, 0, card_Type, maxCard)
	end
    
	self:playerChipsUpdate_Callback(seatNO, 0, 0,user_Chips)
    
    
end

--[[http请求返回]]
----------------------------------------------------------
function ReplayView:httpResponse(event)

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

function ReplayView:onHttpResponse(tag, content, state)
	self:removeChild(self.m_loadingView,true)
	if tag == POST_COMMAND_GETBOARDINFO then
        if content and string.len(content)>10 then
            self.m_boardInfo = BoardInfo:create(false)
            if(self.m_boardInfo:parseJson(content)==BIZ_PARS_JSON_SUCCESS) then
                self:startPlay()
            else
                --alert(牌局信息出错)
                local alert = require("app.Component.ETooltipView"):alertView(self,"","牌局信息出错!")
                alert:show()
            end
        else
            --alert(网络故障)
            local alert = require("app.Component.ETooltipView"):alertView(self,"","网络故障,并未获取到牌局信息!")
            alert:show()
        end
        
	end
    
end

function ReplayView:onEnter()
	BoardInfo:getInstance().isReplay=1

end

function ReplayView:onExit()

	BoardInfo:getInstance().isReplay=0
	
    if schId_beginHR then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schId_beginHR)
		schId_beginHR = nil
	end
    
end

--[[
用户操作点击事件
]]
--返回上一级
function ReplayView:doBackToLobby(event)

    local view = require("app.Component.EAlertView"):alertView(self,self,Lang_Title_Prompt,
        "是否退出牌局回放", Lang_Button_Cancel, Lang_Button_Confirm)
    view:alertShow()
    view:setTag(102)

end

function ReplayView:clickButtonAtIndex(alertView, index)
	local tag = alertView:getTag()
	if tag == 102 then --确认是否退出房间提示
		if index==1 then
			-- if self.mBackView then
   --      		GameSceneManager:switchSceneWithType(self.mBackView)
			-- else
        		GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
   --      	end

        	-- GameLayerManager:switchLayerWithType(GameLayerManager.TYPE.PERSONCENTER,self)
		end
	end
end

return ReplayView