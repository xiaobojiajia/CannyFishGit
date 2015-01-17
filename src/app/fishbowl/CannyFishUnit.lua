--设计鱼鱼模型结构
 
local CannyFishUnit = class("CannyFishUnit",function()
	return display.newNode():setNodeEventEnabled(true)
end)
 
CannyFishUnit.Min_Random_Line_Distance  = display.width/4
CannyFishUnit.Min_Random_Skew_Distance  = display.width/4
CannyFishUnit.Min_Random_Fast_Distance  = display.width/3
CannyFishUnit.Min_Random_Scare_Distance = display.width/7


CannyFishUnit.Node_Tags	  = {   Animate_Normal	=1,
								Animate_Turn	=2,
								Animate_Eat		=3,
								Animate_Ext		=4,
								Fish_Gem		=5,
								Fish_Mind		=6,
								Fish_Talk		=7  }

CannyFishUnit.Node_ZOrder = {   Animate_Tmp		=1,
							    Fish_Gem		=2,
							    Fish_Mind		=3,
							    Fish_Talk		=4  }


function CannyFishUnit:ctor(fishUID,fishMetaID,fishState)
	if self:initCannyFishUnit(fishUID,fishMetaID,fishState) then
	   return self
	end
	return nil
end

function CannyFishUnit:init()
	self:setAnchorPoint(EventType.DefaultAnchor)
	self.nFishUID_ 				=  0								--
	self.nFishMetaID_ 			=  0
	self.nFishState_ 			=  0
	self.nCurAnimateType_ 	    =  EventType.UnKown_Animate_Type
	self.nCurSwimState_			=  EventType.NormalSwimState
	self.bFlipX_ 				=  false
	self.bCanRotation_ 			=  false
	self.bExistExtAction_ 		=  false  
	self.textureSize_ 			=  cc.size(0,0)
	self.safeRextBound_ 		=  cc.rect(0, 0, 0, 0)
    self.pAnimateSpriteGroup_   =  {}
	self.pAnimateUnit_ 			=  nil       						--动画控制单元
	self.pAnimationEffect_      =  nil  							--当前播放动画
	self.piAnimateSprite_       =  nil
	self.bRunning_              =  false 							--当前鱼鱼是否在休眠
	self.bLastTurn_ 			=  false 							--当前鱼鱼上次只能动作是否为转身
	
	self.bSwimUp_ 				=  false
	self.bSwimDown_ 			=  false  
end

function CannyFishUnit:initCannyFishUnit(fishUID,fishMetaID,fishState) 
	assert(fishUID and fishMetaID,"initCannyFishUnit Error!" )
	self:init() 
	self.nFishUID_     = fishUID
	self.nFishMetaID_  = fishMetaID
	self.nFishState_   = fishState 
	self.pAnimateUnit_ = GlobalMode:getModeByName(EventType.FishAnimatesCache):getFishAnimateUnitByMetaID(self.nFishMetaID_)
	assert(self.pAnimateUnit_,"AnimateUnit Error: %s",tostring(self.nFishMetaID_))
	self.pAnimateSpriteGroup_[EventType.Normal_Animate_Type] = cc.Sprite:create()
	self.pAnimateSpriteGroup_[EventType.Eat_Animate_Type] 	 = cc.Sprite:create()
	self.pAnimateSpriteGroup_[EventType.Turn_Animate_Type] 	 = cc.Sprite:create() 
	self.bRunning_     = true 
	self.bLastTurn_    = false 
	self:addChild(self.pAnimateSpriteGroup_[EventType.Normal_Animate_Type],CannyFishUnit.Node_ZOrder.Animate_Tmp,CannyFishUnit.Node_Tags.Animate_Normal)
	self:addChild(self.pAnimateSpriteGroup_[EventType.Eat_Animate_Type],CannyFishUnit.Node_ZOrder.Animate_Tmp,CannyFishUnit.Node_Tags.Animate_Turn)
	self:addChild(self.pAnimateSpriteGroup_[EventType.Turn_Animate_Type],CannyFishUnit.Node_ZOrder.Animate_Tmp,CannyFishUnit.Node_Tags.Animate_Eat)
	--默认执行普通游动动作
	self:playAnimate(EventType.Normal_Animate_Type,true) 	
	self.textureSize_ = self.pAnimateSpriteGroup_[EventType.Normal_Animate_Type]:getContentSize()
	-- printInfo("FishInfo texture width : %f heigh: %f",self.textureSize_.width,self.textureSize_.height)            
	self.safeRextBound_ =  {}
	-- cc.rect(self.textureSize_.width/2,self.textureSize_.height/2,display.width-self.textureSize_.width/2,display.height-self.textureSize_.height/2) 
    self.safeRextBound_.getMaxX = function () 
		return display.width-self.textureSize_.width/2
	end 
	self.safeRextBound_.getMinX = function () 
		return self.textureSize_.width/2
	end 
	self.safeRextBound_.getMinY = function () 
		return self.textureSize_.height/2
	end  
	self.safeRextBound_.getMaxY = function () 
		return display.height-self.textureSize_.height/2
	end   
 
	--注册触摸事件通知 
    uifunction.bindBtnEventHandler(self,self,self.touchFishHandler)

    self:onRandInit()
    return true
