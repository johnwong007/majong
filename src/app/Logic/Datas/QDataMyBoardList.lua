--
-- Author: junjie
-- Date: 2015-12-17 11:31:50
--
local QDataBase = require("app.Logic.Datas.QDataBase")
local QDataMyBoardList = class("QDataMyBoardList",QDataBase)
function QDataMyBoardList:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self      
    return o
end

function QDataMyBoardList:removeItemData(replay_fid)

     if not self._msg  then return nil end    
     for i,v in pairs(self._msg) do  
        if v[REPLAY_FID] == replay_fid then
          table.remove(self._msg,i)
        end
     end

end

--[[
  更新列表 名字 
]]
function QDataMyBoardList:updateMsgData(tableData,replay_fid)
    if not self._msg then return nil end   
    for p,q in pairs(self._msg) do 
        if v[REPLAY_FID] == replay_fid then
            v[REPLAY_NAME] = tableData  --
            break
        end
    end
    -- dump(self._msg)
end
return QDataMyBoardList