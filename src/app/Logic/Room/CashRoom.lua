local BaseRoom = require("app.Logic.Room.BaseRoom")
require("app.GUI.ProfitNotification")
local myInfo = require("app.Model.Login.MyInfo")
require("app.Tools.EStringTime")
require("app.Logic.newerGuide.NewerGuideControl")
require("app.Logic.Datas.TableData.PushMessage")

local CashRoom = class("CashRoom", function()
		return BaseRoom:new()
	end)

function CashRoom:create(seatNum)
	local cashRoom = CashRoom:new()
	cashRoom:initData(seatNum)
	return cashRoom
end

function CashRoom:ctor()
	BaseRoom.setChildRoom(self)

	self.m_bNeedGameHint    = true
	self.m_bNeedOperateHint = true
	self.m_bIsFirstRound    = true
	self.m_bHaveShowClose   = false
	self.m_nHadNumbers      = 0
	self.m_newerGuideControl = NewerGuideControl:new()
    
	--为区分现金场和锦标赛  不在牌桌中显示所以view传nil
	ProfitNotification:sharedInstance():registerCurrentView(nil, eProViewCashRoomView)



end

function CashRoom:dealTableInfoResp(dataModel)
	BaseRoom.dealTableInfoResp(self, dataModel)

	DBHttpRequest:getTaskAndHappyHourConfig(function(event) self:httpResponse(event) end)
	DBHttpRequest:queryActivityReward(function(event) if self.httpResponse then self:httpResponse(event) end end,82)

	self:getNewerGuideInfo()

	--[[关闭新手引导提示]]
	if self.m_bNeedGameHint then
		self.m_newerGuideControl.m_currentState = kTechControlEnter
	end

	local minBigBlind = 0.0
	if TRUNK_VERSION==DEBAO_TRUNK then
		minBigBlind = 0.02
	else
		minBigBlind = 2
	end
	if self.m_bNeedGameHint and self.m_roomInfo.bigBlind<=minBigBlind then
		self.m_pCallbackUI:showNewerGuideStage(self.m_roomInfo.tableId,kTableStageEnter)
	end
end

--[[新手引导]]
function CashRoom:getNewerGuideInfo()
	--[[获取新手引导设置]]
	local bNeedHint = UserDefaultSetting:getInstance():getNewTipsEnable()

	local bNeedOperateHint = bNeedHint  --操作提示
	local bNeedGameHint    = bNeedHint  --游戏提示

	--[[获取登录时间：上次和现在]]
	local nLast = UserDefaultSetting:getInstance():getLastLoginTimeStamp()
	local nNow = myInfo.data.serverTime

	local timeLast = ETimeDeal:create(nLast)
	local timeNow = ETimeDeal:create(nNow)

	--[[操作提示]]
	local DAY_COUNT = 7
	local bInSevenDay = (nLast == 0 or timeNow.daysAfterLastTime(timeLast) <= DAY_COUNT)
	bNeedOperateHint = bNeedOperateHint and bInSevenDay
    
	--[[游戏提示]]
	local bFirstLogin = (nLast == 0 or timeNow.isFirstTimeToday(timeLast))
	bNeedGameHint = bNeedGameHint and bFirstLogin
	bNeedGameHint = bNeedGameHint and myInfo.data.isNewer
    
	self.m_bNeedOperateHint = bNeedOperateHint
	self.m_bNeedGameHint    = bNeedGameHint
	self.m_bNeedGameHint = self.m_bNeedGameHint and (not myInfo.data.isLearnGuide)
    
	if self.m_pCallbackUI then
		self.m_pCallbackUI:setGuideConfig(self.m_roomInfo.tableId,self.m_bNeedOperateHint,self.m_bNeedGameHint)
	end
end

function CashRoom:dealHandStartResp(dataModel)
	-- normal_info_log("CashRoom:dealHandStartResp")

	BaseRoom.dealHandStartResp(self,dataModel)
	--[[隐藏“本局尚未开始，请耐心等待，先观察一下对手吧！”提示]]
	if BaseRoom.myselfIsPlaying(self) then
		self.m_pCallbackUI:showStartNextHand(self.m_roomInfo.tableId,"",false)
    end
	--[[重新获取新手引导设置]]
	self:getNewerGuideInfo()
	
	self.m_nHadNumbers= self.m_nHadNumbers + 1
