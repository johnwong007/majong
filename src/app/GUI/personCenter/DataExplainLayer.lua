--
-- Author: junjie
-- Date: 2016-01-15 19:24:31
--
--名词解释
local title_list = {"【入局率】","【PFR翻牌前加注】","【AF激进度】","【3-bet再加注】","【Stealing Blinds偷盲】",
	"【Cbet持续下注】","【WTSD摊牌率注】","【BB/100百手盈利率】"}
local content_list = {"VPIP（通常缩写为VP）是玩家主动向底池中投入筹码的比率，即除了位于大盲注并看牌（即没有其他人加注）以外的，所有的跟注/下注/加注行为的频率。它是扑克牌中一项重要的基础数据，通过玩家入局的频率，反应其打牌的松紧度。例如，如果一个牌手的VPIP只有1%，这就表示他很可能只在底牌是KK或者AA时才参与底池；而VPIP为100%则意味着不管这个玩家底牌如何，在翻牌圈前他都会入局。VPIP和一个牌手在牌桌上的形象紧密相关，你和对手都会通过VPIP去考察一个玩家的打法是松还是紧，以及应对其打法的策略。比如，当你的VPIP很低时，你的对手会更少的诈唬你，而你则可以借着紧的形象去诈唬他们，因为他们都会认为，一旦你入局，就是有大牌。但事实上，关于VPIP的高低和牌手的松紧并没有绝对的数字界限，针对不同的人数的牌桌还会有不同的划分。下面以无限注德州扑克六人桌为例进行说明：（1）非常紧的牌手：这类玩家很少入局，他们的VPIP往往小于14%。（2）较紧的牌手：这类的玩家会玩更多还不错的底牌，他们会把VPIP控制在14%-23%，不过整体来说他们的牌还是会很强。（3）较松的牌手：VPIP在23%-32%之间，这类玩家会玩更宽范围的底牌，会有更多运气的成分在里面，比如用79不同花参与底池以期博中顺子。如果他们有好的翻牌后技巧，即使没有成牌也有机会赢得牌局。然而如果翻牌后的技巧不足，运气不会总是站在他们那边。（4）VPIP>40%的非常松的牌手：比起获胜，他们更喜欢主动行动，因为越广的起手牌范围，需要越高超的翻牌后技巧才能驾驭，否则不可能一直都赢。所以你会发现，那些玩的越好、在各类情况下都很自如的牌手，打的会越松。当你的牌技提高了，你也会有更强的能力去处理更多的底牌，但在此之前，适时的控制你的VPIP十分重要。",
	"PFR即翻牌前加注，指的是一个玩家翻牌前加注的比率。比如，10%的PFR表明该玩家在第一轮有10%的情况下会加注。PFR是主动入局（VPIP）的其中一种情况，从两者的概念上看，VPIP反映的是翻牌前跟注或者加注的比率，而PFR只反映翻牌前加注的比率（故PFR在数值上通常也比VPIP低）。PFR和VPIP通常会配合着使用，即（VPIP/PFR）这一比值可以从某种程度上反映一个牌手的技术水平。大多数新手的PFR只占他们VPIP值的一小部分，这就意味着他们没有很好的翻牌前的技巧，更多的入局却很少用加注获取主动。好的牌手PFR可能会占到VPIP的70%，即如果VPIP的值是20%，那么PFR应该大于等于14%是个很理想的情况。FPR比VPIP更有针对性的反映了一个牌手的松紧程度，而（VPIP/PFR）则反映了牌手在翻牌前的激进程度。比如一个牌手的VPIP大部分是由PFR组成，那么就表示他在翻牌前很激进，通常会通过加注来入局。一个牌手VPIP和PFR的情况有以下几种：（1）紧凶型：这类牌手一般有着中VPIP/高PFR（如 22/18），翻牌前技术很强，且在翻牌后通常也可以打得很好。（2）极紧极凶的岩石型玩家：他们有着低VPIP/高PFR（比如 7/5甚至7/6），只在底牌很好的情况下入局。他们很少诈唬，所以当然他们采取行动时，你需要格外注意。（3）松凶型：这类牌手有着高VPIP/高PFR(比如 40/35)，他们可能会随意的跟注或者加注，享受入局并且尝试用各种技巧赢得尽可能多数的底池。（4）松弱型的新手：新手常常喜欢玩很多起手牌，却很少通过正确适时的加注获取主动权，他们有着高VPIP/低PFR（比如 34/5），面对他人的下注不够敏感，翻牌后的技巧性不足使得他们总是为看牌（即看三张翻牌）付出大量的成本。",
	"由于德州扑克有两种赢牌的方式：打到河牌并通过比牌战胜对手；以及迫使所有对手弃牌而赢得底池。故德州扑克中视发出翻牌后的主动下注/加注为激进的行动，跟注为被动的行动。AF即是用来衡量一个玩家打牌激进程度的数值，它的计算方法是（下注的次数+加注的次数）/跟注的次数。一个玩家的AF数据越高，他主动下注或者加注的比例就更高，被动跟注的比例就更低，因此也就更多的掌握了主动权。如果一个AF值低的玩家主动下注，通常你可以推测出他的牌应该是很强的。AF通常会在1.4-4之间，低于这个范围会太过于被动而超过这个范围则打的太过激进。要想在德州扑克中取得更多的胜利，保持合理的激进度、以及应对激进的对手是非常重要的，正确的使用AF这项数据能够帮助你更好的实现这个目标。",
	"即在他人下注，有人加注之后的再加注，由于是一轮下注中的第三次加注，故称3bet。3-bet保持在3-6%是一个不错的范围，一般建议初学者采用强牌来3bet，例如：AA-QQ, AK就是很适合于3-bet的起手牌。Fold to 3-bet是与3bet相对应的另一项数据，即玩家面对3bet时的弃牌率。如果一个玩家的这项数值很高，那么你通过3bet去诈唬他的成功率也越大，反之亦然。根据一个玩家的3-bet和fold to 3-bet两项数值，可以选择更具针对性的策略去应对。例如一个玩家的3-bet值较高，且fold to 3-bet的值也很高，那么赶在他之前进行3-bet会是个不错的选择。",
	"如果没有盲注，每个人都只需要等待好牌再出手就可以了，那样游戏会变得非常的枯燥。而如果一个玩家加注而其他所有玩家都弃牌，不管他底牌如何，都能赢得底池，所以德州扑克实际上是个由盲注引发战争的游戏。Stealing Blinds即偷盲,是指一个玩家单纯的为了赢得盲注而加注，通常指以下情况：当玩家处于断口位（CO）、按钮，或者小盲注的位置时，轮到玩家行动前其他人全部弃牌，这时玩家以盲注为目标而进行加注，以图迫使剩下的玩家也弃牌，从而直接赢得大小盲注。关于偷盲的一点技巧：（1）根据对手的松紧度调整你的战术。你应该尽可能的对紧的选手进行偷盲，因为他们面对加注的弃牌率会更高；些玩家即使在他前面已经有人加注或者再加注了，他也不会轻易放弃盲注，所以当你没牌时，尽量避免偷这类玩家的盲注；而如果是面对那些对偷盲弃牌率高达90%的对手，由于他们不会防御偷盲，你几乎可以拿任意底牌进行偷盲。面对不同类型的对手，你需要设定不同的偷盲战术，以尽可能多的实现偷盲的目的。（2）对手打法是否直接。面对一个打法十分直接的玩家，你可以试着更多的偷盲，因为即使他们跟注，开牌后他们也会很快的暴露自己的牌是否够强，而你可以利用位置优势去进一步的诈唬，从而赢得底池。（3）多用半诈唬等技巧性的方式去偷盲。面对松和激进的玩家，你应该只用潜力牌去偷盲，比如小对子，同花连牌等。因为激进的玩家虽然弃牌率低，但你通过偷盲进行了一次半诈唬，在有位置又有主动权的情况下，一旦发出你需要的牌，你能让激进的对手为他们第二大的底牌支付更多的筹码。千万不要用J-4，K-2不同花之类的高底牌去对他们偷盲，这样一旦他们跟注，发出任何牌都会使你趋于被动。Fold to steal是与steal相对应的另一项数据，用以衡量一个玩家在面对steal时的弃牌率。若一个玩家的fold to cbet值很低，那么你就需要减少他在盲注位置时的steal频率，并更加慎重的选择进行steal的起手牌。",
	"Cbet即持续下注，是指一个玩家在前一轮主动下注或加注后，在当前这一轮再次主动下注。持续下注的典型情况是，一个玩家在翻牌前加注并被另一个玩家跟注，然后他在发出翻牌后继续下注。一般来说，持续下注的大小相当于底池的2/3-3/4是比较适合的，如果下注的太少，很多玩家就会跟注，而如果下注的太多，那么为了赢得底池所冒的风险就太大了。影响持续下注的因素有很多：（1）对手的实力。如果对方实力很强，他就能意识到你的打法，猜到你很可能在用不好的底牌加注，所以他会采取加注或跟注来对抗你的持续下注；（2）入局的玩家数量。一般对手在两个以下时适合采取持续下注；（3）位置。位置越靠后，你能看到越多的对手的行动，从而可以更好的去判断自己是否要进行持续下注。但是也要注意一些有计谋的玩家，他们会采取过牌加注的打法，设圈套并希望你进行持续下注。另外，对于持续下注还有一些点需要注意：（1）翻牌圈牌面越干燥（即没有太多可能的博顺子或同花），越适合持续下注；（2）在比较干燥的翻牌面上，下注量可以少一点；（3）持续下注的原因是为了平衡打法；（4）不要因为一次的失败就否定了持续下注这一打法，你要认识到持续下注是为了从长远的角度去赢得更多的筹码。Fold to cbet是与cbet相对应的另一项数据，用以衡量一个玩家在面对cbet时的弃牌率。若一个玩家的fold to cbet值很低，那么你在翻牌后就应该尽可能的减少cbet的频率，并在拥有大牌时果断的持续下注。最后，要想保证偷盲行为长期上的盈利，你需要有足够好的翻牌后打法，毕竟你不能期待每次偷盲都可以成功。当你能更加熟练的面对偷盲失败之后的局面时（如对手跟注或再加注你的加注），你通过偷盲获得的盈利也就越大。",
	"WTSD即摊牌率，是指一个玩家看到翻牌圈并玩到摊牌的百分比。它表明一个玩家在看到翻牌后打到摊牌的频率，并可以衡量一个玩家在翻牌后弃牌的倾向。这个数据越高，他就越少弃牌，你也就越要少诈唬他，通过用好牌加注来获得最大的收益。如果你面对的是WSTD值很高的玩家，你就可以果断的采取价值下注，相反，果你面对的是WTSD值很低的玩家，那么如果他在河牌下注，而你的底牌是属于边缘牌，你就应该弃牌。一般来说，WTSD值在25%-35%之间是比较合理的，面对低于20%的玩家，你可以持续的诈唬，而面对高于40%的玩家，你应该采取价值下注。",
	"BB/100（百手盈利率）：BB是Big Blind（大盲注）的简称，BB/100用以衡量玩家每玩100手牌局的盈亏。",
}
local bgWidth = CONFIG_SCREEN_WIDTH
local bgHeight = CONFIG_SCREEN_HEIGHT
local contentStartPosX = CONFIG_SCREEN_WIDTH/2-150
local DataExplainLayer = class("DataExplainLayer",function()
		return display.newLayer()
	end)

function DataExplainLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self.mActivitySprite = {}
	self.mAllSelectNode =  {}
	self.params = {}
	self.params.size    = cc.size(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
	self.params.bgType  = 3
	self.params.selectIdx = 1
	self.params.isFullScreen = true
end

function DataExplainLayer:create()
	self:initUI()
	self.mSelectIndex = 1
	self:changeSecBg(1)
end

function DataExplainLayer:initUI()
	local bg = cc.ui.UIImage.new("picdata/public_new/bg.png", {scale9 = true})
    bg:setLayoutSize(bgWidth, bgHeight)
    bg:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, CONFIG_SCREEN_HEIGHT/2)
    	:addTo(self)
    self.mBg = bg

    local backBtn = CMButton.new({normal = "picdata/public_new/btn_back2.png",
        pressed = "picdata/public_new/btn_back2.png"},function () self:back() end)
	backBtn:setPosition(45, bgHeight-40)
	bg:addChild(backBtn)
	    local sprite = cc.ui.UIImage.new("picdata/public_new/mask_foot.png", {scale9=true})
	    sprite:setLayoutSize(CONFIG_SCREEN_WIDTH, 40)
	    sprite:align(display.LEFT_BOTTOM, 0, 0)
	    	:addTo(self,3)

	self.m_pTitle = cc.ui.UILabel.new({
        UILabelType = 1,
        text  = "数据解释",
        font  = "fonts/title.fnt",
        align = cc.ui.TEXT_ALIGN_CENTER,
    })
    self.m_pTitle:align(display.CENTER, bgWidth/2,bgHeight - 40)
    bg:addChild(self.m_pTitle)

    local line1 = cc.ui.UIImage.new("picdata/public_new/line2.png")
    line1:align(display.CENTER, 382/1136*CONFIG_SCREEN_WIDTH, 282)
        :addTo(self.mBg)
    line1:setRotation(-90)
    line1:setScaleX(0.7)
	contentStartPosX = line1:getPositionX()

	local button_images = {
        off = "picdata/personCenterNew/dataExplain/btn_tab.png",
        off_pressed = "picdata/personCenterNew/dataExplain/btn_tab_p.png",
        off_disabled = "picdata/personCenterNew/dataExplain/btn_tab_p.png",
        on = "picdata/personCenterNew/dataExplain/btn_tab_p.png",
        on_pressed = "picdata/personCenterNew/dataExplain/btn_tab.png",
        on_disabled = "picdata/personCenterNew/dataExplain/btn_tab_p.png",
    }
    local button_title = {"VP:入局率(VPIP)","PFR:翻牌前加注率","AF:激进度","3B:再加注率(3-Bet)",
		"STL:偷盲率(Steal)","CB:持续下注(C-Bet)","W:摊牌率(WTSD)","bb/100:百手盈利",}
	local colorN = cc.c3b(255,255,255)
	local colorP = cc.c3b(19,23,31)
	local fontSize = 26
	local fontName = "黑体"

	local group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
	for i=1,#button_title do
		local button = cc.ui.UICheckBoxButton.new(button_images)
	    button:setButtonLabel("off", cc.ui.UILabel.new({
	    	text = button_title[i],
	    	color = colorN,
	    	size = fontSize,
	    	font = fontName
	    	}))
	    button:setButtonLabel("on", cc.ui.UILabel.new({
	    	text = button_title[i],
	    	color = colorP,
	    	size = fontSize,
	    	font = fontName
	    	}))
	    button:setButtonLabel("select", cc.ui.UILabel.new({
	    	text = button_title[i],
	    	color = colorP,
	    	size = fontSize,
	    	font = fontName
	    	}))
	    button:setButtonLabelOffset(-120, 0)
		group:addButton(button)
	end
	group:setButtonsLayoutMargin(0, 0, 0, 0)
		:onButtonSelectChanged(function(event)
            self:switchTab(event.selected)
        end)
        :align(display.CENTER, line1:getPositionX()-299, CONFIG_SCREEN_HEIGHT-66*8-90)
        -- :addTo(bg)
        group:getButtonAtIndex(1):setButtonSelected(true)

    self.mListSize = cc.size(280,bgHeight-110)
    self.mActivityList = cc.ui.UIListView.new({
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
		viewRect = cc.rect(contentStartPosX-self.mListSize.width-25, 0, self.mListSize.width, self.mListSize.height),
		-- bgColor = cc.c4b(125,125,125,125)
	})
	:onTouch(handler(self, self.touchListener))
    :addTo(bg,1) 

    self.mAtivityName = button_title
    for i = 1,#self.mAtivityName do 
		local item = self.mActivityList:newItem() 
		local btnImage1 = "picdata/personCenterNew/dataExplain/btn_tab.png"
		local btnImage2 = "picdata/personCenterNew/dataExplain/btn_tab_p.png"
		local btnActivity = cc.Sprite:create(btnImage1)
	    :align(display.CENTER, 0,0) --设置位置 锚点位置和坐标x,y
	    item:addContent(btnActivity)   
	    	 
		local selecthSprite = cc.Sprite:create(btnImage2)
		selecthSprite:setVisible(false)
		selecthSprite:setPosition(selecthSprite:getContentSize().width/2,selecthSprite:getContentSize().height/2)
		btnActivity:addChild(selecthSprite,0,101)

		local sDetail = cc.ui.UILabel.new({
		        -- UILabelType = 1,
		        text  = self.mAtivityName[i],
		        align = cc.ui.TEXT_ALIGN_CENTER,
		        -- font  = "fonts/tab.fnt",
		    	color = colorN,
		    	size = fontSize,
		    	font = fontName,
		    })
		sDetail:setAnchorPoint(cc.p(0.5, 0.5))
		sDetail:setPosition(cc.p(btnActivity:getContentSize().width/2-10,btnActivity:getContentSize().height/2))
		btnActivity:addChild(sDetail,1,102)
		local sDetail1 = cc.ui.UILabel.new({
		        -- UILabelType = 1,
		        text  = self.mAtivityName[i],
		        align = cc.ui.TEXT_ALIGN_CENTER,
		        -- font  = "fonts/tab_p.fnt",
		    	color = colorP,
		    	size = fontSize,
		    	font = fontName,
		    })
		sDetail1:setAnchorPoint(cc.p(0.5, 0.5))
		sDetail1:setPosition(cc.p(btnActivity:getContentSize().width/2-10,btnActivity:getContentSize().height/2))
		btnActivity:addChild(sDetail1,1,103)
		sDetail1:setVisible(false)
		item:setItemSize(selecthSprite:getContentSize().width, selecthSprite:getContentSize().height+10)	

	   	self.mActivityList:addItem(item)
		self.mActivitySprite[#self.mActivitySprite + 1] = btnActivity

	end	
	self.mActivityList:reload()

-- title_list content_list
    self.m_pContentTitle = cc.ui.UILabel.new({
		text = title_list[1],
		color = cc.c3b(255,255,255),
		size = 32,
		font = "黑体"
		})
    self.m_pContentTitle:align(display.CENTER, contentStartPosX+(CONFIG_SCREEN_WIDTH+299-contentStartPosX-contentStartPosX)/2, CONFIG_SCREEN_HEIGHT - 130)
    	:addTo(self.mBg)
    local line2 = cc.ui.UIImage.new("picdata/public_new/line.png")
    line2:align(display.LEFT_CENTER, line1:getPositionX(), self.m_pContentTitle:getPositionY()-30)
        :addTo(self.mBg)
    line2:setScaleX(0.9)

    local bound = {x = contentStartPosX, y = 0, width = 0, height = line2:getPositionY()-10} 
    bound.width = bgWidth-contentStartPosX-(line1:getPositionX()-299)
    line2:setScaleX(bound.width/line2:getContentSize().width)
    self.m_pScrollViewBound = bound
	local nameValue = cc.ui.UILabel.new({
            text  = content_list[1],
            size  = 26,
            color = cc.c3b(180,192,220),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
            dimensions = cc.size(bound.width,0),
        })
    nameValue:align(display.LEFT_TOP, contentStartPosX,bound.height)
    -- item:addChild(nameValue)
    self.nameValue = nameValue
    self.m_pContentScrollView = cc.ui.UIScrollView.new({
	    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
	    viewRect = bound, 
	   -- scrollbarImgH = "scroll/barH.png",
	   -- scrollbarImgV = "scroll/bar.png",
	   -- bgColor = cc.c4b(125,125,125,125)
	})
    self.m_pContentScrollView:addScrollNode(nameValue)
    :addTo(bg)
end

function DataExplainLayer:switchTab(index)
	if not self.m_pContentScrollView then return end
	self.m_pContentScrollView:getScrollNode():removeFromParent(true)
	-- self.nameValue:setString(content_list[index])

	local nameValue = cc.ui.UILabel.new({
            text  = content_list[index],
            size  = 26,
            color = cc.c3b(180,192,220),
            align = cc.ui.TEXT_ALIGN_LEFT,
            --UILabelType = 1,
            font  = "黑体",
            dimensions = cc.size(self.m_pScrollViewBound.width,0),
        })
    nameValue:align(display.LEFT_TOP, contentStartPosX,self.m_pScrollViewBound.height)
    self.m_pContentScrollView:addScrollNode(nameValue)

    self.m_pContentTitle:setString(title_list[index])
end

function DataExplainLayer:back()
	CMClose(self, true)
end

--[[
	listview:触摸事件，回调
]]
function DataExplainLayer:touchListener(event)
	local name, x, y = event.name, event.x, event.y	
	 if name == "clicked" then
	 	self:checkTouchInSprite_(self.touchBeganX,self.touchBeganY,event.itemPos)
	 else
		if name == "began" then
	        self.touchBeganX = x
	        self.touchBeganY = y
	       return true
	    end	    
	 end
	
end
function DataExplainLayer:checkTouchInSprite_(x, y,itemPos)
	local isTouchList = false	
	for i = 1,#self.mActivitySprite do		
		if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then	
			isTouchList = true
			if self.mSelectIndex == i then 
				return 
			end
			self:changeSecBg(i)
			if self.mAllSelectNode[self.mSelectIndex] then 
				self.mAllSelectNode[self.mSelectIndex]:setVisible(false) 
			end
			self.mSelectIndex = i
			if self.mAllSelectNode[self.mSelectIndex] then 
				self.mAllSelectNode[self.mSelectIndex]:setVisible(true) 
			else	
				self:onMenuSwitch(i)
			end
			
		else
			if self.mActivitySprite[i] then
				self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
				self.mActivitySprite[i]:getChildByTag(103):setVisible(false)
				self.mActivitySprite[i]:getChildByTag(102):setVisible(true)
			end
		end
	end	
	
	if not isTouchList then
		self.mActivitySprite[self.mSelectIndex]:getChildByTag(101):setVisible(true)
		self.mActivitySprite[self.mSelectIndex]:getChildByTag(103):setVisible(true)
		self.mActivitySprite[self.mSelectIndex]:getChildByTag(102):setVisible(false)
	end
end

function DataExplainLayer:changeSecBg(idx)	
	self.mActivitySprite[idx]:getChildByTag(101):setVisible(true)
	self.mActivitySprite[idx]:getChildByTag(103):setVisible(true)
	self.mActivitySprite[idx]:getChildByTag(102):setVisible(false)
end

function DataExplainLayer:onMenuSwitch(idx)	
	self:switchTab(idx)
end
return DataExplainLayer