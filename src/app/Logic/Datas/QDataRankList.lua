--
-- Author: junjie
-- Date: 2015-12-01 13:41:27
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataRankList = class("QDataRankList",QDataBase)
    -- 1 = {
    --      "2003" = "6213"
    --      "2004" = "holylee871"
    --      "201E" = 0
    --      "2022" = 0
    --      "300C" = "342"
    --      "300E" = "1000"
    --      "4003" = "ONLINE"
    --      "4006" = "/static/images/sysimage/avatar.png"
    --      "4010" = "None"
    --      "4021" = false
    --      "4059" = ""
    --      "5008" = "1500"
    --      "500D" = "1"
    --      "5029" = 100006500
    --  }
function QDataRankList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
function QDataRankList:Init(_msg,nType)
	self._msg = self._msg or {}
    if not self._msg[nType] then
	   self._msg[nType] = _msg
    else
        if #_msg < 1 then return end
        for i = 2,#_msg do
            table.insert(self._msg[nType],_msg[i])
        end
    end

	--dump(self._msg)
end
function QDataRankList:Instance(key)
    --key = "QDataBase"
    if self.instance == nil then       
        self.instance = self:new()
    end
    return self.instance
end
function QDataRankList:removeMsgData(nType)
	if nType then 
		self._msg[nType] = nil
	else
		self._msg = nil
	end
end
function QDataRankList:getMsgData(nType)
	if not self._msg then return nil end
	return self._msg[nType]
end
--[[玩家自身数据]]
function QDataRankList:getMsgFirstData(nType)
	if not self._msg or not self._msg[nType] then return nil end
	return self._msg[nType][1]
end
--[[所有玩家ID列表]]
function QDataRankList:getMsgUserList(nType)
    if not self._msg or not self._msg[nType] then return nil end
    if #self._msg[nType] < 2 then return nil end
    local userList = ""
    for i = 2,#self._msg[nType] do
        if i == 2 then 
            userList = self._msg[nType][i][USER_ID]
        else
            userList = userList .. "," .. self._msg[nType][i][USER_ID] 
        end
    end
    return userList
end
--[[获取列表中一位玩家数据]]
function QDataRankList:getMsgUserData(nType,index)
    if not self._msg or not self._msg[nType] then return nil end
    index = (index or 1) + 1
    return self._msg[nType][index]
end
function QDataRankList:updateMsgData(tableData,nType,key)
    if not self._msg or not self._msg[nType] then return nil end
    for i,v in pairs(tableData) do 
        for p,q in pairs(self._msg[nType]) do 
            if v[USER_ID] == q[USER_ID] then
                q[key] = v[USER_LEVEL]  --USER_LEVEL :500D
                break
            end
        end
    end
end
--[[获取当前排名数量]]
function QDataRankList:getMsgLength(nType)
    if not self._msg or not self._msg[nType] then return 0 end
    return #self._msg[nType] - 1
end
return QDataRankList