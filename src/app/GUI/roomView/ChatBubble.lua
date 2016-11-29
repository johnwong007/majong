eLeftBubble			=0
eRightBubble		=1

eChatString			=0
eChatFace			=1
eChatUnknow			=2

local ChatBubble = class("ChatBubble", function()
		return display.newNode()
	end)

function ChatBubble:bubble()
	local bubb = ChatBubble:new()
	return bubb
end

function ChatBubble:ctor()
	self.m_bScrolling = false
	self.m_chatType = 0
	self.m_stringWidth = 0
	self.m_layerWidth = 0
	self.m_faceDelay = 0.0

    self:setNodeEventEnabled(true)
end

function ChatBubble:onNodeEvent(event)
    if event == "exit" then
    	self:onExit()
    end
end

function ChatBubble:onExit()
	if self.m_ScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_ScriptFuncId)
		self.m_ScriptFuncId = nil
    end
end

function ChatBubble:updateOffset(dt)

	local offset = self.m_layerScroll:getContentOffset().x
	if (offset <= self.m_layerWidth - self.m_stringWidth) then
	
		local out = cc.FadeOut:create(0.5)
		local action = cc.CallFunc:create(handler(self,self.hide))
		self.m_bubbleSprite:runAction(cc.Sequence:create(out, action))
		self.m_bScrolling = false
	else
		self.m_layerScroll:setContentOffset(cc.p(self.m_layerScroll:getContentOffset().x - 1, 0), false)
	end
	
end
function ChatBubble:stringVisibleComplete()
	self.m_ScriptFuncId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateOffset),0.05,false)
	self.m_bScrolling = true
end
function ChatBubble:loadChatInfo(message, around, money)
	self:setVisible(false)
	if(self.m_bubbleSprite) then
		self.m_bubbleSprite:stopAllActions()
	end
	if self.m_ScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_ScriptFuncId)
		self.m_ScriptFuncId = nil
	end
	self:removeAllChildren(false)
	self.m_bScrolling = false
	local faceSprite = nil
	if(self.m_bFace) then
	
		faceSprite = require("app.Tools.FacePicManger"):getInstance():getFaceByName(message)
	end
	
	if(faceSprite) then
	
		self.m_chatType = eChatFace
		if (faceSprite==nil) then
			return 
		end
		faceSprite:setParent(nil)
		local group = 1
		if (group == 1) then
		
			self.m_faceDelay = 3.5
		elseif(group == 2) then
		
			self.m_faceDelay = faceSprite:getAnimateTime()
		end
		self:addChild(faceSprite,2)
		faceSprite:setScale(0.9)
		faceSprite:setPosition(-58,-20)
		self.m_bubbleSprite = faceSprite
	else
	
		if (self.m_bFace) then
		
			self.m_chatType = eChatUnknow
			return
		end
		self.m_chatType = eChatString
		local pictureBubble = nil
		if (eLeftBubble== around) then
			pictureBubble="picdata/table/chatBubble.png"
		else
			pictureBubble="picdata/table/chatBubble.png"
		end
		
		local bubbleSprite = cc.Sprite:create(pictureBubble)
		self:addChild(bubbleSprite,1, 100)
		self.m_bubbleSprite = bubbleSprite
        
		local node = display.newNode()
		local lable = cc.ui.UILabel.new({
			text = message,
			font = "黑体",
			size = 16,
			color = cc.c3b(0,0,0),
			align = cc.TEXT_ALIGNMENT_LEFT,
			valign = cc.TEXT_ALIGNMENT_CENTER,
			-- dimensions = cc.size(bubbleSprite:getContentSize().width, lable:getContentSize().height)
			})
			:align(display.LEFT_CENTER, 10, 10)
			:addTo(node)

		self.m_layerWidth = bubbleSprite:getContentSize().width - 10
		local bubbleTextFieldSize=cc.size(self.m_layerWidth, bubbleSprite:getContentSize().height)
		self.m_stringWidth = lable:getContentSize().width
		
		self.m_layerScroll = cc.ScrollView:create(cc.size(self.m_layerWidth, bubbleTextFieldSize.height+30), node)
		self.m_layerScroll:setPosition(cc.p(5, bubbleTextFieldSize.height/2 - 3))
		self.m_layerScroll:setDirection(0)
		self.m_layerScroll:setTouchEnabled(false)
		self.m_bubbleSprite:addChild(self.m_layerScroll, 10)
	end
    
	--
end
function ChatBubble:show(message, around, money, bFace)
	
	self.m_bFace = bFace
	self:loadChatInfo(message, around,money)
	self:setVisible(true)
	if (self.m_chatType == eChatString) then
		local offset = self.m_layerScroll:getContentOffset().x
		if (offset <= self.m_layerWidth - self.m_stringWidth) then
		
			self.m_bubbleSprite:setOpacity(0)
			local fadein = cc.FadeIn:create(0.5)
			local time = cc.DelayTime:create(2)
			local out = cc.FadeOut:create(0.5)
			local action = cc.CallFunc:create(handler(self,self.hide))
			self.m_bubbleSprite:runAction(cc.Sequence:create(fadein, time, out, action))
		else
		
			local fadein = cc.FadeIn:create(0.5)
			local time = cc.DelayTime:create(2)
			local action = cc.CallFunc:create(handler(self,self.stringVisibleComplete))
			self.m_bubbleSprite:runAction(cc.Sequence:create(fadein, time, action))
		end
	elseif(self.m_chatType == eChatFace) then
	
		--local  actionBy = cc.FadeIn:create(0.5)
		local waitAction = cc.DelayTime:create(self.m_faceDelay)
		local  FadeTo = cc.FadeOut:create(0.5)
		local action = cc.CallFunc:create(handler(self,self.hide))
		self.m_bubbleSprite:runAction(cc.Sequence:create(waitAction,FadeTo,action))
	end
end
function ChatBubble:hide()

	self.m_bubbleSprite:stopAllActions()
	if self.m_ScriptFuncId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_ScriptFuncId)
		self.m_ScriptFuncId = nil
	end
	self:setVisible(false)
end

return ChatBubble