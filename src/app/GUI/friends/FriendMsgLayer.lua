--
-- Author: junjie
-- Date: 2015-12-08 13:49:49
--
--好友聊天
local CMCommonLayer = require("app.Component.CMCommonLayer")
local FriendMsgLayer = class("FriendMsgLayer",CMCommonLayer)
local myInfo = require("app.Model.Login.MyInfo")
local QDataFriendList = nil
require("app.Network.Http.DBHttpRequest")
require("app.CommonDataDefine.CommonDataDefine")
function FriendMsgLayer:ctor(params)
    --dump(params)
	self.params = params
	self:setNodeEventEnabled(true)
    self.mCfgData = {}
    QDataFriendList = QManagerData:getCacheData("QDataFriendList")
end
function FriendMsgLayer:onExit()
    QManagerListener:Notify({layerID = eFriendLayerID})
end

function FriendMsgLayer:create()
    local serData = QDataFriendList:getMsgUserData(self.params.nType,self.params.index) or {}
    self.mSerData = serData 
    FriendMsgLayer.super.ctor(self,{titlePath = revertPhoneNumber(self.mSerData[USER_NAME] or ""),}) 
    FriendMsgLayer.super.initUI(self)
    self:initUI()
end
function FriendMsgLayer:initUI()
	DBHttpRequest:getMessage(function(tableData,tag) self:httpResponse(tableData,tag) end,"PRIVATE",self.mSerData[USER_ID] or "","NOT_READ")
	
    local bgWidth = self.mBg:getContentSize().width
    local bgHeight= self.mBg:getContentSize().height

    local bg = cc.Sprite:create("picdata/friend/bg_lt.png")
    bg:setPosition(bgWidth/2, bgHeight/2+15)
    self.mBg:addChild(bg)

    local shawbg = cc.Sprite:create("picdata/public/tc1_bg2_shadow.png")
    shawbg:setPosition(bgWidth/2,130)
    self.mBg:addChild(shawbg)

    local inputBox = CMInput:new({
        --bgColor = cc.c4b(255, 255, 0, 120),
        maxLength = 60,
        place     = "不超过60个字符",
        color     = cc.c3b(0,0,0),
        fontSize  = 30,
        bgPath    = "picdata/friend/bg_srk.png" ,        
        --listener = handler(self,self.onEdit), -- 绑定输入监听事件处理方法
    })
    inputBox:setPosition(bgWidth/2 - 90,55)
    self.mBg:addChild(inputBox )

	self.mChatBox = inputBox

    local btnSend = CMButton.new({normal = "picdata/friend/btn_fs.png",pressed = "picdata/friend/btn_fs2.png"},function () self:onMenuCallBack() end, {scale9 = false})    
    :align(display.CENTER, bgWidth - 110,55) --设置位置 锚点位置和坐标x,y
    :addTo(self.mBg)

end
function FriendMsgLayer:onMenuCallBack(tag)
    -- self.mIdx = (self.mIdx or 0) + 1
    -- local item = self:createPageItem(self.mIdx,{[MESSAGE_CONTENT] = self.mChatBox:getText()})
    -- self.mList:addItem(item,1)
    -- self.mList:reload()
    local text = self.mChatBox:getText()
    if text == "" then return end
    DBHttpRequest:sendFriendMsg(function(tableData,tag) self:httpResponse(tableData,tag) end,self.mSerData[USER_ID],self.mSerData[USER_NAME],text)
end

function FriendMsgLayer:createRightList( tableData)
    -- body
    self.mListSize = cc.size(810,420  ) 
    self.mList = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(30, 110, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchRightListener))
    :addTo(self.mBg,1)    
    if #tableData == 0 then return end
    for i = 1,#tableData do 
        local item = self:createPageItem(i,tableData[#tableData+1-i])
        self.mList:addItem(item)
    end 

    self.mList:reload() 
end

function FriendMsgLayer:createPageItem(idx,serData)

        serData = serData or {}
	    local item = self.mList:newItem()  
       
        local node = cc.Node:create() 
        local itemSize = cc.size(self.mListSize.width,90)
        local bgWidth = itemSize.width
        local bgHeight= itemSize.height
        item:addContent(node)
        node:setContentSize(self.mListSize.width,itemSize.height)
        item:setItemSize(self.mListSize.width,itemSize.height)
        

        -- local content     
        -- content = cc.LayerColor:create(
        --     cc.c4b(math.random(250),
        --         math.random(250),
        --         math.random(250),
        --         250))
        -- content:setContentSize(itemSize.width, itemSize.height)
        -- content:setTouchEnabled(true)    
        -- item:addChild(content) 

        local headPic = CMCreateHeadBg("",cc.size(70,70))
        headPic:setPosition(70,bgHeight/2)
        node:addChild(headPic)

        local nTime = cc.ui.UILabel.new({
                text  = serData[ADDTIME] or CMGetCurrentTime(),--serData[NOTICE_CONTENT],
                size  = 20,
                color = cc.c3b(135, 154, 192),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                -- dimensions = cc.size(530,48),
            })
        nTime:setPosition(120,bgHeight/2+25)
        node:addChild(nTime)

        local content = cc.ui.UILabel.new({
                text  = serData[MESSAGE_CONTENT] or "",
                size  = 20,
                color = cc.c3b(255, 255, 255),
                align = cc.ui.TEXT_ALIGN_LEFT,
                --UILabelType = 1,
                font  = "黑体",
                dimensions = cc.size(580,48),
            })
        content:setPosition(120,bgHeight/2-10)
        node:addChild(content)

        local line = cc.Sprite:create("picdata/friend/line1.png")
        line:setScaleX(80)
        line:setPosition(bgWidth/2, line:getContentSize().height/2)
        node:addChild(line)
        if not serData[SOURCE_UID] or tostring(myInfo.data.userId) == serData[SOURCE_UID]  then
            nTime:setPositionX(bgWidth-nTime:getContentSize().width-110)
            headPic:setPositionX(bgWidth-70)
        end
        return item
end
function FriendMsgLayer:touchRightListener(event)

    
end
function FriendMsgLayer:httpResponse(tableData,tag,nType)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_getMessage then 
        self.mCfgData = tableData or {}
		self:createRightList(tableData)
        if #self.mCfgData >4 then
            self.mList:moveItems(1,#self.mCfgData,0,(#self.mCfgData-4)*90,false)
        end
	elseif tag == POST_COMMAND_SENDPRIVATEMESSAGE then
		if tableData then
            table.insert(self.mCfgData,{[MESSAGE_CONTENT] = self.mChatBox:getText()})
			local item = self:createPageItem(#self.mCfgData,{[MESSAGE_CONTENT] = self.mChatBox:getText()})
		    self.mList:addItem(item,#self.mCfgData)
		    self.mList:reload()
		    self.mChatBox:setText("")
            if #self.mCfgData >4 then
                self.mList:moveItems(1,#self.mCfgData,0,(#self.mCfgData-4)*90,false)
            end
		else
			local AlertDialog = require("app.Component.CMAlertDialog").new({text = "发送消息失败，请重试",})
			CMOpen(AlertDialog,self)
		end
	end
end



return FriendMsgLayer