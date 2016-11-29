local _p = require("app.Network.Socket.protocols")
local Protocol = require("app.Network.Socket.Protocol")
local InfoUtil = {}

local function _getMsgFmt(__name, __msgid)
	print(type(__msgid))
	assert(_p[__name][__msgid], "Can not find ".. __name .." protocol in method:"..__msgid.."!")
	local __msgFmtTable = _p[__name][__msgid]
	return __msgFmtTable
end

function InfoUtil:getSendMsgFmt(__msgid)
	return _getMsgFmt("send", __msgid)
end

function InfoUtil:getRecevieMsgFmt(__msgid)
	return _getMsgFmt("receive", __msgid)
end

return InfoUtil