end

function CashRoom:dealTableBlindResp(dataModel)
	-- normal_info_log("CashRoom:dealTableBlindResp")
	BaseRoom.dealTableBlindResp(self, dataModel)
	local data = dataModel
    
	if not data.blindInfo and #data.blindInfo ~= 2 then
		return
	end
    
	if not self.m_bNeedGameHint then
		return
	end
    
	--[[用户头像上大小盲新手提示]]
	if((self.m_nHadNumbers <=1 or (not self.m_bHaveShowClose and self.m_nHadNumbers <= 2)) 
		and self.m_pCallbackUI) then
		local blind1 = data.blindInfo[1]
		local blind2 = data.blindInfo[2]
        
		local isBigBlind = blind1.smallBlind > blind2.smallBlind
		self.m_pCallbackUI:showNewerBlindHint(self.m_roomInfo.tableId,blind1.sBlindNo,isBigBlind)
		self.m_pCallbackUI:showNewerBlindHint(self.m_roomInfo.tableId,blind2.sBlindNo,not isBigBlind)
	end
end

function CashRoom:dealPocketCardResp(dataModel)
	-- normal_info_log("CashRoom:dealPocketCardResp")
	BaseRoom.dealPocketCardResp(self, dataModel)
	--[[手牌提示]]
	if self.m_bNeedOperateHint and BaseRoom.myselfHasCards(self) then
		local seat = BaseRoom.getSeat(self, self.m_myselfSeatId)
		local pocketCard = {}
		pocketCard[1] = seat.pokerCard1
		pocketCard[2] = seat.pokerCard2
		self.m_newerGuideControl:pushPocketCard(pocketCard)
		self.m_newerGuideControl.m_isFirstRound = true
		self.m_newerGuideControl.m_currentState = kTechControlPocket
	end
    
	local seat = BaseRoom.getSeat(self, self.m_myselfSeatId)
	if seat == nil then
		return
	end	
	if self.m_bNeedGameHint and self.m_nHadNumbers <= 1 and self.m_myselfSeatId ~= -1 
		and not seat.isTrustee and BaseRoom.myselfHasCards(self) then
		if self.m_nHadNumbers <=1 or (not self.m_bHaveShowClose and self.m_nHadNumbers <= 2) then
			self.m_pCallbackUI:showNewerGuideStage(self.m_roomInfo.tableId,kTableStagePocket)
		end
	end
end

function CashRoom:dealFlopCardsResp(dataModel)
	-- normal_info_log("CashRoom:dealFlopCardsResp")
	BaseRoom.dealFlopCardsResp(self, dataModel)
	--[[转牌提示]]
	if self.m_roomInfo.comunityCard and #self.m_roomInfo.comunityCard == 3 then
		if self.m_bNeedOperateHint then
			local flopCard = self.m_roomInfo.comunityCard
			self.m_newerGuideControl:pushFlopCard(flopCard)
			self.m_newerGuideControl.m_isFirstRound = true
			self.m_newerGuideControl.m_currentState = kTechControlFlop
		end
        
		if self.m_bNeedGameHint then
			if(self.m_nHadNumbers <=1 or (not self.m_bHaveShowClose and self.m_nHadNumbers <= 2)) then
				self.m_pCallbackUI:showNewerGuideStage(self.m_roomInfo.tableId,kTableStageFlop)
			end
		end
        
	end
end

function CashRoom:dealTurnCardResp(dataModel)
	-- normal_info_log("CashRoom:dealTurnCardResp")

	BaseRoom.dealTurnCardResp(self, dataModel)

	--[[新手指导]]
	if self.m_bNeedOperateHint then
		self.m_newerGuideControl.m_currentState = kTechControlTurn
	end
	if self.m_bNeedGameHint then
		if(self.m_nHadNumbers <=1 or (not self.m_bHaveShowClose and self.m_nHadNumbers <= 2)) then
			self.m_pCallbackUI:showNewerGuideStage(self.m_roomInfo.tableId,kTableStageTurn)
		end
	end
