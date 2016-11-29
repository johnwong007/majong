--
-- Author: junjie
-- Date: 2016-03-18 17:34:59
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataMyMatchList = class("QDataMyMatchList",QDataBase)


function QDataMyMatchList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end

function QDataMyMatchList:getMsgTableId(idx)
	if not self._msg or not self._msg["LIST"] or not self._msg["LIST"][idx] then return end
	return self._msg["LIST"][idx][TABLE_ID]

end
function QDataMyMatchList:getMsgItemData(idx)
	if not self._msg or not self._msg["LIST"] then return end
	return self._msg["LIST"][idx]
end
function QDataMyMatchList:addMsgData(idx,tableData)
	if not self._msg or not self._msg["LIST"] or not self._msg["LIST"][idx] then return end
	self._msg["LIST"][idx]["rank"] = tableData
	self:sortData(idx)
end
function QDataMyMatchList:addMsgRoomId(idx,roomId)
	if not self._msg or not self._msg["LIST"] or not self._msg["LIST"][idx] then return end
	self._msg["LIST"][idx]["ROOM_ID"] = roomId
end
function QDataMyMatchList:sortData(idx)
	function comp(a,b)
		return tonumber(a["WIN_COUNT"]) > tonumber(b["WIN_COUNT"])
	end
	table.sort(self._msg["LIST"][idx]["rank"],comp)
end
return QDataMyMatchList