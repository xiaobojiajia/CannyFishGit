--为鱼鱼而设计的动画管理器
--auchor: xiabo.wu
--date: 2014-12-09

local FishAnimateUnit = class("FishAnimateUnit")

--鱼鱼动画模板
FishAnimateUnit.Fish_PlistName_Template	   =  {"%d_normal_Big_Normal_%d.png",	
											   "%d_normal_Big_Eat_%d.png",
											   "%d_normal_Big_Turn_%d.png",
											   "%d_normal_Big_Ext_%d.png",
											   "%d_normal_Big_Ext_%d.png"} 
--皇冠动画模板									
FishAnimateUnit.Util_PlistName_Template    =  {"%d_ulti_Ulti_Eat_%d.png",
											   "%d_ulti_Ulti_Eat_%d.png",
											   "%d_ulti_Ulti_Turn_%d.png",
											   "%d_ulti_Ulti_Ext_%d.png",
											   "%d_ulti_Ulti_Ext_%d.png"}  
			
--鱼鱼动画KeyCache模板						
FishAnimateUnit.Fish_AnimateName_Template  =  {"%d_Fish_Big_Normal",
											   "%d_Fish_Big_Eat",
											   "%d_Fish_Big_Turn",
											   "%d_Fish_Big_Ext"}
  
--鱼鱼皇冠KeyCache模板		
FishAnimateUnit.Util_AnimateName_Template  =  {"%d_Ulti_Normal",
											   "%d_Ulti_Eat",
										       "%d_Ulti_Turn",
										       "%d_Ulti_Ext"}		
									
--鱼鱼动画文件的相对路径
FishAnimateUnit.Fish_PlistPath="fishes/%d_normal_1920x1080"
FishAnimateUnit.Util_PlistPath="fishes/%d_ulti_1920x1080"

FishAnimateUnit.Default_Fish_MetaID        =  101238


--目前的设计为直接读取动画到AnimateCache中，后续加入FishMetaData 来配置

--鱼鱼动画构造器
function FishAnimateUnit:ctor(fishMetaID)
	if self:initWithMetaID(fishMetaID) then 
	   return self
	end
	return nil
end
  

--根据鱼鱼的MetaID初始化鱼鱼动画管理器
-- 1.Meta配置中有无此MetaID,若没有才是默认MetaID 填补,
-- 2.若默认替补MetaID无法找到，那么直接返回false

function FishAnimateUnit:initWithMetaID(fishMetaID) 
	assert(fishMetaID,"FishAnimateUnit Meta ID  Error!")
    self.nFishMetaID_	    	= fishMetaID			--鱼鱼的配置ID
	self.nPreFishMetaID_        = fishMetaID   		    --备用的鱼鱼配置ID
	self.tFishAnimateGroup_ 	= {}				    --鱼鱼的游动动画组
	self.tUtilAnimateGroup_ 	= {}					--鱼鱼的皇冠动画组
	self.bExsitExtAnimate_  	= false  				--是否存在扩展动画
	self.bExsitUtilAnimate_ 	= false                 --是否存在皇冠动画配置
	self.bExsitFishAnimate_     = false 				--是否存在鱼鱼动画配置 
	self.bValid_				= true					--当前鱼鱼配置是否合法  
	return self:checkMetaValid()
end
 

--获取当前动画器是否合法
function FishAnimateUnit:getValidEnable()
	return self.bValid_
end

--重新刷新当前动画管理器
function FishAnimateUnit:reUpdateAnimateUnit(bLoadUtil)
   self.nFishMetaID_ = self.nPreFishMetaID_
   self:checkMetaValid()
   self:loadFishAnimates(bLoadUtil)
end

--加载鱼鱼动画数据 
--param: 是否需要立即加载皇冠动画
function FishAnimateUnit:loadFishAnimates(bLoadUtilsConfig) 
	--首先校验当前的鱼鱼MetaID是否合法 
	self.tFishAnimateGroup_ 	= {}				    --鱼鱼的游动动画组
	self.tUtilAnimateGroup_ 	= {}					--鱼鱼的皇冠动画组
    for typeIndex=1,EventType.Animate_Type_Count do
		self.tFishAnimateGroup_[typeIndex] = self:innerLoadFishAnimatesByType(typeIndex)
		if bLoadUtilsConfig then 
		   self.tUtilAnimateGroup_[typeIndex] = self:innerLoadUtilAnimateByType(typeIndex)
		end
	end
	return 0 < table.nums(self.tFishAnimateGroup_)
end
 

--检测当前鱼鱼的Meta配置文件是否正确
function FishAnimateUnit:checkMetaValid()
    local fishPlistPath = string.format(FishAnimateUnit.Fish_PlistPath,self.nFishMetaID_)
    self.bExsitFishAnimate_ = utils:CheckFileExist(fishPlistPath..".plist")
    local UtilPlistPath = string.format(FishAnimateUnit.Util_PlistPath,self.nFishMetaID_)
	self.bExsitUtilAnimate_ = utils:CheckFileExist(UtilPlistPath..".plist")
	if not self.bExsitFishAnimate_ then 
	   printf("FishMeta UnValid: %s",tostring(self.nFishMetaID_))
	   self.bValid_ = false
	   self.bExsitFishAnimate_ = true 
	   self.nFishMetaID_ = FishAnimateUnit.Default_Fish_MetaID
	end
	return self.bExsitFishAnimate_ 
end 

 
 
