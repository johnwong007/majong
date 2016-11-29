--
-- Author: junjie
-- Date: 2015-12-14 14:48:37
--
local HeadEditLayer = class("HeadEditLayer",function() 
  return display.newNode()
end)
require("app.Network.Http.DBHttpRequest")
local CMButton = require("app.Component.CMButton")
local myInfo = require("app.Model.Login.MyInfo")

local QDataHeadList = nil
local NetCallBack = require("app.Network.Http.NetCallBack")
require("app.CommonDataDefine.CommonDataDefine")
local EnumMenu =
{ 
    eBtnSure = 1,  --确认
    eBtnAgain= 2,  --重新上传
}
function HeadEditLayer:ctor(params)
  QDataHeadList = QManagerData:getCacheData("QDataHeadList")
  self.params = params or {}
  self.mActivitySprite = {}
  self.mHeadSprite = {}
  self.mAllType = {"JD","ZDY",}
end
function HeadEditLayer:create()
   self:initUI()
end

function HeadEditLayer:initUI()
  self:setContentSize(600,500)
  self:setPosition(-35, -18)
  self.mBg = self
  self:createButtonGroup()
end

--[[tabbar按钮]]
function HeadEditLayer:createButtonGroup()

  -- local bg = cc.Sprite:create("picdata/public/btn_1_menu.png")
  -- bg:setScaleX(1.1)
  -- bg:setPosition(580,490)
  -- self.mBg:addChild(bg)

    local line1 = cc.ui.UIImage.new("picdata/public_new/line2.png")
    line1:align(display.CENTER, 480-162, 282)
        :addTo(self.mBg)
    line1:setRotation(-90)
    line1:setScaleX(0.7)

    local buttonText = {"经典头像","自定义头像"}
    local group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
    for i=1,#buttonText do
        local button = cc.ui.UICheckBoxButton.new({
          off = "picdata/public_new/tap.png",
          off_pressed = "picdata/public_new/tap_p.png", 
          on = "picdata/public_new/tap_p.png"})
        button:setButtonLabel("off", cc.ui.UILabel.new({
              UILabelType = 1,
              text  = buttonText[i],
              font  = "fonts/tab.fnt",
              size  = 30,
              align = cc.ui.TEXT_ALIGN_CENTER,
          }))
        button:setButtonLabel("on", cc.ui.UILabel.new({
              UILabelType = 1,
              text  = buttonText[i],
              font  = "fonts/tab_p.fnt",
              size  = 30,
              align = cc.ui.TEXT_ALIGN_CENTER,
          }))
        button:setButtonLabelOffset(-80, 2)
        if i==1 then
          button:setButtonLabelOffset(-80+10, 2)
        end
        group:addButton(button)
    end
    group:setButtonsLayoutMargin(0, 0, 0, 0)
    :onButtonSelectChanged(function(event)
        local group = self.mGroup:getButtonAtIndex(event.selected)
        -- self.menu:setPosition(group:getPositionX()+484,group:getPositionY()+476)
        self:onChangeSwitch(event.selected)
       
    end)
    :align(display.CENTER, 10 ,CONFIG_SCREEN_HEIGHT-270)
    :addTo(self.mBg,1)
     self.mGroup = group
    group:getButtonAtIndex(1):setButtonSelected(true)
    group:getButtonAtIndex(2):setPositionY(42)
end
--[[
    我的物品－－经典
    ]]
