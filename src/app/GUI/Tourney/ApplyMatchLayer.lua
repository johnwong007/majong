local DialogBase = require("app.GUI.roomView.DialogBase")
local TABLE_CELL_WIDTH = 492
local TABLE_CELL_HEIGHT = 116
local ApplyMatchLayer = class("ApplyMatchLayer", function()
		return DialogBase:new()
	end)

function ApplyMatchLayer:layer()
	local layer = ApplyMatchLayer:new()
	return layer
end

function ApplyMatchLayer:ctor()

    self.m_detailList = {}
    self.m_userTableList = nil

    self.m_table = nil
    self.m_matchesData = nil
    self.m_serverTime = 0
    self.m_clickIndex = 0

    self:manualLoadxml()
    self:setPosition(LAYOUT_OFFSET)

    DBHttpRequest:getUserTableList(handler(self, self.httpResponse))
end

function ApplyMatchLayer:manualLoadxml()
	self.main_bg = cc.ui.UIImage.new("signedBG.png")
	self.main_bg:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

    local width = 490
    local height = 320
    self.m_node = display.newNode()
    self.m_node:addTo(self)
    self.m_node:setContentSize(self.main_bg:getContentSize())
    self.m_node:setPositionX(self.main_bg:getPositionX()-width)
    self.m_node:setPositionY(self.main_bg:getPositionY()-height)

	self.backbutton = cc.ui.UIPushButton.new({normal="btn_2_close.png", pressed="btn_2_close2.png",
		disabled="btn_2_close2.png"})
	self.backbutton:align(display.CENTER, 755, 565)
		:addTo(self.m_node, 1)
	self.backbutton:onButtonClicked(function(event)
		self:button_click(111)
	end)
end

function ApplyMatchLayer:initTableCells()
    if self.m_tableViewCells then
        self.m_table:removeAllItems()
    end
    self.m_tableViewCells=nil
    self.m_tableViewCells={}
    if self.m_detailList==nil or #self.m_detailList<=0 then
        return
    end
    
    -- dump(self.m_detailList)
    for i=#self.m_detailList,1,-1 do
        if string.find(self.m_detailList[i].tourneyType, "SNG") ~= nil or string.find(self.m_detailList[i].payType, "POINT") ~= nil then
            table.remove(self.m_detailList, i)
        end
    end

    for i=1,#self.m_detailList do
        local item = self.m_table:newItem()
        self.m_tableViewCells[i] = self:tableCellAtIndex(self.m_table, i)
        item:addContent(self.m_tableViewCells[i])
        item:setItemSize(TABLE_CELL_WIDTH, TABLE_CELL_HEIGHT)
        self.m_table:addItem(item)
    end
    self.m_table:reload()
end

