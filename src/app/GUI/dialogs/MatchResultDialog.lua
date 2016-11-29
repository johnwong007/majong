local DialogBase = require("app.GUI.roomView.DialogBase")

local MatchResultDialog = class("MatchResultDialog", function(event)
		return DialogBase:new()
	end)

function MatchResultDialog:create(target, callfunc, rank, prize, matchPoint, matchName, isTitleHide)
	local dialog = MatchResultDialog:new()
	dialog:initWithParam(target, callfunc, rank, prize, matchPoint, matchName, isTitleHide)
	return dialog
end

function MatchResultDialog:initWithParam(target, callfunc, rank, prize, matchPoint, matchName, isTitleHide)
	self.m_rank = rank
	self.m_prize = prize
	self.m_matchPoint = matchPoint+0
	self.m_target = target
	self.m_callback = callfunc
	self.m_matchName = matchName
	self.m_titleHide = isTitleHide
end

function MatchResultDialog:ctor()
	self.m_rank = 0
	self.m_prize = ""
	self.m_matchPoint = 0.0
	self.m_target = nil
	self.m_callback = nil
	self.m_titleHide = 0
	self.m_matchName = ""
    self:setNodeEventEnabled(true)
end

function MatchResultDialog:onEnter()
    self:manualLoadxml()
	self:updateInfo()
	self:reloadLayout(self.m_rank, self.m_titleHide)
end

function MatchResultDialog:onExit()

end

