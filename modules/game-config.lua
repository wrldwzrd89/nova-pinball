local config = {values={}}

config.settings = {
    {meta = "cameraFollowsBall",
    title = "Camera",
    options = {"Ball", "Table"},
    values = {1, 2},
    default = 1,
    details = {"Zoomed in and follows the ball",
              "Zoomed out, full table visible"
              }
    },
    {meta = "missionHints",
    title = "Mission Hints",
    options = {"LED", "Lights", "Both", "None"},
    values = {1, 2, 3, 4},
    default = 3,
    details = {"Words in the LED display",
              "Flashing Lights",
              "Words & Lights",
              "No Hints"
              }
    },
    {meta = "fullscreen",
    title = "Screen",
    options = {"Full Screen", "Window"},
    values = {1, 2},
    default = 2,
    details = {"",
              ""
              }
    },
}

-- Load config from file
function config:load()
    local exists = love.filesystem.exists("config")
    if (exists) then
        local data, size = love.filesystem.read("config", nil)
        local pickle = require("modules.pickle")
        config.values = pickle.unpickle(data)
    end
    config:applyMissing()
end

-- Apply default values to any missing settings
function config:applyMissing()
    for _, default in pairs(self.settings) do
        if (not self.values[default.meta]) then
            self.values[default.meta] = default.default
        end
    end
end

-- Reset all values back to defaults
function config:applyDefaults()
    for _, default in pairs(self.settings) do
        self.values[default.meta] = default.default
    end
end

-- Save config to file
function config:save()
    local pickle = require("pickle")
    local data = pickle.pickle(config.values)
    love.filesystem.write("config", data, nil)
end

-- Return the option title for a given meta and value
function config:getValue(meta, value)
    for _, setting in pairs(self.settings) do
        if (setting.meta == meta) then
            return setting.options[value]
        end
    end
end

function config:get(meta)
    return self.values[meta]
end

return config
