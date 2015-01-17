-- 鱼鱼动画集合管理器
-- 负责加载和管理 所有的鱼鱼的动画结构

local FishesAnimateController = class("FishesAnimateController")
local FishAnimateUnit = import(".FishAnimateUnit")

FishesAnimateController.CannyFoodPath = "foods/FishFood_1920x1080"


function  FishesAnimateController:ctor()
    self.fishesMetaInfoData_    = {}
	self.fishesAnimateData_ 	= {}
	
end

function  FishesAnimateController:getFishInfoByMetaID(metaID)
	return  self.fishesMetaInfoData_[metaID]
end

function  FishesAnimateController:getFishAnimateUnitByMetaID(metaID) 
	assert(self.fishesAnimateData_[metaID],"getFishAnimateUnitByMetaID Error : %s",tostring(metaID))
	return self.fishesAnimateData_[metaID]
end

--根据本地存储数据预加载 鱼鱼的纹理数据信息
function  FishesAnimateController:preLoadAnimatesCacheFromLocal() 
end

function  FishesAnimateController:preLoadAnimatesCacheFromMetas(fishMetas)
	assert(type(fishMetas)=="table","LoadAnimatesCacheFromMetas Param Error!")
	local totalMetaCount = table.nums(fishMetas)
	for index,metaID in ipairs(fishMetas) do 
	 	 local iFishAnimateUnit = FishAnimateUnit.new(metaID)
		 self.fishesAnimateData_[metaID]=iFishAnimateUnit		
		 if iFishAnimateUnit:loadFishAnimates(false) then 	
	        self:updateLoadingEvent(index,totalMetaCount)
		 else 
			printInfo("load [%d] Fish Animate Faild !",metaID)
		 end 
	end 		
end

function FishesAnimateController:preLoadCannyFoodsFrames()
    cc.SpriteFrameCache:getInstance():addSpriteFrames(FishesAnimateController.CannyFoodPath..".plist",FishesAnimateController.CannyFoodPath..".png") 
end


function  FishesAnimateController:generateAnimateUnitByMetaID(metaID)
	 local iFishAnimateUnit = FishAnimateUnit.new(metaID)
	 self.fishesAnimateData_[metaID]=iFishAnimateUnit	
	 iFishAnimateUnit:loadFishAnimates()
end
 
function  FishesAnimateController:getAnimatesCacheCount()
	return table.nums(self.fishesAnimateData_)
end

--更新修复移除Animate 
function  FishesAnimateController:reUpdateUnValidAnimate()
	for metaID,animateItem in pairs(self.fishesAnimateData_) do 
		if not animateItem:getValidEnable() then 
			animateItem:reUpdateAnimateUnit(false)
		end
	end
end


function  FishesAnimateController:updateLoadingEvent(curProgressIndex,totalProgressCount) 
end

return FishesAnimateController











