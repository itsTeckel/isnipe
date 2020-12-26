import { Teams } from "./Teams";

export interface Player {
    id?: number,
    name: string;
    ping: number;
    kill: number;
    death: number;
    isDead: boolean;
    index: number;
    team?: Teams;
};

export interface Players {
    [Teams.All]: Player[],
    [Teams.Attackers]: Player[],
    [Teams.Defenders]: Player[],
}
