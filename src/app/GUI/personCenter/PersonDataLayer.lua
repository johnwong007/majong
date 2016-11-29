--
-- Author: junjie
-- Date: 2016-01-15 17:05:43
--
local PersonDataLayer = class("PersonDataLayer",function() 
  return display.newNode()
end)
local myInfo = require("app.Model.Login.MyInfo")
require("app.Network.Http.DBHttpRequest")
function PersonDataLayer:ctor(params)
	self.params = params or {}
	self.params.nType = self.params.nType or 1
  	self.mPageNode = {}
  	self.mAllType  = {"zyc","jbs","sjfx","mzmx"}
  	--self:initUI()
end
function PersonDataLayer:create()
    self:initUI()
end
function PersonDataLayer:initUI()
    self:setContentSize(600,500)
    self:setPosition(-35,-18)


    local title = cc.ui.UILabel.new({
			        UILabelType = 1,
			        text  = "牌手报告",
			        font  = "fonts/title.fnt",
			        align = cc.ui.TEXT_ALIGN_CENTER,
			    })
    local titleWidth = title:getContentSize().width
    local btnHelp = CMButton.new({normal = "picdata/public_new/btn_q.png",pressed = "picdata/public_new/btn_q.png"},
      function ()  
      	local RewardLayer = require("app.GUI.personCenter.DataExplainLayer")
		CMOpen(RewardLayer, GameSceneManager:getCurScene(),nil,0,1)
       end,{scale9 = true})
      btnHelp:setPosition(580,CONFIG_SCREEN_HEIGHT-40)
      btnHelp:setTouchSwallowEnabled(false)
     self:addChild(btnHelp)

		

    self.mBg = self

    self:createRightList()
  	DBHttpRequest:getUserMatchData(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId)
	DBHttpRequest:hudForMobile(function(tableData,tag) self:httpResponse(tableData,tag) end,myInfo.data.userId)
end
function PersonDataLayer:createRightList()
	local bg = self.mBg
	local bgWidth = bg:getContentSize().width
	local bgHeight= bg:getContentSize().height

    local line1 = cc.ui.UIImage.new("picdata/public_new/line2.png")
    line1:align(display.CENTER, 320, 300)
        :addTo(self.mBg)
    line1:setRotation(-90)
    line1:setScaleX(0.7)

	local nType = self.params.nType
	if self.mAllType[nType] == "zyc" then
		local leftNode = self:createLeftNode()
		bg:addChild(leftNode)
		self.mPageNode["leftNode"] = leftNode
	elseif self.mAllType[nType] == "jbs" then
		local midNode = self:createMidNode()
		--midNode:setVisible(false)
		bg:addChild(midNode)
		self.mPageNode["midNode"]  = midNode
	elseif self.mAllType[nType] == "sjfx" then
		local rightNode= self:createRightNode()
		--rightNode:setVisible(false)
		bg:addChild(rightNode)
		self.mPageNode["rightNode"] = rightNode
	else
		local earningNode= self:createEarningNode()
		bg:addChild(earningNode)
		self.mPageNode["earningNode"] = earningNode
		HttpClient:queryEarning(handler(self, self.queryEarningCallback),myInfo.data.userId)
	end
	-- self.mPageNode["leftNode"] = leftNode
	-- self.mPageNode["midNode"]  = midNode
	-- self.mPageNode["rightNode"] = rightNode

	-- self:showPageNode("midNode")
end

function PersonDataLayer:createEarningNode()
	local node = cc.Node:create()
	return node
end

