--[[
* 获取用户拥有的道具列表
     * @param String $props_group 道具分类 CARD FACE DECORATION FUNCTION
     * @param Int $uid 用户ID，可不填
     * @param String $subclass 道具子类，可不填，用来取指定子类目的道具列表


     **目前只用到了开房卡，以后需要其他道具再扩展
]]
local sharedUserPropsList = nil
UserPropsList = class("UserPropsList")

function UserPropsList:getInstance()
	if sharedUserPropsList==nil then
		sharedUserPropsList = UserPropsList:new()
	end
	return sharedUserPropsList
end

function UserPropsList:ctor()
	self.m_propsList = {}
	self.m_propsList["CARD"] = {}
	self.m_propsList["FACE"] = {}
	self.m_propsList["DECORATION"] = {}
	self.m_propsList["FUNCTION"] = {}
end

function UserPropsList:resetData()
	self.m_propsList = nil
	self.m_propsList = {}
	self.m_propsList["CARD"] = {}
	self.m_propsList["FACE"] = {}
	self.m_propsList["DECORATION"] = {}
	self.m_propsList["FUNCTION"] = {}
end

function UserPropsList:updatePropsList(strJson)
	self:resetData()
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		for i=1,#jsonTable do
			local props_group = jsonTable[i][MYGOODS_PROPS_PROPS_GROUP]
			if props_group == "CARD" then
				self:updatePropsCardList(jsonTable[i])
			elseif props_group == "FACE" then
				self:updatePropsFaceList(jsonTable[i])
			elseif props_group == "DECORATION" then
				self:updatePropsDecorationList(jsonTable[i])
			elseif props_group == "FUNCTION" then
				self:updatePropsFunctionList(jsonTable[i])
			end
		end
	end
end

function UserPropsList:updatePropsCardList(eachJson)
end

function UserPropsList:updatePropsFaceList(eachJson)

end

function UserPropsList:updatePropsDecorationList(eachJson)

end

function UserPropsList:updatePropsFunctionList(eachJson)
	local funcArgs = eachJson[MYGOODS_GOODS_PROPS_USAGE]
	local propName = "其他"
	if funcArgs == "animate" then
		propName = TABLE_ANIMATE
	elseif funcArgs == "smallHorn" then
		propName = SMALL_HORN
	elseif funcArgs~=nil and type(funcArgs)=="string" then
		if string.find(funcArgs, "createRoom:6")~=nil then
			propName = CREATE_ROOM_6HOUR
		elseif string.find(funcArgs, "createRoom:1")~=nil then
			propName = CREATE_ROOM_STANDARD
		elseif string.find(funcArgs, "createRoom:2")~=nil then
			propName = CREATE_ROOM_NO_FEE
		elseif string.find(funcArgs, "createRoom:3")~=nil then
			propName = CREATE_ROOM_DIY
		elseif string.find(funcArgs, "createMatch:SNG")~=nil then
			propName = CREATE_MATCH_DIY_SNG
		elseif string.find(funcArgs, "createMatch:MTT")~=nil then
			propName = CREATE_MATCH_DIY_MTT
		elseif string.find(funcArgs, "createRoom:4")~=nil then
			propName = CREATE_ROOM_6Plus
		end
	end
	if not self.m_propsList["FUNCTION"][propName] then
		self.m_propsList["FUNCTION"][propName] = {}
	end
	self.m_propsList["FUNCTION"][propName]["pid"] = eachJson[MYGOODS_PROPS_PROPS_ID]
	self.m_propsList["FUNCTION"][propName]["name"] = eachJson[MYGOODS_PROPS_PROPS_NAME]
	self.m_propsList["FUNCTION"][propName]["description"] = eachJson[MYGOODS_PROPS_PROPS_DESC]
	self.m_propsList["FUNCTION"][propName]["url"] = eachJson[MYGOODS_GOODS_PROPS_PIC]
	self.m_propsList["FUNCTION"][propName]["num"] = eachJson[MYGOODS_GOODS_PROPS_NUM]
	self.m_propsList["FUNCTION"][propName]["usage"] = eachJson[MYGOODS_GOODS_PROPS_USAGE]
end
