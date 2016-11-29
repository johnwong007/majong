--
-- Author: junjie
-- Date: 2016-03-18 10:03:58
--
--私人牌局

local CMCommonLayer = require("app.Component.CMCommonLayer")
local MyMatchLayer = class("MyMatchLayer",CMCommonLayer)
local CMColorLabel     = require("app.Component.CMColorLabel")
require("app.Network.Http.DBHttpRequest")
local myInfo = require("app.Model.Login.MyInfo")
local QDataMyMatchList = nil
local EnumMenu =
{ 
    
}
function MyMatchLayer:ctor(params)
  QDataMyMatchList = QManagerData:getCacheData("QDataMyMatchList")
  self.mActivitySprite = {}
  self.mTableSize = 0
  self.mCurSelectIndex = nil
end
function MyMatchLayer:create()
    MyMatchLayer.super.ctor(self,{
		-- titlePath = "picdata/personCenterNew/myMatch/w_title_pyj.png",
		titlePath = "朋友局",
		titleFont = "fonts/title.fnt",
    	titleOffY = -40,
    	-- bgType = 7,
		isFullScreen = true,
    	}) 
    MyMatchLayer.super.initUI(self)
   	
   	local bg = cc.Sprite
    self:createLeftList( )
    -- self:createRightUI()
    -- self:createNoMatch()
end
function MyMatchLayer:onExit()
	QManagerData:removeCacheData("QDataMyMatchList")
	QDataMyMatchList = nil

end
function MyMatchLayer:createNoMatch()
	if self.mNoNode then self.mNoNode:removeFromParent() self.mNoNode = nil end
	local bgWidth =  510
    local bgHeight =  500
	self.mNoNode = cc.Node:create()
	self.mBg:addChild(self.mNoNode)

	local icon = cc.Sprite:create("picdata/public/icon_empty.png")
    icon:setPosition(self.mBg:getContentSize().width/2, bgHeight/2+150)
    self.mNoNode:addChild(icon,1)

    local name = cc.ui.UILabel.new({
        text  = "您暂未创建或参加朋友局",
        color = cc.c3b(134, 153, 191),
        size  = 24,
        align = cc.ui.TEXT_ALIGN_CENTER,
        --UILabelType = 1,
        font  = "黑体",
    })
    name:align(display.CENTER, self.mBg:getContentSize().width/2, bgHeight/2 + 60)
    self.mNoNode:addChild(name) 

    local btnChange = CMButton.new({normal = "picdata/public_new/btn_greenlong.png",pressed = "picdata/public_new/btn_greenlong_p.png"},function () 
    	CMOpen(require("app.GUI.hallview.PrivateHallView"), self, 0, 0, 10) end, {scale9 = false})    
    :align(display.CENTER, self.mBg:getContentSize().width/2,bgHeight/2-40) --设置位置 锚点位置和坐标x,y
    :addTo(self.mNoNode)
    btnChange:setButtonLabel("normal",cc.ui.UILabel.new({
	    color = cc.c3b(255, 255, 255),
	    -- color = cc.c3b(255, 255, 155),
	    text = "约朋友局",
	    size = 28,
	    font = "黑体",
		}) )  
