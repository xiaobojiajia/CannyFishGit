--全局模型管理器 

GlobalMode = {}

--全局模型构造器
function GlobalMode:init()
	self.modeList_ = {}
end

--装载模型队列
function GlobalMode:pushModeByData(modeName,modeData)
	assert(modeName and modeData,"pushMode Error For [%s]",modeName)
	if not self.modeList_[modeName] then 
       printInfo("pushModeByData [%s] had Exist Before!",modeName)
	end 
	self.modeList_[modeName] = modeData
    printInfo("pushModeByData [%s] success!",modeName)
   	return modeData
end

--装载Mode队列
function GlobalMode:pushModeBySName(modeName,modeFile,attachParam) 
	local modeFullName = "app.modes."..modeFile
	return self:pushModeByFullName(modeName,modeFullName,modeFullName)
end

--装载全局模型队列
function GlobalMode:pushModeByFullName(modeName,modeFile,attachParam) 
	assert(modeName and modeFile,"pushMode Error For [%s]",modeName)	
	if not self.modeList_[modeName] then 
       	local modeHandler = require(modeFile)
		if modeHandler then 
	       return self:pushModeByData(modeName,modeHandler.new(attachParam))
	    else
	       printInfo("Cannot Found ModePath: %s",modeFile)
	       return nil
		end
	else
		return self.modeList_[modeName]
	end  
end

--获取知道模型数据
function GlobalMode:getModeByName(modeName) 
	return self.modeList_[modeName]  
end 

--获取模型总数
function GlobalMode:getModesCount() 
	return table.nums(self.modeList_)
end

function GlobalMode:destory()
	self.modeList_ = nil
	__G["GlobalMode"]=nil
end
 
return GlobalMode