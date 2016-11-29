require("app.Tools.StringFormat")

TABLENAMECCP     =cc.p(-450,0)
BLINDCCP         =cc.p(TABLENAMECCP.x+240,0)

PLAYINGNUMCCP    =cc.p(315,2)
PROGRESSCCP      =cc.p(0,0)
INTOCHIPSCCP     =cc.p(74,0)
BACKBTNCCP       =cc.p(447,0)

--TABLENAMECCP     =cc.p(250,30)
--BLINDCCP         =cc.p(520,30)
--PLAYINGNUMCCP    =cc.p(105,30)
--PROGRESSCCP      =cc.p(0,30)
--INTOCHIPSCCP     =cc.p(668,30)
--BACKBTNCCP       =cc.p(587,40)
LOCKCCP          =cc.p(16,30)

PROGRESSWIDTH    =193

LABELCOLOR       =cc.c3b(255,255,255)
LABELSIZE        =cc.size(200,40)
LABELFONTSIZE    =26


LINEPIC               ="line.png"
BTNDOWNPIC            ="cellSelect.png"
BTNDOWNPIC1            ="cellSelect1.png"
BTNUPPIC              ="cellSelect.png"
--PROGRESSEMPTYPIC      ="sta_31_rennum_public_android.png"
--PROGRESSBLUEPIC       ="sta_32_rennum_public_android.png"
ROOM_LOCK_ICON        ="sta_30_shou_public_android.png"

bg_unlock             ="sta_3_table_android.png"
bg_lock               ="sta_3_lock_android.png"

img_progress_gray           ="sta_3_dot_non_android.png"
img_progress_light          ="sta_3_dot_on_android.png"


local HallTableViewCell = class("HallTableViewCell", function()
		return display.newNode()
	end)


function HallTableViewCell:ctor(className, parent, leftGameLevel, index)
	--[[背景]]
	-- self.blank = cc.ui.UIImage.new("bg_3_one.png")
        -- :addTo(self):align(display.CENTER, 0, 0)
        self.m_parent = parent
        self.leftGameLevel=leftGameLevel
    if leftGameLevel==Left_Private then
        self:initPrivateTableCells(index)
        return 
    end
    local bgFileName = ""
    local bgSelectFileName = ""
    
    if leftGameLevel==Left_PrimaryField then
        bgFileName = "bg_3_one1.png"
        bgSelectFileName = BTNDOWNPIC1
    else
        bgFileName = "bg_3_one.png"
        bgSelectFileName = BTNDOWNPIC
    end
    local sprite = cc.ui.UIImage.new(bgFileName)
	self.background = cc.ui.UIPushButton.new({
    	normal = bgFileName,
    	pressed = bgSelectFileName,
   	 	disabled = bgSelectFileName,
		})
		-- :setButtonSize(882, sprite:getContentSize().height)
        :onButtonClicked(function(event) 
            self:enterRoom()
            end)
        :addTo(self):align(display.CENTER, 0, 0)
        :setTouchSwallowEnabled(false)
	--[[座位分布情况]]
