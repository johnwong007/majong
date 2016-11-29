 local myInfo = require("app.Model.Login.MyInfo")
local DialogBase = require("app.GUI.roomView.DialogBase")

local FreeGoldDialog = class("FreeGoldDialog", function(event)
		return DialogBase:new()
	end)

function FreeGoldDialog:ctor()
	self.m_leftTimes = ""
	self.m_target = nil
	self.m_callFunc = nil
end

function FreeGoldDialog:dialog(pCallback, pCallbackFuc, enoughMoney)
    local pDialog = FreeGoldDialog:new()
    
    if(pDialog and pDialog:init(pCallback,pCallbackFuc,enoughMoney)) then
        return pDialog
    end
    
    pDialog = nil
    return nil
end

function FreeGoldDialog:init(pCallback, pCallbackFuc, enoughMoney)
    if(not DialogBase:init()) then
    
        return false
    end
    self:manualLoadxml()
    
    self.m_target = pCallback
    self.m_callFunc = pCallbackFuc
	local isVip
    if MyInfo.data.vipLevel=="" then
    	isVip = false
    else
    	isVip = MyInfo.data.vipLevel+0 >0
    end
    self.countLabel:setString(UserDefaultSetting:getInstance():getFreeGoldTimes())
  
    if (enoughMoney) then
        self.bg_layer:setVisible(true)
        self.can_get_layer:setVisible(false)
        
        if (not isVip) then
            self.bindPhoneBtnLayer:setVisible(true)
        end
        
    else
        self.m_leftTimes = UserDefaultSetting:getInstance():getFreeGoldTimes()
        self.freegoldtips:setVisible(false)
        self.can_get_layer:setVisible(true)

        if (not isVip) then
            self.getmoney1:setVisible(false)
        else
            self.gotoshop:setVisible(false)
            self.getmoney:setVisible(false)
            self.getmoney1:setVisible(true)

            
        end
        self:updateLayer()
    end

   	DBHttpRequest:getActivityData(handler(self, self.httpResponse), "206", "", true)
    return true
end

