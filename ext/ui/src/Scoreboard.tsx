import React from "react";
import ScoreboardTeam from "./components/ScoreboardTeam";
import { GameStates } from "./helpers/GameStates";
import { Players, Player } from "./helpers/Player";
import { RoundInfo } from "./helpers/RoundInfo";
import { Teams } from "./helpers/Teams";

import './Scoreboard.scss';

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

const Scoreboard: React.FC<Props> = ({ showScoreboard, teamAttackersScore, teamDefendersScore, players, clientPlayer, gameState, round, maxRounds, roundsList }) => {
    const rounds = [];

    return (
        <>
            {showScoreboard &&
                <div id="inGameScoreboard" className="fadeInBottom">
                    <ScoreboardTeam team={Teams.All} score={teamAttackersScore} players={players[Teams.All]} clientPlayer={clientPlayer} gameState={gameState} />
                </div>
            }
        </>
    );
};

Scoreboard.defaultProps = {
    showScoreboard: false,
};


export default Scoreboard;
