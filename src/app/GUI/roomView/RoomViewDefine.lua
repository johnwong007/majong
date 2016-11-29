cell_left = 0
cell_right = 1


--获取方向，参数为座位号和座位总数
function getDirectBySeatNoAndSeatNum(seatNo, seatNum)
	local tmpDirection = cell_left
	if seatNum == 6 then 
		if seatNo>=0 and seatNo<=3 then
			tmpDirection = cell_left
		else
			tmpDirection = cell_right
		end
	elseif seatNum == 9 then
		if seatNo>=0 and seatNo<=4 then
			tmpDirection = cell_left
		else
			tmpDirection = cell_right
		end
	elseif seatNum == 2 then
		-- tmpDirection = (seatNo == 1) and cell_right or cell_left
		tmpDirection = cell_left
	end
	return tmpDirection
end

--RoomView层级
--[0500]:xml文件布局使用
--[5011000]:代码层级范围
--10001:弹出层窗体层级
	kZAnimateChip    = 501--动画筹码层级
	kZSafa           = 502--沙发位置层级
	kZPot            = 503--奖池层级
    kZUserCell       = 504--usercell层级
	kZShowDown       = 505--亮牌层级
	kZDispatchCard   = 506--发牌层级
	kZCommunityCard  = 507--公共牌层级
	kZYouWin         = 508--you win提示层级
	kZFirstHandCard  = 509--亮牌层级
	kZInfoHint       = 510--公告信息层级
    
    kZOperateBoard   = 515--操作面板
	kZNewerGuide     = 516--新手引导
    
	kZMax            = 1001--最大层级


--RoomView触摸优先级
--kCCMenuHandlerPriority = -128

	kMaxPriotity			= -1000--游戏最大优先级
	kAlertViewPriotity		= -500 --警告等弹框优先级
	kDialogPriotity			= -400 --滑动列等表框优先级
	kRoomViewMaxPriority    = -300--房间最大
    
	kUsercellPriority       = -203--Usercell
	kSafaPriority           = -202--沙发
	kRoomViewNormalPriority = -201--普通层级按钮
	kOperateBoardPriority   = -200--控制面板

	--RoomView Tag
--[0500]:xml内使用
--[5011000]:代码添加对象使用

kTagAnimateChip = 510--移动筹码

--牌桌类型
	kNone = 0  --
	kGold = 1  --金币场
	kSilver = 2 --银币场

	--聊天内容
	RVChatMsg = {}
	RVChatMsg.boolIsMine = false --是我说的么用来高亮
	RVChatMsg.userName = "sdfsd"   --用户名
	RVChatMsg.chatMsg = ""    --聊天内容

TEXT_FONT = "黑体"

--------------------------------------------------界面元素图片和坐标
s_room_bg               = "picdata/table_dif/tableBG.png"

--牌桌
ROOM_TABLE_POS         = cc.p(480,0)
s_room_cash_table       = "picdata/table/gameTable.png"
s_room_tourney_table    = "picdata/table/tourneyTable.png"

--牌桌类型
ROOM_TABLE_ICON_POS         = cc.p(480,320+30)

s_room_cash_table_icon       = "picdata/table/tableLogo.png"
s_room_tourney_table_icon    = "picdata/table/tableLogo.png"

--ROOM_TABLE_TIME_POS    = cc.p(SCREEN_IPHONE5?970:882,568)
ROOM_TABLE_TIME_POS    = cc.p(80,530)

s_room_dealer           = "picdata/table/dealerBtn.png"

s_room_safaN            = "picdata/table/sit.png"
s_room_safaS            = "picdata/table/sitdown.png"
s_room_recordS = "picdata/table/save1.png"
s_room_recordN = "picdata/table/save.png"
--退出
ROOM_BACK_BTN_POS      = cc.p(50,597)
s_room_backN            = "picdata/table/backMenu.png"
s_room_backS            = "picdata/table/backMenu1.png"

