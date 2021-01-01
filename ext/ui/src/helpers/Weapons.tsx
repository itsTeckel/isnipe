export let Weapons = {
    // Sniper
    U_M98B: {
        Key: "U_M98B",
        Name: "M98B",
        Image: "fb://UI/Art/Persistence/Weapons/m98b",
        Vext: "Weapons/Model98B/U_M98B",
        Attachments: {
            Sights: {
                default: {
                    Key: "U_M98B_Rifle_Scope",
                    Name: "Rifle Scope (8x)",
                    Vext: "Weapons/Model98B/U_M98B_Rifle_Scope",
                },
                U_L96_ACOG: {
                    Key: "U_L96_ACOG",
                    Name: "ACOG (4x)",
                    Vext: "Weapons/Model98B/U_M98B_Acog",
                },
            },
            Primary: {
                default: {
                    Key: "U_M98B_StraightPull",
                    Name: "Straight Pull Bolt",
                    Vext: "Weapons/Model98B/U_M98B_StraightPull",
                },
            },
            Secondary: {
                None: {
                    Key: "Knife",
                    Name: "Knife",
                    Vext: "Weapons/Knife/U_Knife",
                },
                // None: {
                //     Key: "None",
                //     Name: "No Secondary",
                //     Vext: "",
                // },
            },
        },
    },
    U_L96: {
        Key: "U_L96",
        Name: "L96A1",
        Image: "fb://UI/Art/Persistence/Weapons/l96",
        Vext: "Weapons/XP1_L96/U_L96",
        Attachments: {
            Sights: {
                default: {
                    Key: "U_L96_Rifle_Scope",
                    Name: "Rifle Scope (8x)",
                    Vext: "Weapons/XP1_L96/U_L96_Rifle_Scope",
                },
                U_L96_ACOG: {
                    Key: "U_L96_ACOG",
                    Name: "ACOG (4x)",
                    Vext: "Weapons/XP1_L96/U_L96_ACOG",
                },
            },
            Primary: {
                default: {
                    Key: "U_L96_StraightPull",
                    Name: "Straight Pull Bolt",
                    Vext: "Weapons/XP1_L96/U_L96_StraightPull",
                },
            },
            Secondary: {
                None: {
                    Key: "Knife",
                    Name: "Knife",
                    Vext: "Weapons/Knife/U_Knife",
                },
            },
        },
    },
    U_SV98: {
        Key: "U_SV98",
        Name: "SV98",
        Image: "fb://UI/Art/Persistence/Weapons/sv98",
        Vext: "Weapons/SV98/U_SV98",
        Attachments: {
            Sights: {
                default: {
                    Key: "U_SV98_Rifle_scope",
                    Name: "Rifle Scope (8x)",
                    Vext: "Weapons/SV98/U_SV98_Rifle_Scope",
                },
            },
            Primary: {
                default: {
                    Key: "U_SV98_StraightPull",
                    Name: "Straight Pull Bolt",
                    Vext: "Weapons/SV98/U_SV98_StraightPull",
                },
            },
            Secondary: {
                None: {
                    Key: "Knife",
                    Name: "Knife",
                    Vext: "Weapons/Knife/U_Knife",
                },
            },
        },
    },

    U_M40A5: {
        Key: "U_M40A5",
        Name: "M40A5",
        Image: "fb://UI/Art/Persistence/Weapons/M40A5",
        Vext: "Weapons/M40A5/U_M40A5",
        Attachments: {
            Sights: {
                default: {
                    Key: "U_M40A5_Rifle_scope",
                    Name: "Rifle Scope (8x)",
                    Vext: "Weapons/M40A5/U_M40A5_Rifle_Scope",
                },
            },
            Primary: {
                default: {
                    Key: "U_M40A5_StraightPull",
                    Name: "Straight Pull Bolt",
                    Vext: "Weapons/M40A5/U_M40A5_StraightPull",
                },
            },
            Secondary: {
                None: {
                    Key: "Knife",
                    Name: "Knife",
                    Vext: "Weapons/Knife/U_Knife",
                },
            },
        },
    },

    U_JNG90: {
        Key: "U_JNG90",
        Name: "JNG-90",
        Image: "fb://UI/Art/Persistence/Weapons/JNG90",
        Vext: "Weapons/XP2_JNG90/U_JNG90",
        Attachments: {
            Sights: {
                default: {
                    Key: "U_JNG90_Rifle_Scope",
                    Name: "Rifle Scope (8x)",
                    Vext: "Weapons/XP2_JNG90/U_JNG90_Rifle_Scope",
                },
            },
            Primary: {
                default: {
                    Key: "U_M40A5_StraightPull",
                    Name: "Straight Pull Bolt",
                    Vext: "Weapons/XP2_JNG90/U_JNG90_StraightPull",
                },
            },
            Secondary: {
                None: {
                    Key: "Knife",
                    Name: "Knife",
                    Vext: "Weapons/Knife/U_Knife",
                },
            },
        },
    },

    // Secondary
    U_M9: {
        Key: "U_M9",
        Name: "M9",
        Image: "fb://UI/Art/Persistence/Weapons/m9",
        Vext: "Weapons/M9/U_M9",
    },
    U_Taurus44: {
        Key: "U_Taurus44",
        Name: ".44 Magnum",
        Image: "fb://UI/Art/Persistence/Weapons/taurus44",
        Vext: "Weapons/Taurus44/U_Taurus44",
    },

    // Tactical
    U_C4: {
        Key: "U_C4",
        Name: "C4",
        Image: "fb://UI/Art/Persistence/Weapons/C4",
        Vext: "Weapons/Gadgets/C4/U_C4",
    },
    U_Medkit: {
        Key: "U_Medkit",
        Name: "Medkit",
        Image: "fb://UI/Art/Persistence/Weapons/MedicBag",
        Vext: "Weapons/Gadgets/Medicbag/U_Medkit",
    },
    U_Ammobag: {
        Key: "U_Ammobag",
        Name: "Ammobag",
        Image: "fb://UI/Art/Persistence/Weapons/Ammobag",
        Vext: "Weapons/Gadgets/Ammobag/U_Ammobag",
    },
    U_UGS: {
        Key: "U_UGS",
        Name: "T-UGS",
        Image: "fb://UI/Art/Persistence/Weapons/t-ugs",
        Vext: "Weapons/Gadgets/T-UGS/U_UGS",
    },
    U_Claymore: {
        Key: "U_Claymore",
        Name: "Claymore",
        Image: "fb://UI/Art/Persistence/Weapons/claymore",
        Vext: "Weapons/Gadgets/Claymore/U_Claymore",
    },
    U_MAV: {
        Key: "U_MAV",
        Name: "MAV",
        Image: "fb://UI/Art/Persistence/Weapons/mav",
        Vext: "Weapons/Gadgets/MAV/U_MAV",
    },
    U_M320_SMK: {
        Key: "U_M320_SMK",
        Name: "M320 Smoke",
        Image: "fb://UI/Art/Persistence/Weapons/m320",
        Vext: "Weapons/Gadgets/M320/U_M320_SMK",
    },


    // Lethal
    U_M67: {
        Key: "U_M67",
        Name: "M67 Grenade",
        Image: "fb://UI/Art/Persistence/Weapons/Grenade",
        Vext: "Weapons/M67/U_M67",
    },

    None: {
        Key: "None",
        Name: "None",
        Vext: "",
    },
}
