 
DBManager = {} 

function DBManager:init(...)
	self.datalist_={}
	require("app.utils.config.ConfigWithTxtReader") 
	self:loadTableData_("skillData","data/skill.txt")
	self:loadTableData_("behaviorData","data/behavior.txt")
	self:loadTableData_("effectData","data/effect.txt")
	self:loadTableData_("enemyData","data/enemy.txt")
	self:loadTableData_("buffData","data/buff.txt") 
	self:loadTableData_("shapeData","data/shape.txt") 
	self:loadTableData_("actiongroupData","data/actiongroup.txt") 
 	self:loadTableData_("sceneData","data/scene.txt") 
	self:loadTableData_("shapeactionData","data/shapeaction.txt")
	self:loadTableData_("effectgroupData","data/effectgroup.txt")
	self:loadTableData_("playerGroupData","data/playerdata.txt")
	self:loadTableData_("sectionData","data/section.txt")
	self:loadTableData_("stageData","data/stage.txt")
	self:loadTableData_("wujdData","data/wujd.txt")
	self:loadTableData_("itemData","data/item.txt")
	self:loadTableData_("resourceData","data/resource.txt")
	self:loadTableData_("chipData","data/chip.txt")
	self:loadTableData_("stageListData","data/stageslist.txt")
	self:loadTableData_("relationshipData","data/relationship.txt")
	self:loadTableData_("expData","data/exp.txt")
	self:loadTableData_("equipment","data/equipment.txt")
	self:loadTableData_("TreasureData","data/treasure.txt")
	self:loadTableData_("attributeData","data/attribute.txt")
	self:loadTableData_("suitData","data/suit.txt")
	self:loadTableData_("exchangeData","data/exchange.txt")
	self:loadTableData_("NoticeData","data/syslang.txt")
	self:loadTableData_("fontStyleData","data/fontstyle.txt")
	self:loadTableData_("plotData","data/plot.txt")
	self:loadTableData_("plotlistData","data/plotlist.txt") 
	self:loadTableData_("tacticsData","data/tactics.txt")
	self:loadTableData_("functionData","data/function.txt")  	
	self:loadTableData_("guideData","data/guide.txt") 
	self:loadTableData_("richtextData","data/richtext.txt")
 
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