end

function CashRoom:dealRiverCardResp(dataModel)
	-- normal_info_log("CashRoom:dealRiverCardResp")
	
	BaseRoom.dealRiverCardResp(self, dataModel)
	--[[新手引导]]
	if self.m_bNeedOperateHint then
		self.m_newerGuideControl.m_currentState = kTechControlRiver
	end
	if self.m_bNeedGameHint and self.m_nHadNumbers <= 1 then
		if self.m_nHadNumbers <=1 or (not self.m_bHaveShowClose and self.m_nHadNumbers <= 2) then
			self.m_pCallbackUI:showNewerGuideStage(self.m_roomInfo.tableId,kTableStageRiver)
		end
	end
end

function CashRoom:dealHandFinishResp(dataModel)
	BaseRoom.dealHandFinishResp(self, dataModel)

	--[[新手指导]]
	if self.m_bNeedOperateHint then
		self.m_newerGuideControl:clearAllSet()
	end
	if self.m_bNeedGameHint then
		if self.m_nHadNumbers == 1 then
			self.m_bHaveShowClose = true
			myInfo.data.isLearnGuide = true
			self.m_pCallbackUI:showNewerGuideStage(self.m_roomInfo.tableId,kTableStageClose)
		else
			self.m_pCallbackUI:showNewerGuideStage(self.m_roomInfo.tableId,kTableStageNone)
		end
		
	end
end


function CashRoom:dealFoldResp(dataModel)
	BaseRoom.dealFoldResp(self, dataModel)

	local data = dataModel
	local seat = BaseRoom.getSeat(self, data.m_seatNo)
    
	--[[新手指导]]
	if BaseRoom.isMyseat(self, seat.seatId) then
		if self.m_newerGuideControl.m_currentState == kTechControlPocket then
			self.m_pCallbackUI:showNewerGuideStage(self.m_roomInfo.tableId,kTableStageNone)
		end
	end
end

function CashRoom:dealSitOutResp(dataModel)
	BaseRoom.dealSitOutResp(self, dataModel)

	--[[自己离座消除提示信息]]
	local data = dataModel
	if data.m_userId == myInfo.data.userId then
		if self.m_pCallbackUI then
			self.m_pCallbackUI:showStartNextHand(self.m_roomInfo.tableId,"",false)
		end
	end
end

---------------------------------------------------
function CashRoom:callBuyDialog(isAdd, needShowAutoBuySign, currentShow)
	needShowAutoBuySign = needShowAutoBuySign and needShowAutoBuySign or false
	if self.m_pCallbackUI then
		local seat = BaseRoom.getSeat(self,myInfo.data.userId)

		if not seat then --[[自己不在座位上时提示]]
			if self.m_pCallbackUI then
				self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(
                                                                self.m_roomInfo.tableId,
                                                                Lang_OnlySitCanBuyin,
                                                                myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin)
			end
			return
		end
        local isRakePoint
        local mychips = BaseRoom.getMyTotalMoney(self)
        if self.m_roomInfo.payType == "RAKEPOINT" then
            isRakePoint = true
            mychips = BaseRoom.getMyRakePoint(self)
        end
        
    	if self.m_roomInfo.serviceCharge>0 and self.m_isPrivateRoom then
        	local percent = (100-self.m_roomInfo.serviceCharge)/100
        	mychips = mychips*percent
    	end
		local tmpBuysMin = self.m_roomInfo.tmpBuyChipsMin>0.0 and self.m_roomInfo.tmpBuyChipsMin
			or self.m_roomInfo.buyChipsMin
		local tmpBuysMax = self.m_roomInfo.tmpBuyChipsMax>0.0 and self.m_roomInfo.tmpBuyChipsMax
			or self.m_roomInfo.buyChipsMax

		local min = isAdd and
        	(seat.seatChips>=self.m_roomInfo.buyChipsMin and 
        		seat.seatChips or 
        		self.m_roomInfo.buyChipsMin
        	) or
        	(mychips>tmpBuysMin and tmpBuysMin or mychips)

