
--
-- Author: junjie
-- Date: 2015-11-24 14:02:35
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataTaskList = class("QDataTaskList",QDataBase)
local myInfo = require("app.Model.Login.MyInfo")
  --  {
  --       "afterdone" = "KEEP"
  --       "key"       = "25:6212:20151124"
  --       "name"      = "高级场玩牌5局"
  --       "priority"  = "48"
  --       "prog"      = "0"
  --       "rdesc"     = "10000金币"
  --       "reward"    = "ACCT:GOLD:10000"
  --       "showorder" = "2"
  --       "status"    = "NOTREADY"
  --       "target"    = "5"
  --   }
function QDataTaskList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end

function QDataTaskList:sortData()
	function comp(a,b)	
		if a.status == b.status then	
	 		if tonumber(a.priority) == tonumber(b.priority) then
				return tonumber(a.showorder or 1) < tonumber(b.showorder or 1)
			else
				return tonumber(a.priority or 0)  > tonumber(b.priority or 0)
			end
		else
			return a.status > b.status
		end
	end
	table.sort(self._msg,comp)
end

function QDataTaskList:getMsgData()
	if not self._msg then return nil end 
	self:sortData()
	local newMsg = {}
	local isExist 
	for i = 1,#self._msg do
		isExist = false
		for p,q in pairs(newMsg) do 
			if  q.priority == self._msg[i].priority and q.showorder ~= self._msg[i].showorder  then
				isExist = true
				break
			end
		end
		if not isExist then
			table.insert(newMsg,self._msg[i])
		end	
	end
	
	for i ,v in pairs (newMsg) do 
		if v.status == "DONE" and v.afterdone == "DEL" then
			table.remove(newMsg,i)
		end
	end

	return newMsg
end
function QDataTaskList:updateMsgData(tableData)
    -- tableData = {
    --     [1] = {
    --         ["key"]    = "USERVIP:BONUS:TASK:6212:3",
    --         ["reward"] = "2500金币",
    --     }
    -- }
    
	for p,q in pairs(tableData) do 	
		for i,v in pairs(self._msg) do
		--print(v.key .. "==".. q.key) 
			if v.key == q.key then
				v.status = "DONE"
				break
			end	
		end
	end
	
end

function QDataTaskList:addMsgData(times)
	local data = {
        ["afterdone"] = "KEEP",
        ["key"]       = "206",
        ["name"]      = "每日免费金币(账户余额≤1000金币时可领取)",
        ["priority"]  = 5,
        ["prog"]      = times,
        ["rdesc"]     = "1000金币",
        ["reward"]    = "ACCT:GOLD:1000",
        ["showorder"] = 2,
        ["status"]    = "NOTREADY",
        ["target"]    = 0,
    }
    if (tonumber(myInfo.data.vipLevel) ~= 0 ) then
    	data.rdesc = "3000金币"
    	data.reward= "ACCT:GOLD:3000"

    end
                             
    local Chips = tonumber(myInfo.data.totalChips)
    if tonumber(times) > 0 then
    	if Chips < 1000 then
    		data.status = "READY"
    	else
    		data.status = "NOTREADY"
    	end
    else
    	data.status = "DONE"
    end
    
    table.insert(self._msg,1,data)

end
--[[
  检查是否有未领取
]]
function QDataTaskList:checkIsReady()
  local newMsg = self:getMsgData()
  if not newMsg then return false end
  for i,v in pairs(newMsg) do 
    if v.status == "READY" then 
        return true
    end
  end
  return false
end
return QDataTaskList