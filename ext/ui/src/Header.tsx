import React from "react";
import { GameStates, GameStatesRoundString } from "./helpers/GameStates";
import { GameTypes, GameTypesString } from './helpers/GameTypes';
import { useTimer } from "react-compound-timer/build/hook/useTimer";

import {  Player, Players } from "./helpers/Player";
import { Teams } from "./helpers/Teams";


import skull from './assets/img/human-skull.svg';
import like from './assets/img/helmet.svg';

import './Header.scss';

interface Props {
    showHud: boolean;
    clientPlayer: Player;
    killStreak: number;
}

const Header: React.FC<Props> = ({
    showHud,
    clientPlayer,
    killStreak
 }) => {
    window.SetTimer = function(p_Time: number) {
        setTime(1000 * p_Time);
        start();
        reset();
    }
    var position = "-";
    if(clientPlayer["id"] != -1) {
        position = window.stringifyNumber(clientPlayer["index"]);
    }

    const { value, controls: { setTime, reset, start }} = useTimer({ initialTime: 0, direction: "backward", startImmediately: false });

    return (
        <>
            <div id="promodHeader">
                iSnipe
            </div>

            <div id="promodVersion">
                v 1.0
            </div>

            <div id="debug">
                <button onClick={() => window.SetTimer(300)}>300 sec</button>
                <button onClick={() => window.SetTimer(200)}>200 sec</button>
                <button onClick={() => window.SetTimer(100)}>100 sec</button>
            </div>

            {showHud &&
                <div id="inGameHeader" className="fadeInTop">
                    <div className="playerIcons attackers">
                    </div>
                    <div id="score">
                        <div id="scoreAttackers">
                            <span className="points">{position}</span>
                        </div>
                        <div id="roundTimer">
                            <span className={"timer"}>
                                {(value !== null)
                                ?
                                    <>
                                        {(value.m < 10 ? `0${value.m}` : value.m)}:{(value.s < 10 ? `0${value.s}` : value.s)}
                                    </>
                                :
                                    <>
                                        00:00
                                    </>
                                }
                            </span>
                            <div className="gameTypeLabel">
                                Sniper only
                            </div>
                        </div>
                        <div id="scoreDefenders">
                            <span className="points">{killStreak} streak</span>
                        </div>
                    </div>
                    <div className="playerIcons defenders">
                    </div>
                </div>
            }
        </>
    );
};

Header.defaultProps = {

};

export default Header;

declare global {
    interface Window {
        SetTimer: (p_Time: number) => void;
    }
}
