--
-- Author: junjie
-- Date: 2015-12-17 10:06:23
--
--牌局收藏
local CMCommonLayer = require("app.Component.CMCommonLayer")
local MyBoardLayer = class("MyBoardLayer",CMCommonLayer)
require("app.Network.Http.DBHttpRequest")
local myInfo = require("app.Model.Login.MyInfo")
local QDataMyBoardList = nil
local EnumMenu =
{ 
    eBtnPlayer = 1,  --播放
    eBtnShare  = 2,  --分享
    eBtnDelete = 3,  --删除
}
function MyBoardLayer:ctor(params)
  QDataMyBoardList = QManagerData:getCacheData("QDataMyBoardList")
  self.params = params or {}
  self.mPersonData = {}
  self.m_selectedItem = nil
  self.m_canMove = true
  self.m_selectedItem = nil




end
function MyBoardLayer:create()
    MyBoardLayer.super.ctor(self,{
      -- titlePath = "picdata/personCenterNew/myBoard/w_pjsc.png",
      titlePath = "牌局收藏",
      titleFont = "fonts/title.fnt",
      -- bgType = 2,
      titleOffY = -40,
      isFullScreen = true,
      }) 
    MyBoardLayer.super.initUI(self)
    self:createRightList()
end

function MyBoardLayer:createRightList( )
 	local cfgData = QDataMyBoardList:getMsgData()
 	if not cfgData then
 		DBHttpRequest:getUserReplay(function(tableData,tag) self:httpResponse(tableData,tag) end)
 		return
 	end
  if type(cfgData) ~= "table" then return end
  dump(cfgData)
 	if self.mList then self.mList:removeFromParent() self.mList = nil end
	-- body
	self.mActivitySprite = {}
  self.mActivityBg = {}
  self.mActivityBgStartPosX = {}
  self.mActivityDeleteBtn = {}
	local rightSize = cc.size(CONFIG_SCREEN_WIDTH,CONFIG_SCREEN_HEIGHT-105)	
  -- rightSize = cc.size(874,606)
	self.mList = cc.ui.UIListView.new {
    	--bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(0, 0, rightSize.width, rightSize.height),    	
    	direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self)    
	
    local backPath = "picdata/personalCenter/bg_pzsc.png"
    backPath = "picdata/personCenterNew/myBoard/bg.png"
    local imagePath = "picdata/personalCenter/transBG.png"
    local imgBgPath="picdata/personalCenter/bg_3_list_thing.png"
    local txtBgPath="picdata/personalCenter/bg_4_list_input.png"
    
    -- local btnPlayPath="picdata/personCenterNew/myBoard/icon_pj.png"
    -- local btnPlayPath2="picdata/personCenterNew/myBoard/icon_pj.png"
    local btnPlayPath="picdata/personCenterNew/myBoard/icon_play.png"
    local btnPlayPath2="picdata/personCenterNew/myBoard/icon_play.png"

    local btnEditPath="picdata/personalCenter/editIcon.png"
    local btnSharePath="picdata/public_new/btn_mini_green.png"
    local btnSharePath2="picdata/public_new/btn_mini_green.png"
    local btnDeletePath="picdata/public_new/btn_mini_blue.png"
    local btnDeletePath2="picdata/public_new/btn_mini_blue.png"

	 for i = 1,#cfgData do
    -- local fid = cfgData[i][REPLAY_FID]
    -- HttpClient:getBoardInfo(handler(self, self.getHandPoker), fid)
		local itemData = cfgData[i] or {}
		local item = self.mList:newItem() 

		local bg = cc.ui.UIImage.new(backPath)
		-- local bgWidth = bg:getContentSize().width
    local bgWidth = CONFIG_SCREEN_WIDTH
    local bgHeight= bg:getContentSize().height
		bg:setPosition(bgWidth/2,bgHeight/2)
		item:addContent(bg)
		item:setItemSize(bgWidth,bgHeight+9)
	   	self.mList:addItem(item)
	   	
    	local imagePath = "picdata/public/transBG.png"
    	local imageSize = cc.size(610, 30)
	    local inputBox = cc.ui.UIInput.new({
		    image = imagePath, -- 输入控件的背景
		    --x = 580,
		   -- y = 50,	    	
		    maxLength = 16,
		    size = imageSize,
		    listener = function (event,editbox) self:onEdit(event,editbox,itemData) end
		})
	    inputBox:setText(itemData[REPLAY_NAME] or "我的牌局")
		inputBox:setPlaceHolder("德堡牌局")
		inputBox:setFont("黑体", 28)
		inputBox:setFontSize(26)		
		inputBox:setFontColor(cc.c3b(255,255,255))
		inputBox:setPosition(430+45,86+4)
		bg:addChild(inputBox)	

    local time = itemData[REPLAY_TIME] or ""
    local pos = nil
    for i=string.len(time),1,-1 do
      if string.sub(time,i,i)==":" then
        pos = i-1
        break
      end
    end
    if pos then
      time = string.sub(time,1,pos)
    end
		local sTime = cc.ui.UILabel.new({
		        text  = time,
		        size  = 24,
		        color = cc.c3b(135,154,192),
		        x     = 120+45,
		        y     = bgHeight/2 - 26,
		        align = cc.ui.TEXT_ALIGN_LEFT,
		        --UILabelType = 1,
        		font  = "黑体",
		    })
		bg:addChild(sTime)

		itemData.item  = item
		itemData.inputBox = inputBox

		local btnPlayer = CMButton.new({normal = btnPlayPath,pressed = btnPlayPath2},function ()  self:onMenuCallBack(EnumMenu.eBtnPlayer,itemData) end)
    	btnPlayer:setPosition(60+23,bgHeight/2)
    	btnPlayer:setTouchSwallowEnabled(false)
    	bg:addChild(btnPlayer)

		-- local btnShare = CMButton.new({normal = btnSharePath,pressed = btnSharePath2},function ()  self:onMenuCallBack(EnumMenu.eBtnShare,itemData) end)
  --   	btnShare:setPosition(740,sTime:getPositionY())
  --   	btnShare:setTouchSwallowEnabled(false)
  --   	bg:addChild(btnShare)

  --   	local btnDelete = CMButton.new({normal = btnDeletePath,pressed = btnDeletePath2},function ()  self:onMenuCallBack(EnumMenu.eBtnDelete,itemData) end)
  --   	btnDelete:setPosition(640,sTime:getPositionY())
  --   	btnDelete:setTouchSwallowEnabled(false)
  --   	bg:addChild(btnDelete)


    local btnShare = CMButton.new({normal = btnSharePath,pressed = btnSharePath2},
      function ()  self:onMenuCallBack(EnumMenu.eBtnShare,itemData) end,{scale9 = true})
      btnShare:setButtonSize(134, 56)
        btnShare:setButtonLabel("normal", cc.ui.UILabel.new({
            text  = "分享",
            size  = 26,
            color = cc.c3b(255,255,255),
            align = cc.ui.TEXT_ALIGN_CENTER,
            font  = "黑体",
        }))
      btnShare:setButtonLabelOffset(15, 0)
      btnShare:setPosition(812+24,sTime:getPositionY()+2)
      btnShare:setTouchSwallowEnabled(false)
      bg:addChild(btnShare)

      cc.ui.UIImage.new("picdata/public_new/icon_wx.png")
        :align(display.LEFT_CENTER, -40, btnShare:getContentSize().height/2)
        :addTo(btnShare)
      -- local btnDelete = CMButton.new({normal = btnDeletePath,pressed = btnDeletePath2},
      --   function ()  self:onMenuCallBack(EnumMenu.eBtnDelete,itemData) end,{scale9 = true})
      -- btnDelete:setButtonSize(84, 42)
      --   btnDelete:setButtonLabel("normal", cc.ui.UILabel.new({
      --       text  = "删除",
      --       size  = 26,
      --       color = cc.c3b(180,192,220),
      --       align = cc.ui.TEXT_ALIGN_CENTER,
      --       font  = "黑体",
      --   }))
      -- btnDelete:setPosition(692+280,sTime:getPositionY())
      -- btnDelete:setTouchSwallowEnabled(false)
      -- bg:addChild(btnDelete)
      local btnDelete = CMButton.new({normal = "picdata/personCenterNew/myBoard/btn_delete.png",
        pressed = "picdata/personCenterNew/myBoard/btn_delete.png"},
        function ()  self:onMenuCallBack(EnumMenu.eBtnDelete,itemData) end,{scale9 = false})
      -- btnDelete:setButtonSize(84, 42)
      btnDelete:setPosition(692+280,bgHeight/2)
      btnDelete:setTouchSwallowEnabled(false)
      bg:addChild(btnDelete)

      btnDelete:setVisible(false)

		
		self.mActivitySprite[#self.mActivitySprite+1] = inputBox
    self.mActivityBg[#self.mActivityBg+1] = bg
    self.mActivityBgStartPosX[#self.mActivityBgStartPosX+1] = bg:getPositionX()
    self.mActivityDeleteBtn[#self.mActivityDeleteBtn+1] = btnDelete
	end  

	self.mList:reload()		
end
-- 输入事件监听方法
function MyBoardLayer:onEdit(event, editbox,itemData)
    if event == "began" then
    -- 开始输入
        --print("开始输入")
    elseif event == "changed" then
    -- 输入框内容发生变化
        --print("输入框内容发生变化")      
        local _text = editbox:getText()
		local _trimed = string.trim(_text)		
		if _trimed ~= _text then			
		    editbox:setText(_trimed)
		end

    elseif event == "ended" then
    -- 输入结束
        --print("输入结束")        
    elseif event == "return" then
    	local name = editbox:getText()
      if name=="" then
        name = itemData[REPLAY_NAME]
        editbox:setText(name)
      end
    	if itemData[REPLAY_NAME] ~= name then
    		DBHttpRequest:upFavoriteHands(function(tableData,tag) self:httpResponse(tableData,tag,itemData) end,itemData[REPLAY_FID],name)
    	end
    -- 从输入框返回
        --print("从输入框返回")       
    end
end
local ITEM_MOVE_POS = 120
function MyBoardLayer:activityBgMove(index, deltaX)
    local curX = self.mActivityBg[index]:getPositionX()
    curX = curX-deltaX
    if curX<self.mActivityBgStartPosX[index]-ITEM_MOVE_POS then
      curX = self.mActivityBgStartPosX[index]-ITEM_MOVE_POS
    end
    if curX>self.mActivityBgStartPosX[index] then
      curX = self.mActivityBgStartPosX[index]
    end
    self.mActivityBg[index]:setPositionX(curX)
end


function MyBoardLayer:touchRightListener(event)
--         if 3 == event.itemPos then
            -- listView:removeItem(event.item, true)
--         else


    if event.name == "began" then
        local touchPos = cc.p(event.x, event.y)
        for i=1,#self.mActivityBg do
          nodePoint = touchPos
          nodePoint = self.mList:convertToWorldSpace(nodePoint)
          nodePoint = self.mActivityBg[i]:convertToNodeSpace(nodePoint)
          local size = self.mActivityBg[i]:getContentSize()
          local rect = cc.rect(0,0,size.width,size.height)
          if cc.rectContainsPoint(rect, nodePoint) then

            if self.mSeletedIndex then
              self.mActivityBg[self.mSeletedIndex]:setPositionX(self.mActivityBgStartPosX[self.mSeletedIndex])
              self.mActivityDeleteBtn[self.mSeletedIndex]:setVisible(false)
              self.mSeletedIndex = nil
              return true
            end
            self.mSeletedIndex = i
            self.mStartPos = touchPos
            self.mTouchStatus = "began"
            self.mIsTouchBg = true
            break
          end
        end
        return true
    end

    if event.name == "moved" then
      -- self.isValidMove = true]
      if not self.mTouchStatus then return end
      if self.mTouchStatus == "began" then
          if self.mIsTouchBg then
            local deltaX = self.mStartPos.x - event.x
            local deltaY = self.mStartPos.y - event.y
            if deltaX > 0 then
              deltaY = deltaY>0 and deltaY or -deltaY
              if deltaX>deltaY then
                self.mTouchStatus = "moved"
                self.mLastPosX = event.x
                -- self:activityBgMove(self.mSeletedIndex, deltaX)
              else
                self.mTouchStatus = nil
              end
            end
          end 
      end 
      if self.mTouchStatus == "moved" then
          local deltaX = self.mLastPosX - event.x
          self:activityBgMove(self.mSeletedIndex, deltaX)
          self.mActivityDeleteBtn[self.mSeletedIndex]:setVisible(true)
          self.mLastPosX = event.x
      end
      -- return true
    end

    if event.name == "ended" then
        if self.mTouchStatus and self.mSeletedIndex then
          local movePos = self.mActivityBgStartPosX[self.mSeletedIndex] - self.mActivityBg[self.mSeletedIndex]:getPositionX()
          if movePos>ITEM_MOVE_POS/2 then
            self.mActivityBg[self.mSeletedIndex]:setPositionX(self.mActivityBgStartPosX[self.mSeletedIndex]-ITEM_MOVE_POS)
            self.mActivityDeleteBtn[self.mSeletedIndex]:setVisible(true)
          else
            self.mActivityBg[self.mSeletedIndex]:setPositionX(self.mActivityBgStartPosX[self.mSeletedIndex])
            self.mActivityDeleteBtn[self.mSeletedIndex]:setVisible(false)
            self.mSeletedIndex = nil
          end
          self.mStartPos = nil
          self.mTouchStatus = nil
          self.mIsTouchBg = nil
        end
    end



  -- if event.name == "began" then
  --   if self.m_selectedItem then
  --     transition.moveTo(self.m_selectedItem, {x = 0, y = self.m_selectedPosY, time = 0.5, onComplete = function()
  --       self.m_canMove = true
  --       self.m_selectedItem = nil
  --       end,})
  --     return true
  --   end
  -- end
  -- if event.name == "clicked" and event.item and self.m_selectedItem == nil then
  --     if self.m_canMove == true then
  --         if self.m_selectedItem ~= nil then
  --           transition.moveTo(self.m_selectedItem, {x = 0, y = self.m_selectedPosY, time = 0.5, onComplete = function()
  --             self.m_canMove = true
  --             self.m_selectedItem = nil
  --             end,})
  --         else
  --           self.m_selectedItem = event.item
  --           self.m_selectedPosY = event.item:getPositionY()
  --           transition.moveTo(event.item, {x = -60, y = self.m_selectedPosY, time = 0.5, onComplete = function()
  --                   self.m_canMove = true
  --               end,})
  --         end
  --         self.m_canMove = false
  --     end
  -- end
end

function MyBoardLayer:onMenuCallBack(tag,itemData)
  -- dump(itemData)
  	if tag == EnumMenu.eBtnPlayer then
      GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.ReplayView,{REPLAY_FID = itemData[REPLAY_FID]})
  	elseif tag == EnumMenu.eBtnShare then
      local url = ""
      if SERVER_ENVIROMENT == ENVIROMENT_TEST then
          url = "http://debao.boss.com/index.php?act=video&mod=getmobilevideo&fid="..itemData[REPLAY_FID]
      else
          url = "http://www.debao.com/index.php?act=video&mod=getmobilevideo&fid="..itemData[REPLAY_FID]
      end
      local data       = {title = "我在#德堡德州扑克#的一场精彩牌局",content = "我在#德堡扑克#中录制的一场精彩牌局,小伙伴们快来围观~~~",nType = 1,url = url}
      QManagerPlatform:shareToWeChat(data)
  	elseif tag == EnumMenu.eBtnDelete then
  		self:onMenuDelete(itemData)
  	end
end
function MyBoardLayer:onMenuDelete(itemData)
	self:hideInputBox(false)
	local AlertDialog = require("app.Component.CMAlertDialog").new({
    		text = "确定删除牌局？",
    		titleText = "删除牌局",
    		okText    = "删除",
    		showType = 3,
    		callOk = function () 
    			self:hideInputBox(true,true) 
    			DBHttpRequest:delFavoriteHands(function(tableData,tag) self:httpResponse(tableData,tag,itemData) end,itemData[REPLAY_FID]) 
    			end,
    		callCancle = function () 
    			self:hideInputBox(true,true) 
    			end,
    		 })
    	CMOpen(AlertDialog,self)
end
function MyBoardLayer:showActionResult(tableData,itemData,text)
	self:hideInputBox(false)
	local AlertDialog = require("app.Component.CMAlertDialog").new({
		text = text,
		titleText = "提示",
		showType  = 1,
		callOk = function () 
			self:hideInputBox(true,true) 
			
			end,
		 })
	CMOpen(AlertDialog,self)
end
function MyBoardLayer:hideInputBox(isVisible,isDelay,dt)
	if isDelay then
		CMDelay(self, dt or 0.15, function () self:hideInputBox(isVisible) end)
		return
	end
	for i ,v in pairs(self.mActivitySprite) do 
		v:setVisible(isVisible)
	end
end
--[[
  网络回调
]]
function MyBoardLayer:httpResponse(tableData,tag,itemData) 
    dump(tableData,tag)
    if tag == POST_COMMAND_GetUserHandsFavorite then  
    	QDataMyBoardList:Init(tableData)
    	self:createRightList( )
    elseif tag == POST_COMMAND_DelFavoriteHands then
    	if tableData == 1 then
	    	QDataMyBoardList:removeItemData(itemData[REPLAY_FID])
	    	for i,v in pairs(self.mActivitySprite) do 
				if v == itemData.inputBox then
					table.remove(self.mActivitySprite,i)
					break
				end
			end
			self.mList:removeItem(itemData.item,false)
      CMShowTip("删除牌局成功")
	    	--self:showActionResult(tableData,itemData, "删除牌局成功")
	    end
    elseif tag == POST_COMMAND_UpFavoriteHands then
    	if tableData == 1 then
        CMShowTip("修改名称成功")
    		--self:showActionResult(tableData,itemData,"修改名称成功")
    	end
    end
    
end
return MyBoardLayer