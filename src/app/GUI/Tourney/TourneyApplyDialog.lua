local DialogBase = require("app.GUI.roomView.DialogBase")

local TourneyApplyLogic = class("TourneyApplyLogic")

function TourneyApplyLogic:ctor(class, target)
	self._payNum = 0.0
	self._serviceNum = 0.0
    self._payType = ""
	self._ticketId = "" --need ticket id
	self._target = target
end

function TourneyApplyLogic:httpResponse(event)

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

function TourneyApplyLogic:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_UserTicketList then
		self:dealUserTicketListResp(content)
	end

end

function TourneyApplyLogic:dealUserTicketListResp(strJson)
	local data = require("app.Logic.Datas.Sns.UserTicketListData"):new()
	-- dump("=====dealUserTicketListResp======")
	if(data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS) then
		-- print("=====dealUserTicketListResp======")
		-- dump(data)
		local index = -1
		for i=1,#data.ticketList do
			if(data.ticketList[i].ticketId == self._ticketId) then
				index = i
				break
			end
		end
		if(index == -1) then
            self._target:tourneyApplyCallback("","",0,self._payNum,self._serviceNum,self._payType)
		
		else
			self._target:tourneyApplyCallback(
                                                data.ticketList[index].ticketId,
                                                data.ticketList[index].ticketName,
                                                data.ticketList[index].ticketNum+0,
                                                self._payNum,self._serviceNum,self._payType)
		end
	end
	data = nil
end

function TourneyApplyLogic:tourneyApply(ticketId, payNum, serviceNum, payType)

	self._ticketId = ticketId
	self._payNum = payNum
	self._serviceNum = serviceNum
    self._payType = payType
    if self._ticketId==nil or self._ticketId=="" then
		self._target:tourneyApplyCallback("","",0,self._payNum,self._serviceNum,self._payType)
	
	else
		DBHttpRequest:getUserTicketList(handler(self, self.httpResponse))
	end
end
--------------------------------------------------------------------------------
local TourenyApplyDialog = class("TourenyApplyDialog", function()
		return DialogBase:new()
	end)

function TourenyApplyDialog:create(matchName, ticketId, payNum, serviceNum, target, callback, payType)
	payType = payType~=nil and payType or "GOLD"
	local dialog = TourenyApplyDialog:new()
	dialog:init(matchName,ticketId,payNum,serviceNum,target,callback,payType)
	return dialog
end

function TourenyApplyDialog:ctor()
	self._target = nil
	self._callback = nil
	self._ticketId = ""
    self._matchName = ""
	self._payNum = 0.0
	self._serviceNum = 0.0
    self._payType = ""
	self._logic = TourneyApplyLogic:new(self)
end

function TourenyApplyDialog:init(matchName, ticketId, payNum, serviceNum, target, callback, payType)
	--[["layout/tourney/TourneyInfo.xml"]]
    
    
    
    self._matchName = matchName
	self._ticketId = ticketId
	self._target = target
	self._callback = callback
	self._payNum = payNum
    self._payType = payType
	self._serviceNum = serviceNum
    self:manualLoadxml()
	self._logic:tourneyApply(self._ticketId,self._payNum,self._serviceNum,self._payType)
	
    self:setPosition(LAYOUT_OFFSET)
end