--        记录的筹码相等的时候
        if(mychips == tmpBuysMin) then
            min = self.m_roomInfo.buyChipsMin
        end
        local max = isAdd and
        	(self.m_roomInfo.buyChipsMax>=(mychips+seat.seatChips) and 
        		(mychips+seat.seatChips) or 
        		self.m_roomInfo.buyChipsMax
        	) or
        	(tmpBuysMax>=mychips and mychips or tmpBuysMax)
        if self.m_roomInfo.playType == "BIDA" then
        	local times = self.m_roomInfo.buyinTimes
        	if seat.seatChips>0 then
        		times = times-1
        	end
        	local tmp = 0
        	
        	if times<1 then
        		tmp = self.m_roomInfo.originalBuyChipsMax
        	elseif times>0 and times<2 then
	            tmp = self.m_roomInfo.originalBuyChipsMax*2
	        elseif times>1 and times<3 then
	            tmp = self.m_roomInfo.originalBuyChipsMax*4
	        elseif times>2 then
	            tmp = self.m_roomInfo.originalBuyChipsMax*6
	        end
	        self.m_roomInfo.buyChipsMax = tmp
	        -- self.m_roomInfo.buyChipsMin = tmp
	        -- min = isAdd and
        	-- (seat.seatChips>=tmp and 
        	-- 	seat.seatChips or 
        	-- 	tmp
        	-- ) or
        	-- (mychips>tmpBuysMin and tmpBuysMin or mychips)

        	max = isAdd and
        	(tmp>=(mychips+seat.seatChips) and 
        		(mychips+seat.seatChips) or 
        		tmp
        	) or
        	(tmpBuysMax>=mychips and mychips or tmpBuysMax)
        end
        -- dump(max)
        -- dump(self.m_roomInfo.tmpBuyChipsMax)
		if(max < self.m_roomInfo.buyChipsMin) then
			--钱不够
			if(self.m_pCallbackUI) then
				if(myInfo.data.payamount<=0  and  mychips < myInfo.data.brokeMoney) then
				
					self.m_pCallbackUI:showFirstChargeDialog_Callback(self.m_roomInfo.tableId,2,Lang_FirstLessMinBuy) --老用户提示首充活动
				else
				
					local bQuickStartAble =  mychips >= myInfo.data.brokeMoney
					local msg = bQuickStartAble  and Lang_LESS_MINBUYIN or
                    	(isAdd and Lang_NotEnoughMoney or Lang_BANKRUPT_MINBUYIN)
					self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                                                                    msg,
                                                                    myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                                                                    true,
                                                                    false,
                                                                    bQuickStartAble and BUYINFAIL_ACTION_CHANGEROOM or BUYINFAIL_ACTION_QUITEROOM,isRakePoint)
				end
			end
		elseif(min > self.m_roomInfo.buyChipsMax) then
			-- --超过了该房间的最大购买数
			-- if (TRUNK_VERSION==DEBAO_TRUNK) then
			-- 	if (self.m_bfirstSitAndBuy) then
			
			-- 		--显示购买框

   --              	return
			-- 	end
			-- end
   --          if(self.m_pCallbackUI) then
   --              self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(
   --                                                              self.m_roomInfo.tableId,
   --                                                              Lang_MoreEnoughMoney,
   --                                                              myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
   --                                                              false,
   --                                                              true)
   --          end
            if(self.m_pCallbackUI) then
                	self.m_pCallbackUI:showBuyinDiaglog_Callback(
                                                         self.m_roomInfo.tableId,
                                                         mychips+seat.seatChips,
                                                         min,
                                                         min,
                                                         min,
                                                         self.m_roomInfo.bigBlind,
                                                         self.m_roomInfo.payType,
                                                         isAdd,
                                                        needShowAutoBuySign,
                                                        nil,
                                                     currentShow)
            end
		elseif(min == max  and  min ~= self.m_roomInfo.buyChipsMin) then
		
			--钱全部买入了
			if(self.m_pCallbackUI) then
				if(myInfo.data.payamount<=0  and  mychips< myInfo.data.brokeMoney) then
				
					self.m_pCallbackUI:showFirstChargeDialog_Callback(self.m_roomInfo.tableId,2,Lang_FirstLessMinBuy) --老用户提示首充活动
				else
					
					if self.m_roomInfo.buyChipsMax==seat.seatChips then
						self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                                                                    "买入已达到该房间的最大值！",
                                                                    myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                                                                    false,
                                                                    false,
                                                                    bQuickStartAble and BUYINFAIL_ACTION_CHANGEROOM or BUYINFAIL_ACTION_QUITEROOM)
						return
					end
					local bQuickStartAble =  mychips >= myInfo.data.brokeMoney
					local msg = bQuickStartAble and
                    Lang_LESS_MINBUYIN or
                    (isAdd and Lang_NotEnoughMoney or Lang_BANKRUPT_MINBUYIN)

					self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                                                                    msg,
                                                                    myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                                                                    true,
                                                                    false,
                                                                    bQuickStartAble and BUYINFAIL_ACTION_CHANGEROOM or BUYINFAIL_ACTION_QUITEROOM)
				end
			end
		else
			local defaultValue = (max>=self.m_roomInfo.gameMinBuyin) and
            (self.m_roomInfo.gameMinBuyin) or
            (max)
			--显示购买框
			self.m_pCallbackUI:showBuyinDiaglog_Callback(
                                                     self.m_roomInfo.tableId,
                                                     mychips+seat.seatChips,
                                                     min,
                                                     max,
                                                     defaultValue,
                                                     self.m_roomInfo.bigBlind,
                                                     self.m_roomInfo.payType,
                                                     isAdd,
                                                     needShowAutoBuySign,
                                                     self.m_roomInfo.serviceCharge,
                                                     currentShow)
		end
	end
