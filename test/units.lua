---@diagnostic disable: need-check-nil, param-type-mismatch
local UnitTests = {}
local DEBUG = require("shared.config").debug

---Utility for assertions
local function assertEqual(actual, expected, testName)
    local printMessage = ""
    local isSuccessful = actual == expected

    if isSuccessful then
        printMessage = "^2PASS^7: " .. testName
    else
        printMessage = "^1FAIL^7: " .. testName .. " (expected " .. tostring(expected) .. ", got " .. tostring(actual) .. ")"
    end

    if DEBUG then print(printMessage) end

    return isSuccessful
end

local function noop() end

---Mutate ESX.Trace temporarily during tests
local function mutateESXTrace(func)
    local originalTrace = ESX.Trace
    ESX.Trace = noop -- Mute ESX.Trace temporarily
    local result = func()
    ESX.Trace = originalTrace --[[@as fun(message: string, traceType?:  "info" | "warning" | "error" | "trace", forcePrint?: boolean)]]
    return result
end

---Individual Tests
function UnitTests.TestStatusCreation()
    local Status = require("class.Status")
    local status = Status("health", 50)

    return mutateESXTrace(function()
        return assertEqual(status:getName(), "health", "Status:getName") and assertEqual(status:getValue(), 50, "Status:getValue")
    end)
end

function UnitTests.TestStatusManipulation()
    local Status = require("class.Status")
    local status = Status("stamina", 30)
    status:setValue(40)

    return mutateESXTrace(function()
        return assertEqual(status:getValue(), 40, "Status:setValue")
    end)
end

function UnitTests.TestStatusInvalidSet()
    local Status = require("class.Status")
    local status = Status("strength", 80)

    return mutateESXTrace(function()
        return assertEqual(status:setValue("not a number"), false, "Status:setValue invalid type") and assertEqual(status:setValue(-10), false, "Status:setValue out-of-range") and
            assertEqual(status:getValue(), 80, "Status unchanged after invalid set")
    end)
end

---PlayerStatus Tests
function UnitTests.TestPlayerStatusRegister()
    local PlayerStatus = require("class.PlayerStatus")
    local playerStatus = PlayerStatus(1, { health = 100, stamina = 50 })
    local success = playerStatus:registerStatus("energy", 60)

    return mutateESXTrace(function()
        return assertEqual(success, true, "PlayerStatus:registerStatus") and assertEqual(playerStatus:getStatus("energy"), 60, "PlayerStatus:getStatus value")
    end)
end

function UnitTests.TestPlayerStatusUnregister()
    local PlayerStatus = require("class.PlayerStatus")
    local playerStatus = PlayerStatus(1, { health = 100, stamina = 50 })

    playerStatus:registerStatus("energy", 60)

    local success = playerStatus:unregisterStatus("energy")

    return mutateESXTrace(function()
        return assertEqual(success, true, "PlayerStatus:unregisterStatus existing") and assertEqual(playerStatus:unregisterStatus("energy"), false, "PlayerStatus:unregisterStatus non-existing")
    end)
end

---Test Runner with failure handling
return mutateESXTrace(function()
    for test, func in pairs(UnitTests) do
        if not func() then
            if DEBUG then
                print("Test failed at ^3" .. test .. "^7")
            end

            return false
        end
    end

    if DEBUG then
        print("^2All esx_status unit tests were passed. Starting resource...^7")
    end

    return true
end)