function TourenyApplyDialog:manualLoadxml()
	self.background = cc.ui.UIImage.new("tourneyApplyBG.png")
		:align(display.CENTER, display.cx, display.cy) 
		:addTo(self)

	local width = 490
	local height = 320
	local node = display.newNode()
	node:addTo(self)
	node:setContentSize(self.background:getContentSize())
	node:setPosition(self.background:getPosition())
	
	cc.ui.UIImage.new("signTitle.png")
		:align(display.CENTER, 480-width, 455-height) 
		:addTo(node, 2)

	self.close = cc.ui.UIPushButton.new({normal="btn_2_close.png",
		pressed="btn_2_close2.png",disabled="btn_2_close2.png"})
		:align(display.CENTER, 795-width, 490-height)
		:onButtonClicked(function(event)
				self:button_click(102)
			end)
		:addTo(node, 3)

	-------------------------------------------------
	self.submitLayer = display.newNode()
	self.submitLayer:addTo(node, 2)

	self.match_label = cc.ui.UIImage.new("matchName.png")
		:align(display.CENTER, 253-width, 390-height)
		:addTo(self.submitLayer, 7)

	local textColor = cc.c3b(255, 255, 255)
	local textSize = 30

	self.match_name = cc.LabelTTF:create(self._matchName, "黑体", textSize)
	self.match_name:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.match_name:setAnchorPoint(cc.p(0,0.5))
	self.match_name:setPosition(cc.p(330-width, 390-height))
	self.match_name:setColor(textColor)
	self.submitLayer:addChild(self.match_name, 7)

	cc.ui.UIImage.new("matchPayNum.png")
		:align(display.CENTER, 253-width, 335-height) 
		:addTo(self.submitLayer, 7)
		-----------------------
	self.gold_apply_layer = display.newNode()
	self.gold_apply_layer:addTo(self.submitLayer, 7)

	self.gold_checkbox = cc.ui.UICheckBoxButton.new({off = "btn_tick.png", on = "btn_tick1.png"})
        :align(display.LEFT_CENTER, 330-width, 335-height)
        :onButtonStateChanged(function(event)
            self:button_click(101)
        end)
        :addTo(self.gold_apply_layer)
    -- self.gold_checkbox:setButtonSelected(true)
    -- self.gold_checkbox:setTouchEnabled(false)

	self.payTypeIcon = cc.ui.UIImage.new("payTypeGold.png")
		:align(display.CENTER, 400-width, 335-height)
		:addTo(self.gold_apply_layer)

	textColor = cc.c3b(255, 255, 255)
	textSize = 30

	self.gold_info = cc.LabelTTF:create("金币信息", "黑体", textSize)
	self.gold_info:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.gold_info:setAnchorPoint(cc.p(0,0.5))
	self.gold_info:setPosition(cc.p(425-width, 335-height))
	self.gold_info:setColor(textColor)
	self.gold_apply_layer:addChild(self.gold_info)
		-----------------------
	self.ticket_apply_layer = display.newNode()
	self.ticket_apply_layer:addTo(self.submitLayer, 7)
	self.ticket_apply_layer:setVisible(false)

	self.ticket_checkbox = cc.ui.UICheckBoxButton.new({off = "checkboxOff.png", on = "checkboxOn.png"})
        :align(display.LEFT_CENTER, 330-width, 275-height)
        :onButtonStateChanged(function(event)
            self:button_click(100)
        end)
        :addTo(self.ticket_apply_layer)
    -- self.ticket_checkbox:setButtonSelected(false)

	cc.ui.UIImage.new("icon_mp.png")
		:align(display.CENTER, 410-width, 275-height)
		:addTo(self.ticket_apply_layer)

	textColor = cc.c3b(0, 197, 255)
	textSize = 30

	self.ticket_info = cc.LabelTTF:create("门票一张", "黑体", textSize)
	self.ticket_info:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.ticket_info:setAnchorPoint(cc.p(0,0.5))
	self.ticket_info:setPosition(cc.p(445-width, 275-height))
	self.ticket_info:setColor(textColor)
	self.ticket_apply_layer:addChild(self.ticket_info)
		-----------------------

	self.cancel = cc.ui.UIPushButton.new({normal="cancelSign.png",
		pressed="cancelSign.png",disabled="cancelSign.png"})
		:align(display.CENTER, 340-width, 188-height)
		:onButtonClicked(function(event)
				self:button_click(103)
			end)
		:addTo(self.submitLayer, 7)

	self.submit = cc.ui.UIPushButton.new({normal="signBtn.png",
		pressed="signBtn.png",disabled="signBtn.png"})
		:align(display.CENTER, 620-width, 188-height)
		:onButtonClicked(function(event)
				self:button_click(104)
			end)
		:addTo(self.submitLayer, 7)

	-------------------------------------------------
	self.noTicketLayer = display.newNode()
	self.noTicketLayer:setPositionY(-320)
	self.noTicketLayer:addTo(node, 2)
	self.noTicketLayer:setVisible(false)

	textColor = cc.c3b(255, 255, 255)
	textSize = 30
	local noTicketLabel = cc.LabelTTF:create("该场比赛只允许门票报名", "黑体", textSize)
	noTicketLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	noTicketLabel:setAnchorPoint(cc.p(0,0.5))
	noTicketLabel:setPosition(cc.p(300-width, 330))
	noTicketLabel:setColor(textColor)
	self.noTicketLayer:addChild(noTicketLabel)

	self.cancel1 = cc.ui.UIPushButton.new({normal="confirm.png",
		pressed="confirm.png",disabled="confirm.png"})
		:align(display.CENTER, 480-width, 188)
		:onButtonClicked(function(event)
				self:button_click(103)
			end)
		:addTo(self.noTicketLayer, 7)
