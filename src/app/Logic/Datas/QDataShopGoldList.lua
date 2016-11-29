--
-- Author: junjie
-- Date: 2015-11-27 15:52:55
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataShopGoldList = class("QDataShopGoldList",QDataBase)

 -- {
 --    "3026" = "[["TENCENT",""],["ZFB",""],["UP",""],["ALIPAY",""],["PPS",""],["CFT",""],["DPAY",""],["WEIXIN",""]]"
 --    "3051" = 0
 --    "5008" = 5000000
 --    "A01B" = "5000000 金币 "
 --    "A030" = "P1008"
 --    "A031" = "5000000 金币 "
 --    "A032" = 500
 --    "A033" = "http://debaocache.boss.com/style/images/phone/shop/jb_500.png"
 --  }
 local resortType = {"DIYTABLE",--牌局卡
 "CROUPIER",--主播道具
 "TIMECARD",--月卡
}
--[[
	1、金币
	2、月卡
	3、德堡钻
	4、道具
	101、赠送
	102、兑换
]]
 function QDataShopGoldList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
function QDataShopGoldList:Init(_msg,nType)
	self._newMsg ={}
	self._msg = self._msg  or {}
	self._msg[nType] = _msg
	if nType == 1 then
		self:removeItemData(nType) --移除150的项
	end
	--self:addMsgData(3)
	--self:sortData()
	--self:updateMsgData()
	--self:getMsgData()
	--dump(self._msg)
end
function QDataShopGoldList:removeItemData(nType)
	if not self._msg or not self._msg[nType] then return  end
	for i,v in pairs(self._msg[nType]) do  
		if v["A032"] == 150 then
			table.remove(self._msg[nType],i)
			return 
		end
	end
end

function QDataShopGoldList:sortData()
	local newData = {}
	for i,v in pairs (self._msg) do 
		v[GOODS_TYPE] = self:splitData(v[GOODS_TYPE])
		if not newData[v[GOODS_TYPE]] then
			newData[v[GOODS_TYPE]] = {}
			table.insert(newData[v[GOODS_TYPE]],v) 
		else
		 	table.insert(newData[v[GOODS_TYPE]],v) 
		end
	end
	self._newMsg = newData
	--dump(newData)

end
function QDataShopGoldList:splitData(__fmt)
	local data = string.split(__fmt,",")
	if #data > 1 then 
		return data[2]
	else 
		return data[1]
	end
end
function QDataShopGoldList:getMsgData(nType,sortType)
	if not self._msg then return nil end
	if sortType then
		return self:sortPropData(nType,sortType)
	end
	return self._msg[nType]
end
function QDataShopGoldList:isExistMsgData(nType)
	if not self._msg then return false end 
	if self._msg[nType] then 
		return true
	else
		return false
	end
end
function QDataShopGoldList:sortPropData(nType,sortType)
	local newData = {}
	for i,v in pairs(self._msg[nType]) do 
		if v["A041"] == sortType then
			table.insert(newData,1,v)
		else 
			table.insert(newData,v)
		end
	end
	return newData
end
return QDataShopGoldList