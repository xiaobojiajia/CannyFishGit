--为鱼鱼而设计的动画管理器
--auchor: xiabo.wu
--date:  

local FishAnimateUnit = class("FishAnimateUnit")
  
--鱼鱼动画构造器
function FishAnimateUnit:ctor(fishMetaID)
	if self:initWithMetaID(fishMetaID) then 
	   return self
	end
	return nil
end
 
--根据鱼鱼的MetaID初始化鱼鱼动画管理器
function FishAnimateUnit:initWithMetaID(fishMetaID) 
end

--根据动画类型获取对应的鱼鱼游动动画
function FishAnimateUnit:getFishAnimateByType(animateType) 
	
end

--根据动画类型获取对应的鱼鱼黄冠游动动画
function FishAnimateUnit:getUtilAnimateByType(animateType)  
	
end

--加载鱼鱼动画数据
function FishAnimateUnit:loadFishAnimates(bLoadUtilsConfig)    
	
end

--获取当前鱼鱼是否存在扩展动画
function FishAnimateUnit:bExistExtAniamte() 

end

--获取当前鱼鱼是否存在皇冠动画
function FishAnimateUnit:bExistUtilAnimate() 
	
end
 

 
return FishAnimateUnit 