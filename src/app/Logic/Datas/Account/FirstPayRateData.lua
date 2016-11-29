local FirstPayRateData = class("FirstPayRateData")

function FirstPayRateData:ctor()
	self.payRateList = {}
end

function FirstPayRateData:parseJson(strJson)
	local jsonTable = json.decode(strJson)
	if type(jsonTable) == "table" then
		for i=1,#jsonTable do 
			if type(jsonTable[i])== "table" and #jsonTable[i]==2 then
				local payRate = {}
				local payNum = jsonTable[i][1]
				local rebate = jsonTable[i][2]

				payRate[#payRate+1] = payNum
				payRate[#payRate+1] = rebate
				self.payRateList[#self.payRateList+1] = payRate
			end
		end
		self.parsResult = BIZ_PARS_JSON_SUCCESS
		return BIZ_PARS_JSON_SUCCESS
	end
	return BIZ_PARS_JSON_FAILED
end

return FirstPayRateData