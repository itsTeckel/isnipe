import React, { useState } from "react";
import PromodSelect from "../components/PromodSelect";
import Title from "../components/Title";
import { Kits } from "../helpers/Kits";

import './LoadoutScene.scss';
import prepare1 from "../assets/audio/prepare/prepare.wav";
import prepare2 from "../assets/audio/prepare/prepare2.wav";
import prepare3 from "../assets/audio/prepare/prepare3.wav";
import {Settings} from "../helpers/Settings";

interface Loadout {
    class: string|null;
    primary: any;
    secondary: any;
    tactical: any;
    lethal: any;
    primaryAttachments: any;
}

interface Props {
    show: boolean;
    setShowLoadoutPage: (show: boolean) => void;
    settings: Settings;
    setSettings: (settings: Settings) => void;
}

const LoadoutScene: React.FC<Props> = ({ show, setShowLoadoutPage, settings, setSettings }) => {
    const [currentLoadout, setCurrentLoadout] = useState<Loadout>({
        class: null,
        primary: null,
        secondary: null,
        tactical: null,
        lethal: null,
        primaryAttachments: null,
    });

    const [openClassWindow, setOpenClassWindow] = useState<boolean>(false);
    const [selectedClass, setSelectedClass] = useState<number|null>(null);

    const discordSelect = (event: any) => {
        event.target.select();
        document.execCommand("copy");
    }

    const onClickSelectedClass = (key: number) => {
        setSelectedClass(key);
        setOpenClassWindow(true);
        console.log("abu");
        let weapons = Kits[key]["Weapons"];
        console.log(weapons, key)
        if(weapons != null) {
            setCurrentLoadout({
                class: Kits[key].Name,
                primary: weapons.Primary[weapons.defaultPrimary],
                secondary: weapons.Secondary[weapons.defaultSecondary],
                tactical: weapons.Tactical[weapons.defaultTactical],
                lethal: weapons.Lethal[weapons.defaultLethal],
                primaryAttachments: {
                    Sights: weapons.Primary[weapons.defaultPrimary].Attachments.Sights.default,
                    Primary: weapons.Primary[weapons.defaultPrimary].Attachments.Primary.default,
                    Secondary: weapons.Primary[weapons.defaultPrimary].Attachments.Secondary.None,
                },
            });
        }
    }

    const onSelectedWeaponChange = (slot: string, weapon: string) => {
        if(selectedClass !== null) {
            let weapons = Kits[selectedClass]["Weapons"];

            switch (slot) {
                case 'Primary Weapon':
                    setCurrentLoadout(prevState => ({
                        ...prevState,
                        primary: weapons.Primary[weapon],
                        primaryAttachments: {
                            Sights: weapons.Primary[weapon].Attachments.Sights.default,
                            Primary: weapons.Primary[weapon].Attachments.Primary.default,
                            Secondary: weapons.Primary[weapon].Attachments.Secondary.None,
                        },
                    }));
                    break;
                case 'Secondary Weapon':
                    setCurrentLoadout(prevState => ({
                        ...prevState,
                        secondary: weapons.Secondary[weapon],
                    }));
                    break;
                case 'Tactical':
                    setCurrentLoadout(prevState => ({
                        ...prevState,
                        tactical: weapons.Tactical[weapon],
                    }));
                    break;
                case 'Lethal':
                    setCurrentLoadout(prevState => ({
                        ...prevState,
                        lethal: weapons.Lethal[weapon],
                    }));
                    break;
                default:
                    break;
            }
        }
    }

    const onSelectedAttachmentChange = (slot: string, attachment: string) => {
        if(selectedClass !== null) {
            switch (slot) {
                case "Sights":
                    setCurrentLoadout(prevState => ({
                        ...prevState,
                        primaryAttachments: {
                            Sights: prevState.primary.Attachments[slot][attachment],
                            Primary: prevState.primaryAttachments.Primary,
                            Secondary: prevState.primaryAttachments.Secondary,
                        },
                    }));
                    break;
                case "Primary":
                    setCurrentLoadout(prevState => ({
                        ...prevState,
                        primaryAttachments: {
                            Sights: prevState.primaryAttachments.Sights,
                            Secondary: prevState.primaryAttachments.Secondary,
                            Primary: prevState.primary.Attachments[slot][attachment],
                        },
                    }));
                    break;
                case "Secondary":
                    setCurrentLoadout(prevState => ({
                        ...prevState,
                        primaryAttachments: {
                            Sights: prevState.primaryAttachments.Sights,
                            Primary: prevState.primaryAttachments.Primary,
                            Secondary: prevState.primary.Attachments[slot][attachment],
                        },
                    }));
                    break;
                default:
                    break;
            }
        }
    }

    const playPrepare = () => {
        let audio;
        switch(Math.floor(Math.random() * 2)) {
            case 0:
                audio = new Audio(prepare1);
                break
            case 1:
                audio = new Audio(prepare2);
                break
            case 2:
                audio = new Audio(prepare3);
                break
            default:
                audio = new Audio(prepare3);
                break
        }
        audio.volume = 1;
        audio.loop = false;
        audio.play();
    }

    const doneLoadout = () => {
        currentLoadout.class = "a";
        if (navigator.userAgent.includes('VeniceUnleashed')) {
            WebUI.Call('DispatchEventLocal', 'WebUISetSelectedLoadout', JSON.stringify(currentLoadout));
            WebUI.Call('ResetKeyboard');
            WebUI.Call('ResetMouse');
        }
        setShowLoadoutPage(false);
        if(settings.killStreakSound) {
            playPrepare();
        }
    }

    const getWeaponSlot = (name: string, weapons: any, defaultIndex: string) => {
        const defaultValue = { value: '', label: '' };

        const options: Array<{value: string, label: string}> = [];
        Object.keys(weapons).forEach((value: string, key: number) => {
            options.push({
                value: value,
                label: weapons[value].Name,
            });

            if(value === defaultIndex) {
                defaultValue.value = value;
                defaultValue.label = weapons[value].Name;
            }
        });

        let value;
        switch (name) {
            case 'Primary Weapon':
                value = currentLoadout.primary;
                break;
            case 'Secondary Weapon':
                value = currentLoadout.secondary;
                break;
            case 'Tactical':
                value = currentLoadout.tactical;
                break;
            case 'Lethal':
                value = currentLoadout.lethal;
                break;
            default:
                break;
        }

        return (
            <>
                <h3>{name ?? ''}</h3>
                <PromodSelect 
                    type={name}
                    options={options} 
                    defaultValue={defaultValue} 
                    small={false}
                    onChangeSelected={(slot: string, weapon: string) => onSelectedWeaponChange(slot, weapon)}
                    selectValue={{
                        value: value.Key,
                        label: value.Name,
                    }}
                />
            </>
        );
    }

    const getAttachmentOptions = (key: string) => {
        let attachments = currentLoadout.primary.Attachments[key];

        const options: Array<{value: string, label: string}> = [];
        Object.keys(attachments).forEach((value: string, key: number) => {
            options.push({
                value: value,
                label: attachments[value].Name,
            });
        });

        return options;
    }

    const getWeaponAttachmentSlot = (name: string) => {
        let value = {
            value: (currentLoadout.primaryAttachments[name] ? currentLoadout.primaryAttachments[name].Key : ''),
            label: (currentLoadout.primaryAttachments[name] ? currentLoadout.primaryAttachments[name].Name : ''),
        };

        return (
            <div className="attachment">
                <h3>{name}</h3>
                <PromodSelect 
                    type={name}
                    options={getAttachmentOptions(name)} 
                    defaultValue={getAttachmentOptions(name)[0]} 
                    small={true}
                    onChangeSelected={(slot: string, weapon: string) => onSelectedAttachmentChange(name, weapon)}
                    selectValue={value}
                />
            </div>
        )
    }

    const onSettingChange = (key: String) => {
        // @ts-ignore
        settings[key] = !settings[key];
        setSettings(settings);
    }

    if(currentLoadout.class === null) {
        onClickSelectedClass(0);
    }
    return (
        <>
            {show &&
                <div id="pageLoadout" className="page">
                    <Title text="Select" />
                    <div>
                        <div className="classesList">
                            {Object.keys(Kits).map((val: string, key: number) =>
                                <button key={key} onClick={() => onClickSelectedClass(key)} className={"btn border-btn " + (selectedClass === key ? 'secondary' : '')}>
                                    {Kits[key].Name}
                                </button>
                            )}
                        </div>

                        {openClassWindow &&
                            <>
                                <div className="loadoutList">
                                    {Object.keys(Kits).map((value: string, key: number) =>
                                        <div key={key}>
                                            {selectedClass === key && Kits[key]["Weapons"] &&
                                                <>
                                                    {getWeaponSlot("Primary Weapon", Kits[key]["Weapons"].Primary, Kits[key]["Weapons"].defaultPrimary)}

                                                    <div className="attachments">
                                                        {getWeaponAttachmentSlot("Sights")}
                                                        {getWeaponAttachmentSlot("Primary")}
                                                        {getWeaponAttachmentSlot("Secondary")}
                                                    </div>

                                                    <button className="btn border-btn primary" onClick={doneLoadout}>
                                                        Start
                                                    </button>
                                                </>
                                            }

                                            {selectedClass === key && Kits[key]["Settings"] &&
                                            <>
                                                <a>Killstreak sounds</a> <input type="checkbox" defaultChecked={settings["killStreakSound"]} onChange={() => {onSettingChange("killStreakSound")}} />
                                            </>
                                            }
                                        </div>
                                    )}
                                </div>
                            </>
                        }
                    </div>
                    {/*<a id="discord-join" title="Join us on Discord">*/}
                    {/*    <img src="https://discordapp.com/api/guilds/796833114319618099/embed.png?style=banner4" />*/}
                    {/*    <input onClick={discordSelect} value="https://discord.gg/YDXDA6QBkf" />*/}
                    {/*</a>*/}
                    <Title text="F10 - To close Loadouts window" bottom={true} />
                </div>
            }
        </>
    );
};

export default LoadoutScene;
