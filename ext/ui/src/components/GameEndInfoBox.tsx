import React, { useEffect } from "react";
import ScoreboardTeam from "../components/ScoreboardTeam";
import { GameStates } from "../helpers/GameStates";
import { Players, Player } from "../helpers/Player";
import { RoundInfo } from "../helpers/RoundInfo";
import { Teams } from "../helpers/Teams";
import winner from '../assets/img/winner.png';

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
    return (
        <>
            {showScoreboard &&
                <div>
                    <div id="inGameScoreboard" className="fadeInBottom">
                        <ScoreboardTeam team={Teams.All} score={teamAttackersScore} players={players[Teams.All]} clientPlayer={clientPlayer} gameState={gameState} />
                    </div>
                    <img src={winner} />
                </div>
            }
        </>
    );
};

GameEndInfoBox.defaultProps = {
    showScoreboard: false,
};

export default GameEndInfoBox;
