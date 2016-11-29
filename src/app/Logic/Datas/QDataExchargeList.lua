--
-- Author: junjie
-- Date: 2015-11-25 17:14:42
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataExchargeList = class("QDataExchargeList",QDataBase)

	-- {
 --     "3026" = "RAKEPOINT"
 --     "3027" = "1500000"
 --     "9005" = "0"
 --     "A00A" = "150"
 --     "A00B" = "《扑克招数》"
 --     "A00C" = "EXCHANGE"
 --     "A01B" = "作者Ed Miller Doug Hull——提高你扑克技术的实用指南。"
 --     "A021" = "/static/images/news/shoppic/20140827162527_7876.png"
 --     "A026" = "特价"
 --     "A027" = "102"
 --     "A038" = "None"
 --     "A039" = "None"
 --     "A03E" = "5"
 --     "A03F" = "2014-04-30 00:00:00"
 --  }
function QDataExchargeList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
function QDataExchargeList:Init(_msg)
	self._newMsg ={}
	self._msg = _msg
	self:sortData()
	--self:addMsgData(3)
	--self:updateMsgData()
	--self:getMsgData()
	--dump(self._msg)
end

function QDataExchargeList:sortData()
	local newData = {}
	for i,v in pairs (self._msg) do 
		local nextType = nil
		v[GOODS_TYPE],nextType = self:splitData(v[GOODS_TYPE])
		if not newData[v[GOODS_TYPE]] then
			newData[v[GOODS_TYPE]] = {}
			table.insert(newData[v[GOODS_TYPE]],v) 
		else
		 	table.insert(newData[v[GOODS_TYPE]],v) 
		end
		if nextType then
			if not newData[nextType] then
			newData[nextType] = {}
			table.insert(newData[nextType],v) 
		else
		 	table.insert(newData[nextType],v) 
		end
		end
	end
	self._newMsg = newData
	self._msg    = {}
	--dump(newData)

end
function QDataExchargeList:splitData(__fmt)
	local data = string.split(__fmt,",")
	if #data > 1 then 
		return data[1],data[2]
	else 
		return data[1]
	end
end
function QDataExchargeList:getMsgData(nType)
	if not self._newMsg then return nil end
	return self._newMsg[tostring(nType)]
end

return QDataExchargeList