--此文件用于收集功能数据操作方法

utils = {}

--参数区间内的随机数(浮点数) [minValue,maxValue]
function utils.RandomFloat(maxValue,minValue)
	local differValue  = math.abs(maxValue-minValue)
	local realMinValue = math.min(maxValue,minValue)
	if differValue <= 1.0f
	   return maxValue
	end
	return math.random(1000) % math.floor(differValue) + realMinValue
end
 


return utils



