--设计鱼鱼模型结构
 
local CannyFishUnit = class("CannyFishUnit",function()
	return display.newNode():setNodeEventEnabled(true)
end)
 
CannyFishUnit.Min_Random_Line_Distance = display.width/6
CannyFishUnit.Min_Random_Skew_Distance = display.width/7
CannyFishUnit.Min_Random_Fast_Distance = display.width/4


function CannyFishUnit:ctor(fishUID,fishMetaID,fishState)
	if self:initCannyFishUnit(fishUID,fishMetaID,fishState) then
	   return self
	end
	return nil
end

function CannyFishUnit:init()
	self.nFishUID_ 				=  0								--
	self.nFishMetaID_ 			=  0
	self.nFishState_ 			=  0
	self.nActionType_ 			=  0
	self.bFlipX_ 				=  false
	self.bCanRotation_ 			=  false
	self.bExistExtAction_ 		=  false 
	self.bLastTurn_ 			=  false 
	self.textureSize_ 			=  CCSizeMake(0,0)
	self.safeRextBound_ 		=  CCRectMake(0, 0, 0, 0)
	self.pNormalActionSprite_ 	=  nil
	self.pTurnActionSprite_ 	=  nil 
	self.pEatActionSprite_ 		=  nil 
	self.pAnimateHandler_ 		=  nil 
end

function CannyFishUnit:initCannyFishUnit(fishUID,fishMetaID,fishState) 
	self:setAnchorPoint(EventType.DefaultAnchor)
	self.nFishUID_    = fishUID
	self.nFishMetaID_ = fishMetaID
	self.nFishState_  = fishState
  
end
 
function CannyFishUnit:onEnter()

end

function  CannyFishUnit:onExit()
end
 


return  CannyFishUnit