ROOM_BACK_RECORD_POS   = cc.p(140,40)
--s_room_light = "picdata/db_icon/sta_20_light_down.png"
ROOM_BACK_LIGHT_POS    = cc.p(830+28-10,560)

--happyHour
ROOM_HAPPYHOUR_BTN_POS = cc.p(350,454)

--rebuy
ROOM_REBUY_BTN_POS      = cc.p(584,454)
s_room_rebuyN           = "picdata/table/rebuyBtn.png"
s_room_rebuyS           = "picdata/table/rebuyBtn2.png"

s_room_freeGoldN           = "picdata/table/freeGold.png"
s_room_freeGoldS           = "picdata/table/freeGold.png"
--快速充值
s_room_quickRechagreN           = "picdata/table/quickRechagre.png"
s_room_quickRechagreS           = "picdata/table/quickRechagre2.png"

--happyHour
--s_room_happyHourN           = "picdata/db_button/btn_14_choujiang_up_android.png"
--s_room_happyHourS           = "picdata/db_button/btn_14_choujiang_down_android.png"
--s_room_happyHourShrink      = "picdata/db_icon/btn_12_shouchong_light_android.png"

--任务
s_room_tasksN           = "picdata/table/request.png"
s_room_tasksS           = "picdata/table/request2.png"
s_room_tasksBlinkN           = "picdata/table/request.png"
s_room_tasksBlinkS           = "picdata/table/request2.png"
s_room_tasksShrink      = "picdata/table/firstRechargeLight.png"

--帮助
--s_room_helpN            = "picdata/db_icon/btn_11_xinshou_up_android.png"
--s_room_helpS            = "picdata/db_icon/btn_11_xinshou_down_android.png"

--s_room_sngPK_sliderB		= "picdata/db_pure_frame/sta_23_jindu_blue_android.png"
--s_room_sngPK_sliderP		= "picdata/db_pure_frame/sta_23_jindu_red_android.png"
--s_room_sngPK_sliderT		= "picdata/db_pure_frame/sta_23_pk_android.png"

--Menubar
 ROOM_MENU_BAR_POS = cc.p(951,635)

--设置
ROOM_SETTING_BTN_POS   = cc.p(590,454)
--s_room_settingN         = "picdata/db_icon/btn_5_set_up_table_android.png"
--s_room_settingS         = "picdata/db_icon/btn_5_set_down_table_android.png"

--牌型比较
ROOM_TYPE_BTN_POS      = cc.p(35+15,120)
s_room_typeN            = "picdata/table/cardsType.png"
s_room_typeS            = "picdata/table/cardsType2.png"

--买入
ROOM_BUY_BTN_POS       = cc.p(750,454)
s_room_buyN             = "picdata/table/rebuyBtn.png"
s_room_buyS             = "picdata/table/rebuyBtn2.png"

--聊天
ROOM_CHAT_BTN_POS      = cc.p(895,35)
s_room_chatN            = "picdata/table/chat.png"
s_room_chatS            = "picdata/table/chat2.png"

--表情
ROOM_PIC_BTN_POS       = cc.p(815,35)
s_room_picN             = "picdata/table/face.png"
s_room_picS             = "picdata/table/face2.png"

--聊天和表情
ROOM_CHAT_PIC_BTN_POS       = cc.p(35+15,40)
s_room_chatAndPicN             = "picdata/table/icon_talk.png"
s_room_chatAndPicS             = "picdata/table/icon_talk2.png"

--重播 坐标用聊天坐标ROOM_CHAT_BTN_POS
s_room_replayN            = "picdata/table/replay.png"
s_room_replayS            = "picdata/table/replay1.png"
--分享按钮,坐标使用ROOM_MENU_BAR_POS
s_room_shareN            = "picdata/table/wechatShare.png"
s_room_shareS            = "picdata/table/wechatShare1.png"

