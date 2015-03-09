-- 鱼缸触摸控制器
local FoodGroupController = require("app.fishbowl.FoodGroupController") 
local TouchBowlController = class("TouchBowlController",function ()
  return display.newLayer():setNodeEventEnabled(true)
end)

TouchBowlController.UIZOrders={feedView=1}
TouchBowlController.UITags={feedView=1}


function TouchBowlController:ctor(bowlRootView)  
  --鱼鱼总视图
 	self.bowlRootView_ = bowlRootView   
 	self.feedGroup_    = FoodGroupController.new()
  assert(self.feedGroup_)
  self:addChild(self.feedGroup_,TouchBowlController.UIZOrders.feedView,TouchBowlController.UITags.feedView)
  self:setTouchEnabled(true)
  self.cutTouchState_ = EventType.IdleTouchState
  self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self,self.touchEventCall))
  self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE) 
  self:setTouchSwallowEnabled(true)  
end

-- self:setTouchSwallowEnabled(true) 
function TouchBowlController:touchEventCall(event)
  local eventName,x,y = event.name,event.x,event.y
  if eventName == "began" then  
     self:dispatchTouchEvent(EventType.TouchBegin,x,y) 
     return true
  elseif eventName == "moved" then 
     self:dispatchTouchEvent(EventType.TouchMoved,x,y) 
  elseif eventName == "ended" then 
     self:dispatchTouchEvent(EventType.TouchEnded,x,y) 
  elseif eventName == "cancelled" then  
     self:dispatchTouchEvent(EventType.TouchCancel,x,y) 
  end
end

 
function TouchBowlController:dispatchTouchEvent(touchType,posx,posy)
   if EventType.TouchBegin == touchType then 
      self.feedGroup_:startFeedTouch(posx,posy)
   elseif EventType.TouchMoved == touchType then 
      self.feedGroup_:movedFeedTouch(posx,posy)
   elseif EventType.TouchEnded == touchType then    
      self.feedGroup_:endedFeedTouch(posx,posy) 
   elseif EventType.TouchCancel == touchType then 
      self.feedGroup_:canncelFeedTouch(posx,posy)
   end 
end



function TouchBowlController:getTouchState()
	 return self.cutTouchState_ 
end

function TouchBowlController:setTouchState(touchState)
	 self.cutTouchState_ = touchState
end


--获取鱼食组
function TouchBowlController:getFoodGroups()
   return self.feedGroup_
end

function TouchBowlController:onEnter()
end

function TouchBowlController:onExit()
end


return  TouchBowlController