end


function CannyFishUnit:touchFishHandler(sender,attachParam)
	printInfo("CannyFish Touch Event : %s ",tostring(self.nFishUID_))   
	self:stopAllActions() 
	self:scareSwimEventHandler()  
end 

--执行鱼鱼逃走动画
function CannyFishUnit:scareSwimEventHandler()
   --切回正常游动类型
   --分析当前是否需要转身 
   if EventType.ScareSwimState ~= self.nCurSwimState_ then
	  self.nCurSwimState_ = EventType.ScareSwimState 
	  if self:checkScareTurnEnable() then 
	      --准备转身
	      self:playAnimate(EventType.Turn_Animate_Type,false)   
	  else
	   	  --直接快速撤离 水平 斜线加速动作 
	   	  self:scareSwimAwayHandler() 
	  end    
   end
end



function CannyFishUnit:scareSwimAwayHandler()   
	self:onNoramlFreeSwimming()
	self.nCurSwimState_ = EventType.NormalSwimState  
end


--检测分析是否需要加速转身
function CannyFishUnit:checkScareTurnEnable()
    return self:getFaceToSafeBoundXDist() < CannyFishUnit.Min_Random_Scare_Distance  
end


--若本地无上次记录，那么随机生成初始位置 和方向 
function CannyFishUnit:onRandInit()
	local initRandomPoint = cc.p(utils.RandomFloat(self.safeRextBound_:getMaxX(), self.safeRextBound_:getMinX()), utils.RandomFloat(self.safeRextBound_:getMaxY(), self.safeRextBound_:getMinY()))
	self:setPosition(initRandomPoint)
	self.bFlipX_ = math.random(1000) < 500
	self.pAnimateSpriteGroup_[self.nCurAnimateType_]:setFlippedX(self.bFlipX_)
end

--获取鱼鱼距离当前方向安全区X轴距离
function CannyFishUnit:getFaceToSafeBoundXDist() 
	return   math.abs( (self.bFlipX_ and (self:getPositionX()- self.safeRextBound_:getMinX())) or (self.safeRextBound_:getMaxX()-self:getPositionX()) )
end

--获取鱼鱼距离当前方向安全区Y轴距离
function CannyFishUnit:getFaceToSafeBoundYDist(bMoveUp)
	return   math.abs( (bMoveUp and (self.safeRextBound_:getMaxY() - self:getPositionY())) or (self:getPositionY() - self.safeRextBound_:getMinY()) )
end
 
 
--检测当前是否强制转身
function CannyFishUnit:onCheckNeedForceTurn()
	return  self:getFaceToSafeBoundXDist() <= self.textureSize_.width
end

--检测当前可以游动的斜线方向
function CannyFishUnit:onCheckSkewEnable()
	--产生一个随机倾斜角度
	self.bSwimUp_     =  false
	self.bSwimDown_   =  false
	if  self.textureSize_.height <= (self.safeRextBound_:getMaxY()-self:getPositionY()) then 
		self.bSwimUp_   =  true
	end
	if  self.textureSize_.height <= (self:getPositionY()-self.safeRextBound_:getMinX()) then 
		self.bSwimDown_ =  true 
	end
	return  self.bSwimUp_ or self.bSwimDown_ 
end
 

