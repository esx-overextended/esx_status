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
        printMessage = "^1FAIL^7: " .. testName .. " (expected ^5" .. tostring(expected) .. "^7, received ^1" .. tostring(actual) .. "^7)"
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

-----------------------------------------
----------------UNIT TESTS---------------
-----------------------------------------

-- Test case: Validate initial creation of status object with name and value
function UnitTests.TestStatusCreation()
    local Status = require("class.Status")
    local status = Status("health", 50)

    return mutateESXTrace(function()
        return assertEqual(status:getName(), "health", "Status:getName: Correct name on creation") and
            assertEqual(status:getValue(), 50, "Status:getValue: Correct initial value on creation")
    end)
end

-- Test case: Validate manipulation of numeric status without limits, including type checks
function UnitTests.TestStatusNumericTypeNoLimitsManipulation()
    local Status = require("class.Status")
    local status = Status("money", 0)

    return assertEqual(status:getName(), "money", "Status:getName: Correct name for numeric type") and
        assertEqual(status:getValue(), 0, "Status:getValue: Correct initial value for numeric type") and
        -- Invalid type setting
        assertEqual(status:setValue("not a number"), false, "Status:setValue: Reject invalid type (string)") and
        assertEqual(status:getValue(), 0, "Status:getValue: Value remains unchanged after invalid type") and
        -- Valid positive and negative number setting
        assertEqual(status:setValue(500), true, "Status:setValue: Accept valid positive number") and
        assertEqual(status:getValue(), 500, "Status:getValue: Correct value after setting valid positive number") and
        assertEqual(status:setValue(-500), true, "Status:setValue: Accept valid negative number") and
        assertEqual(status:getValue(), -500, "Status:getValue: Correct value after setting valid negative number") and
        -- Test setting a non-numeric value
        assertEqual(status:setValue("non-numeric"), false, "Status:setValue: Reject non-numeric type (string)") and
        assertEqual(status:getValue(), -500, "Status:getValue: Value remains unchanged after non-numeric value")
end

-- Test case: Validate manipulation of numeric status with minimum limit and error handling for invalid types
function UnitTests.TestStatusNumericTypeWithMinLimitManipulation()
    local Status = require("class.Status")
    local status = Status("age", 0)

    return assertEqual(status:getName(), "age", "Status:getName: Correct name for numeric type with min limit") and
        assertEqual(status:getValue(), 0, "Status:getValue: Correct initial value for numeric type with min limit") and
        -- Invalid type setting
        assertEqual(status:setValue("not a number"), false, "Status:setValue: Reject invalid type (string)") and
        assertEqual(status:getValue(), 0, "Status:getValue: Value remains unchanged after invalid type") and
        -- Valid value within range
        assertEqual(status:setValue(25), true, "Status:setValue: Accept valid number within range") and
        assertEqual(status:getValue(), 25, "Status:getValue: Correct value after setting valid number") and
        -- Invalid value below min limit
        assertEqual(status:setValue(-10), false, "Status:setValue: Reject value below min limit") and
        assertEqual(status:getValue(), 25, "Status:getValue: Value remains unchanged after setting below min limit")
end

-- Test case: Validate manipulation of numeric status with min and max limits, including boundary checks
function UnitTests.TestStatusNumericTypeWithLimitsManipulation()
    local Status = require("class.Status")
    local status = Status("health", 50)

    return assertEqual(status:getName(), "health", "Status:getName: Correct name for numeric type with limits") and
        assertEqual(status:getValue(), 50, "Status:getValue: Correct initial value within limits") and
        -- Valid value within range
        assertEqual(status:setValue(75), true, "Status:setValue: Accept valid value within limits") and
        assertEqual(status:getValue(), 75, "Status:getValue: Correct value after setting valid number within limits") and
        -- Invalid value below min limit
        assertEqual(status:setValue(-10), false, "Status:setValue: Reject value below min limit") and
        assertEqual(status:getValue(), 75, "Status:getValue: Value remains unchanged after setting below min limit") and
        -- Invalid value above max limit
        assertEqual(status:setValue(110), false, "Status:setValue: Reject value above max limit") and
        assertEqual(status:getValue(), 75, "Status:getValue: Value remains unchanged after setting above max limit") and
        -- Invalid type setting
        assertEqual(status:setValue("not a number"), false, "Status:setValue: Reject invalid type (string)") and
        assertEqual(status:getValue(), 75, "Status:getValue: Value remains unchanged after invalid type")
end

-- Test case: Validate manipulation of numeric status with strict decimal policy
function UnitTests.TestStatusNumericTypeWithDecimalManipulation()
    local Status = require("class.Status")
    local status = Status("money", 0)

    return assertEqual(status:setValue(500.123456789), true, "Status:setValue: Accept valid number for numeric type with strict decimal policy") and
        assertEqual(status:getValue(), 500.12, "Status:getValue: Correct value after setting valid number for numeric type with strict decimal policy")
end

