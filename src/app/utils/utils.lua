--���ļ������ռ��������ݲ�������

utils = {}

--���������ڵ������(������) [minValue,maxValue]
function utils.RandomFloat(maxValue,minValue)
	local differValue  = math.abs(maxValue-minValue)
	local realMinValue = math.min(maxValue,minValue)
	if differValue <= 0.5 then
	   return maxValue
	end
	return math.random(1000) % math.floor(differValue) + realMinValue
end
 
--�ڶ�ȡ�ļ����ݵ��Ƕ�ȡ��ʽΪ�˿�ƽ̨ʹ�ã���ʹ��"rb"������ȡ

--��ȡָ���ļ���ȫ·��
function utils.GetFullPathByFileName(fileName)
	local  fullPath = cc.FileUtils:getInstance():fullPathForFilename(fileName)
	return fullPath or ""
end
 
--��⵱ǰ�ļ����� ���·��
function utils:CheckFileExist(fileName)
   return io.exists(utils.GetFullPathByFileName(fileName))  
end






return utils



