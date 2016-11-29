--
-- Author: junjie
-- Date: 2015-12-03 11:33:35
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataNoticeList = class("QDataNoticeList",QDataBase)
 --  {
 --   "000D"  = "2015-12-03 09:36:15"
 --   "6009"  = "每周签到"
 --   "600A"  = "恭喜你，成功领取每周签到奖励 30元赛事门票，请查收"
 --   "701A"  = "0"
 --   "image" = "1"
 --   }
function QDataNoticeList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
function QDataNoticeList:Init(_msg,nType)
	self._msg = self._msg or {}
	self._msg[nType] = _msg

	--dump(self._msg)
end

function QDataNoticeList:removeMsgData(nType)
	if self._msg and nType then 
		self._msg[nType] = nil
	else
		self._msg = nil
	end
end
function QDataNoticeList:getMsgData(nType)
	if not self._msg then return nil end
	return self._msg[nType]
end
function QDataNoticeList:sortData(tableData)
	local i = #tableData 
	while i ~= 0 do
		if tableData[i]["PAY_TYPE"] ~= "VGOLD" then
			table.remove(tableData,i)
		end
		i = i - 1
	end
	return tableData
end
function QDataNoticeList:removeMsgDataByType(nType,tableData)
	if not self._msg or not self._msg[nType] then return end
	local tableId = tableData[TABLE_ID]
	local orderId = tableData[ORDER_ID][1]
	for i,v in pairs(self._msg[nType]) do 
		if v[TABLE_ID] == tableId then
			if v["apply"] and #v["apply"] > 0 then
				for p,q in pairs(v["apply"]) do 
					if orderId == q[ORDER_ID] then
						table.remove(v["apply"],p)
					end
				end
			end
		end
	end
	-- dump(self._msg[nType])
end
function QDataNoticeList:addMsgData(nType,tableData,tableId)
	if not self._msg or not self._msg[nType] then return end
	for i,v in pairs(self._msg[nType]) do 
		if v[TABLE_ID] == tableId then
			v["apply"] = tableData
		end
	end
	-- dump(self._msg[nType])
end
--[[
  检查是否有未领取
]]
function QDataNoticeList:checkIsReady(nType)
	if not self._msg or not self._msg[nType] then return false end
	for i,v in pairs(self._msg[nType]) do 
		if v["apply"] and #v["apply"] > 0 then
			return true 
		end
	end
	return false
end
return QDataNoticeList