-- Test case: Validate manipulation of string type status, including type checks
function UnitTests.TestStatusStringTypeManipulation()
    local Status = require("class.Status")
    local status = Status("name", "none")

    return assertEqual(status:getName(), "name", "Status:getName: Correct name for string type") and
        assertEqual(status:getValue(), "none", "Status:getValue: Correct initial value for string type") and
        -- Valid string update
        assertEqual(status:setValue("John"), true, "Status:setValue: Correct update to string") and
        assertEqual(status:getValue(), "John", "Status:getValue: Correct value after setting valid string") and
        -- Invalid type setting
        assertEqual(status:setValue(100), false, "Status:setValue: Reject non-string type (number)") and
        assertEqual(status:getValue(), "John", "Status:getValue: Value remains unchanged after invalid type")
end

-- Test case: Validate manipulation of string type status with strict accepted values, including type checks
function UnitTests.TestStatusStringTypeWithStrictAcceptedValuesManipulation()
    local Status = require("class.Status")
    local status = Status("growth", "low")

    return assertEqual(status:getName(), "growth", "Status:getName: Correct name for string type with strict accepted values") and
        assertEqual(status:getValue(), "low", "Status:getValue: Correct initial value for string type with strict accepted values") and
        -- Valid string update
        assertEqual(status:setValue("high"), true, "Status:setValue: Correct update to string for status with strict accepted values") and
        assertEqual(status:getValue(), "high", "Status:getValue: Correct value after setting valid string for status with strict accepted values") and
        -- Invalid type setting
        assertEqual(status:setValue(100), false, "Status:setValue: Reject non-string type (number) for string status with strict accepted values") and
        assertEqual(status:getValue(), "high", "Status:getValue: Value remains unchanged after invalid type for string status with strict accepted values") and
        -- Invalid value setting
        assertEqual(status:setValue("random string value"), false, "Status:setValue: Reject invalid string value for status with strict accepted values") and
        assertEqual(status:getValue(), "high", "Status:getValue: Value remains unchanged after invalid value for status with strict accepted values")
end

-- Test case: Validate manipulation of boolean type status, including type checks
function UnitTests.TestStatusBooleanTypeManipulation()
    local Status = require("class.Status")
    local status = Status("hasPhone", false)

    return assertEqual(status:getName(), "hasPhone", "Status:getName: Correct name for boolean type") and
        assertEqual(status:getValue(), false, "Status:getValue: Correct initial value for boolean type") and
        -- Valid boolean update
        assertEqual(status:setValue(true), true, "Status:setValue: Correct update to true") and
        assertEqual(status:getValue(), true, "Status:getValue: Correct value after setting true") and
        -- Valid boolean update using 0 & 1 number
        assertEqual(status:setValue(0), true, "Status:setValue: Correct update to false using number 0 as value") and
        assertEqual(status:getValue(), false, "Status:getValue: Correct value after setting false using number 0 as value") and
        -- Valid boolean update using "true" & "false" string
        assertEqual(status:setValue("true"), true, "Status:setValue: Correct update to true using string 'true' as value") and
        assertEqual(status:getValue(), true, "Status:getValue: Correct value after setting true using string 'true' as value") and
        -- Invalid type setting
        assertEqual(status:setValue("yes"), false, "Status:setValue: Reject non-boolean type (string)") and
        assertEqual(status:getValue(), true, "Status:getValue: Value remains unchanged after invalid type")
end

-- Test case: Player status registration with new status
function UnitTests.TestPlayerStatusRegister()
    local PlayerStatus = require("class.PlayerStatus")
    local playerStatus = PlayerStatus(1, { health = 50, age = 30, money = 100, name = "Player1", hasPhone = true })

    local success = playerStatus:registerStatus("growth", "low")

    return assertEqual(success, true, "PlayerStatus:registerStatus: Successfully register new status") and
        assertEqual(playerStatus:getStatus("growth"), "low", "PlayerStatus:getStatus: Correct value for new status")
end

-- Test case: Player status unregistration with existing and non-existing status
function UnitTests.TestPlayerStatusUnregister()
    local PlayerStatus = require("class.PlayerStatus")
    local playerStatus = PlayerStatus(1, { health = 50, age = 30, money = 100, name = "Player1", hasPhone = true })

    playerStatus:registerStatus("growth", "low")
    local success = playerStatus:unregisterStatus("growth")

    return assertEqual(success, true, "PlayerStatus:unregisterStatus: Successfully unregister existing status") and
        assertEqual(playerStatus:unregisterStatus("growth"), false, "PlayerStatus:unregisterStatus: Fail to unregister non-existing status")
end

-----------------------------------------
----------------TEST RUNNER---------------
-----------------------------------------

---Test Runner with failure handling
return mutateESXTrace(function()
    local OGStatuses = require("shared.config").statuses
    require("shared.config").statuses = {                                        -- mock config for using in unit tests
        money    = { value = 0, decimal = 2 },                                   -- number type value with no min/max limit
        age      = { value = 0, min = 0 },                                       -- number type value with no min limit
        health   = { value = 50, min = 0, max = 100 },                           -- number type value with min and max limit
        name     = { value = "none" },                                           -- string type value
        growth   = { value = "", acceptedValues = { "low", "medium", "high" } }, -- string type value with strict accepted values
        hasPhone = { value = false }                                             -- boolean type value
    }

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

    require("shared.config").statuses = OGStatuses

    --Refresh accepted string values after resetting the config.statuses
    require("shared.utils").refreshAcceptedStringValues(OGStatuses)

    return true
end)
