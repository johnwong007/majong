local LoginDataRepository = require("app.architecture.login.LoginDataRepository")
local HallDataRepository = require("app.architecture.hall.HallDataRepository")
local Injection = {}

function Injection:provideLoginDataRepository()
	return LoginDataRepository:new()
end

function Injection:provideHallDataRepository()
	return HallDataRepository:new()
end

return Injection