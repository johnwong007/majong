local CommonFragment = require("app.architecture.components.CommonFragment")

local HallJoinRoomFragment = class("HallJoinRoomFragment", function()
		return CommonFragment:new()
	end)

function HallJoinRoomFragment:ctor(params)
	self.params = params
    self:setNodeEventEnabled(true)
    self.m_roomNumInput = {}
end

function HallJoinRoomFragment:onExit()
	if self.m_pPresenter then
    	self.m_pPresenter:onExit()
	end
end

function HallJoinRoomFragment:onEnterTransitionFinish()
end

function HallJoinRoomFragment:create()
	CommonFragment.initUI(self)
	self:initUI()
end

function HallJoinRoomFragment:initUI()
    local startY = CONFIG_SCREEN_HEIGHT/2-self.bgHeight/2+90
    for i=12,1,-1 do
    	local button = CMButton.new({
    		normal = "picdata/hall/join_room/btn_num"..i..".png",
        	pressed = "picdata/hall/join_room/btn_num_s"..i..".png",},
        	handler(self,self.pressBtn), nil, {changeAlpha = true})
    	local x = CONFIG_SCREEN_WIDTH/2
    	if i%3==0 then
    		x = x+248*SCALE_FACTOR
    	elseif i%3==1 then
    		x = x-248*SCALE_FACTOR
    	end
    	local y = startY+(3-math.floor((i-1)/3))*87*SCALE_FACTOR
    	button:setPosition(x,y)
    	self:addChild(button,1)
    	button:setScale(SCALE_FACTOR)
    	button:setTag(100+i)
    end
    startY = startY+4*87*SCALE_FACTOR

    local labelGap = 60
   	for i=1,6 do
   		cc.ui.UIImage.new("picdata/hall/join_room/img_underline.png")
   			:align(display.CENTER, CONFIG_SCREEN_WIDTH/2+(i-3)*labelGap-labelGap/2, startY)
   			:addTo(self)
   	end

   	startY = startY+30
   	self.m_pRoomNumLabel = {}
   	for i=1,6 do
	   	self.m_pRoomNumLabel[i] = cc.ui.UILabel.new({
	        color = cc.c3b(115, 0, 0),
	        text  = "",
	        size  = 32,
	        font  = "font/FZZCHJW--GB1-0.TTF",
	        align = cc.TEXT_ALIGN_CENTER
	        })
	   		:align(display.CENTER, CONFIG_SCREEN_WIDTH/2+(i-3)*labelGap-labelGap/2, startY)
	   		:addTo(self)
   	end
   	cc.ui.UILabel.new({
        color = cc.c3b(225, 0, 0),
        text  = "请输入房间号",
        size  = 26,
        font  = "font/FZZCHJW--GB1-0.TTF",
        align = cc.TEXT_ALIGN_CENTER
        })
   		:align(display.CENTER, CONFIG_SCREEN_WIDTH/2, startY+40)
   		:addTo(self)
end

function HallJoinRoomFragment:pressBtn(btn)
	local num = btn:getTag()-100
	if num == 10 then
		self.m_roomNumInput = nil
		self.m_roomNumInput = {}
	elseif num == 12 then
		if #self.m_roomNumInput>0 then
			self.m_roomNumInput[#self.m_roomNumInput] = nil
		end
	elseif num == 11 then
		if #self.m_roomNumInput<6 then
			self.m_roomNumInput[#self.m_roomNumInput+1] = "0" 
		end
	else
		if #self.m_roomNumInput<6 then
			self.m_roomNumInput[#self.m_roomNumInput+1] = ""..num 
		end
	end
	for i=1,6 do
		if self.m_roomNumInput[i] then
			self.m_pRoomNumLabel[i]:setString(self.m_roomNumInput[i])
		else
			self.m_pRoomNumLabel[i]:setString("")
		end
	end
	if #self.m_roomNumInput == 6 then
    	GameSceneManager:switchSceneWithType(GameSceneManager.AllScene.RoomView)
    	-- CMOpen(require("app.architecture.components.Toast"), self, {titleText="温馨提示", text = "房间不存在，请重新输入"}, true)
	end
end

return HallJoinRoomFragment