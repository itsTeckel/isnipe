import React from "react";
import { GameStates } from "../helpers/GameStates";
import { Player } from "../helpers/Player";

interface Props {
    player: Player;
    clientPlayer: Player;
    place: number;
    gameState: GameStates;
}

const ScoreboardPlayer: React.FC<Props> = ({ player, clientPlayer, place, gameState }) => {
    const position = window.stringifyNumber(place + 1)
    const curPlayer = clientPlayer.id == player.id ? "curPlayer " : ""
    return (
        <>
            {player.name &&
                <div className={"playerHolder " + curPlayer + (player.isDead ? 'isDead ' : 'isAlive ') + 'pos'+place}>
                    <div className="playerAvatar"><img width="32px" src={"https://discord.imunro.nl/avatar?username="+player.name}/> </div>
                    <div className="playerPosition">{position}</div>
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
