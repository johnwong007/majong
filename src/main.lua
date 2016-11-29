
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    if device.platform == "android" or device.platform == "ios" then
	    buglyReportLuaException(tostring(errorMessage), debug.traceback())
	end

	--[[
		将错误打印至正在运行的界面
	--]]
	local function prinErrorToScene()
		if DEBUG > 1 and app then
			local errorInfo = tostring(errorMessage) .. "\n" .. debug.traceback("", 2)
			local runScene = display.getRunningScene()
			if runScene then
				if tolua.isnull(G_errorLabel) then
					G_errorLabel = cc.ui.UILabel.new({
						text = "", 
						color = cc.c3b(255,0,0), 
						size = 18, 
						textAlign = cc.ui.TEXT_ALIGN_LEFT,
						dimensions = cc.size(display.cx, display.cy)
						}):pos(0, display.cy):addTo(runScene, 9999)
				end
				G_errorLabel:setString(errorInfo)
			end
		end
	end

	prinErrorToScene()
end

-- local writablePath = cc.FileUtils:getInstance():getWritablePath()
-- print(writablePath)

-- cc.FileUtils:getInstance():addSearchPath(writablePath.."res/")
-- cc.FileUtils:getInstance():addSearchPath(writablePath.."src/")
-- cc.FileUtils:getInstance():addSearchPath("res/")
-- cc.FileUtils:getInstance():addSearchPath("src/")

package.path = package.path .. ";src/"

cc.FileUtils:getInstance():setPopupNotify(false)

require("app.MyApp").new():run()


