--���ļ������ռ��������ݲ�������

utils = {}

--���������ڵ������(������) [minValue,maxValue]
function utils.RandomFloat(maxValue,minValue)
	local differValue  = math.abs(maxValue-minValue)
	local realMinValue = math.min(maxValue,minValue)
	if differValue <= 1.0f
	   return maxValue
	end
	return math.random(1000) % math.floor(differValue) + realMinValue
end
 


return utils