--自动游动逻辑
function CannyFishUnit:autoSwimmingLogic()
	if self.bRunning_ then 
	   --检测当前是否必须转身
	   if self:onCheckNeedForceTurn() then 
		  self:playAnimate(EventType.Turn_Animate_Type,false)
	   else 
		  local randTurnSwtich = math.random(1000) 
		  if randTurnSwtich < 1000 then 
			 self:onNoramlFreeSwimming()
		  elseif self.bLastTurn_ then 
		    if not self:onVariableFreeSwimming() then 
		       -- printInfo("-------------------- onNoramlFreeSwimming")
			   self:onNoramlFreeSwimming()
			end 
		  else 
		  	if math.random(1000) < 500 then 
			   self:playAnimate(EventType.Turn_Animate_Type,false)
			else
			   self:autoSwimmingLogic()
			end
		  end 
	   end
	end
end



--默认匀速自由游动逻辑 Default
function CannyFishUnit:onNoramlFreeSwimming()
	self.bLastTurn_ 			=  false 
	if math.random(1000) < 1000 then 
		self:onLineRouteUniformSwimming()
	else
		self:onSkewRouteUniformSwimming()
	end
end


--变速自由游动逻辑
function CannyFishUnit:onVariableFreeSwimming()
	self.bLastTurn_ 			=  false  
	-- printInfo("onVariableFreeSwimming -----------")
	if math.random(1000) < 500 then 
	   return self:onFastLineRoteSwimming()
	else 
	   return self:onFastSkewRoteSwimming()
	end
end



--移动结束回调通知事件
function CannyFishUnit:moveCompleteEventHandler()
	self:autoSwimmingLogic()
end


--直线匀速游动逻辑
function CannyFishUnit:onLineRouteUniformSwimming()
	--检测当前的旋转角度是否为 0   
	local randDistance  = utils.RandomFloat(self:getFaceToSafeBoundXDist(),CannyFishUnit.Min_Random_Line_Distance)
	local totalDuration = randDistance / utils.RandomFloat(40.0, 30.0)
	local randomValue   = math.random(1000)
	if EventType.ScareSwimState == self.nCurSwimState_ then
	   totalDuration    = totalDuration / 2
	   randomValue		= 1000
	end
	-- printInfo("safeDis: %f",self:getFaceToSafeBoundXDist())              
	-- printInfo("line Rand Distance : %f",randDistance)
	-- printInfo("line Rand Duration : %f",totalDuration) 
	if 0.01 < self:getRotation()  then  
	   local  pRotateToAction = cc.RotateTo:create(0.316*totalDuration,0)
	   self:runAction(pRotateToAction)
	end       
	local targetPos = cc.p(self:getPositionX() + randDistance*((self.bFlipX_ and -1.0) or 1.0),self:getPositionY())  
	local pMoveToAction = cc.MoveTo:create(totalDuration,targetPos)
	if  randomValue < 100 then 
	   self.pAnimationEffect_:setSpeedScale(1.1)
	   -- pMoveToAction = cc.EaseSineOut:create(pMoveToAction) 
	   pMoveToAction = AutoEaseAction:create(pMoveToAction)  
	elseif randomValue < 300 then  
	   self.pAnimationEffect_:setSpeedScale(1.4)
	   -- pMoveToAction = cc.EaseExponentialOut:create(pMoveToAction)  
	   -- pMoveToAction = cc.AutoEaseAction:create(pMoveToAction) 
	   pMoveToAction = AutoEaseAction:create(pMoveToAction)  
	elseif randomValue < 1000 then  
	   -- pMoveToAction = cc.EaseSineOut:create(pMoveToAction) 
	   pMoveToAction = AutoEaseAction:create(pMoveToAction)  
	else
	   self.pAnimationEffect_:setSpeedScale(1.8)
	   -- pMoveToAction = cc.EaseExponentialOut:create(pMoveToAction)  
	   pMoveToAction = AutoEaseAction:create(pMoveToAction)  
	end  

	local function callFuncHandler(attachParam) 
		if self.pAnimationEffect_ then 
	   	   self.pAnimationEffect_:setSpeedScale(1.0)
		end
		self:moveCompleteEventHandler()
	end
	pMoveToAction:registerActionScriptEvent(callFuncHandler,1)  
	-- local pActionEvent    = cc.CallFunc:create(callFuncHandler)  
	-- local pSequenceAction = cc.Sequence:create(pMoveToAction, pActionEvent) 
	-- self:runAction(pSequenceAction) 
	-- local scaleAction = cc.ScaleTo:create(0.616*totalDuration,0.4)
	self:runAction(pMoveToAction) 