function HeadEditLayer:createList(nType)
   
    if self.mList then self.mList:removeFromParent() self.mList = nil end
    local cfgData = QDataHeadList:getMsgData(nType)
    if not cfgData or #cfgData == 0 then 
      DBHttpRequest:getPortraitPics(function(tableData,tag) self:httpResponse(tableData,tag) end)
        return
    end 

   self.mCfgData = cfgData
    self.mActivitySprite = {}
    self.mHeadSprite = {}
    -- body
    self.mListSize = cc.size(700,CONFIG_SCREEN_HEIGHT-110) 
    self.mList = cc.ui.UIListView.new {
        --bgColor = cc.c4b(200, 200, 200, 120),
        viewRect = cc.rect(300, 0, self.mListSize.width, self.mListSize.height),       
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    :onTouch(handler(self, self.touchPropListener))
    :addTo(self.mBg,1)    

    local backPath = "picdata/personalCenter/headBack.png"
    local imagePath = ""
    local numPerLine = 3
   local lens = math.ceil(#cfgData/numPerLine)
  for i = 1,lens do   

    local index = (i-1)*numPerLine
    local item = self.mList:newItem()
    local node = display.newNode()  
    item:addContent(node)   

    local bg
    local curIndex
    local posx = 77
    for j = 1,numPerLine do
          curIndex = index + j
        local serData = cfgData[curIndex] 
         if not serData then break end
         if serData["PROTRAIT_URL"] ~= "" then

              local isExist,newPath = NetCallBack:getCacheImage(serData["PROTRAIT_URL"])
              if isExist then
                  imagePath = newPath
              else
                  NetCallBack:doDownloadSend(handler(self,self.onHttpDownloadResponse),DOMAIN_URL..string.gsub(serData["PROTRAIT_URL"],".png",".big.png"),nType,serData["PROTRAIT_URL"],curIndex)
              end
          end
        ------------------------------------------        
        bg = cc.ui.UIImage.new("picdata/personCenterNew/headEdit/btn_tx.png")
        -- bg:align(display.CENTER, bg:getContentSize().width/2+10,bg:getContentSize().width/2)
        bg:align(display.CENTER, bg:getContentSize().width/2+5+(bg:getContentSize().width+10)*(j-1),bg:getContentSize().width/2+15)
        node:addChild(bg,1)
        ------------------------------------------
        -- bg = cc.Sprite:create(backPath)
        -- bg:setPosition(posx,55)
        -- node:addChild(bg)

        local headPic = CMCreateHeadBg(imagePath,cc.size(154,154),cc.size(0,0),"images/sysimage")
        -- headPic:setPosition(bg:getContentSize().width/2+0.5,bg:getContentSize().height/2+1.5)
        headPic:setPosition(bg:getPositionX()+0.5,bg:getPositionY()+1.5)
        node:addChild(headPic)
        posx = posx + bg:getContentSize().width + 25
        headPic:setOpacity(255*0.8)

        self.mActivitySprite[curIndex] = bg
        self.mHeadSprite[curIndex] = headPic
      end

      if i == 1 then 
        --self:onMenuSwitch(1)
      end
      node:setContentSize(self.mListSize.width, bg:getContentSize().height+6)
      item:setItemSize(self.mListSize.width, bg:getContentSize().height+6)
      self.mList:addItem(item)
        dump(myInfo.data.userPotrait)
        
    end 

    self.mList:reload() 
end
function HeadEditLayer:createZDYList()
    local msgBg = cc.Node:create()
    msgBg:setPosition(590+40,400)
    self.mBg:addChild(msgBg)
    self.mZDYBg = msgBg
    -- local tips = cc.Sprite:create("picdata/personalCenter/headEditTxt.png")
    -- tips:setPosition(msgBg:getContentSize().width/2,90)
    -- msgBg:addChild(tips)


    local tips = cc.ui.UILabel.new({
            text  = "温馨提示：为维护网络环境的合法和健康，自定义头像需\n要"..
              "不多于一个工作日的审核，".."审核通过后头像将自动更新。",
            size  = 24,
            color = cc.c3b(180,192,220),
            --UILabelType = 1,
            font  = "黑体",
          
        })
    tips:align(display.CENTER,msgBg:getContentSize().width/2,90)
    msgBg:addChild(tips)


    local headPic = CMCreateHeadBg(self.mNewHeadPath,cc.size(196,196),cc.size(0,0))
    headPic:setPosition(msgBg:getContentSize().width/2,msgBg:getContentSize().height/2 - 90)
    msgBg:addChild(headPic,0,101)

    local maskPath = "picdata/personCenterNew/headEdit/bg_normal.png"
    if tonumber(myInfo.data.vipLevel)>0 then
      maskPath = "picdata/personCenterNew/headEdit/bg_vip.png"
    end
    local headMask = cc.Sprite:create(maskPath)
    headMask:setPosition(msgBg:getContentSize().width/2,msgBg:getContentSize().height/2 - 90)
    msgBg:addChild(headMask)

    local text = "当前头像"
    if tonumber(myInfo.data.headCheck) == 1 then
      text = "头像审核中..."
      local mask = cc.Sprite:create("picdata/personalCenter/head_ready_mask.png") 
      -- mask:setVisible(false)
      mask:setPosition(headPic:getPositionX(),headPic:getPositionY())
      msgBg:addChild(mask,0,102)
    end

    local sDetail = cc.ui.UILabel.new({
            text  =  text,
            size  = 24,
            color = cc.c3b(115,131,163),
            --UILabelType = 1,
            font  = "FZZCHJW--GB1-0",
          
        })
    sDetail:setPosition(headPic:getPositionX()-sDetail:getContentSize().width/2,-215)
    msgBg:addChild(sDetail)
    
    -- local btnAgain = CMButton.new({normal = "picdata/public/btn_1_156_blue.png"},function () self:onMenuCallBack(EnumMenu.eBtnAgain) end,{scale9 = false},{textPath = "picdata/personalCenter/w_btn_cxsc.png" })     
    -- :align(display.CENTER, headPic:getPositionX(),-270) --设置位置 锚点位置和坐标x,y
    -- :addTo(msgBg)

    local btnAgain = CMButton.new({
      normal = "picdata/public_new/btn_blue.png",
      pressed = "picdata/public_new/btn_blue_p.png"
      },function () self:onMenuCallBack(EnumMenu.eBtnAgain) end,{scale9 = false},{textPath = "picdata/personCenterNew/securityCenter/w_xg.png"})     
    :align(display.CENTER, headPic:getPositionX(),-270) --设置位置 锚点位置和坐标x,y
    :addTo(msgBg)
    

end
function HeadEditLayer:onChangeSwitch(idx)
  if idx == 1 then
      if self.mZDYBg then self.mZDYBg:setVisible(false) end
      if self.mList  then
         self.mList:setVisible(true)
      else
         self:createList(self.mAllType[1])
      end
  else
      if self.mList then  self.mList:setVisible(false) end

      if self.mZDYBg then 
          self.mZDYBg:setVisible(true)
          self.mZDYBg:getChildByTag(101):changeHead(self.mNewHeadPath)
      else
          self:createZDYList()
      end
  end
end
function HeadEditLayer:touchPropListener(event)
  local name, x, y = event.name, event.x, event.y 
   if name == "clicked" then
    self:checkTouchInSprite_(self.touchBeganX,self.touchBeganY,event.itemPos)
   else
    if name == "began" then
          self.touchBeganX = x
          self.touchBeganY = y
         return true
      end     
   end
  
end

function HeadEditLayer:checkTouchInSprite_(x, y,itemPos)  
  for i = 1,#self.mActivitySprite do    
    if self.mActivitySprite[i]:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then               
      self:onMenuSwitch(i)
    else
      --self.mActivitySprite[i]:getChildByTag(101):setVisible(false)
    end
  end 
end
function HeadEditLayer:onMenuSwitch(idx)
  if self.mSelectSprite then self.mSelectSprite:removeFromParent() end
    if self.mSelectIndex then
      self.mHeadSprite[self.mSelectIndex]:setOpacity(255*0.8)
    end
    self.mSelectIndex = idx or 1
    self.mHeadSprite[self.mSelectIndex]:setOpacity(255)
    local width = self.mActivitySprite[idx]:getContentSize().width
    local height = self.mActivitySprite[idx]:getContentSize().height
    self.mSelectSprite = cc.Sprite:create("picdata/personCenterNew/headEdit/btn_tx_p.png")
    self.mSelectSprite:setPosition(self.mActivitySprite[idx]:getPositionX(),self.mActivitySprite[idx]:getPositionY())
    self.mActivitySprite[idx]:getParent():addChild(self.mSelectSprite,1)
    self:onMenuCallBack(EnumMenu.eBtnSure)
end
--[[
  按钮
]]
function HeadEditLayer:onMenuCallBack(tag)
  if tag == EnumMenu.eBtnSure then
     DBHttpRequest:updateUserInfo(function(tableData,tag,fileName) self:httpResponse(tableData,tag,self.mCfgData[self.mSelectIndex]["PROTRAIT_URL"]) end,self.mCfgData[self.mSelectIndex]["PROTRAIT_ID"],myInfo.data.username,myInfo.data.userSex)
  elseif tag == EnumMenu.eBtnAgain then
    local data = {}
    data.callback = function (resultData) self:HeadChangeCallback(resultData) end
    QManagerPlatform:showPickHeadImage(data)
  end
end
function HeadEditLayer:HeadChangeCallback(resultData)

    local data = json.decode(resultData.resultData)
    local ret = tonumber(data["Ret"])
    local msg = tostring(data["Data"]["message"])
    local isSuc = false
    if ret == 1 then 
      isSuc = true
      if self.mZDYBg then
        self.mZDYBg:getChildByTag(102):setVisible(true)
      end
    elseif ret == -1 then
      isSuc = false
       if self.mZDYBg then
        self.mZDYBg:getChildByTag(102):setVisible(false)
      end
    end
    local RewardLayer = require("app.Component.CMToolTipView").new({text = msg,isSuc = isSuc})
    CMOpen(RewardLayer, self)

end
--[[
  网络回调
]]
function HeadEditLayer:httpResponse(tableData,tag,fileName) 
  --dump(tableData,tag)
    if tag == POST_COMMAND_GETPORTRAITPICS then   
        QDataHeadList:Init(tableData,self.mAllType[1])
        self:createList(self.mAllType[1])
    elseif tag == POST_COM_UPDATE_USER_INFO then
      local text = "恭喜你修改成功"
      local isSuc = true
      if tableData["CODE"] == 1 then
        myInfo.data.userPotrait = fileName
        self.mNewHeadPath = fileName
        QManagerListener:Notify({layerID = ePersonLayerID,fileName = fileName})
      else
        text = "修改失败"
        isSuc = false
      end
      -- local CMToolTipView = require("app.Component.CMToolTipView").new({text = text,isSuc = isSuc})
      --   CMOpen(CMToolTipView,self)
    end
    
end

----------------------------------------------------------
--[[下载文件回调]]
----------------------------------------------------------
function HeadEditLayer:onHttpDownloadResponse(tag,progress,fileName)

    --if tag == self.mAllType[1] then
        if self.mActivitySprite[progress] then
            self.mActivitySprite[progress]:changeHead(fileName,false,"images/sysimage")
        end
    --end
end
return HeadEditLayer