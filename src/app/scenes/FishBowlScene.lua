
local FishBowlScene = class("FishBowlScene", function()
    return display.newScene("FishBowlScene")
end)

function FishBowlScene:ctor()
--[[    cc.ui.UILabel.new({
            UILabelType = 2, text = "Canny Fish", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)--]]
		self.mainBg_ = display.newSprite("bg/601016_hd.png",display.cx,display.cy)
		self:addChild(self.mainBg_) 
		
end

function FishBowlScene:onEnter()
end

function FishBowlScene:onExit()
end

return FishBowlScene
