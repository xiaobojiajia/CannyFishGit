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
	--�趨�ͻ��˵���Դ����·��
    cc.FileUtils:getInstance():addSearchPath("res/")
	--��ʼ���������(�߾���)
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