end

function CashRoom:autoBuyinOrRebuy()
	--派奖完成后查看是否有需要买入的筹码
	self.m_isAutoBuyinChips = UserDefaultSetting:getInstance():getAutoBuyChip()
	local seat = BaseRoom.getSeat(self,self.m_myselfSeatId)
	if(not seat) then
		return
    end

	if(self.m_isAdd_buyinChips  and  self.m_myBuyChipsNum>0.0) then
	--牌局结束后补充筹码
		
		if((self.m_myBuyChipsNum-seat.seatChips)>0.0) then
		
			-- if (TRUNK_VERSION == TENCENT_TRUNK) then
			-- 	self.m_myBuyChipsNum = (BaseRoom.getMyTotalMoney(self)>self.m_myBuyChipsNum) and
   --      			self.m_myBuyChipsNum or
			-- 		BaseRoom.getMyTotalMoney(self)
			-- else
				self.m_myBuyChipsNum = (BaseRoom.getMyTotalMoney(self)>(self.m_myBuyChipsNum-seat.seatChips)) and
            		(self.m_myBuyChipsNum-seat.seatChips) or
					BaseRoom.getMyTotalMoney(self)
			-- end
			
			BaseRoom.buyin(self,self.m_roomInfo.tableId,seat.userId,self.m_myBuyChipsNum,self.m_roomInfo.payType,true)
		end
		self.m_isAdd_buyinChips = false --只补充一次
	elseif( self.m_isAutoBuyinChips  and  seat.seatChips<=0 ) then
	--输掉了补充筹码.....
		if(BaseRoom.getMyTotalMoney(self)>=self.m_roomInfo.buyChipsMin) then
		
			self.m_myBuyChipsNum = (BaseRoom.getMyTotalMoney(self)>= self.m_roomInfo.gameMinBuyin) and
            (self.m_roomInfo.gameMinBuyin) or
			BaseRoom.getMyTotalMoney(self)

			BaseRoom.buyin(self,self.m_roomInfo.tableId,BaseRoom.getSeat(self,self.m_myselfSeatId).userId,
				self.m_myBuyChipsNum,self.m_roomInfo.payType,false)
			self.m_bAutoBuyinReqing = true
		else
		
			--提示钱不够买入
			if(self.m_pCallbackUI) then
			
				if(myInfo.data.payamount<=0) then
				
					self.m_pCallbackUI:showFirstChargeDialog_Callback(self.m_roomInfo.tableId,2,Lang_FirstLessMinBuy) --老用户提示首充活动
				else
				
					local bQuickStartAble =  (BaseRoom.getMyTotalMoney(self)+seat.seatChips) >= myInfo.data.brokeMoney
					self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                                                                    bQuickStartAble and Lang_LESS_MINBUYIN or Lang_BANKRUPT_MINBUYIN,
                                                                    myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                                                                    true,
                                                                    false,
                                                                    bQuickStartAble and BUYINFAIL_ACTION_CHANGEROOM or BUYINFAIL_ACTION_QUITEROOM)
				end
			end
		end
	elseif(seat.seatChips<=0) then
	
		--显示购买对话框
		local hasFistLost = UserDefaultSetting:getInstance():getHasFirstLost()
		self:callBuyDialog(false, not hasFistLost)
		if (not hasFistLost) then
		
			UserDefaultSetting:getInstance():setHasFistLost(true)
		end
	end
