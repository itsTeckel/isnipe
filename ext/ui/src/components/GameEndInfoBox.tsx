import React, { useEffect } from "react";
import ScoreboardTeam from "../components/ScoreboardTeam";
import { GameStates } from "../helpers/GameStates";
import { Players, Player } from "../helpers/Player";
import { RoundInfo } from "../helpers/RoundInfo";
import { Teams } from "../helpers/Teams";
import winner from '../assets/img/winner.png';
import './GameEndInfoBox.scss';
import winSound from '../assets/audio/win.mp3';
import loseSound from '../assets/audio/lose.mp3';

interface Props {
    showScoreboard: boolean;
    teamAttackersScore: number;
    teamDefendersScore: number;
    players: Players;
    clientPlayer: Player;
    gameState: GameStates;
    round: number;
    maxRounds: number;
    roundsList: RoundInfo[];
}

const GameEndInfoBox: React.FC<Props> = ({ showScoreboard, teamAttackersScore, teamDefendersScore, players, clientPlayer, gameState, round, maxRounds, roundsList }) => {
    var iswinner = clientPlayer.index <= 3;
    if(showScoreboard) {
        let audio;
        if (iswinner) {
            audio = new Audio(winSound);
        } else {
            audio = new Audio(loseSound);
        }
        audio.volume = 1;
        audio.loop = false;
        audio.play();
    }
    
    return (
        <>
            {showScoreboard &&
                <div>
                    <div id="inGameScoreboard" className="fadeInBottom">
                        <ScoreboardTeam team={Teams.All} score={teamAttackersScore} players={players[Teams.All]} clientPlayer={clientPlayer} gameState={gameState} />
                    </div>
                    {iswinner &&
                    <img id="winner" src={winner}/>
                    }
                </div>
            }
        </>
    );
};

GameEndInfoBox.defaultProps = {
    showScoreboard: false,
};

export default GameEndInfoBox;
