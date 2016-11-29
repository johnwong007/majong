--
-- Author: junjie
-- Date: 2016-04-21 10:16:58
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataFightTeamList = class("QDataFightTeamList",QDataBase)

function QDataFightTeamList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end
--[[
	初始化战队信息：nType
	1－－首页信息["ClubInfo"]["ClubNotice"]["ClubHistory"]
	2-－成员列表信息
	3-－留言板

	["teamList"] --战队列表
	["applyList"]--战队申请列表
	["memberApplyList"]--成员申请列表
]]
function QDataFightTeamList:Init(_msg,nType,secType)
	self._msg = self._msg or {}
	if secType then
		self._msg[nType] = self._msg[nType] or {}
		self._msg[nType][secType] = _msg
	else
		if nType == "teamList" then
			self:addMsgData(_msg,nType)
		elseif nType == 2 then
			self:addMsgMemberData(_msg,2,"MEMBER")
			-- self:sortMsgMember()
		else
			self._msg[nType] = _msg
		end
	end
	-- dump(self._msg)
end
--[[
	成员列表排序
	成员列表中，增加一下排序功能。（按职位、牌手分、本周经验、上周经验和离线时间）
]]
function QDataFightTeamList:sortMsgMember()

	if #self._msg[2]["MEMBER"] == 0 then return end
	-- dump(self._msg[2]["MEMBER"])
	local function compStr(a,b)
		return 
	end
	local temp = {
		["chairman"] 	  = 3,
		["vice_chairman"] = 2,
		["member"]        = 1
	}
	function comp(a,b)	
		-- dump(a)
		-- if not a or not b then return end
		if a["A10D"] == b["A10D"] then	
	 		if tonumber(a["4055"]) == tonumber(b["4055"]) then
				if tonumber(a["A112"]) == tonumber(b["A112"]) then
					 return a["4026"]  > a["4026"] 
				else
					return tonumber(a["A112"] or 0)  > tonumber(b["A112"] or 0)
				end
			else
				return tonumber(a["4055"] or 0)  > tonumber(b["4055"] or 0)
			end
		else
			return temp[a["A10D"]] > temp[b["A10D"]] 
		end
	end
	table.sort(self._msg[2]["MEMBER"],comp)
	-- dump(self._msg[2]["MEMBER"])
end
function QDataFightTeamList:Instance(key)
    --key = "QDataBase"
    if self.instance == nil then       
        self.instance = self:new()
    end
    return self.instance
end
--[[
	返回战队信息
]]
function QDataFightTeamList:getMsgData(nType,secType)
	if not self._msg or not self._msg[nType] then return nil end
	-- dump(self._msg)
	if secType then
		return self._msg[nType][secType]
	else
		return self._msg[nType]
	end
end
function QDataFightTeamList:getMsgLength(nType)
	if not self._msg or not self._msg[nType] then return 0 end
	return #self._msg[nType]
end
--[[
	设置是否加入战队
]]
function QDataFightTeamList:setIsJoinFightTeam(isJoin)
	self.mIsAdd = isJoin
end
function QDataFightTeamList:getIsJoinFightTeam()
	return self.mIsAdd
end
--[[
	判断是否已申请过
]]
function QDataFightTeamList:checkIsApply(clubId)
	-- dump(self._msg["applyList"])
	if not self._msg or not self._msg["applyList"] then return false end
	if type(self._msg["applyList"]) ~= "table" then return false end
	for i,v in pairs(self._msg["applyList"]) do 
		if v["A100"] == clubId then 
			return true 
		end
	end

	return false
end
--[[
	返回单条cell数据
]]
function QDataFightTeamList:getMsgItemData(nType,index)
 	if not self._msg or not self._msg[nType] then return nil end
 	if nType == 2 then
 		return self._msg[nType]["MEMBER"][index]
 	end
 	return self._msg[nType][index]
end
function QDataFightTeamList:getMsgMemberPlayerData(nType,userId)
	nType = nType or 2
	if not self._msg or not self._msg[nType] or not self._msg[nType]["MEMBER"] then return nil end
	for i,v in pairs(self._msg[nType]["MEMBER"]) do 
		if v["2003"] == userId then
			return v
		end
	end
end
--[[
	更新数据
]]
function QDataFightTeamList:updateMsgData(tableData,nType)
 
end
--[[
	更新战队基金数量
]]
function QDataFightTeamList:updateMsgFundData(fundNum)
	if not self._msg or not self._msg[1] then return end
	self._msg[1]["ClubInfo"]["A108"] = fundNum
end
--[[
	更新战队积分数量
]]
function QDataFightTeamList:updateMsgJiFenData(Num)
	if not self._msg or not self._msg[1] then return end
	self._msg[1]["ClubInfo"]["5051"] = Num
end
--[[
	添加数据
]]
function QDataFightTeamList:addMsgData(_msg,nType)
	 if not self._msg[nType] then
	   self._msg[nType] = _msg
    else
        if #_msg < 1 then return end
        for i = 2,#_msg do
            table.insert(self._msg[nType],_msg[i])
        end
    end
end
--[[
	添加成员列表数据
]]
function QDataFightTeamList:addMsgMemberData(_msg,nType,secType)
	 if not self._msg[nType] then
	   self._msg[nType] = _msg
    else
        -- if not _msg[secType] or #_msg[secType] < 1 then return end
        for i = 1,#_msg[secType] do
            table.insert(self._msg[nType][secType],_msg[secType][i])
        end
    end
    -- dump(self._msg[nType])
end
--[[
	更新成员列表数据
]]
function QDataFightTeamList:updateMsgMemberData(nType,data)
	self._msg[nType] = data
end
return QDataFightTeamList