end

function CashRoom:showOperateGuideBubble()
	--新手引导，操作提示
	if(self.m_bNeedOperateHint) then
	
		--新手引导
		self.m_newerGuideControl.m_isFirstRound = self.m_roomInfo.isFirstRound
		self.m_newerGuideControl.m_isHaveAllIn  = self.m_roomInfo.hasAllIn
		self.m_newerGuideControl:setGreatCard(self.m_bGreatThanThree)
        
		local showType = self.m_newerGuideControl:getShowType()
		local opType
        
		--判断操作类型
		if showType==kNGCPocketGreatCallRaise or
            showType==kNGCPocketPairCallRaise or
            showType==kNGCPocketGoodCallRaise then
            opType = kOBOHPocketRaise
        elseif showType==kNGCFlopGreatRaise then
            opType = kOBOHFlopRaise
        else
            opType = kOBOHNone
		end
        
		self.m_pCallbackUI:showNewerGuideActionHint(self.m_roomInfo.tableId,showType,opType)
	end
end

function CashRoom:promptWaitNextHand()
	if(not self.m_pCallbackUI) then
	
		return
	end
    
	if(self.m_roomInfo.tableStatus >= TABLE_STATE_HAND  and  self.m_roomInfo.tableStatus < TABLE_STATE_PRIZE) then
	
		self.m_pCallbackUI:showStartNextHand(self.m_roomInfo.tableId,Lang_NextHandCanPlay,true)
	else
	
		local count = 0
		for i=1,#self.m_seatsArray do
		
			local seat = BaseRoom.getSeat(self, i-1)
			if(seat.seatId >= 0) then
				count=count+1
			end
		end
		if(count==1  and  self.m_myselfSeatId >=0 ) then
		
			self.m_pCallbackUI:showStartNextHand(self.m_roomInfo.tableId,Lang_EmptyRoomWaitOthers,true)
		end
	end
end

function CashRoom:localQuickSit()
	for i=0,self.m_roomInfo.seatNum do
	
		local seat = BaseRoom.getSeat(self, i)
		if(seat  and  seat:hasPlayer()) then
		else
			BaseRoom.reqMySit(self, i)
		end
	end
end

function CashRoom:startPushServer()
end

function CashRoom:closePushServer()
end

function CashRoom:dealQueryRewardResp(strJson)
    if not self.m_pCallbackUI then
    	return
    end

    BaseRoom.dealQueryRewardResp(self, strJson)

    local data = require("app.Logic.Datas.Admin.RewardList"):new()
    if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
    	if #data.rewardInfoList>0 then
    		for i=1,#data.rewardInfoList do
    			if data.rewardInfoList[i].activityId == "82" then
    				if data.rewardInfoList[i].isRewarded == "NO" then
    					self.m_pCallbackUI:changeFirstRechargeButtonStatus(self.m_roomInfo.tableId,2)
    				end
    			end
    		end
    		if i==#data.rewardInfoList and myInfo.data.payamount<=0 then
    			self.m_pCallbackUI:changeFirstRechargeButtonStatus(self.m_roomInfo.tableId,1)
    		end
    	end
    elseif strJson=="-404" and myInfo.data.payamount<=0 then
    	self.m_pCallbackUI:changeFirstRechargeButtonStatus(self.m_roomInfo.tableId,1)
    end
