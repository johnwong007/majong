--
-- Author: junjie
-- Date: 2016-03-08 14:48:40
--
require("app.Network.Http.DBHttpRequest")
local myInfo = require("app.Model.Login.MyInfo")
local PushCallBack = {}

function PushCallBack:dealPushMessageResp(data)
   if type(data) ~= "table" then return end
     -- dump(data)
    local simbol = data["simbol"]
    local nType  = tonumber(data["type"])
    local receive= data["receive"]
    local message= data["message"]
    if nType == 71 then      		--免费任务更新
        myInfo.data.showFreegoldTips = true
    	QManagerListener:Notify({layerID = eMainPageViewID,tag = "addFreeGold"})
    elseif nType == 29 then 		--广播通知
--     	data =  {
--     ["message"]   = "妇女节！快乐乐乐乐乐乐乐乐乐乐乐乐乐",
--     ["receivers"] = "0",
--     ["simbol"]    = 2,
--     ["type"]      = 29,
-- }
    	local RewardLayer      = require("app.Component.CMNoticeView") -- 广播测试
   		RewardLayer:playNotice(data)
    elseif nType == 50 then 		--未知
    	DBHttpRequest:GetAllNoticesInfo(function(tableData,tag) self:httpResponse(tableData,tag) end,"4")
    elseif nType == 45 then         --首充额外奖励提示
        local awardData = data["message"] or {}
        local RewardLayer = require("app.GUI.newactivity.RechargeAwardLayer")
        CMOpen(RewardLayer,GameSceneManager:getCurScene(),awardData,0) 
    elseif nType == 57 then         --vip变化
        myInfo.data.vipLevel = data["message"]["500D"]
        QManagerListener:Notify({layerID = eMainPageViewID,tag = "vipChange"})
    end
end

--[[
	网络回调
]]
function PushCallBack:httpResponse(tableData,tag)
	-- dump(tableData,tag)
	if tag == POST_COMMAND_GETALLNOTICEINFO then  				--请求列表回调	
		if not tableData["message"] then return end
		local RewardLayer      = require("app.Component.CMNoticeView") -- 广播测试
   		RewardLayer:playNotice(tableData)
	end
	
end
return PushCallBack