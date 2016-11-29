local Upgrade = class("Upgrade")

function Upgrade:ctor()
	self.m_upgradeUrl = ""
	self.m_versionDesc = ""
	self.m_isUpgrade = false
	self.m_upgradeType = 0 --更新类型 = ""(-1校验失败，0不需要升级，1强制升级，2可选升级）
	self.m_version = ""
end

function Upgrade:parseJson(strJson)
	local jsonTable = strJson
	if type(jsonTable) == "table" then
		local ret=jsonTable["Ret"]+0

		self.m_upgradeType = ret
		local echoValue= jsonTable["Data"]
		if ret==1 or ret==2 then 
			self.m_isUpgrade = true
			self.m_upgradeUrl=echoValue["url"]..""
			self.m_version = echoValue["version"]..""
			if echoValue["desc"] and type(echoValue["desc"])=="table" then
				for index=1,#echoValue["desc"] do 
					if index==#echoValue["desc"] then
						self.m_versionDesc = self.m_versionDesc..echoValue["desc"][index]
					else
						self.m_versionDesc = self.m_versionDesc..echoValue["desc"][index].."\n"
					end
				end
			end
		end

		self.parsResult = BIZ_PARS_JSON_SUCCESS
		
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return Upgrade