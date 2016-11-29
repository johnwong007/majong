MatchStringNode = {first = "",second = ""}

MatchRankLogic = class("MatchRankLogic")

function MatchRankLogic:create(pView)
	local logic = MatchRankLogic:new()
	logic:setMatchRankViewCallback(pView)
	return logic
end

function MatchRankLogic:ctor()
	self.m_prizeResponed = false
	self.m_gainResponed = false
	self.m_prizeInfoList = {}
	self.m_gainInfoList = {}
	self.m_view = nil
end

function MatchRankLogic:setMatchRankViewCallback(callback)
	self.m_view = callback
end

function MatchRankLogic:getMatchRankList(matchId)
	DBHttpRequest:getMatchUserList(handler(self,self.httpResponse),matchId)
end

function MatchRankLogic:getMatchRewardList(matchId, bonusName, gainName, usersNum)
	local _bonusName = bonusName
	local _gainName = gainName
	if _bonusName and string.len(_bonusName)>0 then
	
		self.m_prizeResponed = false
		DBHttpRequest:getPrizeInfo(handler(self,self.httpResponse),matchId,bonusName,usersNum)
	else
	
		self.m_prizeResponed = true
	end

	if _gainName and string.len(_gainName)>0 then
	
		self.m_gainResponed = false
		DBHttpRequest:getGainInfoByName(handler(self,self.httpResponse),gainName)
	else
	
		self.m_gainResponed = true
	end
end


function MatchRankLogic:httpResponse(event)

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
	self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

end

function MatchRankLogic:onHttpResponse(tag, content, state)

    if tag==POST_COMMAND_GETMATCHUSERLIST then
        
        self:dealMatchRankList(content)

    elseif tag==POST_COMMAND_GETPRIZEINFO then
        
        self:dealPrizeInfo(content)

    elseif tag==POST_COMMAND_GETGAININFOBYNAME then
        
        self:dealGainInfoByName(content)

    end
end

function MatchRankLogic:dealMatchRankList(strJson)
	if not strJson then
	
		return
	end
	local parser = require("app.Logic.Datas.Lobby.MatchUserList"):new()
	if(parser:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
		if(self.m_view) then
			local rankList = {}
			for i=1,#parser.matchUserList do
				local player = clone(MatchStringNode)
				player.first = ""..i
				player.second = StringFormat:formatName(parser.matchUserList[i].userName, 12)
				player.third = StringFormat:FormatDecimals(parser.matchUserList[i].userChips, -1)
				rankList[#rankList+1] = player
			end
			self.m_view:updateMatchRankList(rankList)
		end
	end
	parser = nil
end

function MatchRankLogic:dealPrizeInfo(strJson)

	self.m_prizeResponed = true
	if(not strJson) then
		return
	end
    
	local parser = require("app.Logic.Datas.Admin.PrizeList"):new()
	if(parser:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
	
		self.m_prizeInfoList = parser.prizeInfoList
		if(self.m_gainResponed) then
		
			self:enterDealRewardLogic()
		end
	end
	parser = nil
end

function MatchRankLogic:dealGainInfoByName(strJson)

	self.m_gainResponed = true
	if(not strJson) then
	
		return
	end
	local parser = require("app.Logic.Datas.Admin.GainList"):new()
	if(parser:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
	
		self.m_gainInfoList = parser.gainInfoList
		if(self.m_prizeResponed) then
		
			self:enterDealRewardLogic()
		end
	end
	parser = nil
end
--修改积分
function MatchRankLogic:enterDealRewardLogic()

	if(not self.m_view) then
	
		return
	end
	local data = {} 
    
	--合并奖励逻辑-begin
	local max1 = (self.m_prizeInfoList and #self.m_prizeInfoList > 0) and (self.m_prizeInfoList[#self.m_prizeInfoList].prizeEndRank) or 0
	local max2 = (self.m_gainInfoList and #self.m_gainInfoList > 0) and (self.m_gainInfoList[#self.m_gainInfoList].prizeEndRank) or 0
    
	local size = (max1 > max2) and max1 or max2
	if(size <= 0) then
	
		return
	end
	for i=1,size do
		data[i] = clone(MatchStringNode)
	end
    -- dump(self.m_prizeInfoList)
    -- dump(self.m_gainInfoList)
	--取出奖池奖励
	for i=1,#self.m_prizeInfoList do
	
		local node = self.m_prizeInfoList[i]
		for j=node.prizeBeginRank,node.prizeEndRank do
		
			data[j].first = ""..j
			if self.m_payType and self.m_payType == "POINT" then
				data[j].second = StringFormat:FormatDecimals(node.bonusRatio * node.prizePool,2) .. "德堡钻"
			else
				data[j].second = StringFormat:FormatDecimals(node.bonusRatio * node.prizePool,2) .. "金币"
			end
		end
	end
    
	--取出奖励
	for i=1,#self.m_gainInfoList do
	
		local node = self.m_gainInfoList[i]
        for j=node.prizeBeginRandk,node.prizeEndRank do
		
			data[j].first = ""..j
			if(node.gainType == "GOLD") then
			
				if(data[j].second == "") then
					data[j].second = StringFormat:FormatDecimals(node.gainNum,2) .. "金币"
				else
					data[j].second = data[j].second .. "+" .. StringFormat:FormatDecimals(node.gainNum,2) .. "金币"
				end
			elseif(node.gainType == "RAKEPOINT") then
                if(data[j].second == "") then
                    data[j].second = StringFormat:FormatDecimals(node.gainNum,2) .. "积分"
                else
                    data[j].second = data[j].second .. "+" .. StringFormat:FormatDecimals(node.gainNum,2) .. "积分"
                end
            else
			
				if(data[j].second == "") then
					data[j].second = node.goodsName
				else
					data[j].second = data[j].second .. "+" .. node.goodsName
				end
			end
		end
	end
    
	--合并相同奖励内容
	local tmp = ""
	local needData = {}
	for i=1,#data do
	
		if(#needData > 0) then
		
			if(data[i].second == needData[#needData].second) then
			
				tmp = data[i].first
			else
			
				if(tmp ~= "") then
				
					needData[#needData].first = needData[#needData].first .. "-" .. tmp
					tmp = ""
				end
				needData[#needData+1] = data[i]
			end
		else
			needData[#needData+1] = data[i]
		end
	end

    if(tmp ~= "") then
	
		needData[#needData].first = needData[#needData].first .. "-" .. tmp
		tmp = ""
	end
	--合并奖励逻辑-end
    
	self.m_view:updateMatchRewardList(needData)
end


return MatchRankLogic