--final table
s_final_table_image     = "picdata/table/fTableIcon.png"

s_first_recharge_normal = "picdata/table/firstRecharge.png"
s_first_recharge_select = "picdata/table/firstRecharge2.png"
s_first_recharge_get_normal = "picdata/table/firstRecharge.png"
s_first_recharge_get_select = "picdata/table/firstRecharge2.png"
s_first_recharge_blink = "picdata/table/firstRechargeLight.png"


--[[ 
* 沙发位置与usercell位置一直
* 以头像中心为锚点
 ]]
--2人桌坐标
SAFA_LOC_2_0 = cc.p(280,95)
SAFA_LOC_2_1 = cc.p(646,515)

--6人桌时候6个沙发的坐标
--91 / 2 = 45.5
--59 / 2 = 29.5
-- SAFA_LOC_6_0 = cc.p(746,515)
-- SAFA_LOC_6_1 = cc.p(936,367)
-- SAFA_LOC_6_2 = cc.p(450,120)
-- SAFA_LOC_6_3 = cc.p(146,117)
-- SAFA_LOC_6_4 = cc.p(80,367)
-- SAFA_LOC_6_5 = cc.p(280,515)

SAFA_LOC_6_0 = cc.p(450,100)
SAFA_LOC_6_1 = cc.p(146,117)
SAFA_LOC_6_2 = cc.p(80,337)
SAFA_LOC_6_3 = cc.p(280,515)
SAFA_LOC_6_4 = cc.p(746,515)
SAFA_LOC_6_5 = cc.p(936,337)
--9人桌时候9个沙发的坐标
SAFA_LOC_9_0 = cc.p(450,100)
SAFA_LOC_9_1 = cc.p(126,137)
SAFA_LOC_9_2 = cc.p(80,279)
SAFA_LOC_9_3 = cc.p(140,430)
SAFA_LOC_9_4 = cc.p(280,515)
SAFA_LOC_9_5 = cc.p(746,515)
SAFA_LOC_9_6 = cc.p(885,430)
SAFA_LOC_9_7 = cc.p(930,279)
SAFA_LOC_9_8 = cc.p(885,137)

-- SAFA_LOC_9_0 = cc.p(746,515)
-- SAFA_LOC_9_1 = cc.p(885,430)
-- SAFA_LOC_9_2 = cc.p(930,279)
-- SAFA_LOC_9_3 = cc.p(885,137)
-- SAFA_LOC_9_4 = cc.p(450,120)
-- SAFA_LOC_9_5 = cc.p(126,137)
-- SAFA_LOC_9_6 = cc.p(80,279)
-- SAFA_LOC_9_7 = cc.p(140,430)
-- SAFA_LOC_9_8 = cc.p(280,515)
--sngPK赛
SNG_SLIDER = cc.p(480, 640-458)



--奖池位置
ROOM_VIEW_POT_POS = cc.p(530,380)

--活动买入聊天等弹出的top提示
ALL_INFOHINT_POS = cc.p(194+438*0.5,480-60)

 SAFAMENUTAG = 123   --沙发tag起始值

--牌桌几个按钮tag值
ROOMVIEW_SETTINGBTN_TAG = 567
ROOMVIEW_BUYBTN_TAG     = 568
ROOMVIEW_TYPEBTN_TAG    = 569

function SAFALOC(seatNum,seatNo,_num,_NO) 
	if seatNum == _num and seatNo == _NO then
		return true
	end
end

