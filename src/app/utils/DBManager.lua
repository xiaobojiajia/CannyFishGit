 
DBManager = {} 

function DBManager:init(...)
	self.datalist_={}
	require("app.utils.TxtReader")  
 
end

function DBManager:getTableDataByName(tableName)
	if tableName and self.datalist_[tableName] then
		return self.datalist_[tableName]
    else 
    printf("Get TableData Failed ! Name: %s ",tableName)
    end
end
 
function DBManager:getDBTablesCount()
	return  table.nums(self.datalist_) 
end

function DBManager:getKeyIDbyName(tableName,keyName,keyValue)
	local IDlist = {}
    for k,v in pairs (self.datalist_[tableName]) do
    	if v[keyName] == keyValue then
           table.insert(IDlist,k)
    	end
    end
    return IDlist
end

function DBManager:getRecordNumberByTableName(tableName)
	local count = 0
	if tableName and self.datalist_[tableName] then 
		count = table.nums(self.datalist_[tableName]) 
	end
	return count
end

 
function DBManager:loadTableData_(tableName,tableFileName) 
	 printf("Loading File : %s",tableFileName)
	 if tableName and tableFileName then 
	 	if self.datalist_[tableName] then 
	 	   printf("Table : 【 %s 】Aready loaded Before ! FilePath: 【 %s 】",tableName,tableFileName)
	 	end 
	 	local tableData = TxtConfigReader.read(tableFileName)
	 	if next(tableData) then
		   self.datalist_[tableName] = tableData
		else
		printf("LoadTableData Failed! Name: 【 %s 】FilePath:【 %s 】",tableName,tableFileName)
		end
	 end
end


function DBManager:desoty(...)
	self.datalist_={}
	_G[DBManager]=nil
	_G[TxtConfigReader]=nil
end

return  DBManager