end
 


--斜线匀速游动逻辑
function CannyFishUnit:onSkewRouteUniformSwimming()
	if self:onCheckSkewEnable() then 
	   --在此随机判断上下
	   local randRotation = utils.RandomFloat(30,0)
	   if self.bSwimUp_ and self.bSwimDown_ then 
		  if math.random(1000) < 500 then 
		     self:onSkewDownUniformSwimming(randRotation)
		  else 
			 self:onSkewUpUniformSwimming(randRotation)
		  end 
	   elseif self.bSwimUp_ then  
		 self:onSkewUpUniformSwimming(randRotation)
	   elseif self.bSwimDown_ then  
	     self:onSkewDownUniformSwimming(randRotation)
	   end
	end
end 
	
	
--执行向上斜线游动
function CannyFishUnit:onSkewUpUniformSwimming(upRotation)
	local tanRate = math.tan(math.rad(upRotation)) 
	local cosRate = math.cos(math.rad(upRotation))
	local maxXDistance = math.min(math.abs((self.safeRextBound_:getMaxY() - self:getPositionY()) / tanRate),self:getFaceToSafeBoundXDist())
	local randXDistance = utils.RandomFloat(maxXDistance,CannyFishUnit.Min_Random_Skew_Distance)
	local totalDuration = randXDistance/cosRate/utils.RandomFloat(40,25)
	local randomValue = math.random(1000)
	if EventType.ScareSwimState == self.nCurSwimState_ then
	   totalDuration    = totalDuration / 2
	   randomValue		= 1000
	end 
	-- printInfo("onSkewUpUniformSwimming : upRotation: %f", upRotation)               
	-- printInfo("onSkewUpUniformSwimming : randXDistance : %f", randXDistance)
	-- printInfo("onSkewUpUniformSwimming : totalDuration: %f", totalDuration)
	local rotateAction = cc.RotateTo:create(0.228*totalDuration, 0.618*upRotation*((self.bFlipX_ and 1.0) or -1.0))
	local targetPos = cc.p(self:getPositionX()+randXDistance*((self.bFlipX_ and -1) or 1),self:getPositionY()+randXDistance*tanRate)
	local moveAction = cc.MoveTo:create(totalDuration,targetPos)
	if  randomValue < 100 then 
	   self.pAnimationEffect_:setSpeedScale(1.2)
	   moveAction = cc.EaseSineOut:create(moveAction)
	elseif randomValue < 300 then  
	   self.pAnimationEffect_:setSpeedScale(1.4)
	   moveAction = cc.EaseExponentialOut:create(moveAction) 
	elseif randomValue < 1000 then
	else
	   self.pAnimationEffect_:setSpeedScale(1.8)
	   moveAction = cc.EaseExponentialOut:create(moveAction) 
 	end  
	local function moveEndHandler()
		self.pAnimationEffect_:setSpeedScale(1)
		self:moveCompleteEventHandler()
	end
	local endCallFunc = cc.CallFunc:create(moveEndHandler)
	local sequenceActions = cc.Sequence:create(moveAction,endCallFunc)
	self:runAction(rotateAction)
	self:runAction(sequenceActions)
end

