--为鱼鱼所设计的鱼食模型
--auchor: xiaobo.wu
--date: 2014.12.17

--301001 301002 301003 301004 301005 301006 301010 301011 301012 301013  301014 301015 301016
--Buffer Buff301012  Buff301013  Buff301014 Buff301015 Buff301016
--Feed   Feed302001  Feed302002  ...

local CannyFoodUnit = class("CannyFoodUnit",function ()
	  return cc.Sprite:create():setNodeEventEnabled(true)
end)

function CannyFoodUnit:ctor(foodMetaID)
   if self:initCannyFoodByMetaID(foodMetaID) then   	 
   	  return self
   end
   CannyFoodUnit = nil 
   return nil
end

function CannyFoodUnit:initCannyFoodByMetaID(foodMetaID)
	self.foodMetaID_ =  foodMetaID
  self.foodGID_    =  0
	self.bValid_	   =  false
	--检测当前缓存是否存在此MetaID的鱼食 
	local inerSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("Feed"..foodMetaID..".png")
	if inerSpriteFrame then
	   self:setSpriteFrame(inerSpriteFrame) 
	   self.bValid_	= false
     self:setScale(0.8) 
	   return true
	end 
	return false
end

function CannyFoodUnit:setFoodGID(foodGID)
   self.foodGID_    =  foodGID
end 

function CannyFoodUnit:setFoodMID(foodMetaID) 
   local inerSpriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("Feed"..foodMetaID..".png")
   if inerSpriteFrame then
      self.foodMetaID_ = foodMetaID
      self:setSpriteFrame(inerSpriteFrame)
      return true
   end 
   return false 
end

--获取鱼鱼食物的GID
function CannyFoodUnit:getFoodGID()
  return self.foodGID_
end

--获取鱼鱼的MID
function CannyFoodUnit:getFoodMID()
  return self.foodMetaID_
end

--获取鱼鱼食当前的状态 检测是否可以回收利用
function CannyFoodUnit:getFoodValid()
	return self.bValid_
end
  
--执行投射逻辑
function CannyFoodUnit:feedFoodHandler(startPos)
    self.bValid_ = true
	  self:setVisible(true)
    self:stopAllActions()
    self:setOpacity(255)  
    self:setPosition(startPos) 
    local function dropEventHandler(eventID) 
       local fadeOutAction = cc.FadeOut:create(2)
       self:runAction(fadeOutAction)
    end 
    self.dropSpeed_    =   40
    local endYPos      =   50
    local triggerYPos  =   140
    local dropDuration =  (self:getPositionY()-endYPos) / self.dropSpeed_
    local dropTimerAction  =  TimerMoveTo:createTimerMoveTo(dropDuration,cc.p(self:getPositionX(),endYPos),cc.p(self:getPositionX(),triggerYPos))
    dropTimerAction:setActionEventID(self.foodMetaID_)
    dropTimerAction:setScriptEventHandler(dropEventHandler) 
    local function moveEndEventHandler()
       self.bValid_	 =  false
       self:stopAllActions()
       self:setVisible(false)
       EventManager:pushEvent(EventType.FeedFootLostEvent,self) 
    end
    local moveCallAction =  cc.CallFunc:create(moveEndEventHandler) 
    local sequnceAction  =  cc.Sequence:create(dropTimerAction,moveCallAction)
    self:runAction(sequnceAction)
    --分发喂食事件通知
    EventManager:pushEvent(EventType.FeedFootEvent,self) 
end

return CannyFoodUnit
