--加载指定的鱼鱼游动动画 fishAnimateType 见 EventType
function FishAnimateUnit:innerLoadFishAnimatesByType(fishAnimateType)
   -- printInfo("loading AnimateType: [%s]",tostring(fishAnimateType))
   assert(EventType.UnKown_Animate_Type < fishAnimateType and fishAnimateType <= EventType.Ext_Animate_Type,"fishAnimateType Error!")
   local  fishAnimateName = string.format(FishAnimateUnit.Fish_AnimateName_Template[fishAnimateType],self.nFishMetaID_)
   local  fishAnimate = cc.AnimationCache:getInstance():getAnimation(fishAnimateName)
   local  frameTable_ = {}
   if not fishAnimate then 
	  if not self:checkHadLoadedFishPlistBefore() then 
		 local filePath = string.format(FishAnimateUnit.Fish_PlistPath,self.nFishMetaID_)
		 -- printInfo("loading plistFilePath: [%s] ",filePath)             
		 cc.SpriteFrameCache:getInstance():addSpriteFrames(filePath..".plist",filePath..".png")
	  end
	  local tmpSpriteFrame_ = nil 
	  local frameIndex     = 0 
	  tmpSpriteFrame_ = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(FishAnimateUnit.Fish_PlistName_Template[fishAnimateType],self.nFishMetaID_,frameIndex))
	  while tmpSpriteFrame_ do 
 	    frameTable_[#frameTable_ + 1]=tmpSpriteFrame_ 
		frameIndex=frameIndex+1
	    tmpSpriteFrame_ = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(FishAnimateUnit.Fish_PlistName_Template[fishAnimateType],self.nFishMetaID_,frameIndex))
	  end
	  fishAnimate = display.newAnimation(frameTable_,0.08)
	  if fishAnimate then 
		 cc.AnimationCache:getInstance():addAnimation(fishAnimate,fishAnimateName)
		 -- printInfo("FishAnimate Meta : [%s] FishType :[%s] Success!",tostring(self.nFishMetaID_),tostring(fishAnimateName)) 
	  end 
   end 
   return fishAnimate
end

--加载指定鱼鱼的皇冠动画 fishUtilType 见 EventType
function FishAnimateUnit:innerLoadUtilAnimateByType(fishAnimateType)
   assert(EventType.Normal_Animate_Type<fishAnimateType and fishAnimateType <= EventType.Ext_Animate_Type,"loadFishAnimate Type  Error")
   if self.bExsitUtilAnimate_ then 
	   local  fishAnimateName = string.format(FishAnimateUnit.Util_AnimateName_Template[fishAnimateType],self.nFishMetaID_)
	   local  fishAnimate = cc.AnimationCache:getInstance():getAnimation(fishAnimateName)
	   if not fishAnimate then 
		  if self:checkHadLoadedUtilPlistBefore() then 
			 local filePath = string.format(FishAnimateUnit.Util_PlistPath,self.nFishMetaID_)
			 cc.SpriteFrameCache:getInstance():addSpriteFrames(filePath..".plist",filePath..".png")
		  end
		  local tmpSpriteFrame_ = nil 
		  local frameIndex     = 0
		  local frameTable_    = {}
		  tmpSpriteFrame_ = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(FishAnimateUnit.Fish_PlistName_Template[fishAnimateType],self.nFishMetaID_,frameIndex))
		  while tmpSpriteFrame_ do 
			table.insert(frameTable_,tmpSpriteFrame_)
			frameIndex=frameIndex+1
			tmpSpriteFrame_ = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(FishAnimateUnit.Fish_PlistName_Template[fishAnimateType],self.nFishMetaID_,frameIndex))
		  end
		  fishAnimate = display.newAnimation(frameTable_,0.083)
		  if fishAnimate then 
			 cc.AnimationCache:getInstance():addAnimation(fishAnimate,fishAnimateName)
		  end 
	   end 
	   return fishAnimate 
   end 
   return nil 
end


--检测当前是否已经加载动画类型
function FishAnimateUnit:checkHadLoadedFishPlistBefore()
	return 0 < table.nums(self.tFishAnimateGroup_)
end

--检测当前是否已经加载皇冠类型
function FishAnimateUnit:checkHadLoadedUtilPlistBefore()
	return 0 < table.nums(self.tUtilAnimateGroup_)
end

--根据动画类型获取对应的鱼鱼游动动画
function FishAnimateUnit:getFishAnimateByType(animateType) 
	return 	self.tFishAnimateGroup_[animateType] 
end

--根据动画类型获取对应的鱼鱼黄冠游动动画
function FishAnimateUnit:getUtilAnimateByType(animateType)  
	return 	self.tUtilAnimateGroup_[animateType] 
end
 

--获取当前鱼鱼是否存在扩展动画
function FishAnimateUnit:bExistExtAniamte() 
	return self.tFishAnimateGroup_[EventType.Ext_Animate_Type] 
end

--获取当前鱼鱼是否存在皇冠动画
function FishAnimateUnit:bExistUtilAnimate()  
	return self.bExsitUtilAnimate_
end
 
--判断是否加载过皇冠动画
function FishAnimateUnit:bHadLoadedUtilAnimate()
	return  table.nums(self.tUtilAnimateGroup_)
end
  

--销毁加载的动画Cache
function FishAnimateUnit:releaseAllAnimates()
   local animateName = ""
   --移除鱼鱼动画
   for _,fishAnimateItem in pairs(FishAnimateUnit.Fish_AnimateName_Template) do 
     animateName = string.format(fishAnimateItem,self.nFishMetaID_)
     cc.AnimationCache:getInstance():removeAnimation(animateName)
   end
   for _,fishAnimateItem in pairs(FishAnimateUnit.Util_AnimateName_Template) do 
     animateName = string.format(fishAnimateItem,self.nFishMetaID_)
     cc.AnimationCache:getInstance():removeAnimation(animateName)
   end 
   	self.tFishAnimateGroup_ 	= {}				    --鱼鱼的游动动画组
	self.tUtilAnimateGroup_ 	= {}					--鱼鱼的皇冠动画组 
end

return FishAnimateUnit 