--执行向下斜线游动
function CannyFishUnit:onSkewDownUniformSwimming(downRotation)
   	local tanRate = math.tan(math.rad(downRotation)) 
	local cosRate = math.cos(math.rad(downRotation))
	local maxXDistance = math.min(math.abs((self:getPositionY()-self.safeRextBound_:getMinY())/tanRate),self:getFaceToSafeBoundXDist())
	local randXDistance = utils.RandomFloat(maxXDistance,CannyFishUnit.Min_Random_Skew_Distance)
	local totalDuration = randXDistance/cosRate/utils.RandomFloat(40,25)
	local randomValue = math.random(1000)
	if EventType.ScareSwimState == self.nCurSwimState_ then
	   totalDuration    = totalDuration / 2
	   randomValue		= 1000
	end
	-- printInfo("onSkewDownUniformSwimming : downRotation: %f", downRotation)
	-- printInfo("onSkewDownUniformSwimming : totalDuration: %f", totalDuration)
	-- printInfo("onSkewDownUniformSwimming : randXDistance : %f", randXDistance) 
	local rotateAction = cc.RotateTo:create(0.328*totalDuration, 0.618*downRotation*((self.bFlipX_ and -1.0) or 1.0))
	local targetPos   = cc.p(self:getPositionX()+randXDistance*((self.bFlipX_ and -1) or 1),self:getPositionY()-randXDistance*tanRate)
	local moveAction  = cc.MoveTo:create(totalDuration,targetPos)
	if  randomValue < 100 then 
	   self.pAnimationEffect_:setSpeedScale(1.15)
	   moveAction = cc.EaseSineOut:create(moveAction)
	elseif randomValue < 300 then  
	   self.pAnimationEffect_:setSpeedScale(1.4)
	   moveAction = cc.EaseExponentialOut:create(moveAction) 
	elseif randomValue < 1000 then 
	else 
	   self.pAnimationEffect_:setSpeedScale(1.8)
	   moveAction = cc.EaseExponentialOut:create(moveAction) 
	end   
	local function moveEndHandler()
		self.pAnimationEffect_:setSpeedScale(1) 
		self:moveCompleteEventHandler()
	end
	local endCallFunc = cc.CallFunc:create(moveEndHandler)
	local sequenceActions = cc.Sequence:create(moveAction,endCallFunc)
	self:runAction(rotateAction)
	self:runAction(sequenceActions)
end


 
--检测当前是否可以执行加速游动
--param1 加速旋转角度
--param2 上下方向加速
function CannyFishUnit:checkCanRunFastSwimming(rotation,bMoveUp)
    local swimtFastEnable = false
	if rotation < 0.01 then 
		swimtFastEnable = math.max(self.textureSize_.height,self.textureSize_.width) < self:getFaceToSafeBoundXDist()
	else
	    local xMaxDistance = self:getFaceToSafeBoundXDist()
		local yMaxDistance = self:getFaceToSafeBoundYDist(bMoveUp) / math.tan(math.rad(rotation))
	    swimtFastEnable = CannyFishUnit.Min_Random_Fast_Distance <= math.min(xMaxDistance,yMaxDistance) * math.cos(math.rad(rotation))
	end
	return swimtFastEnable
end


--执行鱼鱼加速游动逻辑
--return 是否可以执行横向加速
function CannyFishUnit:onFastLineRoteSwimming()
	if self:checkCanRunFastSwimming(0,false) then
	   self:innerFastSwimingLogic(0,false)
 	   return true
	end
	return false
end

--执行鱼鱼斜线加速游动逻辑
--return 是否可以执行纵向加速
function CannyFishUnit:onFastSkewRoteSwimming()
    local  randRotation = utils.RandomFloat(50,5) 
	local  randResult   = math.random(1000) < 500
	if self:checkCanRunFastSwimming(randRotation,not randResult) then 
		self:innerFastSwimingLogic(randRotation,not randResult)
		return true
	elseif  self:checkCanRunFastSwimming(randRotation,randResult) then
		self:innerFastSwimingLogic(randRotation,randResult)
		return true
	end 
	return false
end



