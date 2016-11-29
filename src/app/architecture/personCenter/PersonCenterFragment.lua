--[[已废弃,重新架构太累]]
local BasePresenter = require("app.architecture.BasePresenter")
local CommonFragment = require("app.architecture.components.CommonFragment")

local PersonCenterPresenter = class("PersonCenterPresenter", function()
        return BasePresenter:new()
    end)

function PersonCenterPresenter:ctor(o,params)
    self.m_pView = params.view
    self.m_pView:setPresenter(self)
end

function PersonCenterPresenter:start()

end

------------------------------------------------------------------------------------------------
local PersonCenterFragment = class("PersonCenterFragment", CommonFragment)

function PersonCenterFragment:create()
    self:initUI()
    if self.m_pPresenter then 
        self.m_pPresenter:start()
    end
end

function PersonCenterFragment:ctor(params)
    PersonCenterFragment.super.ctor(self, params) 
    self.params = params or {}
    PersonCenterPresenter:new({view=self})
    self:setNodeEventEnabled(true)
end

function PersonCenterFragment:onEnterTransitionFinish()
 
end

function PersonCenterFragment:onExit()
    
end

function PersonCenterFragment:initUI()
    
end

function PersonCenterFragment:back()
    PersonCenterFragment.super.back(self) 
end

return PersonCenterFragment