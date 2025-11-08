lib.locale()

return {
    config = {
        debug = true,
        useTarget = false,
        skillCheck = false
    },

    workouts = {
        ["treadmill"] = {
            icon = "fa-duotone fa-solid fa-person-running",
            iconColor = "#28ed09",
            label = "Use Treadmill",
            scenario = "WORLD_HUMAN_JOG_STANDING",
            dictionary = nil,
            clipset = nil,
            flag = nil,
            duration = 18000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["stamina"] = { updateAmount = 1.2, notify = true },
                ["hunger"] = { updateAmount = -2, notify = true },
                ["thirst"] = { updateAmount = -4, notify = true },
                ["stress"] = { updateAmount = -0.2, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://coxdocs.dev/ox_lib/Modules/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://coxdocs.dev/ox_lib/Modules/Interface/Client/skillcheck)
            }
        },
        ["freeweight"] = { -- it causes a lot of barbell prop to be left on the ground if the player abuses this scenario. Therefore another similar workout was created (freeweight100kg)...
            icon = "fa-duotone fa-solid fa-dumbbell",
            iconColor = "#ffe600",
            label = "Do Free Weight",
            scenario = "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS",
            dictionary = nil,
            clipset = nil,
            flag = nil,
            duration = 30000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["strength"] = { updateAmount = 0.2, notify = true },
                ["hunger"] = { updateAmount = -1, notify = true },
                ["thirst"] = { updateAmount = -3, notify = true },
                ["stress"] = { updateAmount = -0.2, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["freeweight100kg"] = {
            icon = "fa-duotone fa-solid fa-dumbbell",
            iconColor = "#ffe600",
            label = "Do Free Weight",
            scenario = nil,
            dictionary = "amb@world_human_muscle_free_weights@male@barbell@base",
            clipset = "base",
            flag = nil,
            duration = 30000,
            prop = {
                model = "prop_barbell_100kg",
                bone = 28422,
                pos = vector3(0.0, 0.0, -0.03),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["strength"] = { updateAmount = 0.2, notify = true },
                ["hunger"] = { updateAmount = -1, notify = true },
                ["thirst"] = { updateAmount = -3, notify = true },
                ["stress"] = { updateAmount = -0.2, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["pullup"] = {
            icon = "fa-solid fa-hand-fist",
            label = "Do Pull-Up",
            scenario = { "PROP_HUMAN_MUSCLE_CHIN_UPS", "PROP_HUMAN_MUSCLE_CHIN_UPS_ARMY", "PROP_HUMAN_MUSCLE_CHIN_UPS_PRISON" }, -- randomly chooses one
            dictionary = nil,
            clipset = nil,
            flag = nil,
            duration = 20000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["strength"] = { updateAmount = 0.1, notify = true },
                ["hunger"] = { updateAmount = -1, notify = true },
                ["thirst"] = { updateAmount = -3, notify = true },
                ["stress"] = { updateAmount = -0.2, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["pushup"] = {
            icon = "fa-solid fa-hand-fist",
            label = "Do Push-Up",
            scenario = "WORLD_HUMAN_PUSH_UPS",
            dictionary = nil,
            clipset = nil,
            flag = nil,
            duration = 20000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["stamina"] = { updateAmount = 0.05, notify = true },
                ["strength"] = { updateAmount = 0.1, notify = true },
                ["hunger"] = { updateAmount = -1, notify = true },
                ["thirst"] = { updateAmount = -1, notify = true },
                ["stress"] = { updateAmount = -0.2, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["situp"] = {
            icon = "fa-solid fa-hand-fist",
            label = "Do Sit-Up",
            scenario = "WORLD_HUMAN_SIT_UPS",
            dictionary = nil,
            clipset = nil,
            flag = nil,
            duration = 30000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["stamina"] = { updateAmount = 0.05, notify = true },
                ["strength"] = { updateAmount = 0.1, notify = true },
                ["hunger"] = { updateAmount = -1, notify = true },
                ["thirst"] = { updateAmount = -1, notify = true },
                ["stress"] = { updateAmount = -0.2, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["yoga"] = {
            icon = "fa-duotone fa-solid fa-brain",
            iconColor = "#28ed09",
            label = "Do Yoga",
            scenario = "WORLD_HUMAN_YOGA",
            dictionary = nil,
            clipset = nil,
            flag = nil,
            duration = 45000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["stress"] = { updateAmount = -2.5, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["benchpress"] = {
            icon = "fa-duotone fa-solid fa-dumbbell",
            iconColor = "#ffe600",
            label = "Use Weight Bench",
            scenario = { "PROP_HUMAN_SEAT_MUSCLE_BENCH_PRESS", "PROP_HUMAN_SEAT_MUSCLE_BENCH_PRESS_PRISON" }, -- randomly chooses one
            dictionary = nil,
            clipset = nil,
            flag = nil,
            duration = 25000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["strength"] = { updateAmount = 0.1, notify = true },
                ["hunger"] = { updateAmount = -1, notify = true },
                ["thirst"] = { updateAmount = -3, notify = true },
                ["stress"] = { updateAmount = -0.2, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["dumbbell"] = {
            icon = "fa-duotone fa-solid fa-dumbbell",
            iconColor = "#ffe600",
            label = "Use Dumbell",
            scenario = nil,
            dictionary = "amb@world_human_muscle_free_weights@male@barbell@base",
            clipset = "base",
            flag = nil,
            duration = 20000,
            prop = {
                {
                    model = "prop_barbell_01",
                    bone = 28422,
                    pos = vector3(-0.25, -0.01, -0.05),
                    rot = vector3(0.0, -40.0, 0.0)
                },
                {
                    model = "prop_barbell_01",
                    bone = 60309,
                    pos = vector3(0.05, 0.0, 0.02),
                    rot = vector3(0.0, 180.0, -100.0)
                }
            },
            effects = {
                ["strength"] = { updateAmount = 0.1, notify = true },
                ["hunger"] = { updateAmount = -1, notify = true },
                ["thirst"] = { updateAmount = -2, notify = true },
                ["stress"] = { updateAmount = -0.1, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["dumbbellpink"] = {
            icon = "fa-duotone fa-solid fa-dumbbell",
            iconColor = "#f279e6",
            label = "Use Pink Dumbell",
            scenario = nil,
            dictionary = "amb@world_human_muscle_free_weights@male@barbell@base",
            clipset = "base",
            flag = nil,
            duration = 20000,
            prop = {
                {
                    model = "prop_freeweight_02",
                    bone = 28422,
                    pos = vector3(-0.25, -0.01, -0.05),
                    rot = vector3(0.0, -40.0, 0.0)
                },
                {
                    model = "prop_freeweight_02",
                    bone = 60309,
                    pos = vector3(0.05, 0.0, 0.02),
                    rot = vector3(0.0, 180.0, -100.0)
                }
            },
            effects = {
                ["strength"] = { updateAmount = 0.05, notify = true },
                ["thirst"] = { updateAmount = -1, notify = true },
                ["stress"] = { updateAmount = -0.1, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["plank"] = {
            icon = "fa-solid fa-hand-fist",
            label = "Do Plank",
            scenario = nil,
            dictionary = "frabi@femalepose@solo@firstsport",
            clipset = "fem_pose_sport_004",
            flag = 1,
            duration = 45000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["stamina"] = { updateAmount = 0.1, notify = true },
                ["strength"] = { updateAmount = 0.1, notify = true },
                ["hunger"] = { updateAmount = -2, notify = true },
                ["thirst"] = { updateAmount = -3, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        },
        ["boxing"] = {
            icon = "fa-solid fa-hand-fist",
            label = "Do Boxing",
            scenario = nil,
            dictionary = "anim@mp_player_intcelebrationmale@shadow_boxing",
            clipset = "shadow_boxing",
            duration = 25000,
            prop = {
                model = nil,
                bone = nil,
                pos = vector3(0.0, 0.0, 0.0),
                rot = vector3(0.0, 0.0, 0.0)
            },
            effects = {
                ["strength"] = { updateAmount = 0.1, notify = true },
                ["hunger"] = { updateAmount = -1, notify = true },
                ["thirst"] = { updateAmount = -3, notify = true },
            },
            skillCheck = {
                mode = "easy",                -- "easy" or "medium" or "hard" or {"easy", "hard", "medium", etc...} => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
                interval = 2000,
                keys = { "w", "a", "s", "d" } -- input keys => (https://overextended.github.io/docs/ox_lib/Interface/Client/skillcheck)
            }
        }
    },

    locations = {
        ["paletobay"] = {
            label = "Paleto Bay Gymnasium",
            coords = vector3(-376.49, 6048.04, 31.48),
            distance = 20.0,
            blip = {
                sprite = 311,
                color = 49,
                scale = 0.8
            },
            zones = {
                workouts = {
                    ["benchpress"] = {
                        {
                            coords = vector3(-371.46, 6035.89, 31.23),
                            size = vector3(1.5, 1.5, 1.5),
                            rotation = 134.65,
                            unique = vector4(-371.55, 6035.77, 29.97, 134.65) -- position that the player will be set in to play the workout animation
                        },
                        {
                            coords = vector3(-372.76, 6037.21, 31.23),
                            size = vector3(1.5, 1.5, 1.5),
                            rotation = 134.65,
                            unique = vector4(-372.85, 6037.09, 29.97, 134.65) -- position that the player will be set in to play the workout animation
                        }
                    },
                    ["pullup"] = {
                        {
                            coords = vector3(-374.69, 6040.30, 31.48),
                            size = vector3(0.5, 1.0, 1.5),
                            rotation = 134.65,
                            unique = vector4(-374.69, 6040.30, 30.46, 134.65) -- position that the player will be set in to play the workout animation
                        },
                        {
                            coords = vector3(-375.97, 6041.60, 31.48),
                            size = vector3(0.5, 1.0, 1.5),
                            rotation = 134.65,
                            unique = vector4(-375.97, 6041.60, 30.46, 134.65) -- position that the player will be set in to play the workout animation
                        }
                    },
                    ["freeweight100kg"] = {
                        {
                            coords = vector3(-378.09, 6042.60, 31.39),
                            size = vector3(1.5, 1.5, 1.5),
                            rotation = 134.65
                        },
                        {
                            coords = vector3(-370.0, 6035.03, 31.47),
                            size = vector3(1.5, 2.5, 1.5),
                            rotation = 134.65
                        },
                        {
                            coords = vector3(-377.64, 6048.88, 31.48),
                            size = vector3(3.5, 2.5, 1.5),
                            rotation = 134.65
                        }
                    },
                    ["treadmill"] = {
                        {
                            coords = vector3(-386.21, 6052.86, 31.30),
                            size = vector3(2.0, 1.0, 1.5),
                            rotation = 134.65
                        }
                    },
                    ["dumbbell"] = {
                        {
                            coords = vector3(-374.89, 6036.52, 31.45),
                            size = vector3(5.0, 2.0, 1.5),
                            rotation = 134.65
                        },
                        {
                            coords = vector3(-380.9, 6045.81, 31.46),
                            size = vector3(3.5, 6.0, 1.5),
                            rotation = 134.65
                        }
                    },
                    ["dumbbellpink"] = {
                        {
                            coords = vector3(-372.11, 6042.54, 31.47),
                            size = vector3(2.5, 3.0, 1.5),
                            rotation = 134.65
                        },
                        {
                            coords = vector3(-369.93, 6044.8, 31.45),
                            size = vector3(1.5, 1.5, 1.5),
                            rotation = 134.65
                        }
                    },
                    ["yoga"] = {
                        {
                            coords = vector3(-372.53, 6034.12, 31.45),
                            size = vector3(1.5, 2.0, 1.5),
                            rotation = 134.65
                        },
                        {
                            coords = vector3(-366.29, 6040.67, 31.44),
                            size = vector3(4.0, 2.4, 1.5),
                            rotation = 134.65
                        }
                    },
                    ["boxing"] = {
                        {
                            coords = vector3(-368.8, 6043.0, 31.45),
                            size = vector3(2.5, 2.0, 1.5),
                            rotation = 134.65
                        }
                    },
                    ["plank"] = {
                        {
                            coords = vector3(-370.92, 6044.13, 31.45),
                            size = vector3(2.0, 0.8, 1.5),
                            rotation = 134.65
                        },
                        {
                            coords = vector3(-368.22, 6039.8, 31.47),
                            size = vector3(6.0, 1.5, 1.5),
                            rotation = 134.65
                        }
                    },
                    ["situp"] = {
                        {
                            coords = vector3(-373.75, 6044.22, 31.48),
                            size = vector3(2.0, 5.0, 1.5),
                            rotation = 134.65
                        },
                        {
                            coords = vector3(-368.18, 6036.86, 31.45),
                            size = vector3(1.5, 2.5, 1.5),
                            rotation = 134.65
                        }
                    },
                    ["pushup"] = {
                        {
                            coords = vector3(-375.20, 6045.74, 31.48),
                            size = vector3(2.0, 6.0, 1.5),
                            rotation = 134.65
                        },
                        {
                            coords = vector3(-370.65, 6038.94, 31.45),
                            size = vector3(4.5, 3.0, 1.5),
                            rotation = 134.65
                        }
                    }
                },
                showers = {
                    -- TODO
                }
            }
        }
    }
}
