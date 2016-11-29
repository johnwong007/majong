local MusicPlayer = require("app.Tools.MusicPlayer")
local commonText = {
	"快点行动，太墨迹了！",
	"速度快点，花儿都谢了！",
	"求人品啊求人品！",
	"这也能赢，什么运气啊！",
	"赌一赌，搏一搏，单车变摩托！",
	"我要加注，你敢跟吗？",
	"来，战个痛快！",
	"运气真差，来点好牌吧！",
	"弃牌，也是一种智慧。",
	"不赢光你我就不离桌了！",
}

local ShowChatView = 0
local ShowExpressionView = 1
local ShowRecordView = 2

local commenTextFont = "黑体" --字体
local commenTextFontSize  = 22 --字体大小
local commenTextCount = 10 --常用语个数

local eTextOften = 0
local eTextRecord = 1
local listRect = cc.rect(102, 110, 338, 508)

local dialogStartPos = cc.p(5,5)
-- local textInputPos = cc.p(dialogStartPos.x+25, dialogStartPos.y+30)
local textInputPos = cc.p(dialogStartPos.x+10, dialogStartPos.y+30)

local buttonPos = cc.p(textInputPos.x+81, 115)
local buttonHeight = 167

-- local imagePath = cc.FileUtils:getInstance():getWritablePath().."images/faces/face/"
local imagePath = "picdata/face/"

local DialogBase = require("app.GUI.roomView.DialogBase")
local ChatAndExpressionDialog = class("ChatAndExpressionDialog", function(event)
        return DialogBase:new()
    end)

--[[
** chatRecord 聊天记录 **
** chatCallback 聊天回调函数 **
** expressionCallback 表情回调函数 **
** currentShow 当前显示，0聊天 1表情 2记录 **
]]
function ChatAndExpressionDialog:dialog(chatRecord, chatCallback, expressionCallback, currentShow)
	local dialog = ChatAndExpressionDialog:new(chatRecord, currentShow)
	dialog.m_chatCallback = chatCallback
	dialog.m_expressionCallback = expressionCallback
	return dialog
end

function ChatAndExpressionDialog:ctor(className, chatRecord, currentShow)
	self.m_chatCallback = nil
	self.m_expressionCallback = nil

	self.m_chatList = nil 
	self.m_expressionList = nil 
	self.m_recordList = nil
	self.m_faceCount = 30
	self.m_chatRecords = chatRecord

	self:init()

	self.m_currentShow = currentShow
	self:switchLayer()

	-- 允许 node 接受触摸事件
    self:setTouchEnabled(true)

	-- 注册触摸事件
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    	-- event.name 是触摸事件的状态：began, moved, ended, cancelled
    	-- event.x, event.y 是触摸点当前位置
    	-- event.prevX, event.prevY 是触摸点之前的位置
    	-- printf("sprite: %s x,y: %0.2f, %0.2f",
     --       event.name, event.x, event.y)

    	-- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
    	-- 则必须返回 true
    	if event.name == "began" then
        	return self:ccTouchBegan(event)
    	end
	end)
	
	MusicPlayer:getInstance():playDialogOpenSound()
end

function ChatAndExpressionDialog:ccTouchBegan(event)
    local pos  = cc.p(event.x, event.y)
    local rect = cc.rect(dialogStartPos.x, dialogStartPos.y, self.m_bkSize.width, self.m_bkSize.height)
    if not cc.rectContainsPoint(rect, pos) then
        self:remove()
		MusicPlayer:getInstance():playDialogCloseSound()
    end
    return true
end

function ChatAndExpressionDialog:init()
	self:manualLoadxml()
end

