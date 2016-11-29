--
-- Author: JayJay
-- Date: 2016-04-17 17:56:28
--
local CMGroupButton = class("CMGroupButton", function()
    return display.newNode()
end)
--[[
	size:可见区域大小
	direction:滑动列表方向
	name:按钮名称{}
	callback:事件回调
]]
function CMGroupButton:ctor(params)
	self.params 	= params or {}
	self.mListSize  = self.params.size or cc.size(210,330)
	self.mDirection = self.params.direction or cc.ui.UIScrollView.DIRECTION_VERTICAL
	self.mListName 	= self.params.name or {"测试1","测试2"}
	self.mCallBack  = self.params.callback
	self.mListSprite= {}
	self.mAllSelectNode = {}
end

function CMGroupButton:create()
	self:addButtonList()
end
function CMGroupButton:onExit()
	dump("ended")
end
--[[
	添加按钮列表
]]
function CMGroupButton:addButtonList()
	self.mListSize = self.mListSize	
	self.mList = cc.ui.UIListView.new {
    	-- bgColor = cc.c4b(200, 200, 200, 120),
    	viewRect = cc.rect(5, 5, self.mListSize.width, self.mListSize.height),    	
    	direction = self.mDirection }
    :onTouch(handler(self, self.touchListener))
    :addTo(self,1)    
  	
	for i = 1,#self.mListName do   
		local item = self.mList:newItem() 
		local btnActivity = cc.Sprite:create("picdata/public/btn_tap.png")
	    :align(display.CENTER, 0,0) --设置位置 锚点位置和坐标x,y
	    item:addContent(btnActivity)   
	    	 
		local selecthSprite = cc.Sprite:create("picdata/public/btn_tap2.png")
		selecthSprite:setVisible(false)
		selecthSprite:setPosition(selecthSprite:getContentSize().width/2,selecthSprite:getContentSize().height/2)
		btnActivity:addChild(selecthSprite,0,101)

		local sDetail = cc.ui.UILabel.new({text = self.mListName[i],size = 28,color = cc.c3b(188,201,229),font = GFZZC})	
		sDetail:setPosition(btnActivity:getContentSize().width/2-sDetail:getContentSize().width/2,btnActivity:getContentSize().height/2)
		btnActivity:addChild(sDetail,1,102)

		item:setItemSize(selecthSprite:getContentSize().width, selecthSprite:getContentSize().height+6)
	   	self.mList:addItem(item)
		self.mListSprite[#self.mListSprite + 1] = btnActivity
	end	
	self.mList:reload()
end
function CMGroupButton:touchListener(event)
	local name, x, y = event.name, event.x, event.y	
	 if name == "clicked" then
	 	self:checkTouchInSprite_(event.itemPos)
	 else
		if name == "began" then
	        -- self.touchBeganX = x
	        -- self.touchBeganY = y
	       return true
	    end	    
	 end
	
end
function CMGroupButton:checkTouchInSprite_(index)
	if not index then return end
	-- if self.mLastIndex == index then 
	-- 	return 
	-- end
	if self.mLastIndex then
		self.mListSprite[self.mLastIndex]:getChildByTag(101):setVisible(false)
		self.mListSprite[self.mLastIndex]:getChildByTag(102):disableEffect()
		self.mListSprite[self.mLastIndex]:getChildByTag(102):setColor(cc.c3b(188,201,229))
	end
	if self.mAllSelectNode[self.mLastIndex] then 
		self.mAllSelectNode[self.mLastIndex]:setVisible(false) 		--隐藏上一个节点
	end
	self.mLastIndex = index
	
	if self.mAllSelectNode[self.mLastIndex] then 
		self.mAllSelectNode[self.mLastIndex]:setVisible(true) 		--显示已创建节点
	else	
		if self.mCallBack then
			self.mAllSelectNode[index] = self.mCallBack(index)		--不存在则创建节点
		end
	end
	self.mListSprite[index]:getChildByTag(102):setColor(cc.c3b(255,238,204))
	self.mListSprite[index]:getChildByTag(102):enableShadow(cc.c4b(0,0,0,190),cc.size(0,-2))
	self.mListSprite[index]:getChildByTag(101):setVisible(true)
	
end

return CMGroupButton