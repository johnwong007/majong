local DialogBase = class("DialogBase", function()
		return display.newLayer()
	end)

function DialogBase:ctor()
	
end

function DialogBase:init()
	return true
end

function DialogBase:show()
	self:setVisible(true)
end

function DialogBase:alertShow()
	self:setVisible(true)
end

function DialogBase:hide()
	self:setVisible(false)
end

function DialogBase:remove()
	if self ~= nil then 
		self:removeFromParent(true)
		if self.m_callback then
			self.m_callback()
		end
	end 
end

function DialogBase:setDialogBaseCallBack(callback)
    self.m_pCallbackUI = callback
end

function DialogBase:setUserObject(userObject)
    self.m_userObject = userObject
end

function DialogBase:getUserObject()
    return self.m_userObject
end

function DialogBase:setUserData(userObject)
    self.m_userObject = userObject
end

function DialogBase:getUserData()
    return self.m_userObject
end

function DialogBase:setCloseCallback(callback)
    self.m_callback = callback
end

return DialogBase