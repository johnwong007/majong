
local DialogBase = require("app.GUI.roomView.DialogBase")
-------------------------------------------------------------------
local FirstRechargeRewardLogic = class("FirstRechargeRewardLogic")

function FirstRechargeRewardLogic:ctor(className, view)
	self.m_userId = ""
	self.m_limitId = ""
	self.m_interface = view
end

function FirstRechargeRewardLogic:fetchReward(userId)
	if not self.m_interface then
		return
	end
    
	self.m_userId = userId
	DBHttpRequest:queryActivityReward(handler(self, self.httpResponse),82)
end

function FirstRechargeRewardLogic:httpResponse(event)

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

function FirstRechargeRewardLogic:onHttpResponse(tag, content, state)
	if tag == POST_COMMAND_SELECTACTIVITYINFO then --[[query reward idd]]
		self:dealQueryRewardResp(content)
	elseif  tag == POST_COMMAND_TAKEACTIVITYMONEY then --[[fetch reward]]
		self:dealFetchRewardResp(content)
	end

end

function FirstRechargeRewardLogic:dealFetchRewardResp(strJson)
	if not self.m_interface then
		return
	end
    
	--
	local data = require("app.Logic.Datas.Account.RewardRespInfo"):new()
	if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
		self.m_interface:updateFirstRechargeReward(true,data.description)
	else
	
		self.m_interface:updateFirstRechargeReward(false,"领取失败！")
	end
end

function FirstRechargeRewardLogic:dealQueryRewardResp(strJson)

	if not self.m_interface then
	
		return
	end
	--
	local data = require("app.Logic.Datas.Admin.RewardList"):new()
	if data:parseJson(strJson) == BIZ_PARS_JSON_SUCCESS then
	
		if self.m_userId ~= "" and data.rewardInfoList and #data.rewardInfoList > 0 then
		
			--fetchReward
			for i=1,#data.rewardInfoList do
			
				if data.rewardInfoList[i].activityId == "82" then
				
					DBHttpRequest:fetchReward(handler(self, self.httpResponse),self.m_userId,data.rewardInfoList[1].rewardId)
					break
				end
			end
		else
		
			self.m_interface:updateFirstRechargeReward(false,"没有奖励信息")
		end
	end
end
-------------------------------------------------------------------

local FirstRechargeRewardDialog = class("FirstRechargeRewardDialog", function(event)
		return DialogBase:new()
	end)

function FirstRechargeRewardDialog:create(target, callfunc, userId)

	local dialog = FirstRechargeRewardDialog:new()
	if dialog and dialog:init(target,callfunc,userId) then
		return dialog
	else
	
	dialog = nil
	return dialog
	end
end

function FirstRechargeRewardDialog:init(target, callfunc, userId)

	if not DialogBase.init(self) then
	
		return false
	end
	self.m_target = target
	self.m_callback = callfunc
	self.m_userId = userId
	return true
end

function FirstRechargeRewardDialog:ctor()

	self.m_target = nil
	self.m_callback = nil
	self.m_userId = nil
	self.m_logic = FirstRechargeRewardLogic:new(self)

    self:setNodeEventEnabled(true)
end

function FirstRechargeRewardDialog:onNodeEvent(event)
    if event == "enter" then
    	self:onEnter()
    elseif event == "exit" then
        self.m_logic = nil
    end
end

function FirstRechargeRewardDialog:onExit()
	self.m_logic = nil
end

function FirstRechargeRewardDialog:onEnter()
	self:manualLoadxml()
	self.m_logic:fetchReward(self.m_userId)
end


function FirstRechargeRewardDialog:manualLoadxml()
	self.background = cc.ui.UIImage.new("alertBG.png")
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self, 1)

	self.title = cc.ui.UILabel.new({
		text = "首充奖励",
		font = "fonts/FZZCHJW--GB1-0.TTF",
		size = 32,
		color = cc.c3b(255,228,173),
		align = cc.TEXT_ALIGNMENT_CENTER
		})
		:align(display.CENTER, display.cx, 460)
		:addTo(self, 6)

	self.reward_image = cc.ui.UIImage.new("sta_58_scjl_tc_android.png")
		:align(display.LEFT_TOP, 182, 422)
		:addTo(self, 2)

	self.hint_label = cc.ui.UILabel.new({
		text = "恭喜您获得",
		font = "黑体",
		size = 28,
		color = cc.c3b(185,185,202),
		align = cc.TEXT_ALIGNMENT_LEFT,
		vlign = cc.TEXT_ALIGNMENT_TOP,
		dimensions = cc.size(295, 400)
		})
		:align(display.LEFT_CENTER, 465, 337)
		:addTo(self, 4)

	local lineSprite = cc.ui.UIImage.new("line.png")
		:align(display.CENTER, display.cx, 250)
		:addTo(self, 1)
	lineSprite:setScale(65.3)

	local images = {normal="confirmBtn.png", pressed="confirmBtn.png", disabled="confirmBtn.png"}
	self.know = cc.ui.UIPushButton.new(images)
		:align(display.CENTER, display.cx, 250)
		:addTo(self, 1)
	self.know:onButtonClicked(function(event)
			self:button_click("know")
		end)
	self.know:setButtonLabel("normal", cc.ui.UILabel.new({
		text = "知道了",
		font = "黑体",
		size = 26,
		color = cc.c3b(255,255,255)
		}))
end

function FirstRechargeRewardDialog:button_click(tag)
	if tag == "know" then
		self:hide()
	end
end

function FirstRechargeRewardDialog:updateFirstRechargeReward(fetchSucc, description)

	local tips = self.hint_label
	if not tips then
	
		return
	end
    
	if fetchSucc and description then
	
		local str = "恭喜你获得"
		str = str..description
		tips:setString(str)
		if self.m_callback then
			self.m_callback()
		end
	else
	
		local str = "很遗憾"
		str = str..description
		tips:setString(str)
	end
end

return FirstRechargeRewardDialog