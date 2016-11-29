	eProViewUnknow = 0
	eProViewMainView = 1
	eProViewHallView = 2
	--eProViewRoomView
	eProViewCashRoomView = 3
	eProViewTourneyRoomView = 4

ProfitNotification = {}
setmetatable(ProfitNotification, {__index = cc.Ref})
ProfitNotification.super = cc.Ref
ProfitNotification.__cname = "ProfitNotification"
ProfitNotification.__ctype = 2
ProfitNotification.__index = ProfitNotification

sharedProfitNotification = nil

function ProfitNotification:sharedInstance()
	if sharedProfitNotification == nil then
		local instance = setmetatable({}, ProfitNotification)
		instance.class = ProfitNotification
		instance:ctor()
		sharedProfitNotification = instance
	end
	return sharedProfitNotification
end

function ProfitNotification:ctor()
	self.m_currentView = nil
	self.m_viewType = eProViewUnknow
	self.m_tableProfit = nil
	self.m_profitRanking = -1
	self.m_infoView = nil
	
	self.tcpRequest = TcpCommandRequest:shareInstance()
	self.tcpRequest:addObserver(self)
end

function ProfitNotification:registerCurrentView(view, viewType)

	if viewType == eProViewTourneyRoomView then
		self.m_tableProfit = nil
	end
	-- 此处判断臃肿  待优化  
	if view ~= nil and self.m_viewType == eProViewCashRoomView and viewType ~= eProViewUnknow and
		viewType ~= eProViewCashRoomView and  viewType ~= eProViewTourneyRoomView and self.m_tableProfit then
		--默认退出房间就到大厅或者主界面  如果有缓存则显示数据
        self:showProfitInfo(self.m_tableProfit, view)
		self.m_tableProfit = nil
	end
	self.m_currentView = view
	self.m_viewType = viewType
end

function ProfitNotification:enableReceiver(bEnable)

end

--[[tcp请求返回]]
----------------------------------------------------------
function ProfitNotification:OnTcpMessage(command, strJson)
	
	if command == COMMAND_LEAVE_CHIPS_STATE then
		-- dump("====COMMAND_LEAVE_CHIPS_STATE====")
		if UserDefaultSetting:getInstance():needWinLoseTip() then
           self:dealTableProfit(strJson)
        end
	end

end

function ProfitNotification:dealGetRankInfo(strJson)
	if not UserDefaultSetting:getInstance():needWinLoseTip() then
		return
	end
	
	local rankingInfo = require("app.Logic.Datas.Analysis.GetUserProfitRanking"):new()
	if rankingInfo:parseJson(strJson)==BIZ_PARS_JSON_SUCCESS then
		if self.m_profitRanking < 0 then
			--初始化
			self.m_profitRanking = rankingInfo.user_ranking+0
		elseif self.m_currentView then
			local currentRanking = rankingInfo.user_ranking+0
			if self.m_infoView then
				if currentRanking > self.m_profitRanking then
					local sprite = self.m_infoView.down
					sprite:setVisible(true)
				elseif currentRanking < self.m_profitRanking then
					local sprite = self.m_infoView.up
					sprite:setVisible(true)
				end
			end
			self.m_profitRanking = currentRanking
		end
	end
	rankingInfo = nil
end

--[[http请求返回]]
----------------------------------------------------------
function ProfitNotification:httpResponse(event)

    local ok = (event.name == "completed")
    local request = event.request
 
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

function ProfitNotification:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_GETUSERPROFITRANKING then
		self:dealGetRankInfo(content)
	end
end

--此处三个通知都可用retain和release来保证对象存在，但是存在http请求若延迟高会引起数据混乱
function ProfitNotification:clickButtonAtIndex(alertView, index)
	self.m_infoView = nil
    
	if index == 3 then
		local str = ""
		if self.m_profitCoin > 0 then
			str = lang_WECHATSHARE_PROFIT_WIN1 .. StringFormat:FormatDecimals(self.m_profitCoin, 2) .. lang_WECHATSHARE_PROFIT_WIN2
		else
			str = lang_WECHATSHARE_PROFIT_FAILT1 .. StringFormat:FormatDecimals(-self.m_profitCoin, 2) .. lang_WECHATSHARE_PROFIT_FAILT2
		end
		-- PerformTool* tool = new PerformTool();
		-- CCString* temp = CCString::create(IConvConvert_GBKToUTF8(str));
		-- tool->performMainThread(temp, eNativeCallJavaShareToWeChat);

    end
end

function ProfitNotification:shareToWechat()
	local temp = ""
	if self.m_profitCoin > 0 then
		temp = lang_WECHATSHARE_PROFIT_WIN1 .. StringFormat:FormatDecimals(m_profitCoin, 2) .. lang_WECHATSHARE_PROFIT_WIN2
	else
		temp = lang_WECHATSHARE_PROFIT_FAILT1 .. StringFormat:FormatDecimals(m_profitCoin, 2) .. lang_WECHATSHARE_PROFIT_FAILT2
	end
	local data       = {title = "分享到微信",
		content = temp,
		nType = 1,
		url = "http://www.debao.com"}
	QManagerPlatform:shareToWeChat(data) 
end

function ProfitNotification:alertWillAutoRemove(alertView)
	self.m_infoView = nil
end

function ProfitNotification:keyBackClickedWillRemove(alertView)
	self.m_infoView = nil
end

function ProfitNotification:showProfitInfo(info, currentView)
	if not currentView or info.m_profitChip == 0 then
		return
	end
	self.m_infoView = require("app.GUI.dialogs.ProfitDialog"):new()

	local tmpProfit = info.m_profitChip
	if info.m_profitChip < 0 then
		tmpProfit = -info.m_profitChip
        self.m_infoView.down:setVisible(true)
		self.m_infoView.sad:setVisible(true)
		self.m_infoView.profit:setColor(cc.c3b(255, 0, 0))
	else
        self.m_infoView.up:setVisible(true)
		self.m_infoView.happy:setVisible(true)
		self.m_infoView.profit:setColor(cc.c3b(1, 250, 221))
	end
	self.m_infoView.m_profitCoin = info.m_profitChip
	self.m_profitCoin = info.m_profitChip
	self.m_infoView.profit:setString(StringFormat:FormatDecimals(tmpProfit, 2))
	CMOpen(self.m_infoView, currentView ,0,1,MAX_ZORDER+1)
end

function ProfitNotification:dealTableProfit(strJson)
	if self.m_viewType == eProViewUnknow or self.m_viewType == eProViewTourneyRoomView then
		return
	end

	local info = require("app.Logic.Datas.TableData.TableProfit"):new()
	if info:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
		if not info.m_bPlaying then
			if self.m_viewType == eProViewCashRoomView then
				--缓存数据
				self.m_tableProfit = nil
				self.m_tableProfit = info
				return
			else
				if self.m_currentView then
					self:showProfitInfo(info, self.m_currentView)
				end
			end
		end
	end
	info = nil
end
