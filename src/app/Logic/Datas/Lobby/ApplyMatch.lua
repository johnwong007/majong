
local ApplyMatch = class("ApplyMatch")

function ApplyMatch:ctor()
	self.applyMatchResult = 0
	self.errorStr = ""
end


function ApplyMatch:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "number" then
		self.applyMatchResult = jsonTable+0
		return BIZ_PARS_JSON_SUCCESS
	elseif type(jsonTable) == "table" then
		self.applyMatchResult = jsonTable[CODE]+0
		self.errorStr = jsonTable[DSCRIPTION]..""
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return ApplyMatch