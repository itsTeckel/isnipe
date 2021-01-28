import { Weapons } from './Weapons';

export var Kits: any = [
    {
        Name: "Edit loadout",
        Weapons: {
            Primary: {
                U_SV98: Weapons.U_SV98,
                U_M40A5: Weapons.U_M40A5,
                U_M98B: Weapons.U_M98B,
                U_L96: Weapons.U_L96,
                U_JNG90: Weapons.U_JNG90,
            },
            Secondary: {
                None: Weapons.None,
            },
            Tactical: {
                None: Weapons.None,
            },
            Lethal: {
                None: Weapons.None,
            },
            defaultPrimary: Weapons.U_L96.Key,
            defaultSecondary: Weapons.None.Key,
            defaultTactical: Weapons.None.Key,
            defaultLethal: Weapons.None.Key,
        },
    },
    {
        Name: "Settings",
        Settings: {},
    }
];
