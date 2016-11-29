local Task_HappyHourConfig = class("Task_HappyHourConfig")

function Task_HappyHourConfig:ctor()

end

function Task_HappyHourConfig:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		self.code=""
		self.taskNum = jsonTable[TASK_HAPPYHOUR_CON1]
		self.happyHourNum = jsonTable[TASK_HAPPYHOUR_CON2]
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return Task_HappyHourConfig