end

function TourenyApplyDialog:tourneyApplyCallback(ticketId, ticketName, ticketNum, payNum, serviceNum, payType)
	local gold
    if (payType == "RAKEPOINT") then
        gold = StringFormat:FormatDecimals(payNum,2) .. "积分+" .. StringFormat:FormatDecimals(serviceNum,2) .. "积分" .. "服务费"

    else
        gold = StringFormat:FormatDecimals(payNum,2) .. "金币+" .. StringFormat:FormatDecimals(serviceNum,2) .. "金币" .. "服务费"

    end
    
    if (self._matchName~="") then
       	self.match_label:setVisible(true)
       	self.match_name:setString(self._matchName)
    end
    local ticketInfo = self.ticket_info
    local goldInfo = self.gold_info
    
    if not ticketInfo or not goldInfo then
        return
    end
    
    goldInfo:setString(gold)
    if ticketId==nil or ticketId=="" then
        if (payType=="TICKET") then 
            local submitNode = self.submitLayer
            submitNode:setVisible(false)
            local ticketNode = self.noTicketLayer
            ticketNode:setVisible(true)
            return
        end
        self.ticket_apply_layer:setVisible(false)
        self.gold_checkbox:setButtonSelected(true)
        self.gold_checkbox:setTouchEnabled(false)
    else
        if (payType=="TICKET") then 
            goldInfo:setVisible(false)
            self.gold_checkbox:setVisible(false)
            self.gold_apply_layer:setVisible(false)
            self.ticket_apply_layer:setVisible(true)
            self.ticket_apply_layer:setPositionY(self.ticket_apply_layer:getPositionY()+60)
            self.ticket_checkbox:setVisible(false)
            -- self.gold_checkbox:setButtonSelected(true)
        else
            goldInfo:setVisible(true)
            self.gold_checkbox:setVisible(true)
            self.ticket_apply_layer:setVisible(true)
            self.ticket_checkbox:setVisible(true)
            self.gold_checkbox:setButtonSelected(true)
        end
    end
end

function TourenyApplyDialog:button_click(tag)

	if tag==100 then --select ticket
        self:selectTicketCallback()
    elseif tag==101 then --select gold
       	self:selectGoldCallabck()
    elseif tag==102 then --close
        self:closeCallback()
    elseif tag==103 then --cancel
        self:cancelCallback()
    elseif tag==104 then --submit
        self:submitCallback()
	end
end

function TourenyApplyDialog:closeCallback()

	self:hide()
end

function TourenyApplyDialog:submitCallback()

	if(not self._target or not self._callback) then
		return
	end
    
	local checkbox = self.ticket_checkbox
    
	local dict = {}
	if checkbox:isButtonSelected() then
		dict["type"]="ticket"
		dict["ticketId"]=self._ticketId
	else
		dict["type"]="gold"
		dict["ticketId"]=""
	end
	self:setUserObject(dict)
	self._callback(self)
	self:hide()
end

function TourenyApplyDialog:cancelCallback()

	self:hide()
end

function TourenyApplyDialog:selectTicketCallback()
	local ticket_checkbox = self.ticket_checkbox
	if(ticket_checkbox:isButtonSelected()) then
		ticket_checkbox:setTouchEnabled(false)
		local gold_checkbox = self.gold_checkbox
		gold_checkbox:setTouchEnabled(true)
		gold_checkbox:setButtonSelected(false)
	end	
end

function TourenyApplyDialog:selectGoldCallabck()
	local gold_checkbox = self.gold_checkbox
	if(gold_checkbox:isButtonSelected()) then
		gold_checkbox:setTouchEnabled(false)
		local ticket_checkbox = self.ticket_checkbox
		ticket_checkbox:setTouchEnabled(true)
		ticket_checkbox:setButtonSelected(false)
	else

	end	
end

return TourenyApplyDialog