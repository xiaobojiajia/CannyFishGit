--封装了一下公共的UI 
uifunction = {}

uifunction.TOUCH_EVENT_BEGAN 	= 0 
uifunction.TOUCH_EVENT_MOVED 	= 1
uifunction.TOUCH_EVENT_ENDED 	= 2 
uifunction.TOUCH_EVENT_CANCELED = 3 

function uifunction.bindBtnEventHandler(touchNode,trigerOwner,triggerHandler,awllowEnable,attachParam,soundType) 
    local function touchEvent(event)
      local eventName,x,y = event.name,event.x,event.y
	  if eventName == "began" then  
         --播放音效
         if awllowEnable == nil then
	        touchNode:setTouchSwallowEnabled(false)
	     else
	        touchNode:setTouchSwallowEnabled(true)
		 end
		 return true
	  elseif eventName == "moved" then 
	  	 return false 
	  elseif eventName == "ended" then 
	     --若弹起超时 也需要播放音效
         triggerHandler(trigerOwner,touchNode,attachParam)
	  	 return false 
	  elseif eventName == "cancelled" then
	  	 return false 
	  end
	end 
    if touchNode then  
       touchNode:setTouchEnabled(true)
       touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT,touchEvent) 
    end
    return touchNode
end



  
return uifunction