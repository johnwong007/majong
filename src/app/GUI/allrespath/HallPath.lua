local HallPath = {}

HallPath["BACKGROUND_22_EMPTY_ANDROID"] = "picdata/hall/background_22_empty_android.png"
HallPath["BG_3_ONE"]                    = "picdata/hall/bg_3_one.png"
HallPath["BG_3_ONE1"]                   = "picdata/hall/bg_3_one1.png"
HallPath["BG_3_ONE2"]                   = "picdata/hall/bg_3_one2.png"
HallPath["BG_3_ONE3"]                   = "picdata/hall/bg_3_one3.png"
HallPath["BG_SRK"]                      = "picdata/hall/bg_srk.png"
HallPath["BLIND"]                       = "picdata/hall/blind.png"
HallPath["BOTTOMBARBG"]                 = "picdata/hall/bottomBarBG.png"
HallPath["BTN_LIST_ADD"]                = "picdata/hall/btn_list_add.png"
HallPath["BTN_LIST_ADD2"]               = "picdata/hall/btn_list_add2.png"
HallPath["BTN_RJ"]                      = "picdata/hall/btn_rj.png"
HallPath["BTN_RJ2"]                     = "picdata/hall/btn_rj2.png"
HallPath["BUYNUM"]                      = "picdata/hall/buyNum.png"
HallPath["CELLSELECT"]                  = "picdata/hall/cellSelect.png"
HallPath["CELLSELECT1"]                 = "picdata/hall/cellSelect1.png"
HallPath["CELLSELECT2"]                 = "picdata/hall/cellSelect2.png"
HallPath["CELLSELECT3"]                 = "picdata/hall/cellSelect3.png"
HallPath["CHUJIBTN"]                    = "picdata/hall/chujiBtn.png"
HallPath["CHUJIBTN1"]                   = "picdata/hall/chujiBtn1.png"
HallPath["CHUJIICON"]                   = "picdata/hall/chujiIcon.png"
HallPath["CLICKBTNBG"]                  = "picdata/hall/clickBtnBG.png"
HallPath["CREATEROOM"]                  = "picdata/hall/createRoom.png"
HallPath["CREATEROOM1"]                 = "picdata/hall/createRoom1.png"
HallPath["DOWNARROW"]                   = "picdata/hall/downArrow.png"
HallPath["ENTERPWBG"]                   = "picdata/hall/enterPWBG.png"
HallPath["ENTERROOM"]                   = "picdata/hall/enterRoom.png"
HallPath["GAOJIBTN"]                    = "picdata/hall/gaojiBtn.png"
HallPath["GAOJIBTN1"]                   = "picdata/hall/gaojiBtn1.png"
HallPath["GAOJIICON"]                   = "picdata/hall/gaojiIcon.png"
HallPath["HALLMENUBG"]                  = "picdata/hall/hallMenuBG.png"
HallPath["HALLTABLEBG"]                 = "picdata/hall/hallTableBG.png"
HallPath["HIDDENLAYERBG"]               = "picdata/hall/hiddenLayerBG.png"
HallPath["ICON_LOCK"]                   = "picdata/hall/icon_lock.png"
HallPath["ICON_PLAYER"]                 = "picdata/hall/icon_player.png"
HallPath["ICON_SNG"]                    = "picdata/hall/icon_sng.png"
HallPath["JIFENBTN"]                    = "picdata/hall/jifenBtn.png"
HallPath["JIFENBTN1"]                   = "picdata/hall/jifenBtn1.png"
HallPath["JIFENICON"]                   = "picdata/hall/jifenIcon.png"
HallPath["PLAYNUM"]                     = "picdata/hall/playNum.png"
HallPath["QUICKSTART"]                  = "picdata/hall/quickStart.png"
HallPath["QUICKSTART1"]                 = "picdata/hall/quickStart1.png"
HallPath["SETBTN"]                      = "picdata/hall/setBtn.png"
HallPath["SETBTN2"]                     = "picdata/hall/setBtn2.png"
HallPath["SIRENBTN"]                    = "picdata/hall/sirenBtn.png"
HallPath["SIRENBTN1"]                   = "picdata/hall/sirenBtn1.png"
HallPath["STA_3_DOT_NON_ANDROID"]       = "picdata/hall/sta_3_dot_non_android.png"
HallPath["STA_3_DOT_ON_ANDROID"]        = "picdata/hall/sta_3_dot_on_android.png"
HallPath["STA_3_LOCK_ANDROID"]          = "picdata/hall/sta_3_lock_android.png"
HallPath["STA_3_TABLE_ANDROID"]         = "picdata/hall/sta_3_table_android.png"
HallPath["STATUSBAR_28_TIPS_EMPTY_ANDROID"]= "picdata/hall/statusbar_28_tips_empty_android.png"
    local imageUtils = require("app.Tools.ImageUtils")
    local tmpFilename = imageUtils:getImageFileName("picdata/hall/tableBG.png")
HallPath["TABLEBG"]                     = tmpFilename
HallPath["TABLEHEADERBG"]               = "picdata/hall/tableHeaderBG.png"
HallPath["TABLENAME"]                   = "picdata/hall/tableName.png"
HallPath["UPARROW"]                     = "picdata/hall/upArrow.png"
HallPath["ZHONGJIBTN"]                  = "picdata/hall/zhongjiBtn.png"
HallPath["ZHONGJIBTN1"]                 = "picdata/hall/zhongjiBtn1.png"
HallPath["ZHONGJIICON"]                 = "picdata/hall/zhongjiIcon.png"

return HallPath