--
-- Author: junjie
-- Date: 2016-01-26 10:14:36
--
--添加事件监听
--[[
	layer:
	layerID:回调Id
]]
local QManagerListener = {}
QManagerListener.LayerTab = {}
--注册接收回调的layer和消息ID
function QManagerListener:Attach(recMsg)
	-- dump(recMsg)
	if type(recMsg) ~= "table" then return end
	for i=1,#recMsg do 		
		local layerID = recMsg[i].layerID
	    if self.LayerTab[layerID] then 
	    	--print("Has Exist ".. layerID .." LayerTab in layerID!")
	        self:Detach(layerID)
	    end
        if type(layerID) == "number" and layerID < 65536 then       	    		    	
        	table.insert(self.LayerTab,layerID,recMsg[i].layer) 
        else
           	self.LayerTab[layerID] = recMsg[i].layer
        end 
	end
	-- dump(self.LayerTab)    
end
--注销回调的消息ID
function QManagerListener:Detach(layerID)
	-- dump("QManagerListener:Detach")
	if type(layerID) == "table" then
		for i,v in pairs(layerID) do 
			if self.LayerTab[v] then
				self.LayerTab[v] = nil
			end
		end
	else
		self.LayerTab[layerID] = nil		
	end
	-- dump(self.LayerTab)	
end
--消息通知
function QManagerListener:Notify(data)
	-- dump(self.LayerTab,#self.LayerTab)
	for i,v in pairs(self.LayerTab) do
		if i and i == data.layerID then
			if v.updateCallBack then
				v:updateCallBack(data)
			end
		end
	end		
end
function QManagerListener:clearAllLayerID()
	self.LayerTab = {}
end
return QManagerListener