function ChatAndExpressionDialog:manualLoadxml()
	--[[背景]]
	self.m_background = cc.ui.UIImage.new("tall_bg.png")
		:align(display.LEFT_BOTTOM, dialogStartPos.x, dialogStartPos.y)
		:addTo(self)
	self.m_bkSize = self.m_background:getContentSize()

	--[[输入框背景]]
	local textFieldBg = cc.ui.UIImage.new("tall_cyy_bg.png")
		:align(display.LEFT_BOTTOM, textInputPos.x, textInputPos.y)
		:addTo(self)

	--[[发送按钮]]
	cc.ui.UIPushButton.new({normal="tall_btn_fs.png", pressed="tall_btn_fs.png", disabled="tall_btn_fs.png"})
		:align(display.LEFT_CENTER, textInputPos.x+textFieldBg:getContentSize().width+5, textInputPos.y+30)
		:onButtonClicked(function(event)
			self:sendWord()
			end)
		:addTo(self, 1)

	--[[聊天按钮]]
	self.m_chatButton = cc.ui.UIPushButton.new({normal="tall_cyy.png", pressed="tall_cyy.png", disabled="tall_cyy.png"})
		:align(display.RIGHT_BOTTOM, buttonPos.x, buttonPos.y+buttonHeight*2)
		:onButtonClicked(function(event)
			self:pressChatButton()
			end)
		:addTo(self, 1)

	--[[表情按钮]]
	self.m_expressionButton = cc.ui.UIPushButton.new({normal="tall_bq.png", pressed="tall_bq.png", disabled="tall_bq.png"})
		:align(display.RIGHT_BOTTOM, buttonPos.x, buttonPos.y+buttonHeight)
		:onButtonClicked(function(event)
			self:pressExpressionButton()
			end)
		:addTo(self, 1)

	--[[聊天记录按钮]]
	self.m_recordButton = cc.ui.UIPushButton.new({normal="tall_jl.png", pressed="tall_jl.png", disabled="tall_jl.png"})
		:align(display.RIGHT_BOTTOM, buttonPos.x, buttonPos.y)
		:onButtonClicked(function(event)
			self:pressRecordButton()
			end)
		:addTo(self, 1)

	--[[输入框]]
    self.m_textField = cc.ui.UIInput.new({
        image = "transBG.png",
        listener = handler(self, self.onEdit),
        size = cc.size(330,50),
        x = textFieldBg:getPositionX()+10,
        y = textInputPos.y+25,
        placeHolder = "dskjfkdsjkfj",
        text = "",
        font = "fonts/FZZCHJW--GB1-0.TTF"
        }):addTo(self, 1)
    self.m_textField:setFontColor(cc.c3b(0, 0, 0))
    self.m_textField:setAnchorPoint(cc.p(0,0.5))
    self.m_textField:setFontSize(25)

	self.m_chatList = cc.ui.UIListView.new{
		viewRect = listRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		:onTouch(handler(self, self.touchListener))
		:addTo(self, 1)
	self:initChatCells()

	self.m_expressionList = cc.ui.UIListView.new{
		viewRect = listRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		:onTouch(handler(self, self.touchListener))
		:addTo(self, 1)
	self:initExpressionCells()

	self.m_recordList = cc.ui.UIListView.new{
		viewRect = listRect,
		direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
		:onTouch(handler(self, self.touchListener))
		:addTo(self, 1)
	self:initRecordCells()
end

-- 输入事件监听方法
function ChatAndExpressionDialog:onEdit(event, editbox)
	if event == "ended" then
    	editbox:setText(FilterWords:filterWord(editbox:getText()))
	end
end

function ChatAndExpressionDialog:touchListener(event)
	if "began" == event.name then
    elseif "clicked" == event.name then
       	if self.m_currentShow == ShowRecordView then
       		self.m_textField:setText(self.m_chatRecords[event.itemPos].chatMsg)
       		self:sendWord()
       	elseif self.m_currentShow == ShowChatView then
       		-- dump(commonText[event.itemPos])
       		self.m_textField:setText(commonText[event.itemPos])
       		self:sendWord()
       	end
    elseif "moved" == event.name then
       
    elseif "ended" == event.name then
        
    else
        
    end
end

function ChatAndExpressionDialog:initChatCells()
	if self.m_chatList then
		self.m_chatList:removeAllItems()
	end

	for i=1,#commonText do
		local item = self.m_chatList:newItem()
		local node = display.newNode()

		cc.ui.UIImage.new("tall_cyy_bg.png")
			:align(display.CENTER, 0, 0)
			:addTo(node)

		local label = cc.ui.UILabel.new({
			text = commonText[i],
			font = "黑体",
			size = 25,
			color = cc.c3b(0,0,0),
			align = cc.TEXT_ALIGNMENT_LEFT
			})
			:align(display.LEFT_CENTER, -160, 0)
			:addTo(node, 1)
		item:addContent(node) item:setItemSize(338,70)
		self.m_chatList:addItem(item)
	end
	self.m_chatList:reload()
end

function ChatAndExpressionDialog:initExpressionCells()
	if self.m_expressionList then
		self.m_expressionList:removeAllItems()
	end

	if not require("app.Tools.FacePicManger"):getInstance():checkUncompress() then
		return
	end
	for i=1,self.m_faceCount/3 do
		local item = self.m_expressionList:newItem()
		local node = display.newNode()
		--[[表情按钮]]
		local tag = (i-1)*3+1
		local filename = imagePath..tag..".png"
		cc.ui.UIPushButton.new({normal=filename, pressed=filename, disabled=filename})
			:align(display.CENTER, -120, 0)
			:onButtonClicked(function(event)
				self:sendFace((i-1)*3+1)
			end)
			:addTo(node)
			:setTouchSwallowEnabled(false)

		tag = (i-1)*3+2
		filename = imagePath..tag..".png"
		cc.ui.UIPushButton.new({normal=filename, pressed=filename, disabled=filename})
			:align(display.CENTER, 0, 0)
			:onButtonClicked(function(event)
				self:sendFace((i-1)*3+2)
			end)
			:addTo(node)
			:setTouchSwallowEnabled(false)

		tag = (i-1)*3+3
		filename = imagePath..tag..".png"
		cc.ui.UIPushButton.new({normal=filename, pressed=filename, disabled=filename})
			:align(display.CENTER, 120, 0)
			:onButtonClicked(function(event)
				self:sendFace((i-1)*3+3)
			end)
			:addTo(node)
			:setTouchSwallowEnabled(false)
		
		item:addContent(node)
		item:setItemSize(338,100)
		self.m_expressionList:addItem(item)
	end
	self.m_expressionList:reload()
end

function ChatAndExpressionDialog:initRecordCells()
	if self.m_recordList then
		self.m_recordList:removeAllItems()
	end

	if self.m_chatRecords== nil then
		return 
	end
	local tempHeight = 100
	for i=1,#self.m_chatRecords do
		local item = self.m_recordList:newItem()
		local node = display.newNode()

		local bg = cc.ui.UIImage.new("line.png")
			:align(display.CENTER, 0, -tempHeight/2)
			:addTo(node)
		bg:setScaleX(100)

		local label = cc.ui.UILabel.new({
			text = self.m_chatRecords[i].userName..":".."",
			font = "黑体",
			size = 25,
			color = cc.c3b(255,228,173),
			align = cc.TEXT_ALIGNMENT_LEFT,
			valign = cc.TEXT_ALIGNMENT_TOP,
			dimensions = cc.size(328,90)
			})
			:align(display.CENTER, 0, 0)
			:addTo(node, 1)

		local str = "\n"
		for j=1,string.len(self.m_chatRecords[i].userName) do
			-- local curByte = string.byte(self.m_chatRecords[i].userName, j)
	  --   	local byteCount = 1
	  --   	if curByte>0 and curByte<=127 then
	  --       	byteCount = 1  
	  --   	elseif curByte > 127 then
	  --       	byteCount = 3  
	  --   	end
	  --   	if byteCount==1 then
	  --   		str = str.." "
	  --   	else
	  --   		str = str.."  "
	  --   	end
	   
	  --   	j = j + byteCount 	
	  	-- str = str.." "
		end
		local label1 = cc.ui.UILabel.new({
			text = str..self.m_chatRecords[i].chatMsg,
			font = "黑体",
			size = 25,
			color = cc.c3b(255,255,255),
			align = cc.TEXT_ALIGNMENT_LEFT,
			valign = cc.TEXT_ALIGNMENT_TOP,
			dimensions = cc.size(328,90)
			})
			:align(display.CENTER, 0, 0)
			:addTo(node, 1)

		item:addContent(node)
		item:setItemSize(338,tempHeight)
		self.m_recordList:addItem(item)
	end
	self.m_recordList:reload()
end

function ChatAndExpressionDialog:sendWord()

    local labelContent = self.m_textField:getText()
    local chatType = "COMMON"
   
    if self.m_chatCallback then
    	self.m_chatCallback(labelContent,chatType)
    end
    self:remove()
end

function ChatAndExpressionDialog:sendFace(tag)
	-- dump(tag)

    local sendWord = "|exp_default_"
    sendWord = sendWord..tag.."|"
    local chatType = "ALL"
   
    if self.m_expressionCallback then
    	self.m_expressionCallback(sendWord,chatType)
    end
    self:remove()
end

function ChatAndExpressionDialog:pressChatButton()
	-- dump("pressChatButton")
	if self.m_currentShow ~= ShowChatView then
		self.m_currentShow = ShowChatView
		self:switchLayer()
	end
end

function ChatAndExpressionDialog:pressExpressionButton()
	if self.m_currentShow ~= ShowExpressionView then
		self.m_currentShow = ShowExpressionView
		self:switchLayer()
	end
end

function ChatAndExpressionDialog:pressRecordButton()
	if self.m_currentShow ~= ShowRecordView then
		self.m_currentShow = ShowRecordView
		self:switchLayer()
	end
end

function ChatAndExpressionDialog:switchLayer()
	if self.m_currentShow == ShowChatView then
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_cyy2.png")
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_cyy2.png")
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_cyy2.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_bq.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_bq.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_bq.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_jl.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_jl.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_jl.png")

		self.m_chatList:setVisible(true)
		self.m_expressionList:setVisible(false) 
		self.m_recordList:setVisible(false)
	elseif self.m_currentShow == ShowRecordView then
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_cyy.png")
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_cyy.png")
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_cyy.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_bq.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_bq.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_bq.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_jl2.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_jl2.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_jl2.png")

		self.m_chatList:setVisible(false)
		self.m_expressionList:setVisible(false) 
		self.m_recordList:setVisible(true)
	else
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_cyy.png")
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_cyy.png")
    	self.m_chatButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_cyy.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_bq2.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_bq2.png")
    	self.m_expressionButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_bq2.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.NORMAL, "tall_jl.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.PRESSED, "tall_jl.png")
    	self.m_recordButton:setButtonImage(cc.ui.UIPushButton.DISABLED, "tall_jl.png")

		self.m_chatList:setVisible(false)
		self.m_expressionList:setVisible(true) 
		self.m_recordList:setVisible(false)
	end
end

return ChatAndExpressionDialog