end
function MyMatchLayer:createLeftList()
	local cfgData = QDataMyMatchList:getMsgData()
	if true then	
		dump(cfgData)
	 	if not cfgData then
	 		DBHttpRequest:getPriTableList(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId,0,50)
	 		return
	 	end
	 	if not cfgData["INFO"] or tonumber(cfgData["INFO"]["num"]) <= 0 then
	 		self:createNoMatch()
	 		return 
	 	end
	else	 	
		cfgData= {}
		cfgData["INFO"] = {["num"] = 2}
		cfgData["LIST"] = {}
	end


    local line1 = cc.ui.UIImage.new("picdata/public_new/line2.png")
    line1:align(display.CENTER, self.mBg:getContentSize().width/2+15, self.mBg:getContentSize().height/2-40)
        :addTo(self.mBg)
    line1:setRotation(-90)
    line1:setScaleX(0.7)
    self.mLine = line1

	if  self.mList then self.mList:removeFromParent() self.mList = nil end
	local leftSize = cc.size(458+20,CONFIG_SCREEN_HEIGHT-105+30)	
	self.mList = cc.ui.UIListView.new {
    	-- bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(line1:getPositionX()-leftSize.width-30, -40, leftSize.width, leftSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg)    
	
    local backPath = "picdata/personCenterNew/myMatch/bg_list.png"
    local commonPath= "picdata/personCenterNew/myMatch/bg_normal.png"
    local commonPath2 = "picdata/personCenterNew/myMatch/bg_sng.png"
    local manzhuPath= "picdata/personalCenter/icon_jb.png"
    manzhuPath = "picdata/personCenterNew/myMatch/icon_blind.png"
    local timePath  = "picdata/personalCenter/icon_time.png"
    timePath  = "picdata/personCenterNew/myMatch/icon_time.png"
    -- local selectPath= "picdata/personalCenter/bg_dbj_dj.png"
    local selectPath= "picdata/personCenterNew/myMatch/xz.png"

 	self.mTableSize = tonumber(cfgData["INFO"]["num"])
	 for i = 1,self.mTableSize do

		local itemData = cfgData["LIST"][i] or {}
		local item = self.mList:newItem() 

		local node = display.newNode()	
		item:addContent(node) 

		local matchPath = commonPath
	   	local nStatus   = "已结束"
	   	if itemData[TABLE_TYPE] == "SNG" then
	   		-- backPath = commonPath2
	   		if itemData[END_TIME] == "None" then
	   			nStatus   = "正在进行中。。。"
	   		end
	   	else
	   		-- backPath = commonPath
	   		local nStartTime = CMStringTime(itemData[START_TIME]) or 0
	   		local nEndTime = CMStringTime(itemData[END_TIME]) or 0
	   		 nStatus = CMGetOverTime(math.abs(nEndTime - nStartTime))
	   	end

		local bgWidth = 438
		local bgHeight= 156
		local bg = cc.ui.UIImage.new(backPath, {scale9=true})
		bg:setLayoutSize(bgWidth, bgHeight)
		bg:setPosition(0,0)
		node:addChild(bg)
		node:setContentSize(bgWidth,bgHeight+7)
		item:setItemSize(bgWidth,bgHeight+7)
	   	self.mList:addItem(item)


		-- local palyerName = CMColorLabel.new({text = string.format("来自#06#22;%s#06#26","名字")})
		-- palyerName:setPosition(85,matchType:getPositionY())		
		-- bg:addChild(palyerName)
		local time = itemData[START_TIME]
		local idx = string.len(time)
		for i = string.len(time), 1 do
			if string.sub(time,i,i) == ":" then
				idx = i-1
				break
			end
		end
		-- time = string.sub(time, 1, idx)
		time = string.sub(time, 1, 16)
		local matchTime = cc.ui.UILabel.new({
	        text  = time or "",
	        size  = 20,
	        color = cc.c3b(89,109,147),
	        -- align = cc.ui.TEXT_ALIGN_LEFT,
	        align = cc.ui.TEXT_ALIGN_CENTER,
	        --UILabelType = 1,
			font  = "黑体",
		    })
		matchTime:align(--[[bgWidth - matchTime:getContentSize().width - 15]]display.CENTER, bgWidth/2 ,bgHeight-54)
		node:addChild(matchTime,2,100)

		local name = itemData[TABLE_NAME]
		if type(name) == "string" then
			name = StringFormat:formatName(name, 20)
		end
	   	local matchName = cc.ui.UILabel.new({
	        text  =  name or "",
	        size  = 26,
	        x     = 28,
	        y     = bgHeight-20,
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        --UILabelType = 1,
			font  = "黑体",
		    })
		node:addChild(matchName,2)

		local IDLabel = cc.ui.UILabel.new({
	        text  =  "(ID:"..itemData["1012"]..")" or "",
	        size  = 20,
	        x     = matchName:getPositionX()+matchName:getContentSize().width,
	        y     = bgHeight-20,
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        --UILabelType = 1,
			font  = "黑体",
		    })
		node:addChild(IDLabel, 2)

		local manzhuIcon = cc.Sprite:create(manzhuPath)
	   	manzhuIcon:setPosition(20+manzhuIcon:getContentSize().width/2,bgHeight/2 -18 )
	   	node:addChild(manzhuIcon,2)

	   	local sManZhu = cc.ui.UILabel.new({
	        text  =  string.format("%s/%s",CMFormatNum(itemData[SMALL_BLIND] or 25),CMFormatNum(itemData[BIG_BLIND] or 50)),
	        size  = 24,
	        -- color = cc.c3b(135,154,192),
	        x     = 45,
	        y     = manzhuIcon:getPositionY(),
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        --UILabelType = 1,
			font  = "黑体",
		    })
		node:addChild(sManZhu,2,101)

	   	local timeIcon = cc.Sprite:create(timePath)
	   	timeIcon:setPosition(manzhuIcon:getPositionX(),manzhuIcon:getPositionY()-30)
	   	node:addChild(timeIcon,2)
	  
	   	 local sTime = cc.ui.UILabel.new({
	        text  =  nStatus or "",
	        size  = 24,
	        color = cc.c3b(255,255,255),
	        x     = 45,
	        y     = timeIcon:getPositionY(),
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        --UILabelType = 1,
			font  = "黑体",
		    })
		node:addChild(sTime,2,102)

		local color 
		local num = tonumber(itemData["WIN_COUNT"] or 0)
		if num > 0 then
			num = "+" .. num
			color = cc.c3b(0,255,255)
		elseif num == 0 then
			color = cc.c3b(255,255,255)
		else
			color = cc.c3b(255,0,0)
		end

		local sAward = cc.ui.UILabel.new({
	        text  = num,
	        size  = 32,
	        color = color,
	        align = cc.ui.TEXT_ALIGN_RIGHT,
	        --UILabelType = 1,
			font  = "黑体",
		    })
		sAward:setPosition(415 - sAward:getContentSize().width, bgHeight/2-18-15)
		node:addChild(sAward,2)

	   	local tableTypeIcon = nil
	   	local tableType = itemData[TABLE_TYPE]
	   	if tableType and tableType == "MTT" then
	   		tableTypeIcon = "picdata/personCenterNew/myMatch/icon_corner_mmt.png"
	   	elseif tableType and tableType == "SNG" then
	   		tableTypeIcon = "picdata/personCenterNew/myMatch/icon_corner_sng.png"
	   	else
	   		tableTypeIcon = "picdata/personCenterNew/myMatch/icon_corner_nomal.png"
	   	end
	   	if tableTypeIcon then
		   	local icon = cc.ui.UIImage.new(tableTypeIcon)
		   	:align(display.LEFT_TOP, 0, bgHeight)
		   	node:addChild(icon,2)
		end

		self.mActivitySprite[#self.mActivitySprite + 1] = bg
		if i == self.mTableSize then 
			self.mSelectSprite= cc.ui.UIImage.new(selectPath, {scale9=true})
			self.mSelectSprite:setLayoutSize(bgWidth, bgHeight)
			self.mSelectSprite:setPosition(self.mActivitySprite[i]:getPositionX(),self.mActivitySprite[i]:getPositionY())
			node:addChild(self.mSelectSprite,4)
			self.mSelectSprite:setVisible(false)
			self:onMenuSwitch(1)
		end
		
	end  

	self.mList:reload()	

end

function MyMatchLayer:createRightUI()
	if self.mRightBg then return end

	
	local bg = cc.Node:create()
	-- bg:setPosition(500,540)
	bg:setContentSize(460,488)
	bg:setPosition(self.mLine:getPositionX(),45+3)
	
	self.mBg:addChild(bg)
	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height
		
	self.mRightBg = bg

	local titleBg = cc.ui.UIImage.new("picdata/personCenterNew/myMatch/bg_title.png", {scale9 = false})
	-- titleBg:setLayoutSize(400, 42)
	titleBg:align(display.LEFT_CENTER, -10, bgHeight - 26 -15)
		:addTo(bg)

	-- self.m_shareBtn = CMButton.new({normal = "picdata/personalCenter/btn_6_wx.png",pressed = "picdata/personalCenter/btn_6_wx2.png"},handler(self, self.onShareWechat), {scale9 = false})    
	--     :pos(bg:getContentSize().width - 50,bgHeight - 26)
	--     :addTo(bg)
	--     :hide()

    local btnSharePath="picdata/public_new/btn_mini_green.png"
    local btnSharePath2="picdata/public_new/btn_mini_green.png"
	self.m_shareBtn = CMButton.new({normal = btnSharePath,pressed = btnSharePath2},
	handler(self, self.onShareWechat),{scale9 = true})
	self.m_shareBtn:setButtonSize(134, 56)
	self.m_shareBtn:setButtonLabel("normal", cc.ui.UILabel.new({
	    text  = "分享",
	    size  = 26,
	    color = cc.c3b(255,255,255),
	    align = cc.ui.TEXT_ALIGN_CENTER,
	    font  = "黑体",
	}))
	self.m_shareBtn:setPosition(bg:getContentSize().width - 70,bgHeight - 24 -15)
	self.m_shareBtn:setTouchSwallowEnabled(false)
	self.m_shareBtn:setButtonLabelOffset(15, 0)
	bg:addChild(self.m_shareBtn)

	cc.ui.UIImage.new("picdata/public_new/icon_wx.png")
      :align(display.LEFT_CENTER, -40, self.m_shareBtn:getContentSize().height/2)
      :addTo(self.m_shareBtn)

	local nameBg = cc.Sprite:create("picdata/personalCenter/bg_2.png")
	nameBg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2 + 150 )
	bg:addChild(nameBg)
	nameBg:setVisible(false)
    local line2 = cc.ui.UIImage.new("picdata/public_new/line.png")
    line2:align(display.LEFT_CENTER, 0,bg:getContentSize().height/2 + 130)
        :addTo(bg)
    line2:setScaleX(460/line2:getContentSize().width)

	local matchType = cc.ui.UIImage.new("picdata/personCenterNew/myMatch/icon_competition_normal.png")
	matchType:align(display.LEFT_CENTER,0,bgHeight-46)
	bg:addChild(matchType,0,103)

	local matchName = cc.ui.UILabel.new({
        text  =  "",
        size  = 28,
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
		font  = "黑体",
	    })
	matchName:setPosition(64,bgHeight-41)
	bg:addChild(matchName,0,101)

	local matchIdBg = cc.Sprite:create("picdata/personalCenter/bg_id.png")
	matchIdBg:setPosition(bgWidth/2, bgHeight-57)
	bg:addChild(matchIdBg)

	local matchId = cc.ui.UILabel.new({
        text  = "",--string.format("2010/2/1 来自%s","名字") or "",
        size  = 20,
        -- color = cc.c3b(135,154,192),
        align = cc.ui.TEXT_ALIGN_LEFT,
        --UILabelType = 1,
		font  = "黑体",
	    })
	matchId:setPosition(bgWidth/2-matchId:getContentSize().width/2, bgHeight-57)
	bg:addChild(matchId,0,102)
	matchIdBg:setVisible(false)
	matchId:setVisible(false)
	-- local matchTime = cc.ui.UILabel.new({
 --        text  = "asdfas",--string.format("2010/2/1 来自%s","名字") or "",
 --        size  = 18,
 --        color = cc.c3b(135,154,192),
 --        align = cc.ui.TEXT_ALIGN_LEFT,
 --        --UILabelType = 1,
	-- 	font  = "黑体",
	--     })
	-- matchTime:setPosition(bgWidth/2-matchTime:getContentSize().width/2, bgHeight-55)
	-- bg:addChild(matchTime,0,102)

	local titleName = {{text = "名次",x = 4},{text = "昵称",x = 85},{text = "盈亏",x = 396}}
	
	for i = 1,#titleName do 
		local title = cc.ui.UILabel.new({
	        text  = titleName[i].text,
	        size  = 24,
	        color = cc.c3b(89,109,147),
	        align = cc.ui.TEXT_ALIGN_LEFT,
	        --UILabelType = 1,
			font  = "黑体",
		    })
		title:setPosition(titleName[i].x, bgHeight-95+4)
		bg:addChild(title)
	end

	self:createRightList()

end

function MyMatchLayer:onShareWechat()
	if not self.m_idx then
		return
	end
	local itemData = QDataMyMatchList:getMsgItemData(self.m_idx)
	if not itemData then
		return
	end
	local url
	if SERVER_ENVIROMENT==ENVIROMENT_TEST then
	 	url = "http://debao.boss.com/index.php?act=video&mod=bill&data="
	else
		url = "http://www.debao.com/index.php?act=video&mod=bill&data="
	end

	local params = {
		name = itemData[TABLE_NAME],
		type = itemData[TABLE_TYPE],
		blind_b = itemData[BIG_BLIND],
		bling_s = itemData[SMALL_BLIND],
		time = itemData[START_TIME],
		tableID = itemData[TABLE_ID],
	}

	dump(url .. URLEncoder:encodeURI(json.encode(params)) , "iccccccccccccccc ")

	local data = {
		title = string.format(lang_WECHATSHARE_FRIEND_GAME,itemData[TABLE_NAME]) or "德堡德州扑克",
		content = string.format(lang_WECHATSHARE_FRIEND_GAME,itemData[TABLE_NAME]),
		nType = 1,
		url = url .. URLEncoder:encodeURI(json.encode(params))
	}
	QManagerPlatform:shareToWeChat(data)
end

function MyMatchLayer:updateName(itemData)
	local bg = self.mRightBg
	local matchName = bg:getChildByTag(101)
	matchName:setString(itemData[TABLE_NAME])
	-- matchName:setPositionX(bg:getContentSize().width/2-matchName:getContentSize().width/2)
	local matchTime = bg:getChildByTag(102)
	matchTime:setString(itemData["ROOM_ID"] or "")
	matchTime:setPositionX(bg:getContentSize().width/2-matchTime:getContentSize().width/2)
	local commonPath = "picdata/personCenterNew/myMatch/icon_competition_normal.png"
	local commonPath2= "picdata/personCenterNew/myMatch/icon_competition_sng.png"
	local matchType = bg:getChildByTag(103)
	if itemData[TABLE_TYPE] == "SNG" then
		commonPath = commonPath2
	end
	matchType:setTexture(commonPath)
	-- matchType:setPosition(matchType:getContentSize().width/2+10,matchName:getPositionY())
end
function MyMatchLayer:createRightList(idx)
	self.m_idx = idx
	local itemData = QDataMyMatchList:getMsgItemData(idx)
	if not itemData then self.m_shareBtn:hide() return end
	self.m_shareBtn:show()
	self:updateName(itemData)
	local cfgData = itemData["rank"]
	if not cfgData then return end

	-- cfgData = {{},{},{}}
	if self.mRightList then self.mRightList:removeFromParent() self.mRightList = nil end

	local rightSize = cc.size(460,360)	
	self.mRightList = cc.ui.UIListView.new {
    	-- bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(-6, 7, rightSize.width, rightSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    -- :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mRightBg) 

	local bgWidth = rightSize.width
	local bgHeight= 32
	-- local posy = bgHeight-150
	for i = 1,#cfgData do 
		local item = self.mRightList:newItem() 

		local node = display.newNode()	
		item:addContent(node) 
		node:setContentSize(bgWidth,bgHeight)
		item:setItemSize(bgWidth,bgHeight)
	   	self.mRightList:addItem(item)

		local titleName = {{text = i,x = 26},{text = CMGetStringLen(revertPhoneNumber(tostring(cfgData[i][USER_NAME])),10,true),x =92},{text = cfgData[i]["WIN_COUNT"] or 0,x =450}}
		for j = 1,#titleName do 
			local alignment = cc.ui.TEXT_ALIGN_LEFT
			if j == 3 then
				alignment = cc.ui.TEXT_ALIGN_RIGHT
			end
			local title = cc.ui.UILabel.new({
		        text  = titleName[j].text,
		        size  = 26,
		        align = alignment,
		        --UILabelType = 1,
				font  = "黑体",
			    })
			if j==3 then
				title:align(display.RIGHT_CENTER, titleName[j].x, bgHeight/2)
			else
				title:align(display.LEFT_CENTER, titleName[j].x, bgHeight/2)
			end
			node:addChild(title)

			if j == 3 then
				local num = tonumber(cfgData[i]["WIN_COUNT"] or 0)
				if num > 0 then
					title:setString("+"..titleName[j].text)
					title:setColor(cc.c3b(0,255,225))
				elseif num == 0 then
					title:setColor(cc.c3b(255,255,255))
				else
					title:setColor(cc.c3b(255,47,0))
				end
			end
		end
		-- posy = posy - 30
	end

	self.mRightList:reload()
end
function MyMatchLayer:touchRightListener(event)
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
function MyMatchLayer:checkTouchInSprite_(x, y,itemPos)	
	for i = 1,#self.mActivitySprite do			
		if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
			if 	self.mCurSelectIndex == i then return end					
			self:onMenuSwitch(i)
		else
			--self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
		end
	end	
end
function MyMatchLayer:onMenuSwitch(idx)
	local bgWidth = 438
	local bgHeight= 156
	local x,y,parent
	if self.mCurSelectIndex then
		x = self.mActivitySprite[self.mCurSelectIndex]:getPositionX()
		y = self.mActivitySprite[self.mCurSelectIndex]:getPositionY()
		parent = self.mActivitySprite[self.mCurSelectIndex]:getParent()
		self.mActivitySprite[self.mCurSelectIndex]:removeFromParent(true)
		self.mActivitySprite[self.mCurSelectIndex] = cc.ui.UIImage.new("picdata/personCenterNew/myMatch/bg_list.png", {scale9=true})
		self.mActivitySprite[self.mCurSelectIndex]:setLayoutSize(bgWidth, bgHeight)
		self.mActivitySprite[self.mCurSelectIndex]:setPosition(0,0)
		parent:addChild(self.mActivitySprite[self.mCurSelectIndex])

		parent:getChildByTag(100):setColor(cc.c3b(89,109,147))
		parent:getChildByTag(101):setColor(cc.c3b(180,192,220))
		parent:getChildByTag(102):setColor(cc.c3b(180,192,220))
	end
	self.mCurSelectIndex = idx
	-- self.mSelectSprite:setVisible(true)
	-- self.mSelectSprite:setPosition(self.mActivitySprite[idx]:getPositionX(),self.mActivitySprite[idx]:getPositionY() - (idx -self.mTableSize)*(self.mActivitySprite[idx]:getContentSize().height+7))
	x = self.mActivitySprite[self.mCurSelectIndex]:getPositionX()
	y = self.mActivitySprite[self.mCurSelectIndex]:getPositionY()
	parent = self.mActivitySprite[self.mCurSelectIndex]:getParent()
	self.mActivitySprite[self.mCurSelectIndex]:removeFromParent(true)
	self.mActivitySprite[self.mCurSelectIndex] = cc.ui.UIImage.new("picdata/personCenterNew/myMatch/bg_list_p.png", {scale9=true})
	self.mActivitySprite[self.mCurSelectIndex]:setLayoutSize(bgWidth, bgHeight)
	self.mActivitySprite[self.mCurSelectIndex]:setPosition(0,0)
	parent:addChild(self.mActivitySprite[self.mCurSelectIndex])
	cc.ui.UIImage.new("picdata/personCenterNew/myMatch/bg_list_p2.png", {scale9=false})
		:align(display.RIGHT_CENTER, bgWidth+16, bgHeight/2+2.0)
		:addTo(self.mActivitySprite[self.mCurSelectIndex])


	parent:getChildByTag(100):setColor(cc.c3b(144,129,101))
	parent:getChildByTag(101):setColor(cc.c3b(211,189,147))
	parent:getChildByTag(102):setColor(cc.c3b(211,189,147))


	local tableId = QDataMyMatchList:getMsgTableId(idx)
	if tableId then
		DBHttpRequest:getPriTableUserList(function(tableData,tag) self:httpResponse(tableData,tag,idx) end,tableId,0,30)
		DBHttpRequest:getDiyFidByTableId(function(tableData,tag) self:httpResponse(tableData,tag,idx) end,tableId)
	end
	
end

--[[
  网络回调
]]
function MyMatchLayer:httpResponse(tableData,tag,idx) 
    -- dump(tableData,tag)
    if tag == POST_COMMAND_GET_PRITABLE_LIST then  
    	dump(tableData,tag)
    	QDataMyMatchList:Init(tableData or {})
    	self:createLeftList( )
    elseif tag == POST_COMMAND_GET_PRITABLE_USER_LIST then
    	if not tableData or not tableData["MSG"] == "success!" then return end
    	QDataMyMatchList:addMsgData(idx,tableData["LIST"])
    	self:createRightUI()
    	self:createRightList(idx)
    elseif tag == POST_COMMAND_GET_DiyFidByTableId then
    	if type(tableData) ~= "table" then return end
    	QDataMyMatchList:addMsgRoomId(idx,tableData[1]["ROOM_ID"])
    	if self.mRightBg then
	    	local matchId = self.mRightBg:getChildByTag(102)
			matchId:setString(string.format("ID:%s",tableData[1]["ROOM_ID"]or ""))
			matchId:setPositionX(self.mRightBg:getContentSize().width/2-matchId:getContentSize().width/2)
		end

    end
    
end
return MyMatchLayer