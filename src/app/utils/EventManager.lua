
--[[
    fun:全局事件管理器
    author:xiaobo.wu
 	date:2014-06-03
]] 
EventManager={}

function  EventManager:init(...)
	self.eventListenList_={}
end
 
function EventManager:addEvent(eventName,target,handler) 
	if type(eventName) =="table" then
	  for _,subEventName in pairs(eventName) do
	  	printf("EventManager >> addEvent : 【%s】",subEventName)
	    self:addEvent_(subEventName,target,handler)
	  end
	elseif type(eventName) =="string" then
		printf("EventManager >> addEvent : 【%s】 ",eventName)
	    self:addEvent_(eventName,target,handler)
	else
		printf("EventManager >> addEvent Error : 【%s】",tostring(eventName))
	end 
end

function EventManager:addEvent_(eventName,target,handler)
	local eventTable = self.eventListenList_[eventName] or {}
	for _,eventHandle in pairs(eventTable) do 
		if eventHandle.target == target then 
		   eventHandle.handler = handler
		   return 
		end 
	end
	local event={
	  target=target,
	  handler=handler,
	}
	table.insert(eventTable,event)
	self.eventListenList_[eventName]=eventTable 
end


function EventManager:pushEvent(eventName,...) 
    printf("EventManager >> pushEvent : 【%s】 ",eventName) 
    local  eventsList = self.eventListenList_[eventName]
    if eventsList then
    	for index,hanlderItem in pairs(eventsList) do
			if hanlderItem and hanlderItem.target and hanlderItem.handler then
			   hanlderItem.handler(hanlderItem.target,eventName,...) 
			end
		end 
    end 
end

function EventManager:removeEventByName(evetName) 
  self.eventListenList_[eventName]={}
end


function EventManager:removeEventByTarget(target)
  assert(target,"EventManager : removeEventByTarget Error! ")
  for _,eventTable in pairs(self.eventListenList_) do
      for index,handler in pairs(eventTable) do
     	  if handler.target == target then
     	  	 eventTable[index] = nil
     	  	 break
     	  end
  	 end
  end 
end

function EventManager:removeEvent(target,eventName)
	local eventslist = self.eventListenList_[eventName]
	if eventslist then
	   for index,eventTable in pairs(eventslist) do
	   	  if eventTable.target == target then
     	     eventslist[index] = nil
             break
     	  end
       end 
	end 
end 

function EventManager:destory()
	self.eventListenList_={}
	_G[EventManager] = nil
end

return   EventManager