function getSafaLocWith(seatNum,seatNo)
	if SAFALOC(seatNum,seatNo,2,0) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_2_0) end
	if SAFALOC(seatNum,seatNo,2,1) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_2_1) end
    
	if SAFALOC(seatNum,seatNo,6,0) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_6_0) end
	if SAFALOC(seatNum,seatNo,6,1) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_6_1) end
	if SAFALOC(seatNum,seatNo,6,2) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_6_2) end
	if SAFALOC(seatNum,seatNo,6,3) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_6_3) end
	if SAFALOC(seatNum,seatNo,6,4) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_6_4) end
	if SAFALOC(seatNum,seatNo,6,5) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_6_5) end
    
	if SAFALOC(seatNum,seatNo,9,0) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_0) end
	if SAFALOC(seatNum,seatNo,9,1) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_1) end
	if SAFALOC(seatNum,seatNo,9,2) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_2) end
	if SAFALOC(seatNum,seatNo,9,3) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_3) end
	if SAFALOC(seatNum,seatNo,9,4) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_4) end
	if SAFALOC(seatNum,seatNo,9,5) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_5) end
	if SAFALOC(seatNum,seatNo,9,6) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_6) end
	if SAFALOC(seatNum,seatNo,9,7) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_7) end
	if SAFALOC(seatNum,seatNo,9,8) then return cc.pAdd(LAYOUT_OFFSET, SAFA_LOC_9_8) end
    
	return cc.p(-1000,0)
end

--[[锚点：图片左上角]]
--6人桌时候6个庄家位的坐标
DEALER_LOC_2_0 = cc.p(346,228)
DEALER_LOC_2_1 = cc.p(547,435)

--6人桌时候6个庄家位的坐标
DEALER_LOC_6_0 = cc.p(390,225)
DEALER_LOC_6_1 = cc.p(190,175)
DEALER_LOC_6_2 = cc.p(120,320)
DEALER_LOC_6_3 = cc.p(320,455)
DEALER_LOC_6_4 = cc.p(666,455)
DEALER_LOC_6_5 = cc.p(820,320)
--9人桌时候9个庄家位的坐标
DEALER_LOC_9_0 = cc.p(390,225)
DEALER_LOC_9_1 = cc.p(176,175)
DEALER_LOC_9_2 = cc.p(135,254)
DEALER_LOC_9_3 = cc.p(190,415)
DEALER_LOC_9_4 = cc.p(320,455)
DEALER_LOC_9_5 = cc.p(666,455)
DEALER_LOC_9_6 = cc.p(790,415)
DEALER_LOC_9_7 = cc.p(835,254)
DEALER_LOC_9_8 = cc.p(790,175)

function DEALERLOC(seatNum,seatNo,_num,_NO) 
	if seatNum == _num and seatNo == _NO then
		return true
	end
end

function getDealerLocWith(seatNum,seatNo)
	if DEALERLOC(seatNum,seatNo,2,0) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_2_0) end
	if DEALERLOC(seatNum,seatNo,2,1) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_2_1) end
    
	if DEALERLOC(seatNum,seatNo,6,0) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_6_0) end
	if DEALERLOC(seatNum,seatNo,6,1) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_6_1) end
	if DEALERLOC(seatNum,seatNo,6,2) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_6_2) end
	if DEALERLOC(seatNum,seatNo,6,3) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_6_3) end
	if DEALERLOC(seatNum,seatNo,6,4) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_6_4) end
	if DEALERLOC(seatNum,seatNo,6,5) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_6_5) end
    
	if DEALERLOC(seatNum,seatNo,9,0) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_0) end
	if DEALERLOC(seatNum,seatNo,9,1) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_1) end
	if DEALERLOC(seatNum,seatNo,9,2) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_2) end
	if DEALERLOC(seatNum,seatNo,9,3) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_3) end
	if DEALERLOC(seatNum,seatNo,9,4) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_4) end
	if DEALERLOC(seatNum,seatNo,9,5) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_5) end
	if DEALERLOC(seatNum,seatNo,9,6) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_6) end
	if DEALERLOC(seatNum,seatNo,9,7) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_7) end
	if DEALERLOC(seatNum,seatNo,9,8) then return cc.pAdd(LAYOUT_OFFSET, DEALER_LOC_9_8) end
    
	return cc.p(-1000,0)
end

------------------------------------------------