-----------------------------------------------------------
	--初始化位置
	-- local progress_x = 686-480+8
	-- local progress_y = self.blank:getContentSize().height/2+13
	-- self.progressPos = {}
	-- self.progressPos[1]=cc.p(80+progress_x+20, 39-progress_y)
 --    self.progressPos[2]=cc.p(75+progress_x+20, 61-progress_y)
 --    self.progressPos[3]=cc.p(88+progress_x+20, 78-progress_y)
 --    self.progressPos[4]=cc.p(110+progress_x+20, 81-progress_y)
 --    self.progressPos[5]=cc.p(131+progress_x+20, 78-progress_y)
 --    self.progressPos[6]=cc.p(145+progress_x+20, 59-progress_y)
 --    self.progressPos[7]=cc.p(139+progress_x+20, 37-progress_y)
 --    self.progressPos[8]=cc.p(120+progress_x+20, 29-progress_y)
 --    self.progressPos[9]=cc.p(99+progress_x+20, 29-progress_y)
    
	-- self.progressSixPos = {}
 --    self.progressSixPos[1]=cc.p(75+progress_x+20, 55-progress_y)
 --    self.progressSixPos[2]=cc.p(93+progress_x+20, 30-progress_y)
 --    self.progressSixPos[3]=cc.p(124+progress_x+20, 30-progress_y)
 --    self.progressSixPos[4]=cc.p(143+progress_x+20, 55-progress_y)
 --    self.progressSixPos[5]=cc.p(124+progress_x+20, 80-progress_y)
 --    self.progressSixPos[6]=cc.p(93+progress_x+20, 80-progress_y)

 --    self.progressGray = {}
 --    self.progressLight = {}
 --    for i=1,9 do
 --    	self.progressGray[i] = cc.ui.UIImage.new(img_progress_gray):addTo(self):align(display.CENTER, 0, 0)
 --    	self.progressGray[i]:setPosition(self.progressPos[i])
 --    	self.progressLight[i] = cc.ui.UIImage.new(img_progress_light):addTo(self):align(display.CENTER, 0, 0)
 --    	self.progressLight[i]:setPosition(self.progressPos[i])
 --    	self.progressLight[i]:setVisible(false)
 --    end

-----------------------------------------------------------
	--[[按钮]]
	-- self.backDown = cc.ui.UIImage.new(BTNDOWNPIC):addTo(self):align(display.CENTER, 0, 0)
	-- self.backDown:setVisible(false)

	--[[行分隔符]]
	-- local line = cc.ui.UIImage.new(LINEPIC):addTo(self):align(display.CENTER, 0, 0)
	-- line:setScaleX(272)
	-- line:setPositionY(-self.blank:getContentSize().height/2)

    --[[牌桌名]]	
    self.tableNameLabel = cc.ui.UILabel.new({
    	text = "tableName",
        font = "fonts/FZZCHJW--GB1-0.TTF",
    	size = 22,
    	color = LABELCOLOR,
    	dimensions = LABELSIZE,
        align = cc.TEXT_ALIGNMENT_CENTER})
    self.tableNameLabel:addTo(self)
    self.tableNameLabel:setPosition(TABLENAMECCP)
    if leftGameLevel==Left_PrimaryField then
        self.tableNameLabel:setPosition(TABLENAMECCP.x-15, TABLENAMECCP.y+8)

        self.curNumLabel = cc.ui.UILabel.new({
            text = "6",
            font = "Arial",
            size = 16,
            color = LABELCOLOR,
            dimensions = LABELSIZE,
            align = cc.TEXT_ALIGNMENT_CENTER})
            :addTo(self)
        self.curNumLabel:setPosition(cc.p(-473, -26))
    end

    --[[大小盲注]]	
    self.blindLabel = cc.ui.UILabel.new({
    	text = "blind",
    	size = LABELFONTSIZE,
    	color = LABELCOLOR,
    	dimensions = LABELSIZE})
    self.blindLabel:addTo(self)
    self.blindLabel:setPosition(cc.p(BLINDCCP.x+50, BLINDCCP.y))

    --[[在玩人数]]
    ---------------获取进度条----------------	
 --    self.progressBg = cc.ui.UIImage.new(bg_unlock):addTo(self):align(display.CENTER, 0, 0)
	-- self.progressBg:setPosition(PLAYINGNUMCCP)

    self.playingNumLabel = cc.ui.UILabel.new({
    	text = "1/6",
    	size = LABELFONTSIZE,
    	color = cc.c3b(0, 255, 255),
    	align = cc.ui.TEXT_ALIGN_CENTER})
    self.playingNumLabel:addTo(self)
    self.playingNumLabel:setPosition(cc.p(PLAYINGNUMCCP.x,PLAYINGNUMCCP.y))
    ----------------------------------------	

    --[[带入筹码]]	
    self.intoChipsLabel = cc.ui.UILabel.new({
    	text = "intochips",
    	size = LABELFONTSIZE,
    	color = LABELCOLOR,
    	dimensions = LABELSIZE})
    self.intoChipsLabel:addTo(self)
    self.intoChipsLabel:setPosition(INTOCHIPSCCP)
