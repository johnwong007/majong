local BaseView = require("app.architecture.BaseView")
local BasePresenter = require("app.architecture.BasePresenter")
local LoginContract = {
	View = class("View", function()
			return BaseView:new()
		end),
	Presenter = class("Presenter", function()
			return BasePresenter:new()
		end) 
}

--[[LoginContract.View]]
--------------------------------------------------------------------------------
function LoginContract.View:ctor()end
function LoginContract.View:updateCallBack(data)end--[[事件监听回调]]
function LoginContract.View:create()end
function LoginContract.View:initUI()end--[[初始化视图]]
function LoginContract.View:switchLayer(tag)end--[[切换视图]]
function LoginContract.View:setRememberAccount(selected)end--[[设置记住帐号单选框]]
function LoginContract.View:setRememberPassword(selected)end--[[设置记住密码单选框]]
function LoginContract.View:setUsernameTextField(text)end--[[设置用户名]]
function LoginContract.View:setPasswordTextField(text)end--[[设置密码]]
function LoginContract.View:addChannelButton(params)end--[[添加渠道登录按钮]]
function LoginContract.View:toCustomerService()end--[[联系客服]]
function LoginContract.View:toTouristLogin()end--[[游客登录]]
function LoginContract.View:toDebaoLogin()end--[[德堡登录]]
function LoginContract.View:toQQLogin()end--[[QQ登录]]
function LoginContract.View:to500Login()end--[[500wan登录]]
function LoginContract.View:AndroidLogin(args)end--[[渠道登录]]
function LoginContract.View:toLogin()end--[[登录游戏]]
function LoginContract.View:switchAccount()end--[[切换帐号]]
function LoginContract.View:pressForgetPass()end--[[忘记密码]]
function LoginContract.View:loginFailedCallback(errorCode, errorMsg)end--[[登录失败提示]]
function LoginContract.View:clickButtonAtIndex(alertView, index)end--[[提示框回调]]
function LoginContract.View:loginProgressCallback()end--[[登录中...]]
function LoginContract.View:showLoadingViewCallback(bEable)end--[[loading页面]]
function LoginContract.View:loginSuccessedCallback()end--[[登录成功跳转]]
--------------------------------------------------------------------------------

--[[LoginContract.Presenter]]
--------------------------------------------------------------------------------
function LoginContract.Presenter:ctor()end
function LoginContract.Presenter:start()end
function LoginContract.Presenter:initLogin()end--[[初始化登录信息]]
function LoginContract.Presenter:switchLayer(tag)end--[[切换登录方式]]
function LoginContract.Presenter:getDebaoLoginInfo()end--[[获取德堡帐号信息]]
function LoginContract.Presenter:get500WanLoginInfo()end--[[获取500wan帐号信息]]
function LoginContract.Presenter:getDebaoLoginName()end--[[获取德堡帐号]]
function LoginContract.Presenter:getDebaoLoginPassword()end--[[获取德堡密码]]
function LoginContract.Presenter:get500WANLoginName()end--[[获取500wan帐号]]
function LoginContract.Presenter:get500WANLoginPassword()end--[[获取500wan密码]]
function LoginContract.Presenter:debaoPlatformLoginRequest(userName, password, loginType, bRemeberPassword, bAutoLogin, sign)end--[[登录请求]]
function LoginContract.Presenter:setTcpIpandPort()end--[[设置ip和端口号]]
function LoginContract.Presenter:OnTcpMessage(command, strJson)end--[[TCP消息]]
function LoginContract.Presenter:dealGetServerPort(jsonTable,tag)end--[[获取服务端口回调]]
function LoginContract.Presenter:dealConnectSuccessResp(strJson)end--[[tcp登录成功]]
function LoginContract.Presenter:connectSuccessEnterRoomOrMainpage()end--[[保存数据进入大厅]]

--------------------------------------------------------------------------------

return LoginContract