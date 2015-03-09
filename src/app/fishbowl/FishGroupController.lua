--鱼群管理器
local CannyFishUnit = require("app.fishbowl.CannyFishUnit") 
local FishGroupController = class("FishGroupController",function ()
   return display.newLayer():setNodeEventEnabled(true)
 end)
 
function  FishGroupController:ctor(fishBowlView)
	self.fishBowlViewRoot_ =  fishBowlView
	self.fishGroups_	   = {}
end


function FishGroupController:initFishesMeta()
	-- local fishBowlMeta= {101917,101278,101279,101251,101263,101253,101219,101222,101812,101818,101908}
	local fishBowlMeta= {101251} 
	for index,fishMetaID in pairs(fishBowlMeta) do 
		local fishItem = CannyFishUnit.new(index,fishMetaID)
		table.insert(self.fishGroups_,fishItem)
		self:addChild(fishItem)
		fishItem:autoSwimmingLogic() 
	end 
end
 

function  FishGroupController:dropInFish() 
end

function  FishGroupController:commonFishesEvent(eventType)
end
 
function  FishGroupController:commonEventHandler(eventName,param1,param2)
	if eventName == EventType.FeedFootEvent then 
	   --通知小鱼鱼,食物来了
	   for _,fishItem in pairs(self.fishGroups_) do 
	      fishItem:feedByFood(param1)
	   end 
	elseif eventName == EventType.FeedFootEatEvent then 
	   --通知食物被吃掉
	   for _,fishItem in pairs(self.fishGroups_) do 
	   	  if fishItem == param1 then 
	   	  	 --吃掉食物后的逻辑 分析当前是否需要继续觅食

	   	  else 
	   	  	 --检测是否正在追逐相同食物
	   	  	if fishItem:checkFollwFoodID(param2) then 
	   	  	   --放弃当前的追逐 食物被其他鱼鱼吃掉了
	   	  	   fishItem:cancelToFollowFood(true)
	   	  	   
	   	  	   -- self.fishBowlViewRoot_:getFoodGroups()
	   	  	   
	   	  	end
	   	  end
	   end
	end
end

function FishGroupController:feedCannyFish(cannyFish)
	assert(cannyFish,"FeedCannyFish")
	if cannyFish:checkBNeedFoods() then 
	   --分析当前所有鱼食,距离当前鱼鱼最短者最佳

	end
end


--获取当前鱼缸中所有鱼食

 
function  FishGroupController:onEnter()
	EventManager:addEvent(EventType.FeedFootEvent,self,self.commonEventHandler)
end

function  FishGroupController:onExit()
	EventManager:removeEventByTarget(self)
end

return FishGroupController