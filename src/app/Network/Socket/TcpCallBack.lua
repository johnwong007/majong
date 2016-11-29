--
-- Author: junjie
-- Date: 2016-03-04 09:53:43
--
local TcpCallBack = {}
local myInfo = require("app.Model.Login.MyInfo")
--[[
	更新缓存
]]
function TcpCallBack:onTcpCallBack(tableData)
	local layerID = tableData.layerID
      -- dump(tableData,layerID)
     -- dump(hexToDecimal(00020306),layerID)
    if layerID == COMMAND_BUYIN_APPLY_RESP then
    	local sTips = "恭喜你，房主已通过你的筹码购买申请"
    	if tableData[CODE] == -1 then
    		sTips = "对不起，房主拒绝了你的筹码购买申请"
		end
		CMShowTip(sTips)
	elseif layerID == COMMAND_BUYIN_APPLY then 		--玩家申请购买
		myInfo.data.showApplyBuy = true
    	QManagerListener:Notify({layerID = eMainPageViewID,tag = "addApplyBuy"})
    	QManagerListener:Notify({layerID = eRoomViewID,tag = "addApplyBuy"})
  elseif layerID == COMMAND_KICK_USER then
    -- CMShowTip("异地登录")
	end
end


return TcpCallBack