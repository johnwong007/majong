local DialogBase = require("app.GUI.roomView.DialogBase")
local EnterPasswordDialog = class("EnterPasswordDialog", DialogBase)

function EnterPasswordDialog:ctor(params)
	self.m_layer = require("app.GUI.hallview.EnterPassword"):new()
	self.m_layer:addTo(self)
	self.m_layer:setDialogBaseCallBack(params.m_pCallbackUI)


	local event = cc.EventCustom:new("HidePrivateHallSearch")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function EnterPasswordDialog:showPrivateHallSearch(isShow)
	self.isPrivateHallSearchShow = isShow
	dump(self.isPrivateHallSearchShow)
end

function EnterPasswordDialog:remove()
	if self.isPrivateHallSearchShow then
		local event = cc.EventCustom:new("ShowPrivateHallSearch")
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
	end
	DialogBase.remove(self)
end

return EnterPasswordDialog