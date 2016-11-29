require("app.GlobalConfig")
LAYOUT_OFFSET = cc.p(0,0)
MAX_ZORDER 					= 10000

g_ServerIP 					= "http://debao.boss.com"--"192.168.0.252"
g_ServerPort   				= 30003
g_PushServerIP				= "http://debao.boss.com"--"192.168.0.252"
g_PushServerPort			= 9001

--[[服务器地址]]
if SERVER_ENVIROMENT == ENVIROMENT_TEST then
	if TRUNK_VERSION==DEBAO_TRUNK then
		g_ServerIP = "http://debao.boss.com" --"192.168.0.252"
		g_ServerPort = 30003
		g_PushServerIP = "http://debao.boss.com" --"192.168.0.252"
		g_PushServerPort = 9001
	else
		g_ServerIP = "192.168.0.246"
		g_ServerPort = 30003
		g_PushServerIP = "192.168.0.246"
		g_PushServerPort = 9001
	end
elseif SERVER_ENVIROMENT == ENVIROMENT_PRE then
	if TRUNK_VERSION==DEBAO_TRUNK then
		g_ServerIP = "debaodev.boss.com" --"192.168.0.247"
		g_ServerPort = 30003
		g_PushServerIP = "debaodev.boss.com" --"192.168.0.247"
		g_PushServerPort = 9001
	else
		g_ServerIP = "192.168.41.120"
		g_ServerPort = 30003
		g_PushServerIP = "192.168.41.120"
		g_PushServerPort = 9001
	end
elseif SERVER_ENVIROMENT == ENVIROMENT_NORMAL then
	if TRUNK_VERSION==DEBAO_TRUNK then
		g_ServerIP = "http://server.debao.com"
		g_ServerPort = 80
		g_PushServerIP = "http://server.debao.com"
		g_PushServerPort = 8080
	else
		g_ServerIP = "123.151.39.13"
		g_ServerPort = 2004
		g_PushServerIP = "192.168.0.252"
		g_PushServerPort = 9001
	end
end
function currentVersion()
	return DBVersion
end