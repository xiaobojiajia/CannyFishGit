
local FishBowlScene = class("FishBowlScene", function()
    return display.newScene("FishBowlScene")
end)

local CannyFishUnit = require("app.fishbowl.CannyFishUnit")
  
function FishBowlScene:ctor()
--[[    cc.ui.UILabel.new({
            UILabelType = 2, text = "Canny Fish", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)--]]
  
		self.mainBg_ = display.newSprite("bg/601016-hd.png",display.cx,display.cy)
		self:addChild(self.mainBg_) 
		-- local fishAnimatesCache = GlobalMode:pushModeByFullName(EventType.FishAnimatesCache,"app.fishbowl.FishesAnimateController")
		-- fishAnimatesCache:preLoadAnimatesCacheFromMetas({101244,101253})
		-- local testFish = CannyFishUnit.new(1,101244)
		-- self:addChild(testFish)
		-- testFish:autoSwimmingLogic() 
end

function FishBowlScene:onEnter()
end

function FishBowlScene:onExit()
end

return FishBowlScene