function ApplyMatchLayer:tableCellAtIndex(table, idx)
    local cell = display.newNode()
    -- cell:setPosition(cc.p(-TABLE_CELL_WIDTH/2, -TABLE_CELL_HEIGHT/2))
    local bg = cc.ui.UIImage.new("picdata/tourney/signedCellBG.png")
    bg:align(display.CENTER, 0, 0)
    cell:addChild(bg)
    
    local name = cc.LabelTTF:create(self.m_detailList[idx].matchName , "黑体", 24, cc.size(375, 35))
    name:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    name:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    name:setAnchorPoint(cc.p(0,0.5))
    name:setPosition(cc.p(40-TABLE_CELL_WIDTH/2, 85-TABLE_CELL_HEIGHT/2))
    name:setColor(cc.c3b(1, 250, 221))


    cell:addChild(name)
    
    local time = cc.LabelTTF:create(self.m_detailList[idx].presetStartTime , "黑体", 20, cc.size(250, 35))
    time:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    time:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    time:setAnchorPoint(cc.p(0,0.5))
    time:setPosition(cc.p(50-TABLE_CELL_WIDTH/2, 45-TABLE_CELL_HEIGHT/2))
    time:setColor(cc.c3b(164, 195, 255))
    cell:addChild(time)
    
    
    local timeIcon = cc.Sprite:create("picdata/tourney/timeIcon.png")
    local uIcon = cc.Sprite:create("picdata/tourney/playerIcon.png")
    timeIcon:setPosition(cc.p(25-TABLE_CELL_WIDTH/2, 45-TABLE_CELL_HEIGHT/2))
    uIcon:setPosition(cc.p(25-TABLE_CELL_WIDTH/2, 20-TABLE_CELL_HEIGHT/2))
    cell:addChild(timeIcon)
    cell:addChild(uIcon)
    
    local curUnum=self.m_detailList[idx].curUnum.."人"
    local curUnumLabel = cc.LabelTTF:create(curUnum , "黑体", 20, cc.size(250, 35))
    curUnumLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    curUnumLabel:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    curUnumLabel:setAnchorPoint(cc.p(0,0.5))
    curUnumLabel:setPosition(cc.p(50-TABLE_CELL_WIDTH/2, 20-TABLE_CELL_HEIGHT/2))
    curUnumLabel:setColor(cc.c3b(164, 195, 255))
    cell:addChild(curUnumLabel)
    -- dump(self.m_detailList[idx].matchStatus)
    if (self.m_detailList[idx].matchStatus~="REGISTERING") then 
        --       进入比赛
        if self.m_userTableList.tableList and #self.m_userTableList.tableList>0 then 
        	for i=1,#self.m_userTableList.tableList do 
            	if (self.m_userTableList.tableList[i].usermatchId == self.m_detailList[idx].matchId) then 
                	local bgButtonMenu = cc.ui.UIPushButton.new({normal="picdata/tourney/recentBtn1.png",
                		pressed="picdata/tourney/recentBtn1.png",disabled="picdata/tourney/recentBtn1.png"})
                		:align(display.CENTER, 420-TABLE_CELL_WIDTH/2, 30-TABLE_CELL_HEIGHT/2)
                		:addTo(cell, 4)
                	bgButtonMenu:onButtonClicked(handler(self, self.cellBtnEnterGame))
                	bgButtonMenu.m_userData = self.m_userTableList.tableList[i].usertableId
                
                	local menuStr = cc.LabelTTF:create("进入牌桌", "黑体", 26, cc.p(0,0))
                    menuStr:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                	menuStr:setColor(cc.c3b(255, 255, 255))
                	menuStr:setPosition(cc.p(420-TABLE_CELL_WIDTH/2, 30-TABLE_CELL_HEIGHT/2))
                	cell:addChild(menuStr, 5)
            	else
                	local bgButtonMenu = cc.ui.UIPushButton.new({normal="picdata/tourney/recentBtn1.png",
                		pressed="picdata/tourney/recentBtn1.png",disabled="picdata/tourney/recentBtn1.png"})
                		:align(display.CENTER, 420-TABLE_CELL_WIDTH/2, 30-TABLE_CELL_HEIGHT/2)
                		:addTo(cell, 4)
                	bgButtonMenu:onButtonClicked(handler(self, self.cellBtnEnterGame))
                	bgButtonMenu.m_userData = self.m_userTableList.tableList[i].usertableId
                
	                local menuStr = cc.LabelTTF:create("正在游戏", "黑体", 26, cc.p(0,0))
                    menuStr:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	                menuStr:setColor(cc.c3b(255, 255, 255))
	                menuStr:setPosition(cc.p(420-TABLE_CELL_WIDTH/2, 30-TABLE_CELL_HEIGHT/2))
	                cell:addChild(menuStr, 5)
	                
	                bgButtonMenu:setButtonEnabled(false)
            	end
        	end
        end
    else
--        退赛
        local bgButtonMenu = cc.ui.UIPushButton.new({normal="picdata/tourney/recentBtn2.png",
            pressed="picdata/tourney/recentBtn2.png",disabled="picdata/tourney/recentBtn2.png"})
            :align(display.CENTER, 420-TABLE_CELL_WIDTH/2, 30-TABLE_CELL_HEIGHT/2)
            :addTo(cell, 4)
        bgButtonMenu:onButtonClicked(handler(self, self.cellBtnQuitGame))
        bgButtonMenu.m_userData = self.m_detailList[idx].matchId
        bgButtonMenu:setTag(idx)

        local menuStr = cc.LabelTTF:create("退赛", "黑体", 26, cc.size(0,0))
        menuStr:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        menuStr:setColor(cc.c3b(255, 255, 255))
        menuStr:setPosition(cc.p(420-TABLE_CELL_WIDTH/2, 30-TABLE_CELL_HEIGHT/2))
        cell:addChild(menuStr, 5)
        
    end
    return cell
end

