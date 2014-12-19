--设计鱼鱼模型结构
 
local CannyFishUnit = class("CannyFishUnit",function()
	return display.newNode():setNodeEventEnabled(true)
end)
 
CannyFishUnit.Min_Random_Line_Distance = display.width/6
CannyFishUnit.Min_Random_Skew_Distance = display.width/7
CannyFishUnit.Min_Random_Fast_Distance = display.width/4

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
	self.nCurAnimateType_ 	    =  0
	self.bFlipX_ 				=  false
	self.bCanRotation_ 			=  false
	self.bExistExtAction_ 		=  false 

	self.textureSize_ 			=  CCSizeMake(0,0)
	self.safeRextBound_ 		=  CCRectMake(0, 0, 0, 0)
    self.pAnimateSpriteGroup_   =  {}
	self.pAnimateUnit_ 			=  nil       						--动画控制单元
	self.pAnimationEffect_      =  nil  							--当前播放动画
	self.bRunning_              =  false 							--当前鱼鱼是否在休眠
	self.bLastTurn_ 			=  false 							--当前鱼鱼上次只能动作是否为转身
	
	self.bSwimUp_ 				=  false
	self.bSwimDown_ 			=  false 
end

function CannyFishUnit:initCannyFishUnit(fishUID,fishMetaID,fishState) 
	assert(fishUID and fishMetaID,"initCannyFishUnit Error!" )
	self:init() 
	self.nFishUID_    = fishUID
	self.nFishMetaID_ = fishMetaID
	self.nFishState_  = fishState 
	self.pAnimateSpriteGroup_[EventType.Normal_Animate_Type] = display.newSprite()
	self.pAnimateSpriteGroup_[EventType.Eat_Animate_Type] 	 = display.newSprite()
	self.pAnimateSpriteGroup_[EventType.Turn_Animate_Type] 	 = display.newSprite() 
	self.bRunning_     = true 
	self.bLastTurn_    = false 
	self.pAnimateUnit_ = FishesAnimateManager:getAnimateUnitByMetaID(self.nFishMetaID_)
	self:addChild(self.pAnimateSpriteGroup_[EventType.Normal_Animate_Type],CannyFishUnit.Node_ZOrder.Animate_Tmp,CannyFishUnit.Node_Tags.Animate_Normal)
	self:addChild(self.pAnimateSpriteGroup_[EventType.Eat_Animate_Type],CannyFishUnit.Node_ZOrder.Animate_Tmp,CannyFishUnit.Node_Tags.Animate_Turn)
	self:addChild(self.pAnimateSpriteGroup_[EventType.Turn_Animate_Type],CannyFishUnit.Node_ZOrder.Animate_Tmp,CannyFishUnit.Node_Tags.Animate_Eat)
	--默认执行普通游动动作
	self:playAnimate(EventType.Normal_Animate_Type,true) 	
	self.textureSize_ = self.pAnimateSpriteGroup_[EventType.Normal_Animate_Type]:getContentSize()
	self.safeRextBound_ = CCSizeMake(self.textureSize_.width/2,self.textureSize_.height/2,display.width-self.textureSize_.width,display.height-self.textureSize_.height)

end

--若本地无上次记录，那么随机生成初始位置 和方向 
function CannyFishUnit:onRandInit()
	local initRandomPoint = ccp(RandomFloat(m_safeRectBound:getMaxX(), m_safeRectBound:getMinX()), RandomFloat(m_safeRectBound:getMaxY(), m_safeRectBound:getMinY()))
	self:setPosition(initRandomPoint);
	m_bFlipX = math.random(1000) < 500;
	self.pAnimateSpriteGroup_[self.nCurAnimateType_]:setFlipX(m_bFlipX)
end

--获取鱼鱼距离当前方向安全区X轴距离
function CannyFishUnit:getFaceToSafeBoundXDist()
	return   math.abs( (self.bFlipX_ and self:getPostionX()- self.safeRextBound_:getMinX()) or (self.safeRextBound_:getMaxX()-self:getPostionX()) )
end

--获取鱼鱼距离当前方向安全区Y轴距离
function CannyFishUnit:getFaceToSafeBoundYDist(bMoveUp)
	return   math.abs( (bMoveUp and self.safeRextBound_:getMaxY() - self:getPostionY()) or (self:getPostionY() - self.safeRextBound_:getMinY()) )