function FreeGoldDialog:manualLoadxml()
	------------------------------------------------------------
	self.bg_layer = display.newNode()
	self.bg_layer:addTo(self, 3)

	cc.ui.UIImage.new("freeGoldNoChances.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self.bg_layer)

	self.countLabel = cc.ui.UILabel.new({
		text = "3",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 20,
		color = cc.c3b(255,177,54),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, display.cx+12, display.cy-132)
		:addTo(self.bg_layer, 4)

	self.freegoldtips = cc.ui.UIImage.new("freegoldtips.png")
		:align(display.CENTER, display.cx, display.cy-212)
		:addTo(self.bg_layer)

	self.cancel = cc.ui.UIPushButton.new({normal="btn_2_close.png", pressed="btn_2_close2.png", disabled="btn_2_close2.png"})
		:align(display.CENTER, display.cx+401, display.cy+282)
		:addTo(self.bg_layer, 3)
	self.cancel:onButtonClicked(function(event)
			self:button_click(10000)
		end)
			---------------------
	self.bindPhoneBtnLayer = display.newNode()
	self.bindPhoneBtnLayer:addTo(self.bg_layer, 2)

	self.bindPhoneBtn = cc.ui.UIPushButton.new({normal="btn_mfjb_czvip.png", pressed="btn_mfjb_czvip.png", disabled="btn_mfjb_czvip.png"})
		:align(display.CENTER, display.cx+203, display.cy-55)
		:addTo(self.bindPhoneBtnLayer)
	self.bindPhoneBtn:onButtonClicked(function(event)
			self:button_click(3)
		end)
			---------------------
	self.can_get_layer = display.newNode()
	self.can_get_layer:addTo(self.bg_layer, 3)
	self.can_get_layer:setVisible(false)

	self.gotoshop = cc.ui.UIPushButton.new({normal="btn_mfjb_cz.png", pressed="btn_mfjb_cz.png", disabled="btn_mfjb_cz.png"})
		:align(display.CENTER, display.cx-214, display.cy-212)
		:addTo(self.can_get_layer)
	self.gotoshop:onButtonClicked(function(event)
			self:button_click(3)
		end)

	self.getmoney = cc.ui.UIPushButton.new({normal="btn_mfjb.png", pressed="btn_mfjb.png", disabled="btn_mfjb.png"})
		:align(display.CENTER, display.cx+208, display.cy-212)
		:addTo(self.can_get_layer)
	self.getmoney:onButtonClicked(function(event)
			self:button_click(2)
		end)

	self.getmoney1 = cc.ui.UIPushButton.new({normal="btn_mfjb_vip.png", pressed="btn_mfjb_vip.png", disabled="btn_mfjb_vip.png"})
		:align(display.CENTER, display.cx, display.cy-212)
		:addTo(self.can_get_layer)
	self.getmoney1:onButtonClicked(function(event)
			self:button_click(2)
		end)
			---------------------
	------------------------------------------------------------
	self.get_gold_layer = display.newNode()
	self.get_gold_layer:addTo(self, 3)
	self.get_gold_layer:setVisible(false)

	cc.ui.UIImage.new("freeGoldGetBG.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self.get_gold_layer)

	self.freeGoldIcon = cc.ui.UIImage.new("freeGoldIcon.png")
		:align(display.CENTER, display.cx, display.cy+45)
		:addTo(self.get_gold_layer)

	cc.ui.UILabel.new({
		text = "德堡免费送你",
		font = "黑体",
		size = 30,
		color = cc.c3b(255,228,173),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, display.cx-136, display.cy-70)
		:addTo(self.get_gold_layer, 4)

	self.GainGoldNum = cc.ui.UILabel.new({
		text = "3000金币",
		font = "黑体",
		size = 30,
		color = cc.c3b(255,228,173),
		align = cc.TEXT_ALIGNMENT_LEFT
		})
		:align(display.LEFT_CENTER, display.cx+43, display.cy-70)
		:addTo(self.get_gold_layer, 4)

	self.cancel1 = cc.ui.UIPushButton.new({normal="btn_2_close.png", pressed="btn_2_close2.png", disabled="btn_2_close2.png"})
		:align(display.CENTER, display.cx+228, display.cy+217)
		:addTo(self.get_gold_layer, 3)
	self.cancel1:onButtonClicked(function(event)
			self:button_click(10000)
		end)

	self.getBtn = cc.ui.UIPushButton.new({normal="btn_qd.png", pressed="btn_qd.png", disabled="btn_qd.png"})
		:align(display.CENTER, display.cx, display.cy-150)
		:addTo(self.get_gold_layer, 3)
	self.getBtn:onButtonClicked(function(event)
			self:button_click(10000)
		end)
	------------------------------------------------------------
			---------------------
	self.btnLayerHavePhone = display.newNode()
	self.btnLayerHavePhone:addTo(self.bg_layer, 3)
	self.btnLayerHavePhone:setVisible(false)

	self.getBtn1 = cc.ui.UIPushButton.new({normal="getBtn.png", pressed="getBtn.png", disabled="getBtn.png"})
		:align(display.CENTER, display.cx, display.cy-145)
		:addTo(self.btnLayerHavePhone)
	self.getBtn1:onButtonClicked(function(event)
			self:button_click(2)
		end)
			---------------------
	------------------------------------------------------------
			---------------------
	self.btnLayerNoPhone = display.newNode()
	self.btnLayerNoPhone:addTo(self.bg_layer, 3)
	self.btnLayerNoPhone:setVisible(false)

	self.getBtn2 = cc.ui.UIPushButton.new({normal="getBtn.png", pressed="getBtn.png", disabled="getBtn.png"})
		:align(display.CENTER, display.cx, display.cy-145)
		:addTo(self.btnLayerNoPhone)
	self.getBtn2:onButtonClicked(function(event)
			self:button_click(2)
		end)
			---------------------
	------------------------------------------------------------
end

function FreeGoldDialog:button_click(tag)
    if tag==10000 then
        self:remove()
    elseif tag==2 then --领取金币
        DBHttpRequest:joinActivity(handler(self, self.httpResponse), "206", "")
    elseif tag==3 then --绑定手机
        self.m_callFunc(1)
        self:remove()
    end
end

function FreeGoldDialog:httpResponse(event)

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

function FreeGoldDialog:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_GetActivityData then --[[获取已领了几次]]
		self:dealGetActivityData(content)
	elseif tag == POST_COMMAND_JoinActivity then
		self:dealJoinActivity(content)
	end

end

function FreeGoldDialog:dealJoinActivity(strJson)
    local var = json.decode(strJson)
    if var and var["CODE"]==10000 then
        self.m_leftTimes = var["LIST"][1]["LEFT_TIMES"]
        local flag
        if var["CODE"] == "10000" or var["CODE"] == 10000 then
            UserDefaultSetting:getInstance():setFreeGoldTimes(self.m_leftTimes+0)
            self.get_gold_layer:setVisible(true)
            self.bg_layer:setVisible(false)
            self.GainGoldNum:setString(var["LIST"][1]["DESC"])
            local money = var["LIST"][1]["DESC"]
            local len = string.len(money)
            local index = len
            while(index>0) do
            	local value = tonumber(string.sub(money, index, index))

                if value==nil then
                	money = string.sub(money,1,index-1)..string.sub(money,index+1,len)
                    index = index-1
                    len = len-1
                else
                     
                    break  
                end     
            end
             myInfo:setTotalChips(myInfo:getTotalChips()+money)
        end
    	local alert = require("app.Component.ETooltipView"):alertView(self,"","领取金币成功!",true)
        alert:setPosition(cc.p(0, 0))
        alert:show()

        self.can_get_layer:setVisible(false)
        self:updateLayer()
    elseif var["CODE"]==-13001 then
    	local alert = require("app.Component.ETooltipView"):alertView(self,"",var["MSG"],false)
        alert:setPosition(cc.p(0, 0))
        alert:show()
    elseif var["CODE"]==-14030 then
    	local alert = require("app.Component.ETooltipView"):alertView(self,"",var["MSG"],false)
        alert:setPosition(cc.p(0, 0))
        alert:show()
    else
    	local alert = require("app.Component.ETooltipView"):alertView(self,"","领取金币失败!",false)
        alert:setPosition(cc.p(0, 0))
        alert:show()
    end

end

function FreeGoldDialog:dealGetActivityData(strJson)
    local var = json.decode(strJson)
    if var then
        self.m_leftTimes = var["LIST"][1]["LEFT_TIMES"]
		UserDefaultSetting:getInstance():setFreeGoldTimes(self.m_leftTimes)
        self:updateLayer()
    end

end

function FreeGoldDialog:updateLayer()
	self.countLabel:setString(self.m_leftTimes)
    if (self.m_leftTimes == "0") then
        self.m_callFunc(0)
        self:hide()
    end
end

return FreeGoldDialog