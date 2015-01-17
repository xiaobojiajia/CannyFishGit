--鱼食总管理器
local CannyFoodUnit       = require("app.fishbowl.CannyFoodUnit")
local FoodGroupController = class("FoodGroupController",function ()
	return display.newNode():setNodeEventEnabled(true)
end)  

--创建鱼鱼控制层 
function FoodGroupController:ctor() 	
	if self:initFoodGroupController() then 
	   return self
	end
	_G.FoodGroupController = nil
	FoodGroupController    = nil
	return nil
end

function FoodGroupController:initFoodGroupController()
	local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("301001.png")
	if  spriteFrame then
		--创建纹理集合
   	    self.foodsBatchLayer_	 = cc.SpriteBatchNode:createWithTexture(spriteFrame:getTexture())
		self:addChild(self.foodsBatchLayer_)
		self.bFeedState_   		 = EventType.UnKownFeedState
		self.activeFoodID_ 		 = nil 
		self.circleFoodsList_    = {}
		self.startGIDIndex_ 	 = math.random(100)
		self.curFoodIndex_       = self.startGIDIndex_
		return true
	end
	return false
end


function FoodGroupController:startFeedTouch(posX,posY)
end

function FoodGroupController:movedFeedTouch(posX,posY)
end

function FoodGroupController:endedFeedTouch(posX,posY)
end

function FoodGroupController:canncelFeedTouch()
end

function FoodGroupController:setFeedState(feedState)
    self.bFeedState_ = feedState
end

function FoodGroupController:getFeedState()
	return self.bFeedState_
end

--选中当前需要投食类型  
function FoodGroupController:selectFeedFoodID(foodID) 
	self.activeFoodID_ = foodID
end

--检测当前投食合法 自动递减食物，不足时候自动更换，所有都没有返回false
function FoodGroupController:checkSafeFood()  
   return self.activeFoodID_ ~= nil	
end 

function FoodGroupController:getFoodGID() 
   self.curFoodIndex_ = self.curFoodIndex_ + 1
   return self.curFoodIndex_
end

--对外接口 完成食物投递 操作
--param1 喂食坐标
function FoodGroupController:cannyFeeding(feedPos)  
    if self:checkSafeFood() then
   	   --首先分析循环队列中是否存在相同的ID	 
	    local cannyFoodItem = nil
	    local cricleTables = self.circleFoodsList_[self.activeFoodID_]
	    if cricleTables and next(cricleTables) then
	       cannyFoodItem = cricleTables[1]
	       table.remove(cricleTables,1)
	    else
	       cannyFoodItem = CannyFoodUnit.new(self.activeFoodID_)
	       self.foodsBatchLayer_:addChild(cannyFoodItem)
	    end   
	    cannyFoodItem:setFoodGID(self:getFoodGID())
	    cannyFoodItem:feedFoodHandler(feedPos)
	end
end 

--回收已经被吃掉或者丢失的食物
function FoodGroupController:circleCannyFood(cannyFood)
   assert(cannyFood,"circle canyfood nil!")
   local circleTabls = self.circleFoodsList_[cannyFood:getFoodMID()] or {}
   table.insert(circleTabls,cannyFood)
   self.circleFoodsList_[cannyFood:getFoodMID()] = circleTabls
end

function FoodGroupController:commonEventHandler(eventType,attachParam) 
   if EventType.FeedFootEvent == eventType then 
   	  --可以接收外部通知消息来喂食
   	  self:cannyFeeding(attachParam)
   elseif EventType.FeedFootLostEvent == eventType then 
   	  --食物丢失
   	  self:circleCannyFood(attachParam)
   elseif EventType.FeedFootEatEvent  == eventType then 
   	  --食物被吃掉了
   	  self:circleCannyFood(attachParam)
   end 
end

function FoodGroupController:getAllPostFeedCount()
	return self.curFoodIndex_ - self.startGIDIndex_
end
 
   
function FoodGroupController:onEnter()
	EventManager:addEvent({EventType.FeedFootEvent,EventType.FeedFootLostEvent,
		EventType.FeedFootEatEvent},self,self.commonEventHandler)
end

function FoodGroupController:onExit()
   EventManager:removeEventByTarget(self)
end
 
return FoodGroupController