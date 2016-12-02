QDataPlayer = {}
function QDataPlayer:new()
	QDataPlayer.data = {
		userPotraitUri = nil,
		userId = 4331,
		userName = "我叫m\'t",
		roomCardNum = 100,
	}
end

QDataPlayer:new()

local socket = require("socket")
if not QDataPlayer.data.userPotraitUri then
	math.randomseed(socket.gettime()*1000)
    local randomValue = math.random(12)
    QDataPlayer.data.userPotraitUri = "picdata/portrait/portrait"..randomValue..".png"
end