end

function HallTableViewCell:initPrivateTableCells(index)
    if index == 1 then
        local sprite = cc.ui.UIImage.new("picdata/hall/btn_list_add.png")
        -- self.background = cc.ui.UIPushButton.new({
        --     normal = "picdata/hall/btn_list_add.png",
        --     pressed = "picdata/hall/btn_list_add2.png",
        --     disabled = "picdata/hall/btn_list_add2.png",
        --     })
        --     :onButtonClicked(function(event) 
        --         self:createDebaoRoom()
        --         end)
        --     :addTo(self):align(display.CENTER, 0, 0)
        --     :setTouchSwallowEnabled(false)
        local btnOk = CMButton.new({normal = "picdata/hall/btn_list_add.png",pressed = "picdata/hall/btn_list_add2.png"},
            function () self:createDebaoRoom() end)
        btnOk:setPosition(0,0)
        self:addChild(btnOk)
        return
    end
    local sprite = cc.ui.UIImage.new("bg_3_one2.png")
    self.background = cc.ui.UIPushButton.new({
        normal = "bg_3_one2.png",
        pressed = "cellSelect2.png",
        disabled = "cellSelect2.png",
        })
    self.background:onButtonClicked(function(event) 
            self:enterRoom()
            end)
        :addTo(self):align(display.CENTER, 0, 0)
        :setTouchSwallowEnabled(false)

    cc.ui.UIImage.new("picdata/privateHall/bg_massage.png")
        :align(display.CENTER_TOP, 0, -24)
        :addTo(self)

    cc.ui.UIImage.new("picdata/hall/icon_lock.png")
        :align(display.CENTER, 0, 0)
        :addTo(self)

    local labColor = cc.c3b(255,255,255) 
    local labPosx = 20
         --[[牌桌名]]  
    self.tableNameLabel = cc.ui.UILabel.new({
        text = "11",
        font = GFZZC,
        -- font = "Arial",
        size = 26,
        color = labColor,
        -- dimensions = LABELSIZE,
        -- align = cc.TEXT_ALIGNMENT_CENTER
        })
        :align(display.CENTER, 0, 0)
    self.tableNameLabel:addTo(self)
    self.tableNameLabel:setPosition(cc.p(0, 25+4))
    self.tableNameLabel:enableShadow(cc.c4b(0,0,0,190),cc.size(0,2))

    --[[大小盲注]]  
    self.blindLabel = cc.ui.UILabel.new({
        text = "blind",
        size = 20,
        color = labColor,
        dimensions = LABELSIZE,
        align = cc.TEXT_ALIGNMENT_CENTER})
        :align(display.CENTER, 0, 0)
    self.blindLabel:addTo(self)
    self.blindLabel:setPosition(cc.p(0, -82-5))

    self.playingNumLabel = cc.ui.UILabel.new({
        text = "1/6",
        size = LABELFONTSIZE,
        color = labColor,
        align = cc.TEXT_ALIGNMENT_CENTER})
        :align(display.CENTER, 0, 0)
    self.playingNumLabel:addTo(self)
    self.playingNumLabel:setPosition(cc.p(0,58+4))
    ----------------------------------------    

    --[[带入筹码]]  
    self.intoChipsLabel = cc.ui.UILabel.new({
        text = "intochips",
        size = 20,
        color = labColor,
        dimensions = LABELSIZE,
        align = cc.TEXT_ALIGNMENT_CENTER})
        :align(display.CENTER, 0, 0)
    self.intoChipsLabel:addTo(self)
    self.intoChipsLabel:setPosition(cc.p(0, -48-5))
end

function HallTableViewCell:enterRoom()
    self.m_parent.hallEnterRoom_delegate:hallEnterRoom(self:getEachInfo())
end

function HallTableViewCell:createDebaoRoom()
    -- dump("创建朋友局")
    CMOpen(require("app.GUI.dialogs.CreateDebaoRoomDialog"), cc.Director:getInstance():getRunningScene(), 0, 0, 0)
end

