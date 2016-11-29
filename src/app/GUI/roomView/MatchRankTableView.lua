local SeqActionTag = 888
local kTagTableView = 10
local kTagMoreButton = 111
local kTagRankListButton = 112
local kTagRewadListButton = 113

local TABLE_WIDTH = 200

local MatchRankTableViewCell = class("MatchRankTableViewCell", function()
		return display.newNode()
	end)

function MatchRankTableViewCell:create()
	local cell = MatchRankTableViewCell:new()
	return cell
end

function MatchRankTableViewCell:ctor()
	self.m_first = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT,
		-- valign = cc.TEXT_VALIGNMENT_BOTTOM
		})
	self.m_first:align(display.LEFT_CENTER, -TABLE_WIDTH/2+10, 0)
	self.m_first:addTo(self)

	self.m_second = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT,
		-- valign = cc.TEXT_VALIGNMENT_BOTTOM
		})
	self.m_second:align(display.LEFT_CENTER, self.m_first:getPositionX()+40, 0)
	self.m_second:addTo(self)

	self.m_third= cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT,
		-- valign = cc.TEXT_VALIGNMENT_BOTTOM
		})
	self.m_third:align(display.LEFT_CENTER, self.m_first:getPositionX()+160, 0)
	self.m_third:addTo(self)
end

function MatchRankTableViewCell:setFirstString(label)
	if self.m_first then
		self.m_first:setString(label)
	end
end

function MatchRankTableViewCell:setSecondString(label)
	if self.m_second then
		self.m_second:setString(label)
	end
end

function MatchRankTableViewCell:setThirdString(label)
	if self.m_third then
		self.m_third:setString(label)
	end
end

------------------------------------------------------------------------------------------

local MatchRankTableView = class("MatchRankTableView", function()
		return display.newLayer()
	end)

function MatchRankTableView:create(matchId,bonusName,gainName,usersNum, payType)
	local tab = MatchRankTableView:new()
	tab:init(matchId,bonusName,gainName,usersNum, payType)
	return tab
end

function MatchRankTableView:ctor()
	self.m_sourceData = {}

	self.m_tableView = nil
	self.m_tabIndex = 0
	self.m_logic = require("app.Logic.Room.MatchRankLogic"):create(self)
	self.m_matchId = ""
	self.m_bonusName = ""
	self.m_gainName = ""
	self.m_usersNum = 0
	self.m_hadShowTip = 0.0
	self.m_isMore = 0.0

	-- 允许 node 接受触摸事件
    self:setTouchEnabled(false)

	-- 注册触摸事件
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	-- event.name 是触摸事件的状态：began, moved, ended, cancelled
    	-- event.x, event.y 是触摸点当前位置
    	-- event.prevX, event.prevY 是触摸点之前的位置
    	printf("sprite: %s x,y: %0.2f, %0.2f",
           event.name, event.x, event.y)

    	-- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
    	-- 则必须返回 true
    	if event.name == "began" then
        	return self:ccTouchBegan(event)
    	end
	end)
end

function MatchRankTableView:setMatchInfo(matchId, bonusName, gainName, usersNum, payType)

	self.m_matchId = matchId
	self.m_bonusName = bonusName
	self.m_gainName = gainName
	self.m_usersNum = usersNum
	self.m_payType = payType
	self.m_logic.m_payType = payType
end