--内部实现的直线加速游动逻辑
function CannyFishUnit:innerFastSwimingLogic(rotation,bMoveUp)
	--首先随机距离
	local maxDistance = 0
	if rotation < 0.001 then  
	   maxDistance  = self:getFaceToSafeBoundXDist()
	else
	   local xMaxDistance = self:getFaceToSafeBoundXDist()
	   local yMaxDistance = self:getFaceToSafeBoundYDist(bMoveUp)  
	   maxDistance = math.min(yMaxDistance/math.sin(math.rad(rotation)),
	   	xMaxDistance/math.cos(math.rad(rotation)))
	end 
	local randomInitSpeed = 0
	local randomEndSpeed  = utils.RandomFloat(35,30)
	local randomDistance  = 0
	if CannyFishUnit.Min_Random_Fast_Distance < maxDistance then 
		randomDistance = utils.RandomFloat(maxDistance,CannyFishUnit.Min_Random_Fast_Distance)
	else  
		randomDistance = maxDistance
	end 
	randomInitSpeed = utils.RandomFloat(3*randomDistance-randomEndSpeed, 2*randomDistance-randomEndSpeed)
	randomInitSpeed = math.min(randomInitSpeed,utils.RandomFloat(230,80))
	--计算减速下的时间
	local reduceSpeedDuration  = 2 * 0.72 * randomDistance / (randomInitSpeed + randomEndSpeed)
	local uniformSpeedDuration = 0.28 * randomDistance / randomEndSpeed
	local pVariableSpeedAction = VariableSpeedMoveAction:createVariableSpeedMoveAction(self.bFlipX_,bMoveUp,rotation,randomInitSpeed,randomEndSpeed,
		(reduceSpeedDuration+uniformSpeedDuration),uniformSpeedDuration,self.pAnimationEffect_,reduceSpeedDuration,3.2,0.85)
	-- printInfo("innerFastLineRoteLogic real Distance : %f",randomDistance)
	-- printInfo("innerFastLineRoteLogic real reduceDur: %f",reduceSpeedDuration)
	-- printInfo("innerFastLineRoteLogic real uniforDur: %f",uniformSpeedDuration) 
	-- printInfo("innerFastLineRoteLogic real Duration : %f",(reduceSpeedDuration+uniformSpeedDuration))

	local function moveEndHandler()
		self:moveCompleteEventHandler()
	end
	local moveEndCall = cc.CallFunc:create(moveEndHandler)
	local sequenceAction = cc.Sequence:create(pVariableSpeedAction,moveEndCall)
	self:runAction(sequenceAction) 	 	
end
 
 
--公共单次游动动画结束事件
function CannyFishUnit:commonSingleAnimateEvent(animationID,animationType) 
   self.piAnimateSprite_:stopAllActions() 
   self:playAnimate(EventType.Normal_Animate_Type,true)
   if EventType.ScareSwimState == self.nCurSwimState_ then
   	  self:scareSwimAwayHandler()
   else
      self:autoSwimmingLogic()	
   end 
end
 

--播放鱼鱼指定动作
--param1: 动画类型  可见 EventType 枚举
--param2: 是否循环
function CannyFishUnit:playAnimate(animateType,bLoop)  
	if animateType == EventType.Turn_Animate_Type then 
	   self.bLastTurn_ 			=  true 
	end
	local bLoopEnable = false 
	if self.piAnimateSprite_ then 
	   self.piAnimateSprite_:stopAllActions()
	end
    for iAnimateType,iAnimateSprite in pairs(self.pAnimateSpriteGroup_) do 
		if iAnimateType == animateType then 
		   iAnimateSprite:setVisible(true)	
		   iAnimateSprite:setFlippedX(self.bFlipX_)
		   iAnimateSprite:stopAllActions()
		   if iAnimateType == EventType.Turn_Animate_Type then 
		   	  self.bFlipX_ = not self.bFlipX_
		   end
		   --播放指定动画
		   bLoopEnable = bLoop or (iAnimateType == EventType.Normal_Animate_Type) 
		   self.nCurAnimateType_  = iAnimateType
		   -- printInfo("Animate Type:  %d",tostring(iAnimateType))
		   assert(self.pAnimateUnit_,"pAnimateUnit_ nil faild!")
		   assert(self.pAnimateUnit_:getFishAnimateByType(iAnimateType),"pAnimateUnit_ getAnimateByType Faild!")
		   self.pAnimationEffect_ = AnimationEffect:create(iAnimateType,self.pAnimateUnit_:getFishAnimateByType(iAnimateType),bLoopEnable) 		  
		   assert(self.pAnimationEffect_,"AnimationEffect:create Failde!")

		   if not bLoopEnable then 
		   	  local function singleAnimate(animationID,animationType) 
 				  self:commonSingleAnimateEvent(animationID,animationType)
		   	  end
		   	  if EventType.ScareSwimState == self.nCurSwimState_ then 
		   	  	 self.pAnimationEffect_:setSpeedScale(1.8)
		   	  end
		   	  self.pAnimationEffect_:registerAnimationScriptEvent(singleAnimate)
		   end
		   self.piAnimateSprite_ = iAnimateSprite
		   iAnimateSprite:runAction(self.pAnimationEffect_)
		else  
		   iAnimateSprite:setVisible(false)
		end 
	end
end

 
 
function CannyFishUnit:onEnter() 
end

function CannyFishUnit:onExit()
end 

return  CannyFishUnit