end
 
 
--检测当前是否强制转身
function CannyFishUnit:onCheckNeedForceTurn()
	return  self:getFaceToSafeBoundXDist() <= self.textureSize_.width
end

--检测当前可以游动的斜线方向
function CannyFishUnit:onCheckSkewEnable()
	--产生一个随机倾斜角度
	if  m_textureSize.height <= (self.safeRextBound_:getMaxY()-self:getPostionY()) then 
		self.bSwimUp_   =  true
	end
	if  m_textureSize.height <= (self:getPostionY()-self.safeRextBound_:getMinX()) then 
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
		  if randTurnSwtich < 800 then 
			 self:onNoramlFreeSwimming()
		  elseif self.bLastTurn_ then 
		    if not self:onVariableFreeSwimming() then 
			   self:onNoramlFreeSwimming()
			end 
		  else 
			 self:playAnimate(EventType.Turn_Animate_Type,false)
		  end 
	   end
	end
end



--默认匀速自由游动逻辑 Default
function CannyFishUnit:onNoramlFreeSwimming()
	if math.random(1000) < 350 then 
		self:onLineRouteUniformSwimming()
	else
		self:onSkewRouteUniformSwimming()
	end
end


--变速自由游动逻辑
function CannyFishUnit:onVariableFreeSwimming()
	if math.random(1000) < 300 then 
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
	local randDistance = utils.RandomFloat(self:getFaceToSafeBoundXDist(),CannyFishUnit.Min_Random_Line_Distance)
	local totalDuration = randDistance / RandomFloat(40.0, 20.0)
	printInfo("line Rand Distance : %f",randDistance)
	printInfo("line Rand Duration : %f",totalDuration) 
	if 0.01 < self:getRotation()  then  
		local  pRotateToAction = RotateTo:create(0.382f*totalDuration,0)
		self:runAction(pRotateToAction)
	end 
	local targetPos = ccp(self:getPostionX() + randDistance*((m_bFlipX and -1.0) or 1.0),self:getPostionY()  
	local pMoveToAction   = MoveTo::create(totalDuration, targetPos);
	local function callFuncHandler()
		self:moveCompleteEventHandler()
	end
	local pActionEvent    = CallFunc::create(callFuncHandler)
	local pSequenceAction = Sequence::createWithTwoActions(pMoveToAction, pActionEvent);
	self:runAction(pSequenceAction) 
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
	local tanRate = math.tan(math.rad(upRotation) 
	local cosRate = math.cos(math.rad(upRotation)
	local maxXDistance = math.min(math.abs((m_safeRectBound:getMaxY() - self:getPositionY()) / tanRate),self:getFaceToSafeBoundXDist())
	local randXDistance = utils.RandomFloat(maxXDistance,CannyFishUnit.Min_Random_Skew_Distance)
	local totalDuration = randDistance/cosRate/utils.RandomFloat(40,25)
	printInfo("onSkewUpUniformSwimming : randDistance : %f", randXDistance)
	printInfo("onSkewUpUniformSwimming : totalDuration: %f", totalDuration)
	local rotateAction = RotateTo:create(0.228f*totalDuration, 0.618f*upRotation*((m_bFlipX and 1.0) or -1.0))
	local targetPos = ccp(self:getPostionX()+randXDistance*((m_bFlipX and -1) or 1),self:getPositionY()+randXDistance*tanRate)
	local moveAction = MoveTo:create(totalDuration,targetPos)
	local function moveEndHandler()
		self:moveCompleteEventHandler()
	end
	local endCallFunc = CallFunc:create(moveEndHandler)
	local sequenceActions = Sequence:createWithTwoActions(moveAction,endCallFunc)
	self:runAction(rotateAction)
	self:runAction(sequenceActions)
end

--执行向下斜线游动
function CannyFishUnit:onSkewDownUniformSwimming(downRotation)
   	local tanRate = math.tan(math.rad(upRotation) 
	local cosRate = math.cos(math.rad(upRotation)
	local maxXDistance = math.min(math.abs((self:getPositionY-m_safeRectBound:getMinY())/tanRate),self:getFaceToSafeBoundXDist())
	local randXDistance = utils.RandomFloat(maxXDistance,CannyFishUnit.Min_Random_Skew_Distance)
	local totalDuration = randXDistance/cosRate/utils.RandomFloat(40,25)
	printInfo("onSkewDownUniformSwimming : randDistance : %f", randXDistance)
	printInfo("onSkewDownUniformSwimming : totalDuration: %f", totalDuration)
	local rotateAction = RotateTo:create(0.328f*totalDuration, 0.618f*upRotation*((m_bFlipX and -1.0) or 1.0))
	local targetPos = ccp(self:getPostionX()+randXDistance*((m_bFlipX and -1) or 1),self:getPositionY()-randXDistance*tanRate)
	local moveAction = MoveTo:create(totalDuration,targetPos)
	local function moveEndHandler()
		self:moveCompleteEventHandler()
	end
	local endCallFunc = CallFunc:create(moveEndHandler)
	local sequenceActions = Sequence:createWithTwoActions(moveAction,endCallFunc)
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
	    swimtFastEnable = CannyFishUnit.Min_Random_Fast_Distance <= math.min(xMaxDistance, yDistanceToXMax) * math.cos(math.rad(rotation))
	end
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
	elseif  self:checkCanRunFastSwimming(randRotation,randResult)
		self:innerFastSwimingLogic(randRotation,randResult)
		return true
	end 
	return false
end



--内部实现的直线加速游动逻辑
function CannyFishUnit:innerFastSwimingLogic(rotation,bMoveUp)
	--首先随机距离
	local xMaxDistance = self:getFaceToSafeBoundXDist()
	local yMaxDistance = self:getFaceToSafeBoundYDist(bMoveUp) 
	local maxDistance  = math.min(xMaxDistance,yMaxDistance)*math.cos(math.rad(rotation))
	local randomInitSpeed = 0
	local randomEndSpeed  = utils.RandomFloat(40,30)
	local randomDistance  = 0
	if CannyFishUnit.Min_Random_Fast_Distance < maxDistance then 
		randomDistance = utils.RandomFloat(maxDistance,CannyFishUnit.Min_Random_Fast_Distance)
	else  
		randomDistance = maxDistance
	end 
	printInfo("innerFastLineRoteLogic real Distance : %f",randomDistance)
	randomInitSpeed = utils.RandomFloat(3*randomDistance-randomEndSpeed, 2*randomDistance-randomEndSpeed)
	randomInitSpeed = math.min(randomInitSpeed,utils.RandomFloat(200,80))
	--计算减速下的时间
	local reduceSpeedDuration  = 2 * 0.72 * randomDistance / (randomInitSpeed + randomEndSpeed)
	local uniformSpeedDuration = 0.28 * randomDistance / randomEndSpeed
	local pVariableSpeedAction = VariableSpeedMoveAction:createVariableSpeedMoveAction(self.bFlipX_,bMoveUp,rotation,randomInitSpeed,randomEndSpeed,
		(reduceSpeedDuration+uniformSpeedDuration),uniformSpeedDuration,self.pAnimationEffect_,reduceSpeedDuration,3.5,0.8)
	local function moveEndHandler()
		self:moveCompleteEventHandler()
	end
	local moveEndCall = CallFunc:create(moveEndHandler)
	local sequenceAction = Sequence:createWithTwoActions(pVariableSpeedAction,moveEndCall)
	self:runAction(sequenceAction) 	 	
end
 



--播放鱼鱼指定动作
--param1: 动画类型  可见 EventType 枚举
--param2: 是否循环
function CannyFishUnit:playAnimate(animateType,bLoop) 
	self.bLastTurn_ 			=  false 
	if animateType == EventType.Turn_Animate_Type then 
	   self.bLastTurn_ 			=  true 
	end
	local bLoopEnable = false 
    for iAnimateType,iAnimateSprite in pairs(self.pAnimateSpriteGroup_) do 
		if iAnimateType == animateType then 
		   iAnimateSprite:setVisible(true)	
		   iAnimateSprite:setFlipX(self.bFlipX_)
		   iAnimateSprite:stopAllActions()
		   --播放指定动画
		   bLoopEnable = bLoop or (iAnimateType == EventType.Normal_Animate_Type) 
		   self.nCurAnimateType_  = iAnimateType
		   self.pAnimationEffect_ = AnimationEffect:create(iAnimateType,self.pAnimateUnit_[iAnimateType],bLoopEnable)
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






