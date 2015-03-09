
local FishBowlScene = class("FishBowlScene", function()
    return display.newScene("FishBowlScene")
end)
 
local TouchBowlController = require("app.fishbowl.TouchBowlController")
local FishGroupController = require("app.fishbowl.FishGroupController")

  
function FishBowlScene:ctor()
	self.mainBg_ = display.newSprite("bg/601004.jpg",display.cx,display.cy)
	-- self.mainBg_ = display.newSprite("bg/601015-hd.png",display.cx,display.cy) 
	self:addChild(self.mainBg_) 
	local fishAnimatesCache = GlobalMode:pushModeByFullName(EventType.FishAnimatesCache,"app.fishbowl.FishesAnimateController")
	fishAnimatesCache:preLoadAnimatesCacheFromMetas({101251,101917,101278,101279,101263,101253,101219,101222,101812,101818,101908})
	fishAnimatesCache:preLoadCannyFoodsFrames()


	self.fishGroupController_ = FishGroupController.new(self)
	self:addChild(self.fishGroupController_)
	self.fishGroupController_:initFishesMeta()
	self.touchBowlController_ = TouchBowlController.new(self)
	self:addChild(self.touchBowlController_)
 
end

function FishBowlScene:getFoodGroups()
	return self.touchBowlController_:getFoodGroups()
end


function FishBowlScene:onEnter()
end

function FishBowlScene:onExit()
end

return FishBowlScene