end

function CashRoom:DebaoBuyin()
	if(self.m_isQuickStart  and  self.m_myselfSeatId>=0) then
	
		local seat = BaseRoom.getSeat(self, self.m_myselfSeatId)
		if(BaseRoom.getMyTotalMoney(self)>=self.m_roomInfo.buyChipsMin) then
		
			local minBuyNum = (self.m_roomInfo.gameMinBuyin>self.m_roomInfo.tmpBuyChipsMin) and
            (self.m_roomInfo.gameMinBuyin) or self.m_roomInfo.tmpBuyChipsMin
            
			self.m_myBuyChipsNum = (BaseRoom.getMyTotalMoney(self)>= minBuyNum) and minBuyNum or BaseRoom.getMyTotalMoney(self)
			BaseRoom.buyin(self, self.m_roomInfo.tableId,seat.userId,self.m_myBuyChipsNum,self.m_roomInfo.payType,false)
		else
		
			--提示钱不够
			local bQuickStartAble =  (BaseRoom.getMyTotalMoney(self)) >= myInfo.data.brokeMoney
			self.m_pCallbackUI:showSitAndBuyFailureMsg_Callback(self.m_roomInfo.tableId,
                                                            bQuickStartAble and Lang_LESS_MINBUYIN or Lang_BANKRUPT_MINBUYIN,
                                                            myInfo:getTotalChips(),self.m_roomInfo.buyChipsMin,
                                                            true, 
                                                            false,
                                                            bQuickStartAble and BUYINFAIL_ACTION_CHANGEROOM or BUYINFAIL_ACTION_QUITEROOM)
            
		end
		self.m_isQuickStart=false
	end
end

-- --[[获取玩家的任务列表]]
-- function CashRoom:dealGetTableInfo(dataModel)
	
-- end

--[[获取任务列表配置和HappyHour配置]]
function CashRoom:dealGetTaskHappyHourCongfig(content)
    -- normal_info_log("CashRoom:dealGetTaskHappyHourCongfig")

	local data = require("app.Logic.Datas.Activity.Task_HappyHourConfig"):new()
	if data:parseJson(content)==BIZ_PARS_JSON_SUCCESS then
		if self.m_pCallbackUI then
			self.m_pCallbackUI:showTaskHappyHourInfo(self.m_roomInfo.tableId,
				data.taskNum,data.happyHourNum)
		end
	end
end

function CashRoom:dealPushMessage(dataModel)
	
	local pData = dataModel
    
	if(pData.m_simbol == 2) then
	
		self.m_pCallbackUI:showPushMessage_Callback(pData.m_type,pData.m_message)
	elseif(pData.m_simbol == 1) then
	
	 	if(pData.m_type == 15) then
	 	
	 		local data = CardHandPointPushMsg:new()
	 		if(data:parsJson(pData.m_message) == BIZ_PARS_JSON_SUCCESS) then
	 		
				local seat = BaseRoom.getSeat(self, data.userId)
				if(seat) then
				
					local seatId = seat.seatId
					self.m_pCallbackUI:updateUserCardHandPoint(self.m_roomInfo.tableId,seatId,data.pointNow - data.pointOld)
				end									
	 		end
	 		data = nil
	 	end
	end
end

function CashRoom:dealRemindUserTableDestroy(dataModel)

	local data = dataModel
	if(self.m_pCallbackUI) then
		self.m_pCallbackUI:showPushMessage_Callback(1,data.message)
	end	
end

function CashRoom:reqGamblingIsCarryOn()
	if(self.m_roomInfo.tableStatus >= TABLE_STATE_HAND  and  self.m_roomInfo.tableStatus < TABLE_STATE_PRIZE) then
	
		return true
	end
	return false
end



return CashRoom