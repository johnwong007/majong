local LoginDataRepository = require("app.architecture.login.LoginDataRepository")
local HallDataRepository = require("app.architecture.hall.HallDataRepository")
local RoomDataRepository = require("app.architecture.room.RoomDataRepository")
local Injection = {}

function Injection:provideLoginDataRepository()
	return LoginDataRepository:new()
end

function Injection:provideHallDataRepository()
	return HallDataRepository:new()
end

function Injection:provideRoomDataRepository()
	return RoomDataRepository:new()
end

return Injection