-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

local thisState = {}
local state = nil
local currentOptions = {}
local mainOptions = {"Play", "Settings", "About", "Leave"}
local selectedItem = 1
local sprites = {}
local spriteStates = spriteManager:new()
local about = nil

function thisState:load()
    state = stateManager:new()
    state:add("main", 60, "about")
    state:add("config")
    state:add("about")
    state:set("main")
    currentOptions = mainOptions
    -- Load the about display module
    about = require("modules.about-state")
    about:load()
    -- Apply the screen setting
    love.window.setFullscreen(cfg:get("fullscreen") == 1)
    -- Load image resources
    sprites.ball = loadSprite("images/ball.png")
    sprites.background = loadSprite("images/about-screen-background.png")
    sprites.spikes = loadSprite("images/about-screen-spikes.png")
    -- Rotating checkerboard
    local spr = spriteStates:add("checkers", sprites.background):setRotation(0.05)
    spr:setBlendmode("subtractive")
    spr.sprite.x = scrWidth / 2
    spr.sprite.y = scrHeight / 2
end

function thisState:update (dt)
    state:update(dt)
    spriteStates:update(dt)
    if state:on("about") then
        about:update(dt)
    end
end

function thisState:keypressed (key)
    -- Menu navigation
    if (key == "up") then
        selectedItem = selectedItem - 1
        if (selectedItem < 1) then selectedItem = #currentOptions end
    elseif (key == "down") then
        selectedItem = selectedItem + 1
        if (selectedItem > #currentOptions) then selectedItem = 1 end
    elseif (key == "return" or key == "enter" or key == " ") then
        self:menuAction()
    end
    
    if (state:on("main")) then
        if (key == "escape") then
            -- Focus the last main menu item
            selectedItem = #currentOptions
        end
    elseif (state:on("config")) then
        if (key == "escape") then
            -- Save config
            love.window.setFullscreen(cfg:get("fullscreen") == 1)
            cfg:save()
            -- Escape to the main menu
            state:set("main")
            currentOptions = mainOptions
            self:resetSelection()
        end
    elseif (state:on("about")) then
        if (key == " ") then
            about:forward()
        elseif (key == "escape") then
            state:set("main")
        end
    end

end

function thisState:keyreleased(key)
    if (playstate:gameInProgress()) then
        mainOptions[1] = "Continue"
    else
        mainOptions[1] = "Play"
    end
end

function thisState:drawOptionsMenu()
   local y = 100
    local color
    for _, m in ipairs(currentOptions) do
        if (currentOptions[selectedItem] == m) then
            color = {255, 255, 255, 255}
            love.graphics.draw(sprites.ball.image, 160, y)
        else
            color = {200, 200, 200, 255}
        end
        printShadowText(m, y, color)
        y = y + 100
    end
end

function thisState:drawSelectedOptionDescription()
    local setting = cfg.settings[selectedItem]
    local value = cfg.values[setting.meta]
    local detail = setting.details[value]
    printShadowText(detail, scrHeight - 60, {200, 255, 200, 255})
end

function thisState:draw ( )
    love.graphics.setColor(255, 255, 255, 255)
    -- Draw background
    love.graphics.draw(sprites.background.image, 0, 0)
    -- Draw rotating overlay
    spriteStates:draw()
    -- Draw spikes
    love.graphics.draw(sprites.spikes.image, 0, 0)
    -- Draw the menus
    if state:on("main") then
        self:drawOptionsMenu()
    elseif state:on("config") then
        self:drawOptionsMenu()
        self:drawSelectedOptionDescription()
    elseif state:on("about") then
        about:draw()
    end
end

function thisState:resize (w, h)

end

function thisState:resetSelection()
    selectedItem = 1
end

function thisState:menuAction()
    local item = currentOptions[selectedItem]

    -- Main
    if (item == "Play" or item == "Continue") then
        mainstate:set("play")
    elseif (item == "Settings") then
        state:set("config")
        self:buildConfigMenu()
        self:resetSelection()
        return
    elseif (item == "About") then
        state:set("about")
    elseif (item == "Leave") then
        love.event.quit()
    end

    -- Config
    if state:on("config") then
        -- selected item index matches the setting index
        local setting = cfg.settings[selectedItem]
        local value = cfg.values[setting.meta]
        -- Rotate the value
        value = value + 1
        if (value > #setting.options) then value = 1 end
        cfg.values[setting.meta] = value
        self:buildConfigMenu()
    end
end

function thisState:buildConfigMenu()
    currentOptions = {}
    for i, setting in ipairs(cfg.settings) do
        local value = cfg.values[setting.meta]
        local valueTitle = cfg:getValue(setting.meta, value)
        local item = string.format("%s: %s", setting.title, valueTitle)
        table.insert(currentOptions, item)
    end
end

return thisState
