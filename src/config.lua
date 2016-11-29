
G_RELEASE = true

if not G_RELEASE then
	DEBUG = 2
	DEBUG_FPS = true
	DEBUG_MEM = false
else
	-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
	DEBUG = 0

	-- display FPS stats on screen
	DEBUG_FPS = false

	-- dump memory info every 10 seconds
	DEBUG_MEM = false
end

-- load deprecated API
LOAD_DEPRECATED_API = false

LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

-- design resolution
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 640

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
--CONFIG_SCREEN_AUTOSCALE = "SHOW_ALL"
-- CONFIG_SCREEN_AUTOSCALE_CALLBACK = function(w, h)
--     if w/h < 960/640 then
--         CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
--     end
-- end