function MatchRankTableView:init(matchId, bonusName, gainName, usersNum, payType)
    
	self:manualLoadxml()
	self.m_matchId = matchId
	self.m_bonusName = bonusName
	self.m_usersNum = usersNum
	self.m_gainName = gainName
	self.m_payType = payType
	self.m_logic.m_payType = payType

	self.m_tableView = cc.ui.UIListView.new{
		-- bg = "sunset.png",
		-- bgScale9 = true,
		viewRect = cc.rect(-34,10,293,241),
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		-- :onTouch(handler(self, self.touchListener))
	self.m_tableView:setTag(kTagTableView)
	self:initTableCells()
    
	local pParent = self.more_select_tab_layer
	if(pParent) then
	
		pParent:addChild(self.m_tableView,5)
		self.m_tableView:reload()
		self:changeTableViewOffset()
	end
    
	self:setButtonSelected(self.rank_button,true)
	self:updateMatchRankInfo(0,0)
	return true
end

function MatchRankTableView:manualLoadxml()
	---------------------------------------------------------------------------------------
	self.more_button_layer = display.newNode()
	self.more_button_layer:addTo(self)

	self.more_button = cc.ui.UIPushButton.new({normal="moreLayerBtn.png",pressed="moreLayerBtn.png",disabled="moreLayerBtn.png"})
	self.more_button:align(display.LEFT_TOP, 9, 570)
	self.more_button:addTo(self.more_button_layer, 0, 111)
	self.more_button:onButtonClicked(function(event)
		self:button_click(111)
	end)

	self.match_blind_info = cc.ui.UILabel.new({
		text = "0/0",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
	self.match_blind_info:align(display.LEFT_CENTER, 21, 536)
	self.match_blind_info:addTo(self.more_button_layer, 1)
	

	self.match_player_rank = cc.ui.UILabel.new({
		text = "0",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
	self.match_player_rank:align(display.LEFT_CENTER, 21, 555)
	self.match_player_rank:addTo(self.more_button_layer, 1)
	

	self.match_player_total = cc.ui.UILabel.new({
		text = "/0",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
	self.match_player_total:align(display.LEFT_CENTER, 21, 555)
	self.match_player_total:addTo(self.more_button_layer, 1)

	self.match_ante_info = cc.ui.UILabel.new({
		text = "前注：0",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
	self.match_ante_info:align(display.LEFT_CENTER, 21, 517)
	self.match_ante_info:addTo(self.more_button_layer, 1)
	self.match_ante_info:setVisible(false)
	---------------------------------------------------------------------------------------
	self.more_select_tab_layer = display.newNode()
	self.more_select_tab_layer:align(display.LEFT_TOP, 9, 570)
	self.more_select_tab_layer:addTo(self)
	self.more_select_tab_layer:setContentSize(cc.size(238, 386))
	self.more_select_tab_layer:setVisible(false)

	cc.ui.UIImage.new("infoBk.png")
		:align(display.LEFT_TOP, 0, 386) 
		:addTo(self.more_select_tab_layer, 1)

	self.infoTabBG = cc.ui.UIImage.new("infoTabBG.png")
		:align(display.LEFT_TOP, 10, 380) 
		:addTo(self.more_select_tab_layer, 1)

	self.rank_button = cc.ui.UIPushButton.new({normal="rankBtn.png",pressed="rankBtn1.png",disabled="rankBtn1.png"})
	self.rank_button:align(display.LEFT_TOP, 10, 377)
	self.rank_button:addTo(self.more_select_tab_layer, 2, 112)
	self.rank_button:onButtonClicked(function(event)
		self:button_click(112)
	end)
	self.rank_button:setButtonEnabled(false)

	self.reward_button = cc.ui.UIPushButton.new({normal="rewardBtn.png",pressed="rewardBtn1.png",disabled="rewardBtn1.png"})
	self.reward_button:align(display.LEFT_TOP, 134, 377)
	self.reward_button:addTo(self.more_select_tab_layer, 2, 113)
	self.reward_button:onButtonClicked(function(event)
		self:button_click(113)
	end)

	self.rank_layer = display.newNode()
	self.rank_layer:addTo(self.more_select_tab_layer, 3)
	self.rank_layer:setVisible(false)

	cc.ui.UILabel.new({
		text = "你当前排名：",
		font = "黑体",
		size = 18,
		color = cc.c3b(235,235,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 19, 309)
		:addTo(self.rank_layer)

	self.detail_player_rank = cc.ui.UILabel.new({
		text = "0",
		font = "Arial",
		size = 18,
		color = cc.c3b(0,255,0),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 130, 309)
		:addTo(self.rank_layer)

	self.detail_player_total = cc.ui.UILabel.new({
		text = "/0",
		font = "黑体",
		size = 18,
		color = cc.c3b(235,235,255),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 145, 309)
		:addTo(self.rank_layer)

	local gap = 60
	local rankViewStartX = 19
	cc.ui.UILabel.new({
		text = "排名",
		font = "Arial",
		size = 18,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, rankViewStartX, 271)
		:addTo(self.rank_layer)

	cc.ui.UILabel.new({
		text = "用户名",
		font = "Arial",
		size = 18,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, rankViewStartX+gap, 271)
		:addTo(self.rank_layer)

	cc.ui.UILabel.new({
		text = "筹码",
		font = "Arial",
		size = 18,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, rankViewStartX+2*gap+40, 271)
		:addTo(self.rank_layer)

	local lineImg = cc.ui.UIImage.new("line.png")
		:align(display.LEFT_BOTTOM, 18, 292) 
		:addTo(self.rank_layer, 1)
	lineImg:setScaleX(280/lineImg:getContentSize().width)


	self.reward_layer = display.newNode()
	self.reward_layer:addTo(self.more_select_tab_layer, 3)
	self.reward_layer:setVisible(false)

	cc.ui.UILabel.new({
		text = "排名",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 19, 309)
		-- :addTo(self.reward_layer)

	cc.ui.UILabel.new({
		text = "奖励",
		font = "Arial",
		size = 16,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 19, 309)
		:addTo(self.reward_layer)

	---------------------------------------------------------------------------------------
	self.match_info_with_ante_layer = display.newNode()
	self.match_info_with_ante_layer:addTo(self)
	self.match_info_with_ante_layer:setVisible(false)

	cc.ui.UIImage.new("bg_7_jbs_tips_2_android.png")
		:align(display.LEFT_TOP, 114, 582) 
		:addTo(self.match_info_with_ante_layer)

	self.match_info_with_ante_label1 = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 18,
		color = cc.c3b(34,34,34),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 144, 560)
		:addTo(self.match_info_with_ante_layer)

	self.match_info_with_ante_label2 = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 18,
		color = cc.c3b(34,34,34),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 144, 536)
		:addTo(self.match_info_with_ante_layer)

	self.match_info_with_ante_label3 = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 18,
		color = cc.c3b(34,34,34),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 144, 512)
		:addTo(self.match_info_with_ante_layer)
	---------------------------------------------------------------------------------------
	self.match_info_no_ante_layer = display.newNode()
	self.match_info_no_ante_layer:addTo(self)
	self.match_info_no_ante_layer:setVisible(false)

	cc.ui.UIImage.new("bg_7_jbs_tips1_android.png")
		:align(display.LEFT_TOP, 114, 572) 
		:addTo(self.match_info_no_ante_layer)

	self.match_info_no_ante_label1 = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 18,
		color = cc.c3b(34,34,34),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 144, 550)
		:addTo(self.match_info_no_ante_layer)

	self.match_info_no_ante_label2 = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 18,
		color = cc.c3b(34,34,34),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, 144, 526)
		:addTo(self.match_info_no_ante_layer)

	---------------------------------------------------------------------------------------
	self.match_ante_layer = display.newNode()
	self.match_ante_layer:addTo(self)
	self.match_ante_layer:setVisible(false)

	cc.ui.UIImage.new("bg_7_jbs_tips3_android.png")
		:align(display.LEFT_TOP, 28, 515) 
		:addTo(self.match_ante_layer)

	self.match_ante_label = cc.ui.UILabel.new({
		text = "",
		font = "Arial",
		size = 18,
		color = cc.c3b(34,34,34),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, 117, 474)
		:addTo(self.match_ante_layer)

	---------------------------------------------------------------------------------------

end

function MatchRankTableView:showSngContent()
	self.infoTabBG:setVisible(false)
	self.reward_button:setVisible(false)
	self.rank_button:setPositionX(60)
end

function MatchRankTableView:initTableCells()

	if self.tableViewCells then
		self.m_tableView:removeAllItems()
	end
	self.tableViewCells=nil
	self.tableViewCells={}
	if self.m_sourceData==nil or #self.m_sourceData<=0 then
		return
	end
	
	for i=1,#self.m_sourceData do
		local item = self.m_tableView:newItem()
		self.tableViewCells[i] = MatchRankTableViewCell:create()
		item:addContent(self.tableViewCells[i])
		item:setItemSize(293,30)
		self.m_tableView:addItem(item)
		self.tableViewCells[i]:setFirstString(self.m_sourceData[i].first)
		self.tableViewCells[i]:setSecondString(self.m_sourceData[i].second)
		self.tableViewCells[i]:setThirdString(self.m_sourceData[i].third)
	end
	self.m_tableView:reload()
end

function MatchRankTableView:updateMatchInfo(playerNum, totalNum, smallBlind, bigBlind, ante)

	local bTmp = self.m_hadShowTip
	self.m_hadShowTip = true
	self:updateMatchRankInfo(playerNum,totalNum)
	self:updateMatchBlindInfo(smallBlind,bigBlind)
	self:updateMatchAnteInfo(ante)
    
	self:changeMatchInfoPosition(ante > 0)
	
	self.m_hadShowTip = bTmp
	if(not self.m_hadShowTip) then
	
		if(ante > 0) then
		
			self:showMatchInfoAnteTip(playerNum,totalNum,smallBlind,bigBlind,ante)
			self.m_hadShowTip = true
		else
		
			self:showMatchInfoNoAnteTip(playerNum,totalNum,smallBlind,bigBlind)
		end
	end
end

function MatchRankTableView:updateMatchRankInfo(playerRank, totalPlayer)
	
	local strRank = StringFormat:FormatDecimals(playerRank,2)
	local strTotal = "/" .. StringFormat:FormatDecimals(totalPlayer,2)
    
	local pMainRank = self.match_player_rank
	local pMainTotal = self.match_player_total
	local pDetailRank = self.detail_player_rank
	local pDetailTotal = self.detail_player_total
    
	if(pMainRank and pMainTotal and pDetailRank and pDetailTotal) then
	
		pMainRank:setString(strRank)
		pDetailRank:setString(strRank)
		pMainTotal:setString(strTotal)
		pDetailTotal:setString(strTotal)
        
		pMainTotal:setPosition(cc.p(pMainRank:getPositionX() + pMainRank:getContentSize().width ,pMainTotal:getPositionY()))
		pDetailTotal:setPosition(cc.p(pDetailRank:getPositionX() + pDetailRank:getContentSize().width ,pDetailTotal:getPositionY()))
	end
end

function MatchRankTableView:updateMatchBlindInfo(smallBlind, bigBlind)

	local strBlind = StringFormat:FormatDecimals(smallBlind,2) .. "/" .. StringFormat:FormatDecimals(bigBlind,2)
    
	local pBlind = self.match_blind_info
	if(pBlind) then
	
		pBlind:setString(strBlind)
	end
end

function MatchRankTableView:updateMatchAnteInfo(ante)

	local strAnte = StringFormat:FormatDecimals(ante,2)
    
	local pAnte = self.match_ante_info
	if(pAnte) then
	
		pAnte:setString(strAnte)
	end
    
	self:changeMatchInfoPosition(ante > 0)
	if(not self.m_hadShowTip) then
	
		if(ante > 0) then
		
			self:showAnteInfoTip(ante)
			self.m_hadShowTip = true
		end
	end
end

function MatchRankTableView:updateMatchRankList(pData)
	if(pData and self.m_tabIndex == 0) then
	
		self.m_sourceData = pData
		self:initTableCells()
	end
end

function MatchRankTableView:updateMatchRewardList(pData)

	if(pData and self.m_tabIndex == 1) then
	
		self.m_sourceData = pData
		self:initTableCells()
	end
end

function MatchRankTableView:button_click(menuItemTag)
	
	if menuItemTag == kTagMoreButton then
        self.more_select_tab_layer:setVisible(true)
        self.match_info_no_ante_layer:setVisible(false)
        self.match_info_with_ante_layer:setVisible(false)
        self.match_ante_layer:setVisible(false)
        self:switchAnimation(true)
        self:setTouchEnabled(true)
    elseif menuItemTag == kTagRankListButton then
        self.m_tabIndex = 0
        self.m_tableView:setViewRect(cc.rect(-34,10,293,241))
        self.m_sourceData = nil
        self.m_sourceData = {}
        self.m_tableView:reload()
        self:changeTableViewOffset()
        self:setTouchEnabled(true)
		self.rank_button:setButtonEnabled(false)
		self.reward_button:setButtonEnabled(true)
    elseif menuItemTag == kTagRewadListButton then
        self.m_tabIndex = 1
        self.m_tableView:setViewRect(cc.rect(-34,10,293,241))
        self.m_sourceData = nil
        self.m_sourceData = {}
        self.m_tableView:reload()
        self:changeTableViewOffset()
        self:setTouchEnabled(true)
		self.rank_button:setButtonEnabled(true)
		self.reward_button:setButtonEnabled(false)
	end

	if(self.m_tabIndex == 0) then
	
		if(self.m_logic) then
		
			self.m_logic:getMatchRankList(self.m_matchId)
		end
	else
	
		if(self.m_logic) then
		
			self.m_logic:getMatchRewardList(self.m_matchId,self.m_bonusName,self.m_gainName,self.m_usersNum)
		end
        
	end
    
	self:setButtonSelected(self.rank_button,self.m_tabIndex == 0)
	self:setButtonSelected(self.reward_button,self.m_tabIndex == 1)
	self.rank_layer:setVisible(self.m_tabIndex == 0)
	self.reward_layer:setVisible(self.m_tabIndex == 1)
end

function MatchRankTableView:ccTouchBegan(event)

    local pos  = cc.p(event.x, event.y)
    local pNode = self.more_select_tab_layer
    local rect = cc.rect(pNode:getPositionX() - pNode:getContentSize().width * pNode:getAnchorPoint().x,
        pNode:getPositionY() - pNode:getContentSize().height * pNode:getAnchorPoint().y,
        238, pNode:getContentSize().height)
    
    if(event.x>238 or not cc.rectContainsPoint(rect, pos)) then
        self:switchAnimation(false)
    end
    return true
end

function MatchRankTableView:setButtonSelected(button, isSelected)

	if button then
		button.state = "selected"
	end
end

function MatchRankTableView:switchAnimation(isToMore)

	local FDURATION = 0.2
    local pMoreLayer = self.more_select_tab_layer

	if isToMore then
	
		local pLessLayer = self.more_button_layer
		pMoreLayer:setScale(0.5)
		pMoreLayer:runAction(cc.ScaleTo:create(FDURATION,1.0))
        
		pLessLayer:setVisible(false)
	else
		
		pMoreLayer:setScale(1.0)
        local seq = cc.Sequence:create(cc.ScaleTo:create(FDURATION,0.5),cc.Hide:create(),cc.CallFunc:create(handler(self, self.showMainLayer)))
        seq:setTag(SeqActionTag)
        pMoreLayer:runAction(seq)
        self:setTouchEnabled(false)
	end
	self.m_isMore = isToMore
end

function MatchRankTableView:showMainLayer()

	local pLayer = self.more_button_layer
	if pLayer then
	
		pLayer:setVisible(true)
	end
end

function MatchRankTableView:changeTableViewOffset()

	local size = self.m_tableView:getContentSize()
	if(size.height > 0) then
	
		local fViewHeight = (self.m_tabIndex == 1) and 241 or 206
		local fHeight = fViewHeight - size.height
		self.m_tableView:setContentOffset(cc.p(0,fHeight),false)
	end
end

function MatchRankTableView:changeMatchInfoPosition(hasAnte)

	local pPlayerRank = self.match_player_rank
	local pTotalPlayers = self.match_player_total
	local pBlind = self.match_blind_info
	local pAnte = self.match_ante_info
    
	if(hasAnte) then
	
		pPlayerRank:setPosition(cc.p(pPlayerRank:getPositionX(),555))
		pTotalPlayers:setPosition(cc.p(pTotalPlayers:getPositionX(),555))
		pBlind:setPosition(cc.p(pBlind:getPositionX(),536))
		pAnte:setVisible(true)
	else
	
		pPlayerRank:setPosition(cc.p(pPlayerRank:getPositionX(),555-10))
		pTotalPlayers:setPosition(cc.p(pTotalPlayers:getPositionX(),555-10))
		pBlind:setPosition(cc.p(pBlind:getPositionX(),536-10))
		pAnte:setVisible(false)
	end
end

function MatchRankTableView:showMatchInfoNoAnteTip(playerRank, totalPlayer, smallBlind, bigBlind)

	local pLabel = {}
	local strId = {"match_info_no_ante_label1","match_info_no_ante_label2"}
	pLabel[1] = self.match_info_no_ante_label1
	pLabel[2] = self.match_info_no_ante_label2
    
	strId[1] = playerRank .. "/" .. totalPlayer .. "为您当前排名信息"
	strId[2] = StringFormat:FormatDecimals(smallBlind,2) .. "/" .. StringFormat:FormatDecimals(bigBlind,2) .. "为当前比赛盲注级别"
    
	pLabel[1]:setString(strId[1])
	pLabel[2]:setString(strId[2])
    
	local pNode = self.match_info_no_ante_layer
	pNode:runAction(CCSequence:create(CCShow:create(),CCDelayTime:create(1),CCHide:create(),NULL))
end

function MatchRankTableView:showMatchInfoAnteTip(playerRank, totalPlayer, smallBlind, bigBlind, ante)

	local pLabel = {}
	local strId = {"match_info_with_ante_label1","match_info_with_ante_label2","match_info_with_ante_label3"}
	pLabel[1] = self.match_info_with_ante_label1
	pLabel[2] = self.match_info_with_ante_label2
	pLabel[3] = self.match_info_with_ante_label3
    
	strId[1] = playerRank .. "/" .. totalPlayer .. "为您当前排名信息"
	strId[2] = StringFormat:FormatDecimals(smallBlind,2) .. "/" .. StringFormat:FormatDecimals(bigBlind,2) .. "为当前比赛盲注级别"
	strId[3] = StringFormat:FormatDecimals(ante,2) .. "为当前前注"
    
	pLabel[1]:setString(strId[1])
	pLabel[2]:setString(strId[2])
	pLabel[3]:setString(strId[3])
    
	local pNode = self.match_info_with_ante_layer
	pNodeself.runAction(CCSequence:create(CCShow:create(),CCDelayTime:create(1),CCHide:create(),NULL))
end

function MatchRankTableView:showAnteInfoTip(ante)

	local pLabel
	local strId = ""
	pLabel = self.match_ante_label
	strId = StringFormat:FormatDecimals(ante,2) + "为当前前注"
	pLabel:setString(strId)
    
	local pNode = self.match_ante_layer
	pNode:runAction(CCSequence:create(CCShow:create(),CCDelayTime:create(1),CCHide:create(),NULL))
end

return MatchRankTableView