function HallTableViewCell:resetData(info)
    if info == nil then
        return
    end
    -- dump(info)
    self.eachInfo = info
    local bigblind=info.bigBlind
    local curUnum=info.curUnum
    local seatNum=info.seatNum
    local tableName= info.tableName
    local buyChipsMax=info.butChipsMax
    local buyChipsMin=info.buyChipsMin
    local waittingUnum=info.waittingUnum
    local smallBlind=info.smallBlind
    local gameSpeed=info.gameSpeed
    local tableId=info.tableId
    local smallBlindno=info.smallBlind
    local password = info.password
    local uniqKey = info.uniqKey or ""

    bigblind = StringFormat:FormatDecimals(bigblind,-1)
    smallBlind=StringFormat:FormatDecimals(smallBlind,-1)
    buyChipsMin =StringFormat:FormatDecimals(buyChipsMin,-1)
    buyChipsMax=StringFormat:FormatDecimals(buyChipsMax,-1)
    
    local newBlindStr = smallBlind.."/"..bigblind
    local newCurNumStr = curUnum.."/"..seatNum
    if info.listType == "PRIMARY" then
        newCurNumStr = curUnum
    end
    local newBuyStr = buyChipsMin.."/"..buyChipsMax

    newBlindStr = "盲注"..smallBlind.."/"..bigblind
    newBuyStr = "最小买入"..buyChipsMin

    if self.leftGameLevel==Left_Private then
        if string.find(info.playType, "SNG") ~= nil or string.find(info.playType, "MTT") ~= nil then
            newBlindStr = "初始筹码"..info.initChips
            newBuyStr = "升盲时间"..info.upSeconds
        end
    end
    
    self.tableNameLabel:setString(tableName)

    self.blindLabel:setString(newBlindStr)
    self.playingNumLabel:setString(newCurNumStr)
    self.intoChipsLabel:setString(newBuyStr)

if self.leftGameLevel==Left_Private then
    -- if string.find(uniqKey, "DIYMATCH:SNG") ~= nil then
    --     cc.ui.UIImage.new("picdata/hall/icon_sng.png")
    --         :align(display.CENTER_BOTTOM, 0, 80)
    --         :addTo(self)
    if string.find(info.playType, "SNG") ~= nil then
        cc.ui.UIImage.new("picdata/hall/icon_sng.png")
            :align(display.CENTER_BOTTOM, 0, 88)
            :addTo(self)

        self.background:setButtonImage("normal", "picdata/hall/bg_3_one3.png")
        self.background:setButtonImage("pressed", "picdata/hall/cellSelect3.png")
        self.background:setButtonImage("disabled", "picdata/hall/cellSelect3.png")
    elseif string.find(info.playType, "MTT") ~= nil then
        cc.ui.UIImage.new("picdata/hall/icon_mtt.png")
            :align(display.CENTER_BOTTOM, 0, 88)
            :addTo(self)

        self.background:setButtonImage("normal", "picdata/hall/bg_3_one3.png")
        self.background:setButtonImage("pressed", "picdata/hall/cellSelect3.png")
        self.background:setButtonImage("disabled", "picdata/hall/cellSelect3.png")
        
        self.playingNumLabel:setString(""..curUnum.."人报名")
    else
        cc.ui.UIImage.new("picdata/hall/icon_player.png")
            :align(display.CENTER_BOTTOM, 0, 88)
            :addTo(self)
    end

    local matchNameDefalutWidth = 120
    local matchNameLen = string.utf8len(tableName)
    if matchNameLen>5 then
        local w = self.tableNameLabel:getContentSize().width
        local ratio = matchNameDefalutWidth/w
        if ratio<1 then
            self.tableNameLabel:setScale(matchNameDefalutWidth/w)
        end
    end
end
    if leftGameLevel==Left_PrimaryField then
        if self.curNumLabel then
            self.curNumLabel:setString(seatNum)
        end
    end
end

function HallTableViewCell:getEachInfo()
    return self.eachInfo
end

function HallTableViewCell:clickedEnter(touch)
	self.backDown:setVisible(touch)
end

return HallTableViewCell