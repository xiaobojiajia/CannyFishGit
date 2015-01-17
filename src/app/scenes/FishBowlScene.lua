
local FishBowlScene = class("FishBowlScene", function()
    return display.newScene("FishBowlScene")
end)

local CannyFishUnit = require("app.fishbowl.CannyFishUnit") 
local FoodGroupController = require("app.fishbowl.FoodGroupController")

  
function FishBowlScene:ctor()
		self.mainBg_ = display.newSprite("bg/601004.jpg",display.cx,display.cy)
		-- self.mainBg_ = display.newSprite("bg/601015-hd.png",display.cx,display.cy) 
		self:addChild(self.mainBg_) 
		local fishAnimatesCache = GlobalMode:pushModeByFullName(EventType.FishAnimatesCache,"app.fishbowl.FishesAnimateController")
		fishAnimatesCache:preLoadAnimatesCacheFromMetas({101917,101278,101279,101263,101253,101219,101222,101812,101818,101908})
		fishAnimatesCache:preLoadCannyFoodsFrames()
		for index=1,50 do 
			local fishItem = CannyFishUnit.new(index,101279)
			self:addChild(fishItem)
			fishItem:autoSwimmingLogic() 
		end 
		-- local foodUnit = CannyFoodUnit.new(302001)
		-- self:addChild(foodUnit)
		-- foodUnit:feedFoodHandler(cc.p(display.cx,display.height))

		-- local iGroupController = FoodGroupController.new()
		-- self:addChild(iGroupController)
		-- iGroupController:selectFeedFoodID(302001)
		-- iGroupController:cannyFeeding(cc.p(display.cx,display.height))

		-- local metasList = {101278,101917,101279,101917,101917,101917,101917,101917,101917,101917,101917,101917,
		-- 101917,101263,101253,101219,101222,101812,101818,101908}
		-- for _,metaID in pairs(metasList) do 
		-- 	local fishItem = CannyFishUnit.new(1,metaID)
		-- 	self:addChild(fishItem)
		-- 	fishItem:autoSwimmingLogic()
		-- end 
end

function FishBowlScene:onEnter()
end

function FishBowlScene:onExit()
end

return FishBowlScene
