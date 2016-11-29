--
-- Author: junjie
-- Date: 2015-12-04 14:37:18
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataFriendList = class("QDataFriendList",QDataBase)
  --  1 = {
  --     "501E" = "2015-12-02 17:54:37"
  --     "5040" = "2635"
  --     "5041" = "0"
  --     "5042" = "admin"
  --     "5043" = "6224"
  --     "5044" = "holylee882"
  --     "5045" = "APPLY_FRIEND"
  --     "5046" = "NOT_READ"
  --     "5047" = "6213:holylee871"
  -- }
  -- 2 = {
  --     "501E" = "2015-12-02 17:22:39"
  --     "5040" = "2616"
  --     "5041" = "0"
  --     "5042" = "admin"
  --     "5043" = "6224"
  --     "5044" = "holylee881"
  --     "5045" = "ADD_FRIEND"
  --     "5046" = "NOT_READ"
  --     "5047" = "6223:holylee881"
  -- }
--[[nType ={
  "FriendList"
  "APPLY_FRIEND"
  "OTHER_FRIEND"
} ]]
function QDataFriendList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
function QDataFriendList:Init(_msg,nType)
	self._msg = self._msg or {}
	--self._msg[nType] = _msg
  if not self._msg[nType] then
   self._msg[nType] = _msg
  else
      if #_msg < 1 then return end
      for i = 1,#_msg do
          table.insert(self._msg[nType],_msg[i])
      end
  end
end

function QDataFriendList:removeMsgData(nType)
	if nType then 
		 self._msg[nType] = nil
	else
		 self._msg = nil
	end
end
function QDataFriendList:removeItemDataByIndex(nType,idx)
    if not self._msg or not self._msg[nType] then return nil end 
    table.remove(self._msg[nType],idx)
end
function QDataFriendList:removeItemData(nType,messageId)
-- self._msg ={}
--     self._msg[nType] = {
--     [1] = {[MESSAGE_ID] = 1,},
--     [2] = {[MESSAGE_ID] = 2,},
--     [3] = {[MESSAGE_ID] = 3,}
--   }
     if not self._msg or not self._msg[nType] then return nil end    
     for i,v in pairs(self._msg[nType]) do  
        if v[MESSAGE_ID] == messageId then
          table.remove(self._msg[nType],i)
        end
     end

end
--[[
  好友列表
]]
function QDataFriendList:getMsgData(nType)
	if not self._msg then return nil end
	return self._msg[nType]
end
--[[所有玩家ID列表]]
function QDataFriendList:getMsgUserList(nType)
    if not self._msg or not self._msg[nType] then return nil end
    local userList = ""
    for i = 1,#self._msg[nType] do
        if i == 1 then 
            userList = self._msg[nType][i][USER_ID]
        else
            userList = userList .. "," .. self._msg[nType][i][USER_ID] 
        end
    end
    return userList
end

--[[
  更新好友列表 VIP和等级  
]]
function QDataFriendList:updateMsgData(tableData,nType,key)
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
--[[
  收件箱／我的申请
]]
function QDataFriendList:sortReceiveData(tableData)
  if not tableData then return end
  if not self._msg then self._msg = {} end
  self._msg["APPLY_FRIEND"] = {}
  self._msg["OTHER_FRIEND"] = {}
  for i,v in pairs (tableData) do 
      if v[MESSAGE_TYPE] == "APPLY_FRIEND" then
          table.insert(self._msg["APPLY_FRIEND"],v)
      else  
          table.insert(self._msg["OTHER_FRIEND"],v)
      end
  end
end
function QDataFriendList:updateReceiveData(tableData)
     for i,v in pairs(self._msg["APPLY_FRIEND"]) do
        local data = string.split(v,":")
     end
end
--[[
  消息列表
  APPLY_FRIEND
]]
function QDataFriendList:getMsgReceiveData(key)
  if not self._msg then return nil end
  
  return data
end

--[[获取列表中一位玩家数据]]
function QDataFriendList:getMsgUserData(nType,index)
    if not self._msg or not self._msg[nType] then return nil end
    index = index or 1
    return self._msg[nType][index]
end
--[[获取当前好友数量]]
function QDataFriendList:getMsgLength(nType)

    if not self._msg or not self._msg[nType] then return 0 end
    return #self._msg[nType] 
end
return QDataFriendList