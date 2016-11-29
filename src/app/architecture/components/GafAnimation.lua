local GafAnimation = {}
function GafAnimation:loadAndPlayGAF(data)
    local asset = gaf.GAFAsset:create(data.gafFile)
    local animation = asset:createObject()
    data.parent:addChild(animation,data.zOrder or 0,data.tag or 0)
    animation:setPosition(data.pos or cc.p(0,0))
    animation:setAnchorPoint(cc.p(0.5,0.5))
    animation:setLooped(true, true)
    animation:start()
    return animation
end

function GafAnimation:loadAndPlayLoadingGAF(data)
	data.gafFile = "picdata/public/loading.gaf"
	return GafAnimation:loadAndPlayGAF(data)
end

return GafAnimation