function MatchResultDialog:manualLoadxml()
	self.title = cc.ui.UIImage.new("profitInfoBG.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	local width = 460
	local height = 320
	self.m_node = display.newNode()
	self.m_node:addTo(self)
	self.m_node:setPosition(display.cx-width, display.cy-height)

	cc.ui.UIImage.new("profitInfoTitle.png")
		:align(display.CENTER, 460, 470)
		:addTo(self.m_node)

	cc.ui.UILabel.new({
		text = "比赛名次",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 32,
		color = cc.c3b(26,26,26),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, 480, 480)
		:addTo(self.m_node, 1)

	self.close = cc.ui.UIPushButton.new({normal="btn_2_close.png", pressed="btn_2_close2.png", disabled="btn_2_close2.png"})
		:align(display.CENTER, 680, 519)
		:addTo(self.m_node, 4)
		:onButtonClicked(function(event)
			self:button_click(100)
			end)

	self.player_rank_sprite = cc.ui.UIImage.new("cup1.png")
		:align(display.CENTER_BOTTOM, 480, 279)
		:addTo(self.m_node, 4)

	self.fringe = cc.ui.UIImage.new("fringe.png")
		:align(display.CENTER_BOTTOM, 460, 279)
		:addTo(self.m_node, 4)

	self.fringe1 = cc.ui.UIImage.new("fringe1.png")
		:align(display.CENTER_BOTTOM, 473, 279)
		:addTo(self.m_node, 4)
	self.fringe1:setVisible(false)

	self.add = cc.ui.UIImage.new("add.png")
		:align(display.CENTER, 320, 252)
		:addTo(self.m_node, 4)
	self.add:setVisible(false)


	self.match_point_label = cc.ui.UILabel.new({
		text = "0积分",
		font = "Arial",
		size = 30,
		color = cc.c3b(255,228,173),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.CENTER, 393, 250)
		:addTo(self.m_node, 4)
	self.match_point_label:setVisible(false)

	self.match_prize_label = cc.ui.UILabel.new({
		text = "0金币",
		font = "黑体",
		size = 30,
		color = cc.c3b(255,228,173),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, 480, 250)
		:addTo(self.m_node, 4)


	self.no_prize_label = cc.ui.UILabel.new({
		text = "遗憾没得到奖励，再接再厉！",
		font = "黑体",
		size = 30,
		color = cc.c3b(161,166,178),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, 480, 253)
		:addTo(self.m_node, 4)
	self.no_prize_label:setVisible(false)

	self.player_game = cc.ui.UIPushButton.new({normal="shareResultBtn.png", pressed="shareResultBtn.png", disabled="shareResultBtn.png"})
		:align(display.CENTER, 480, 170)
		:addTo(self.m_node, 4)
		:onButtonClicked(function(event)
			self:button_click(101)
			end)	
end

function MatchResultDialog:button_click(tag)
	if tag==100 then --返回大厅
        self:runCallback(0)
    elseif tag==101 then --继续游戏
        self:runCallback(0)
		local temp = lang_WECHATSHARE_TOURNEY1
		temp = temp..self.m_matchName
		temp = temp..lang_WECHATSHARE_TOURNEY2
		temp = temp..self.m_rank
		temp = temp..lang_WECHATSHARE_TOURNEY3
		local data       = {title = "分享到微信",
			content = temp,
			nType = 1,
			url = "www.debao.com"}
		QManagerPlatform:shareToWeChat(data) 
	end
	self:removeFromParent(true)
end

function MatchResultDialog:reloadLayout(rank, isTitleHide)

	local cupId = {
	--三个奖杯
		"picdata/gamescene/cup1.png",
		"picdata/gamescene/cup2.png",
		"picdata/gamescene/cup3.png"
	}
    
	local hasCup = (self.m_rank > 0 and self.m_rank < 4)
    
	local pCup = self.player_rank_sprite
	if(isTitleHide==0) then
		-- self.title_icon:setVisible(false)
	end
	if(self.m_rank > 0 and self.m_rank < 4) then
		-- dump(cupId[self.m_rank])
		local pTexture = cc.Director:getInstance():getTextureCache():addImage(cupId[self.m_rank])
		pCup:setTexture(pTexture)
		pCup:setVisible(hasCup)
	else
	
        pCup:setVisible(false)
        if (self.m_prize=="" and self.m_matchPoint<=0) then
            local label = cc.LabelBMFont:create(""..self.m_rank, "picdata/gamescene/blueNum.fnt")
            label:setAnchorPoint(cc.p(0.5, 0.5))
            label:setPosition(cc.p(480 , 370))
            self.m_node:addChild(label,35)
        else
            local label = cc.LabelBMFont:create(""..self.m_rank, "picdata/gamescene/yellowNum.fnt")
            label:setAnchorPoint(cc.p(0.5, 0.5))
            label:setPosition(cc.p(480 , 370))
            self.m_node:addChild(label,35)
        end
        
	end
	
	local COUNT = 2
    
	local hasCupPos= {cc.p(480,252),cc.p(490,252)}
	local noCupPos = {cc.p(480,252),cc.p(490,252)}
    
	local hasCupAnchor = {cc.p(0.5,0.5),cc.p(0.5,0.5)}
	local noCupAnchor = {cc.p(0.5,0.5),cc.p(0.5,0.5)}
    
	local labelId = {"match_point_label","match_prize_label"}
	local pLabel = {}
    
	for i=1,COUNT do
		if i==1 then
			pLabel[i] = self.match_point_label
		else
			pLabel[i] = self.match_prize_label
		end
		if hasCup then
			pLabel[i]:setAnchorPoint(hasCupAnchor[i])
			pLabel[i]:setPosition(hasCupPos[i])
		else
		
			pLabel[i]:setAnchorPoint(noCupAnchor[i])
			pLabel[i]:setPosition(noCupPos[i])
		end
        
	end
	if not hasCup then
       self.fringe1:setVisible(true)
       self.fringe:setVisible(false)
	end
end

function MatchResultDialog:updateInfo()

	local str = ""
    
    
	local pPoint = self.match_point_label
	if(self.m_matchPoint > 0) then
        self.add:setVisible(true)
		-- pPoint:setVisible(true)
		str = StringFormat:FormatDecimals(self.m_matchPoint,2) .. "积分"
		pPoint:setString(str)
	else
	
		pPoint:setVisible(false)
	end

	local pPrize = self.match_prize_label
    local noPrize = self.no_prize_label
	if self.m_prize ~= "" then
	
        self.add:setVisible(true)
		pPrize:setVisible(true)
		str = self.m_prize .. ""
		pPrize:setString(str)
		pPoint:setVisible(false)
	else
	
		pPrize:setVisible(false)
	end
    if self.m_prize=="" and self.m_matchPoint<=0 then
        noPrize:setVisible(true)
        self.add:setVisible(false)

        noPrize:setString("恭喜你获得第"..self.m_rank.."名！")
    end
end

function MatchResultDialog:runCallback(data)

	if(self.m_target and self.m_callback) then
	
		self.m_callback(self, data)
	end
end

return MatchResultDialog