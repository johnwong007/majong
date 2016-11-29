
local DialogBase = require("app.GUI.roomView.DialogBase")
-------------------------------------------------------------------
local FirstPayLogic = class("FirstPayLogic")

function FirstPayLogic:getFirstPayRate()
	DBHhttpRequest:getFirstPayRate(handler(self,self.httpResponse))
end

function FirstPayLogic:httpResponse(event)

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

function FirstPayLogic:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_FIRST_PAY_RATE then
		self:dealFirstPayRate(content)
	end

end

function FirstPayLogic:dealFirstPayRate(strJson)
	local data = require("app.Logic.Datas.Account.FirstPayRateData"):new()
	if self.m_callback ~= nil and data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
		self.m_callback:updateFirstPayRate(data.payRateList)
	end
	data = nil
end

function FirstPayLogic:ctor(className, callback)
	self.m_callback = callback
end
-------------------------------------------------------------------

local FirstRechargeDialog = class("FirstRechargeDialog", function(event)
		return DialogBase:new()
	end)

function FirstRechargeDialog:create(target, callfunc, isFromClick, isInRoom)

	local dialog = FirstRechargeDialog:new()
	if dialog and dialog:init(target, callfunc, isFromClick, isInRoom) then
		return dialog
	else
	
	dialog = nil
	return dialog
	end
end

function FirstRechargeDialog:init(target, callfunc, isFromClick, isInRoom)

	if not DialogBase.init(self) then
	
		return false
	end

	self.m_target = target
	self.m_callback = callfunc
	self.m_isFromClick = isFromClick
	self.m_isInRoom = isInRoom
	return true
end

function FirstRechargeDialog:ctor()

	self.m_logic = FirstPayLogic:new(self)
	self.m_isFromClick = true
	self.m_target = nil
	self.m_callback = nil
	self.m_isInRoom = false
	self:setNodeEventEnabled(true)
end

function FirstRechargeDialog:onNodeEvent(event)
    if event == "enter" then
    	self:onEnter()
    elseif event == "exit" then
        self.m_logic = nil
    end
end

function FirstRechargeDialog:onExit()
	self.m_logic = nil
end

function FirstRechargeDialog:onEnter()
	self:manualLoadxml()
	if self.active_package then
		self.active_package:setVisible(true)
	end
end

function FirstRechargeDialog:manualLoadxml()
	
	self.background = cc.ui.UIImage.new("picdata/activity/activity_first.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	self.active_package = cc.ui.UIPushButton.new({normal="btn_8_down_sclb_android.png", pressed="btn_8_up_sclb_android.png",
		disabled="btn_8_up_sclb_android.png"})
		:align(display.CENTER, display.cx, 115)
		:addTo(self, 1)
	self.active_package:onButtonClicked(function(event)
			self:button_click("active_package")
		end)

	self.close = cc.ui.UIPushButton.new({normal="btn_2_close.png", pressed="btn_2_close2.png", disabled="btn_2_close2.png"})
		:align(display.CENTER, display.cx+403, display.cy+280)
		:addTo(self, 1)
	self.close:onButtonClicked(function(event)
			self:button_click("close")
		end)
end

function FirstRechargeDialog:button_click(tag)
	if tag == "back_hall" then
		GameSceneManager:switchSceneWithType(EGSMainPage)
	elseif tag == "active_package" then
		--在房间里直接弹出渠道选择弹窗，在其他的地方跳进商城，自动选择某一选项
		dump(self.m_isInRoom)
		if self.m_isInRoom == true then
			self.m_callback(self, nil)
		else
			GameSceneManager:setJumpLayer(GameSceneManager.AllLayer.SHOP) 
			GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.MainPageView)
		end
	elseif tag == "close" then
		if self.m_isInRoom == false then
			GameSceneManager:switchSceneWithType(EGSMainPage)
		end
	end
	self:hide()
end

function FirstRechargeDialog:updateFirstPayRate(payRate)

end

return FirstRechargeDialog