function PersonDataLayer:showEarningData()
	if not self.m_pEarningData then
		return
	end
	self.mListSize = cc.size(640,CONFIG_SCREEN_HEIGHT-110) 
    self.mList = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(315, 0, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    -- :onTouch(handler(self, self.touchRightListener))  
    :addTo(self.mPageNode["earningNode"],1)  
    if #self.m_pEarningData == 0 then return end
    local len = #self.m_pEarningData

    for i = 1,len do
        local item = self:createEarningItem(i,self.m_pEarningData[i])
        self.mList:addItem(item)
    end 
    self.mList:reload() 
end

function PersonDataLayer:createEarningItem(idx,serData)
	serData = serData or {}
    local item = self.mList:newItem()
    local lineHeight = 72+6
    local itemSize = cc.size(self.mListSize.width,lineHeight*5)
    item:setItemSize(itemSize.width,itemSize.height)
    local node = cc.Node:create()
    local bgWidth = itemSize.width
    local bgHeight= itemSize.height
    item:addContent(node)

    local padding = 4
    local titleBg = cc.ui.UIImage.new("picdata/personCenterNew/personData/bg_title.png")
	titleBg:align(display.LEFT_CENTER,padding-itemSize.width/2,lineHeight*2+15)
	node:addChild(titleBg)
	local title = cc.ui.UILabel.new({
	            text  = serData[BLIND_INFO],
	            size  = 28,
	            color = cc.c3b(180,192,220),
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            font  = "黑体",
	        })
	title:align(display.LEFT_CENTER,14,titleBg:getContentSize().height/2)
	titleBg:addChild(title)

	local text = {"总局数","总盈利","百手盈利","VPIP","PFR","AF","3-Bet","WTSD"} 
	local subText = {"","","","入局率","激进指数","翻牌前加注率","再加注率","摊派率"} 
	local data = {}
	data[1] = tostring(serData[STAT_KEY_HANDS])
	data[2] = string.format("%.2f",serData["2022"])
	data[3] = string.format("%.2f",serData["8010"])
	data[4] = string.format("%.2f",serData[STAT_KEY_VPIP])
	data[5] = string.format("%.2f",serData[STAT_KEY_PFR])
	data[6] = string.format("%.2f",serData[STAT_KEY_AF])
	data[7] = string.format("%.2f",serData["8004"])
	data[8] = string.format("%.2f",serData["800F"])

	local posx = 156+padding-itemSize.width/2
	local posy = lineHeight+20
	local posx1 = posx+312+4
	for i = 1 ,#text do
		local bgposx = posx
		if i%2==0 then
			bgposx = posx1
		end
		local bg = cc.ui.UIImage.new("picdata/personCenterNew/personData/bg_list.png", {scale9 = true})
		    bg:setLayoutSize(312, 72)
		    bg:align(display.CENTER, bgposx, posy)
		    	:addTo(node)
		if i%4==0 or i%4==3 then
			bg:setOpacity(255*0.5)
		end
		local sDetail = cc.ui.UILabel.new({
		        text  =   text[i].."",
		        size  = 28,
		        color = cc.c3b(0,255,225),
		        font  = "黑体",
	    		align = cc.ui.TEXT_ALIGN_LEFT,
		    })
		sDetail:align(display.LEFT_CENTER,bgposx-140,posy+2)
		node:addChild(sDetail)
		if subText[i]~="" then
			sDetail:setPositionY(posy+12)
			local subDetail = cc.ui.UILabel.new({
		        text  =   subText[i].."",
		        size  = 18,
		        color = cc.c3b(180,192,220),
		        font  = "黑体",
	    		align = cc.ui.TEXT_ALIGN_LEFT,
		    })
			subDetail:align(display.LEFT_CENTER,bgposx-140,posy-12)
			node:addChild(subDetail)
		end

		local perNum = cc.ui.UILabel.new({
		        text  =  data[i],
		        size  = 28,
		        color = cc.c3b(255,255,255),
		        --UILabelType = 1,
	    		font  = "Arial",
    			align = cc.ui.TEXT_ALIGN_RIGHT,
		    })
		perNum:align(display.RIGHT_CENTER,bgposx+140,posy+2)
		node:addChild(perNum,0,100+i)
		if i%2==0 then
			posy = posy - lineHeight
		end
	end




 --    if serData["4026"] == "-" then
 --    	nTime = "在线"
 --    else
 --    	nTime = string.gsub(serData["4026"] or "","-","/")
 --    	nTime = string.sub(nTime,1,string.len(nTime)-3)
 --    end
    
	-- local labelText = {
	-- 	{text = serData["2004"],posx = 120},{text = clubPositon[serData["A10D"]],posx = 340},{text = tonumber(serData["4055"] or 0),posx = 435},
	-- 	{text = serData["A112"],posx = 555},{text = serData["A113"],posx = 660},{text = nTime,posx = 743},
	-- }
 --    local node = cc.Node:create() 
 --    local itemSize = cc.size(self.mListSize.width-50,60)
	-- local bgWidth = itemSize.width
 --    local bgHeight= itemSize.height
 --     item:addContent(node)
 --    node:setContentSize(self.mListSize.width,itemSize.height)
 --    item:setItemSize(self.mListSize.width,itemSize.height)

 --    local size = cc.size(bgWidth,50)
	-- bg = cc.ui.UIImage.new("picdata/fightteam/bg_list.png", {scale9 = true})
 --    bg:setLayoutSize(size.width,size.height)
	-- bg:setPosition(25,0)
	-- node:addChild(bg)
	-- local color = cc.c3b(255,255,255)
	-- if serData["2003"] == myInfo.data.userId then
	-- 	color = cc.c3b(0,255,255)
	-- end
 --    for i = 1,#labelText do
	--      local content = cc.ui.UILabel.new({
	--             text  = labelText[i].text  or "123",
	--             size  = 22,
	--             color = color,
	--             align = cc.ui.TEXT_ALIGN_LEFT,
	--             --UILabelType = 1,
	--             font  = "黑体",
	--         })
	--     content:setPosition(labelText[i].posx-80,bgHeight/2-5)
	--     node:addChild(content)
	--     if i == #labelText then
	--     	content:setPosition(755 -content:getContentSize().width/2 ,bgHeight/2-5)
	--     end
	--  end
	--  local selecthSprite = cc.ui.UIImage.new("picdata/fightteam/bg_list_xz.png", {scale9 = true})
	--  selecthSprite:setLayoutSize(size.width,size.height)
	-- selecthSprite:setVisible(false)
	-- selecthSprite:setPosition(bg:getPositionX(),0)
	-- node:addChild(selecthSprite,0,101)
	-- self.mActivitySprite[idx] = node

	-- self.mAllItemHeight = self.mAllItemHeight + itemSize.height
    return item
end

function PersonDataLayer:createLeftNode()
	local node = cc.Node:create()

	-- local psData = cc.Sprite:create("picdata/personalCenter/w_title_ptc.png")
	-- psData:setPosition(600,483)
	-- node:addChild(psData)

	local text = {"今日局数","今日盈利","总牌局数","总盈利","胜率"
		-- ,"最佳牌型"
	} 
	local posx = 475
	local posy = 500-5
	local posx1 = posx+312+4
	for i = 1 ,#text do
		local bgposx = posx
		if i%2==0 then
			bgposx = posx1
		end
		-- if i ~= #text then
			local bg = cc.ui.UIImage.new("picdata/personCenterNew/personData/bg_list.png", {scale9 = true})
		    bg:setLayoutSize(312, 72)
		    bg:align(display.CENTER, bgposx, posy)
		    	:addTo(node)
		-- else
		-- 	bgposx = posx
		-- 	posy = posy - 80
		-- end

		if i%4==0 or i%4==3 then
			bg:setOpacity(255*0.5)
		end

		local sDetail = cc.ui.UILabel.new({
		        text  =   text[i]..":",
		        size  = 28,
		        color = cc.c3b(0,255,225),
		        --UILabelType = 1,
		        font  = "黑体",
	    		align = cc.ui.TEXT_ALIGN_LEFT,
		    })
		sDetail:align(display.LEFT_CENTER,bgposx-135,posy+2)
		node:addChild(sDetail)
		-- if i ~= #text then
			local perNum = cc.ui.UILabel.new({
			        text  =  "0",
			        size  = 28,
			        color = cc.c3b(255,255,255),
			        --UILabelType = 1,
		    		font  = "Arial",
	    			align = cc.ui.TEXT_ALIGN_RIGHT,
			    })
			perNum:align(display.RIGHT_CENTER,bgposx+135,posy+2)
			node:addChild(perNum,0,100+i)
		-- end
		if i%2==0 then
			posy = posy - 78
		end
	end

	-- local rightBtn =  CMButton.new({normal = "picdata/personalCenter/btn_2_next.png"},function () self:showPageNode("midNode") end, {scale9 = false})    
 --    :align(display.CENTER, 400,psData:getPositionY()) --设置位置 锚点位置和坐标x,y
 --    :addTo(node)

    return node
end

function PersonDataLayer:createMidNode()
	local node = cc.Node:create()

 --    local psData = cc.Sprite:create("picdata/personalCenter/w_title_jbs.png")
	-- psData:setPosition(600,483)
	-- node:addChild(psData)

	local text = {"参赛次数","获奖次数","总牌局数","总盈利","锦标排名"} 
	local posx = 475
	local posy = 500-5
	local posx1 = posx+312+4
	for i = 1 ,#text do 
		local bgposx = posx
		if i%2==0 then
			bgposx = posx1
		end
		local bg = cc.ui.UIImage.new("picdata/personCenterNew/personData/bg_list.png", {scale9 = true})
	    bg:setLayoutSize(312, 72)
	    bg:align(display.CENTER, bgposx, posy)
	    	:addTo(node)
		if i%4==0 or i%4==3 then
			bg:setOpacity(255*0.5)
		end

		local sDetail = cc.ui.UILabel.new({
		        text  =   text[i]..":",
		        size  = 28,
		        color = cc.c3b(0,255,225),
		        --UILabelType = 1,
		        font  = "黑体",
	    		align = cc.ui.TEXT_ALIGN_LEFT,
		    })
		sDetail:align(display.LEFT_CENTER,bgposx-135,posy+2)
		node:addChild(sDetail)

		local perNum = cc.ui.UILabel.new({
		        text  =  "0",
		        size  = 28,
			    color = cc.c3b(255,255,255),
		        --UILabelType = 1,
	    		font  = "Arial",
	    		align = cc.ui.TEXT_ALIGN_RIGHT,
			    })
		perNum:align(display.RIGHT_CENTER,bgposx+135,posy+2)
		node:addChild(perNum,0,100+i)

		if i%2==0 then
			posy = posy - 78
		end
	end

	-- local leftBtn =  CMButton.new({normal = "picdata/personalCenter/btn_2_next.png"},
	-- 	function () self:showPageNode("leftNode") end
	-- 	, {scale9 = false})  
 --    :align(display.CENTER, 70,psData:getPositionY()) --设置位置 锚点位置和坐标x,y
 --    :addTo(node)
 --    leftBtn:setScaleX(-1)

 --    local rightBtn =  CMButton.new({normal = "picdata/personalCenter/btn_2_next.png"},function () self:showPageNode("rightNode") end, {scale9 = false})    
 --    :align(display.CENTER, 400,psData:getPositionY()) --设置位置 锚点位置和坐标x,y
 --    :addTo(node)

    -- local awardSp = cc.Sprite:create("picdata/personalCenter/pic_4_cup.png")
    local awardSp = cc.Sprite:create("picdata/personCenterNew/personData/pic_jb.png")
    awardSp:setPosition(630,posy-200)
    node:addChild(awardSp,0,106)

    local posx = 65+20
    local posy = awardSp:getContentSize().height/2+4
    local tag = 100 + #text
    local awardColor = {
    	cc.c3b(254,246,208),
    	cc.c3b(222,229,255),
    	cc.c3b(254,225,199)
	}
    for i = 1,3 do 
    	local awardNum = cc.ui.UILabel.new({
		        text  =  "0",
		        size  = 38,
		        color = awardColor[i],
		        --UILabelType = 1,
	    		font  = "Arial",
		    })
		awardNum:setPosition(posx + 10,posy)
		awardSp:addChild(awardNum,0,i)

    	local label = cc.ui.UILabel.new({
		        text  =  "次",
		        size  = 24,
		        color = awardColor[i],
		        --UILabelType = 1,
	    		font  = "黑体",
		    })
		label:setPosition(posx + 5 + 10,posy-2)
		awardSp:addChild(label,0,3+i)

		posx = posx + 125 + 90
    end
    return node
end

function PersonDataLayer:createRightNode()
	local node = cc.Node:create()

 --    local psData = cc.Sprite:create("picdata/personalCenter/w_title_sjfx.png")
	-- psData:setPosition(600,483)
	-- node:addChild(psData)

	local text = {"激进度(AF)","翻牌前加注率(PFR)","入局率(VPIP)","偷盲率(STL)","摊牌率(W)","再加注率(3B)","持续下注(CB)"} 
	local posx = 475
	local posy = 500
	local posx1 = posx+312+4
	for i = 1 ,#text do 
		local bgposx = posx
		if i%2==0 then
			bgposx = posx1
		end
		local bg = cc.ui.UIImage.new("picdata/personCenterNew/personData/bg_list.png", {scale9 = true})
	    bg:setLayoutSize(312, 72)
	    bg:align(display.CENTER, bgposx, posy)
	    	:addTo(node)

		local sDetail = cc.ui.UILabel.new({
		        text  =   text[i]..":",
		        size  = 24,
		        color = cc.c3b(0,255,225),
		        --UILabelType = 1,
		        font  = "FZZCHJW--GB1-0",
	    		align = cc.ui.TEXT_ALIGN_LEFT,
		    })
		sDetail:align(display.LEFT_CENTER,bgposx-135,posy+2)
		node:addChild(sDetail)

		local perNum = cc.ui.UILabel.new({
		        text  =  "0",
		        size  = 24,
			    color = cc.c3b(255,255,255),
		        --UILabelType = 1,
	    		font  = "Arial",
	    		align = cc.ui.TEXT_ALIGN_RIGHT,
			    })
		perNum:align(display.RIGHT_CENTER,bgposx+135,posy+2)
		node:addChild(perNum,0,100+i)

		if i%2==0 then
			posy = posy - 80
		end
	end

	-- local leftBtn =  CMButton.new({normal = "picdata/personalCenter/btn_2_next.png"},
	-- 	function () self:showPageNode("midNode") end
	-- 	, {scale9 = false})  
 --    :align(display.CENTER, 70,psData:getPositionY()) --设置位置 锚点位置和坐标x,y
 --    :addTo(node)
 --    leftBtn:setScaleX(-1)

 --    local rightBtn =  CMButton.new({normal = "picdata/personalCenter/dataBtn.png"},function () self:onMenuCallBack(EnumMenu.eBtnDataExPlain) end, {scale9 = false})    
 --    :align(display.CENTER, 400,psData:getPositionY()) --设置位置 锚点位置和坐标x,y
 --    :addTo(node)

    return node
end
function PersonDataLayer:updateData(tableData)
	if self.mPageNode["leftNode"] then 
		self.mPageNode["leftNode"]:getChildByTag(101):setString(tableData[HANDS_NUM])
		self.mPageNode["leftNode"]:getChildByTag(102):setString(tableData[WIN_CHIPS])
		self.mPageNode["leftNode"]:getChildByTag(103):setString(tableData[STAT_KEY_HANDS][STAT_KEY_VALUE])
		self.mPageNode["leftNode"]:getChildByTag(104):setString(tableData[STAT_KEY_WINNING][STAT_KEY_VALUE])
		self.mPageNode["leftNode"]:getChildByTag(105):setString(tableData[STAT_KEY_AF][STAT_KEY_VALUE])

		local node = CMAddCard(tableData[MAX_CARD])
		node:setPosition(500,260)
		-- self.mPageNode["leftNode"]:addChild(node)
	else
		self:updateRightNodeData(tableData)
	end
end
function PersonDataLayer:updateMidNodeData(tableData)
	
	if not tableData then return end
	if self.mPageNode["midNode"] then
		self.mPageNode["midNode"]:getChildByTag(101):setString(tableData["1"]["3"])
		self.mPageNode["midNode"]:getChildByTag(102):setString(tableData["1"]["1"])
		self.mPageNode["midNode"]:getChildByTag(103):setString(tableData["1"]["3"])
		self.mPageNode["midNode"]:getChildByTag(104):setString(tableData["1"]["2"])
		
		local rank = tonumber(tableData["1"]["4"])
		if rank then
			rank = rank .. "+"
		end
		self.mPageNode["midNode"]:getChildByTag(105):setString(rank)
		local label1 = self.mPageNode["midNode"]:getChildByTag(106):getChildByTag(1)
		local label2 = self.mPageNode["midNode"]:getChildByTag(106):getChildByTag(2)
		local label3 = self.mPageNode["midNode"]:getChildByTag(106):getChildByTag(3)
		label1:setString(tableData["2"]["1"])
		label2:setString(tableData["2"]["2"])
		label3:setString(tableData["2"]["3"])
		self.mPageNode["midNode"]:getChildByTag(106):getChildByTag(4):setPositionX(label1:getPositionX()+label1:getContentSize().width)
		self.mPageNode["midNode"]:getChildByTag(106):getChildByTag(5):setPositionX(label2:getPositionX()+label2:getContentSize().width)
		self.mPageNode["midNode"]:getChildByTag(106):getChildByTag(6):setPositionX(label3:getPositionX()+label3:getContentSize().width)
	end
end
function PersonDataLayer:updateRightNodeData(tableData)
	if  self.mPageNode["rightNode"] then 
		self.mPageNode["rightNode"]:getChildByTag(101):setString(tableData[STAT_KEY_VPIP][STAT_KEY_VALUE])
		self.mPageNode["rightNode"]:getChildByTag(102):setString(tableData[STAT_KEY_PFR][STAT_KEY_VALUE])
		self.mPageNode["rightNode"]:getChildByTag(103):setString(tableData[STAT_KEY_AF][STAT_KEY_VALUE])
	end
end
function PersonDataLayer:showPageNode(tag)
	for i,v in pairs(self.mPageNode) do 
		if i == tag then
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end
end
--[[
	网络回调
]]
function PersonDataLayer:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_HUDFORMOBILE  then
		self:updateData(tableData)
	elseif tag == POST_COMMAND_getUserMatchData then
		self:updateMidNodeData(tableData)
	end
	
end
--[[
	网络回调
]]
function PersonDataLayer:queryEarningCallback(tableData,tag)
	self.m_pEarningData = nil
	if tableData and tableData["LIST"] then
		self.m_pEarningData = tableData["LIST"]
		self:showEarningData()
	end
end
return PersonDataLayer