import React from "react";
import { GameStates } from "../helpers/GameStates";
import { Player } from "../helpers/Player";
import { Teams } from "../helpers/Teams";
import ScoreboardPlayer from "./ScoreboardPlayer";

interface Props {
    team: Teams;
    score: number;
    players?: Player[];
    clientPlayer: Player;
    gameState: GameStates;
}

const ScoreboardTeam: React.FC<Props> = ({ team, score, players, clientPlayer, gameState }) => {

    const getAlivePlayersCount = () => {
        if (players !== undefined && players.length > 0) {
            var alive = Object.values(players).filter(item => item.isDead === false);
            return alive.length;
        } else {
            return 0;
        }
    }

    return (
        <>
            <div className={"team " + ((team === Teams.Attackers) ? 'attackers' : 'defenders') + ' gameState' + gameState.toString()} >
                <div className="headerBar">
                    <div className="teamName">
                        Scoreboard
                        <span className="alive">{getAlivePlayersCount()} alive</span>
                    </div>
                    <div className="point"></div>
                </div>
                <div className="playersHolderHeader">
                    <div className="playerPosition"></div>
                    <div className="playerPosition">Pos</div>
                    <div className="playerName">Name</div>
                    <div className="playerKill">Kills</div>
                    <div className="playerDeath">Deaths</div>
                    <div className="playerPing">Ping</div>
                </div>
                <div className="playersHolder">
                    <div className="playersHolderInner">
                        {(players !== undefined && players.length > 0)
                        ?
                            players.map((player: Player, place: number) => (
                                <ScoreboardPlayer player={player} place={place} clientPlayer={clientPlayer} gameState={gameState} />
                            ))
                        :
                            <div className="noPlayers">No players...</div>
                        }
                    </div>
                </div>
            </div>
        </>
    );
};

export default ScoreboardTeam;
