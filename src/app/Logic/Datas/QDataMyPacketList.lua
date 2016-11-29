--
-- Author: junjie
-- Date: 2015-12-11 13:57:25
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataMyPacketList = class("QDataMyPacketList",QDataBase)

function QDataMyPacketList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
function QDataMyPacketList:Init(_msg)
	if type(_msg) ~= "table" then return end
	self._newMsg ={}
	self._msg = _msg
	self:sortData()
end

function QDataMyPacketList:sortData()
	local newData = {}
	for i,v in pairs (self._msg) do 
		v[GAIN_TYPE] = self:splitData(v[GAIN_TYPE])
		if not newData[v[GAIN_TYPE]] then
			newData[v[GAIN_TYPE]] = {}
			table.insert(newData[v[GAIN_TYPE]],v) 
		else
		 	table.insert(newData[v[GAIN_TYPE]],v) 
		end
	end
	if newData["PROPS"] then
		local tempPropData = {}
		newData["CARD"] = {}
		for i ,v in pairs(newData["PROPS"]) do
			local index = string.find(v["A003"],"月卡")
			if index then
				table.insert(newData["CARD"],v)
			else
				table.insert(tempPropData,v)
			end
		end
		newData["PROPS"] = tempPropData
	end
	self._newMsg = newData
	--dump(self._newMsg)

end
function QDataMyPacketList:splitData(__fmt)
	local data = string.split(__fmt,",")
	if #data > 1 then 
		return data[2]
	else 
		return data[1]
	end
end
function QDataMyPacketList:getMsgData(nType)
	if not self._newMsg then return nil end
	return self._newMsg[tostring(nType)]
end
return QDataMyPacketList