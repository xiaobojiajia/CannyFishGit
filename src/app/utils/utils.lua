--此文件用于收集功能数据操作方法

utils = {}

--参数区间内的随机数(浮点数) [minValue,maxValue]
function utils.RandomFloat(maxValue,minValue)
	local differValue  = math.abs(maxValue-minValue)
	local realMinValue = math.min(maxValue,minValue)
	if differValue <= 0.5 then
	   return maxValue
	end
	return math.random(1000) % math.floor(differValue) + realMinValue
end
 
--在读取文件数据的是读取方式为了跨平台使用，请使用"rb"方法读取

--获取指定文件的全路径
function utils.GetFullPathByFileName(fileName)
	local  fullPath = cc.FileUtils:getInstance():fullPathForFilename(fileName)
	return fullPath or ""
end
 
--检测当前文件存在 相对路径
function utils:CheckFileExist(fileName)
   return io.exists(utils.GetFullPathByFileName(fileName))  
end

--startRand With Random Key recommond Using 1000 
function utils.startRandFunc(randomkey)
   utils.randomValue = math.max(0,math.random(randomkey)) / 10 
end 

--check rand in range from start to end Rate eg[23.5,54,5]
function utils.CheckRandInRange(startRate,endRate)
  return  startRate <= utils.randomValue and endRate <= utils.randomValue   
end

 
 -- moveAction = cc.EaseExponentialOut:create(moveAction)  
return utils



