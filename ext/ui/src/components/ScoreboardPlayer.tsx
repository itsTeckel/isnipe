import React from "react";
import { GameStates } from "../helpers/GameStates";
import { Player } from "../helpers/Player";

interface Props {
    player: Player;
    gameState: GameStates;
}

const ScoreboardPlayer: React.FC<Props> = ({ player, gameState }) => {
    return (
        <>
            {player.name &&
                <div className={"playerHolder " + (player.isDead ? 'isDead' : 'isAlive')}>

                    {(gameState === GameStates.Warmup) &&
                        <div className={"playerReady " + (player.isReady ? 'ready' : 'wait')}>{player.isReady ? 'Ready' : 'Waiting'}</div>
                    }

                    <div className="playerName">{player.name??' - '}</div>
                    <div className="playerKill">{player.kill??' - '}</div>
                    <div className="playerDeath">{player.death??' - '}</div>
                    <div className="playerPing">{player.ping??0}</div>
                </div>
            }
        </>
    );
};

export default ScoreboardPlayer;
