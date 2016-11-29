CELL_ACTION_DURATION           =0.2   --cell内容左右移动动画时间间隔
CELL_MOVE_ACTION_DURATION      =0.5   --cell座位移动动画时间间隔

CELL_NAMELABEL_CHANGE_DURATION =3.0   --玩家姓名变化时间间隔

s_pMenuNormal       = "picdata/table/playerBG.png"--其他玩家背景图
s_pMenuNormalSelf   = "picdata/table/playerBG.png"--登录玩家背景图
s_pMenuSelected     = "picdata/table/playerBG.png"--点击下的效果图

--牌型高亮
s_winCardBackgroundLeft = "picdata/table/win.png"
s_winCardBackgroundRight = "picdata/table/win.png"

--钻石登记
s_yellowDiamond     = "picdata/usercell/statusbar_12_yellow_zhuan_table_android.png"
s_redDiamond        = "picdata/usercell/statusbar_12_red_zhuan_table_android.png"
s_blueDiamond       = "picdata/usercell/statusbar_12_blue_zhuan_table_android.png"

s_pSpHeadPath       = "picdata/personFace/smhead"
s_pSpMan            = "picdata/personFace/smhead1.png"
s_pSpWoman          = "picdata/personFace/smhead5.png"

--other
s_pSpWaitBG_Green        = "picdata/table/timerGreen.png"
s_pSpWaitBG_Yellow        = "picdata/table/timerYellow.png"
s_pSpWaitBG_Red        = "picdata/table/timerRed.png"
s_pSpWaitBG2        = "picdata/table/timerBlack.png"

s_pSpSitAnim1       = "picdata/table/sitDownAni1.png"
s_pSpSitAnim2       = "picdata/table/sitDownAni2.png"

--s_pSngInfoBackgroundMine[] = "picdata/db_pure_frame/bg_8_liansheng_blue_android.png"
--s_pSngInfoBackgroundOther[] = "picdata/db_pure_frame/bg_8_liansheng_red_android.png"


C_UC_WIN_ANIMATE_POS = cc.p(0,0)    --胜利粒子效果坐标

C_WIN_TYPE_LEFT_POS = cc.p(75,0)--赢牌提示左边坐标
C_WIN_TYPE_RIGHT_POS = cc.p(75,0)--赢牌提示右边坐标

C_UC_NAME_LEFT_POS   = cc.p(80-5,13)    --图像在左时名称位置
C_UC_NAME_RIGHT_POS  = cc.p(80-5,13)   --图像在右时名称位置

C_UC_CHIP_LEFT_POS   = cc.p(80-5,-25)   --图像在左时筹码位置
C_UC_CHIP_RIGHT_POS  = cc.p(80-5,-25)  --图像在右时筹码位置

C_UC_PHOTO_LEFT_POS  = cc.p(0,-0.4) --图像在左侧时图像位置
C_UC_PHOTO_RIGHT_POS = cc.p(0,-0.4)  --图像在右侧时图像位置

C_UC_VIP_IS_SELF  = cc.p(-75,80) --图像在左侧时图像位置
C_UC_VIP_NOT_SELF = cc.p(-75,65)  --图像在右侧时图像位置

C_UC_SNG_INFO_LEFT_POS	=	cc.p(-32, -40)				--sng连胜排名
C_UC_SNG_INFO_RIGHT_POS	=	cc.p(32, -40)

--2人桌时候6个桌的坐标
CELL_LOC_2_0 = cc.p(280,140)
CELL_LOC_2_1 = cc.p(646,515)

--6人桌时候6个桌的坐标

CELL_LOC_6_0 = cc.p(450,120)
CELL_LOC_6_1 = cc.p(146,117)
CELL_LOC_6_2 = cc.p(80,337)
CELL_LOC_6_3 = cc.p(280,515)
CELL_LOC_6_4 = cc.p(746,515)
CELL_LOC_6_5 = cc.p(936,337)
-- CELL_LOC_6_0 = cc.p(280,156)
-- CELL_LOC_6_1 = cc.p(90,330)
-- CELL_LOC_6_2 = cc.p(220,510)
-- CELL_LOC_6_3 = cc.p(480,550)
-- CELL_LOC_6_4 = cc.p(755,510)
-- CELL_LOC_6_5 = cc.p(875,330)

--9人桌时候9个桌的坐标
-- CELL_LOC_9_0 = cc.p(280,156)
-- CELL_LOC_9_1 = cc.p(90,205)
-- CELL_LOC_9_2 = cc.p(100,375)
-- CELL_LOC_9_3 = cc.p(205,530)
-- CELL_LOC_9_4 = cc.p(390,550)
-- CELL_LOC_9_5 = cc.p(565,550)
-- CELL_LOC_9_6 = cc.p(745,530)
-- CELL_LOC_9_7 = cc.p(860,375)
-- CELL_LOC_9_8 = cc.p(870,205)
CELL_LOC_9_0 = cc.p(450,120)
CELL_LOC_9_1 = cc.p(126,137)
CELL_LOC_9_2 = cc.p(80,279)
CELL_LOC_9_3 = cc.p(140,430)
CELL_LOC_9_4 = cc.p(280,515)
CELL_LOC_9_5 = cc.p(746,515)
CELL_LOC_9_6 = cc.p(885,430)
CELL_LOC_9_7 = cc.p(930,279)
CELL_LOC_9_8 = cc.p(885,137)

function CELLLOC(seatNum,seatNo,_num,_NO) 
	if(seatNum == _num and seatNo == _NO) then
		return true
	end
end

function getCellLocWith(seatNum, seatNo)
	if CELLLOC(seatNum,seatNo,2,0) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_2_0) end
	if CELLLOC(seatNum,seatNo,2,1) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_2_1) end
    
	if CELLLOC(seatNum,seatNo,6,0) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_6_0) end
	if CELLLOC(seatNum,seatNo,6,1) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_6_1) end
	if CELLLOC(seatNum,seatNo,6,2) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_6_2) end
	if CELLLOC(seatNum,seatNo,6,3) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_6_3) end
	if CELLLOC(seatNum,seatNo,6,4) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_6_4) end
	if CELLLOC(seatNum,seatNo,6,5) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_6_5) end
    
	if CELLLOC(seatNum,seatNo,9,0) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_0) end
	if CELLLOC(seatNum,seatNo,9,1) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_1) end
	if CELLLOC(seatNum,seatNo,9,2) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_2) end
	if CELLLOC(seatNum,seatNo,9,3) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_3) end
	if CELLLOC(seatNum,seatNo,9,4) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_4) end
	if CELLLOC(seatNum,seatNo,9,5) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_5) end
	if CELLLOC(seatNum,seatNo,9,6) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_6) end
	if CELLLOC(seatNum,seatNo,9,7) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_7) end
	if CELLLOC(seatNum,seatNo,9,8) then return cc.pAdd(LAYOUT_OFFSET,CELL_LOC_9_8) end
    
	return cc.p(0,0)
end