import React from "react";
import { Player, Players } from "../helpers/Player";

import './WarmupScene.scss';

interface Props {
    rupProgress: number;
    clientPlayer: Player;
    players: Players;
}

const WarmupScene: React.FC<Props> = ({ rupProgress, clientPlayer }) => {
    return (
        <>
            <div id="pageWarmup" className="page">

                <div id="tutorial">
                    <div className="keyHolder keyF10">
                        <span>F10</span>
                        <h3>Loadouts</h3>
                    </div>
                </div>

                
            </div>
        </>
    );
};

export default WarmupScene;