function ApplyMatchLayer:cellBtnEnterGame(event)
	local pSender = event.target
    --local tableID = pSender:getUserObject()
    -- local roomViewManager = RoomViewManager:createRoomViewManager()
    -- GameSceneManager:switchScene(roomViewManager)
    -- roomViewManager:enterRoomWithTableId(tableID)

    GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomViewManager,{tableId = pSender.m_userData,m_isGameType = true })
end
function ApplyMatchLayer:cellBtnQuitGame(event)
	local pSender = event.target
    local matchId = pSender.m_userData
    self.m_clickIndex = pSender:getTag()

    local alert = require("app.Component.EAlertView"):alertView(self:getParent(),self,
        "温馨提示","是否退赛?","取消","确定")
    alert:setTag(2)
    alert:setUserObject(pSender.m_userData)
    if (alert) then
    
        alert:alertShow()
    end
end

function ApplyMatchLayer:dealUserTableList(content)

    local data = require("app.Logic.Datas.Lobby.GetUserTableList"):new()
    self.m_userTableList = nil
    if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then
    
        self.m_userTableList = data
        DBHttpRequest:getApplyMatch(handler(self, self.httpResponse))
    end
    data = nil
end

function ApplyMatchLayer:httpResponse(event)

    local ok = (event.name == "completed")
    local request = event.request
 
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        -- print(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        -- print(code)
        return
    end
    -- 请求成功，显示服务端返回的内容
    local response = request:getResponseString()
	-- self:dealLoginResp(request:getResponseString())
	self:onHttpResponse(request.tag, request:getResponseString(), request:getState())

end

function ApplyMatchLayer:onHttpResponse(tag, content, state)
	if tag==POST_COMMAND_QUITMATCH then
        self:dealQuitMatch(content)
    elseif tag==POST_COMMAND_ApplyedMatch then
        self:dealGetApplyMatch(content)
    elseif tag==POST_COMMAND_GETUSERTABLELIST then
        self:dealUserTableList(content)
    end
end

function ApplyMatchLayer:button_click(tag)
    if tag==111 then
        self:getParent():removeChild(self, true)
    end
end

function ApplyMatchLayer:clickButtonAtIndex(alertView, index)
    if (index ==1) then 
        local matchId = alertView:getUserObject()
        local tag = alertView:getTag()
        if tag==1 then
        elseif tag==2 then
            alertView:remove()
            DBHttpRequest:quitMatch(handler(self,self.httpResponse), matchId)
        end
    end
end

function ApplyMatchLayer:dealGetApplyMatch(content)
    local data = require("app.Logic.Datas.Lobby.ApplyMatchData"):new()
    if (data:parseJson(content) == BIZ_PARS_JSON_SUCCESS) then 
        self.m_detailList=data.matchDetailList
        if (not self.m_table) then 
            self.m_table = cc.ui.UIListView.new{
                viewRect = cc.rect(235,78,510,415),
                direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,}
                :onTouch(handler(self, self.touchListener))
            self.m_node:addChild(self.m_table,999)
        end
        self:initTableCells()
    end
    data = nil
end

function ApplyMatchLayer:touchListener(event)

end

function ApplyMatchLayer:dealQuitMatch(content)
    DBHttpRequest:getApplyMatch(handler(self, self.httpResponse))
    local code = content+0
    if (code > 0) then
    
        local alert = require("app.Component.ETooltipView"):alertView(self,"","成功取消报名!")
        alert:show()
        
    else
        local info = "系统异常"
        if (code==-1) then 
            info ="赛事不存在"
        elseif(code==-4) then
            info ="退赛截止时间已过"
        elseif(code==-6) then
            info ="该赛事目前不允许退赛"
        elseif(code==-8) then
            info ="未报名该赛事"
        elseif(code==-10) then
            info ="人满之后不能退赛"
        elseif(code==-403) then
            info ="未登录"
        elseif(code==-500) then
            info ="系统异常"
        elseif(code==-501) then
            info ="系统异常"
        elseif(code==-10000) then
            info ="系统异常"
        elseif(code==-12016) then
            info ="用户不存在"
        elseif(code==-13004) then
            info ="用户不存在"
        end
        local resultStr= "取消赛事失败,原因:"..info
        local alert = require("app.Component.ETooltipView"):alertView(self,"",resultStr)
        alert:show()
    end
end

return ApplyMatchLayer