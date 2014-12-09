

TxtReader = {}
TxtReader.TAT_DESC		= 1 --描述栏
TxtReader.TAT_NAMELINE 	= 2 --标题栏
TxtReader.TAT_FORMATLINE 	= 3 --格式栏
TxtReader.MAIN_KEY		= 1 --主键在的列

TxtReader.TYPE_STRING 	= "string"
TxtReader.TYPE_NUMBER 	= "number"
TxtReader.TYPE_EQUATION   = "equation"
TxtReader.TYPE_POINT		= "point"
TxtReader.TYPE_ARRAY		= "array" --serialize
TxtReader.TYPE_TABLE		= "table" --key-value
  
function string.trimsymbol(input)
    input = string.gsub(input, "^[\"]+", "")
    return string.gsub(input, "[\"]+$", "")
end

function isNumber(str)
	local  strnew = str
	if string.find(str,"[.]?") then
		strnew=string.gsub(strnew,"%.","0")
	end
	return  string.find(strnew,"^[+-]?%d+$")
end

function TxtReader.parseEquation(str,paramName,paramTable)
	local number = 0
	if isNumber(str) then
		number=tonumber(str)
	else
		str=string.gsub(str,"cx",tostring(display.cx))
		str=string.gsub(str,"cy",tostring(display.cy))
		str=string.gsub(str,"width",tostring(display.width))
		str=string.gsub(str,"height",tostring(display.height))
		str=string.gsub(str,"left",tostring(display.left))
		str=string.gsub(str,"top",tostring(display.top))
		str=string.gsub(str,"right",tostring(display.right))
		str=string.gsub(str,"bottom",tostring(display.bottom))
		if paramName then
			for i,v in ipairs(paramName) do
				str=string.gsub(str,v,tostring(paramTable[i]))
			end
		end 
		local  symbol= {"+","-","*","/"}
		local  root = {}
		local function calc_(value1,value2,symbol)
			if symbol=="+" then
				return value1+value2
			elseif symbol == "-" then
				return  value1-value2
			elseif symbol == "*" then
				return  value1*value2
			elseif symbol == "/" then
				return value1/value2
			end
			return 0
		end
		local function analyzeCalc_(str,croot,index)
			if isNumber(str) then
				return tonumber(str)
			end
			local symbolIndex=index
			local value = 0
			while symbolIndex<5 do
				if string.find(str,symbol[symbolIndex]) then
					local child={}
					child.src=str;
					child.symbol=symbol[symbolIndex]
					local splitTable = string.split(str,symbol[symbolIndex])
					for ci,cv in ipairs(splitTable) do
						child[ci]={}
						if ci == 1 then
							value=analyzeCalc_(cv,child[ci],symbolIndex)
						else
							value=calc_(value,analyzeCalc_(cv,child[ci],symbolIndex),child.symbol)
						end
					end
					croot.child=child
					symbolIndex=5
				end
				symbolIndex=symbolIndex+1
			end
			return value
		end
		number=analyzeCalc_(str,root,1) 
	end 
	return number
end

function TxtReader.parsePoint(str)
	local x = 0
	local y = 0
	if str and string.len(str)>2 then
		local pstart,len=string.find(str, "{")
		local pend,len=string.find(str, "}")
		local valueStr=string.sub(str, pstart+1, pend-1)
		local p=string.split(valueStr,",")
		x=TxtReader.parseEquation(p[1])
		y=TxtReader.parseEquation(p[2])
	end
	return ccp(x,y)
end

function TxtReader.parseTable(str)
	if str and string.len(str)>2 then
		local pstart,len=string.find(str, "{")
		local pend,len=string.find(str, "}")
		local valueStr=string.sub(str, pstart+1, pend-1)
		local table_ ={}
		local element=string.split(valueStr,",")

		for elementk,elementv in pairs(element) do
			if string.find(elementv,"=") then
				local value=string.split(elementv,"=")
				table_[value[1]]=value[2]
			else
				table_[elementk]=elementv
			end
		end
		return table_
	else 
		return {}
	end
end

function TxtReader.read(fileName)
	printf("fileName",fileName)
  	assert(fileName,"TxtReader.read fileName is null" ..fileName)
  	local lineTable_={}
  	local dataTile_={}
	local dataFormat_={}
	local data_={}
	local fullpath = CCFileUtils:sharedFileUtils():fullPathForFilename(fileName)
  	local fileData_= CCFileUtils:sharedFileUtils():getFileData(fullpath)
  	--兼容office 2007-2013
  	if string.find(fileData_, "\r\n") then
  		lineTable_=string.split(fileData_, "\r\n")--2007
  	else
		lineTable_=string.split(fileData_, "\r")--2012
  	end
	for i,v in ipairs(lineTable_) do
		local linedata_={}
		local elementTable_ = string.split(v,"\t")
		if i == TxtReader.TAT_DESC then
			
		elseif i == TxtReader.TAT_NAMELINE then
			dataTile_=elementTable_
		elseif i==TxtReader.TAT_FORMATLINE then
			dataFormat_=elementTable_
		else 
			--先解析除了公式外的所有数据
			for ei,ev in ipairs(elementTable_) do
				local dataType_ = string.lower(dataFormat_[ei])
				if dataType_ == TxtReader.TYPE_STRING then
					linedata_[dataTile_[ei]] = tostring(ev)
				elseif dataType_ == TxtReader.TYPE_NUMBER then
					linedata_[dataTile_[ei]] = tonumber(ev)
				elseif dataType_ == TxtReader.TYPE_POINT then
					linedata_[dataTile_[ei]] = TxtReader.parsePoint(string.trimsymbol(ev))
				elseif dataType_ == TxtReader.TYPE_ARRAY then

					linedata_[dataTile_[ei]] = string.split(string.trimsymbol(ev),",")
				elseif dataType_ == TxtReader.TYPE_TABLE then
					linedata_[dataTile_[ei]] = TxtReader.parseTable(ev)
				end
			end
			--仅仅解析公式模式
			for ei,ev in ipairs(elementTable_) do
				if dataFormat_[ei] == TxtReader.TYPE_EQUATION  then
					linedata_[dataTile_[ei]] = TxtReader.parseEquation(ev,dataTile_,linedata_)
				end
			end 
			data_[elementTable_[TxtReader.MAIN_KEY]]=linedata_
		end
	end
	return data_
end




