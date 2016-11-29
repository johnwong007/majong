--
-- Author: junjie
-- Date: 2015-12-09 17:34:34
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataActivityList = class("QDataActivityList",QDataBase)
local myInfo = require("app.Model.Login.MyInfo")
	-- 1 = {
 --     "3007" = "2015-04-23 00:00:00"
 --     "3008" = "2016-04-23 23:59:59"
 --     "3052" = "205"
 --     "3067" = "2"
 --     "4037" = "1"
 --     "5009" = "zhuangwj"
 --     "500A" = ""
 --     "601F" = "2015-04-23 15:22:36"
 --     "6020" = "2015-05-19 10:39:43"
 --     "7017" = "新手礼包"
 --     "7018" = "新玩家专享5大礼包，完成小任务领取大奖励！！"
 --     "703A" = "1001"
 --     "703B" = "立即参与"
 --     "703C" = "http://www.debao.com/static/images/news/sjhd/20150519102000_6678.png"
 --     "703D" = "http://www.debao.com/static/images/news/sjhd/20150519102022_3719.png"
 --     "703E" = ""
 --     "9001" = ""
 -- }

function QDataActivityList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
function QDataActivityList:Init(_msg)
	self._msg = _msg 
	self:insertMsgData()
	self:sortData()
end

function QDataActivityList:insertMsgData()
	if myInfo.data.payamount <= 0 then
		local data = {
		     ["3007"] = "2015-04-23 00:00:00",
		     ["3008"] = "2016-04-23 23:59:59",
		     ["3052"] = "206",
		     ["3067"] = "10",
		     ["4037"] = "1",
		     ["5009"] = "zhuangwj",
		     ["500A"] = "",
		     ["601F"] = "2015-04-23 15:22:36",
		     ["6020"] = "2015-05-19 10:39:43",
		     ["7017"] = "首充大礼包",
		     ["7018"] = "首次充值  豪礼赠送",
		     ["703A"] = "1002",
		     ["703B"] = "充值激活礼包",
		     ["703C"] = "picdata/activity/activity_first.png",
		     ["703D"] = "picdata/activity/btn_first.png",
		     ["703E"] = "",
		     ["9001"] = "",
		     ["isLoadLocalImg"] = true,
		 }
 
 		if not self._msg then self._msg = {} end
	 	table.insert(self._msg,1,data)
	end
end
function QDataActivityList:sortData()
	function comp(a,b)	
		return tonumber(a["3067"] or 0) > tonumber(b["3067"] or 0)
	end
	table.sort(self._msg,comp)
end
function QDataActivityList:getTableMsgData()
	if self._msg then
		for i,data in pairs(self._msg) do
			if string.find(data["500A"], "金币") then
				return data["3052"],data
			end
		end
	end
	return nil,nil
end

return QDataActivityList