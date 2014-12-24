require("app.config")
require("cocos.init")
require("framework.init")
require("app.utils.init")

local CannyFishApp = class("CannyFishApp", cc.mvc.AppBase)

function CannyFishApp:ctor()
    CannyFishApp.super.ctor(self)
    self:init()
end

function CannyFishApp:init()
    GlobalMode:init()
end

function CannyFishApp:run()
	--设定客户端的资源搜索路径
    cc.FileUtils:getInstance():addSearchPath("res/")
	--初始化随机种子(高精度)
	math.randomseed(tostring(os.time()):reverse():sub(1,6)) 
    self:enterScene("FishBowlScene")
end
 
function CannyFishApp:onEnterBackground()
	
    -- self:dispatchEvent({name = AppBase.APP_ENTER_BACKGROUND_EVENT})
end

function CannyFishApp:onEnterForeground()
    -- self:dispatchEvent({name = AppBase.APP_ENTER_FOREGROUND_EVENT})
end
 
function CannyFishApp:exit()
    cc.Director:getInstance():endToLua()
    if device.platform == "windows" or device.platform == "mac" then
        os.exit()
    end
end
 
return CannyFishApp
