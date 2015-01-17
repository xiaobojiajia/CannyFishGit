-- 鱼缸触摸控制器
local TouchBowlController = class("TouchBowlController",function ()
	return display.newLayer():setNodeEventEnabled(true)
end)

function TouchBowlController:ctor(bowlRootView)  
 	self.bowlRootView_ = bowlRootView
 	self.feedGroup_ = self.bowlView_
   	self:setTouchEnabled(true)
   	self.cutTouchState_ = EventType.IdleTouchState
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self,self.touchEventCall))
    self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)  
end

-- self:setTouchSwallowEnabled(true) 
function TouchBowlController:touchEventCall(event)
  local eventName,x,y = event.name,event.x,event.y
  if eventName == "began" then  
	 self.feedGroup_:startFeedTouch(x,y)
     return true
  elseif eventName == "moved" then 
	 self.feedGroup_:movedFeedTouch(x,y)
  elseif eventName == "ended" then 
	 self.feedGroup_:endedFeedTouch(x,y)
  elseif eventName == "cancelled" then 
	 self.feedGroup_:canncelFeedTouch(x,y)
  end
end




function TouchBowlController:getTouchState()
	return self.cutTouchState_ 
end

function TouchBowlController:setTouchState(touchState)
	self.cutTouchState_ = touchState
end


function TouchBowlController:onEnter()
end

function TouchBowlController:onExit()
end






