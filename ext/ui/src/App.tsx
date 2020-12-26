import React, { useState } from "react";

import Header from "./Header";
import Scoreboard from "./Scoreboard";

import RoundEndInfoBox from "./components/RoundEndInfoBox";

import TeamsScene from "./scenes/TeamsScene";
import WarmupScene from "./scenes/WarmupScene";
import EndgameScene from "./scenes/EndgameScene";
import KnifeRoundScene from "./scenes/KnifeRoundScene";
import LoadoutScene from "./scenes/LoadoutScene";

import { GameStates } from './helpers/GameStates';
import { GameTypes } from './helpers/GameTypes';
import { Teams } from "./helpers/Teams";
import { Player, Players } from "./helpers/Player";

import GameEndInfoBox from "./components/GameEndInfoBox";
import BombPlantInfoBox from "./components/BombPlantInfoBox";
import PlantOrDefuseProgress from "./components/PlantOrDefuseProgress";

import './Animations.scss';
import './Global.scss';
import Spectator from "./components/Spectator";
import { RoundInfo } from "./helpers/RoundInfo";

const App: React.FC = () => {
    /*
    * Debug
    */
    let debugMode: boolean = false;
    if (!navigator.userAgent.includes('VeniceUnleashed')) {
        if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
            debugMode = true;
        }
    }

    /*
    * Local States
    */
    const [scene, setScene] = useState<GameStates>(GameStates.None);

    window.ChangeState = function (p_GameState: GameStates) {
        setScene(p_GameState);

        if (p_GameState !== GameStates.None && showHud !== true) {
            setShowHud(true)
        }

        // Reset plant progress
        setPlantProgress(0);
        setPlantOrDefuse("plant");
    }

    const [gameType, setGameType] = useState<GameTypes>(GameTypes.Comp);

    window.ChangeType = function (p_GameType: GameTypes) {
        setGameType(p_GameType);
    }

    /*
    * Global States 
    */
    const [showHud, setShowHud] = useState<boolean>(false);

    const [roundsList, setRoundsList] = useState<RoundInfo[]>([
        {
            winner: Teams.Attackers,
        },
        {
            winner: Teams.Defenders,
        },
    ]);
    
    const [round, setRound] = useState<number>(0);
    const [roundWon, setRoundWon] = useState<boolean>(false);
    const [winningTeam, setWinningTeam] = useState<Teams>(Teams.Attackers);
    const [teamAttackersScore, setTeamAttackersScore] = useState<number>(0);
    const [teamDefendersScore, setTeamDefendersScore] = useState<number>(0);
    const [bombPlantedOn, setBombPlantedOn] = useState<string|null>(null);

    window.UpdateHeader = function (p_AttackerPoints: number, p_DefenderPoints: number, p_Rounds: number, p_BombSite?: string) {
        setTeamAttackersScore(p_AttackerPoints);
        setTeamDefendersScore(p_DefenderPoints);
        setRound(p_Rounds);

        if (p_BombSite === undefined || p_BombSite === null || p_BombSite === 'nil') {
            setBombPlantedOn(null);
        } else {
            setBombPlantedOn(p_BombSite.toString());
        }
    }

    const [maxRounds, setMaxRounds] = useState<number>(12);
    
    window.RoundCount = function (p_Count: number) {
        setMaxRounds(p_Count);
    }

    const [showTeamsPage, setShowTeamsPage] = useState<boolean>(false);
    const [selectedTeam, setSelectedTeam] = useState<Teams>(Teams.None);
    const [showScoreboard, setShowScoreboard] = useState<boolean>(false);

    const setTeam = (team: Teams) => {
        setShowTeamsPage(false);
        setSelectedTeam(team);
        setShowLoadoutPage(true);
    }

    window.OpenCloseTeamMenu = function (forceOpen?: boolean) {
        if (showLoadoutPage) {
            setShowLoadoutPage(false);
        }

        if (showScoreboard) {
            setShowScoreboard(false);
        }

        if (!showTeamsPage) {
            WebUI.Call('DisableKeyboard');
            WebUI.Call('EnableMouse');
        } else {
            WebUI.Call('ResetKeyboard');
            WebUI.Call('ResetMouse');
        }

        if(forceOpen) {
            setShowTeamsPage(true);
        } else {
            setShowTeamsPage(prevState => !prevState);
        }
    }

    const [showLoadoutPage, setShowLoadoutPage] = useState<boolean>(false);

    window.OpenCloseLoadoutMenu = function () {
        if (showTeamsPage) {
            setShowTeamsPage(false);
        }

        if (showScoreboard) {
            setShowScoreboard(false);
        }

        if (!showLoadoutPage) {
            WebUI.Call('DisableKeyboard');
            WebUI.Call('EnableMouse');
        } else {
            WebUI.Call('ResetKeyboard');
            WebUI.Call('ResetMouse');
        }

        setShowLoadoutPage(prevState => !prevState);
    }


    const [showRoundEndInfoBox, setShowRoundEndInfoBox] = useState<boolean>(false);

    window.ShowHideRoundEndInfoBox = function (open: boolean) {
        setShowRoundEndInfoBox(open);
    }

    window.UpdateRoundEndInfoBox = function (p_RoundWon: boolean, p_WinningTeam: string) {
        setRoundWon(p_RoundWon);
        if(p_WinningTeam === 'attackers') {
            setWinningTeam(Teams.Attackers);
        } else {
            setWinningTeam(Teams.Defenders);
        }
    }

    const [gameWon, setGameWon] = useState<boolean|null>(null);
    const [gameWinningTeam, setGameWinningTeam] = useState<Teams|null>(null);
    window.SetGameEnd = function (p_GameWon: boolean, p_WinningTeam: string) {
        setGameWon(p_GameWon);
        
        if(p_WinningTeam === 'attackers') {
            setGameWinningTeam(Teams.Attackers);
        } else if(p_WinningTeam === 'defenders') {
            setGameWinningTeam(Teams.Defenders);
        } else {
            setGameWinningTeam(null);
        }

        setShowRoundEndInfoBox(false);
    }

    const [bombPlanted, setBombPlanted] = useState<string|null>(null);
    window.BombPlanted = function (p_BombSite: string|null) {
        setBombPlanted(p_BombSite)
    }
    
    window.OpenCloseScoreboard = function (open: boolean) {
        if (!showTeamsPage && !showLoadoutPage) {
            setShowScoreboard(open);
        }
    }

    const [players, setPlayers] = useState<Players>({
        [Teams.All]: [],
        [Teams.Attackers]: [],
        [Teams.Defenders]: [],
    });

    const [clientPlayer, setClientPlayer] = useState<Player>({
        id: 0,
        name: '',
        ping: 0,
        kill: 0,
        death: 0,
        isDead: false,
        place: 0,
        team: Teams.All,
    });

    window.UpdatePlayers = function (p_Players: any, p_ClientPlayer: any) {
        setClientPlayer(p_ClientPlayer);
        setPlayers({
            [Teams.All]: p_Players["all"],
            [Teams.Attackers]: [],
            [Teams.Defenders]: [],
        });
    }

    const SetDummyPlayers = () => {
        var dummyPlayers:Player[] = []
        for (let index = 0; index < 10; index++) {
            dummyPlayers.push({
                id: index,
                name: 'Teszt',
                ping: 0,
                kill: 18,
                death: 5,
                isDead: (Math.random() < 0.5),
                place: (index + 1),
                team: Teams.None,
            });
        }

        setPlayers({
            [Teams.All]: dummyPlayers,
            [Teams.Attackers]: [],
            [Teams.Defenders]: [],
        });
    }

    const [rupProgress, setRupProgress] = useState<number>(0);
    window.RupInteractProgress = function(m_RupHeldTime: number, MaxReadyUpTime: number) {
        setRupProgress(Math.round(m_RupHeldTime / MaxReadyUpTime * 100));
    }

    const [plantProgress, setPlantProgress] = useState<number>(0);
    const [plantOrDefuse, setPlantOrDefuse] = useState<string>("plant");
    window.PlantInteractProgress = function(m_PlantOrDefuseHeldTime: number, PlantTime: number, plantOrDefuse: string) {
        if (plantOrDefuse === 'none') {
            setPlantProgress(0);
            setPlantOrDefuse("plant");
    
        } else {
            setPlantProgress(Math.round(m_PlantOrDefuseHeldTime / PlantTime * 100));
            setPlantOrDefuse(plantOrDefuse);
        }
    }

    window.ResetUI = function() {
        setShowHud(false);
        setRound(0);
        setRoundWon(false);
        setWinningTeam(Teams.Attackers);
        setTeamAttackersScore(0);
        setTeamDefendersScore(0);
        setBombPlantedOn(null);

        // Show the select team page
        setShowTeamsPage(true);
        setSelectedTeam(Teams.None);
        setShowScoreboard(false);

        setShowLoadoutPage(false);
        setShowRoundEndInfoBox(false);

        // setGameWon
        // setGameWinningTeam

        setBombPlanted(null);

        setRupProgress(0);
        setPlantProgress(0);
        setPlantOrDefuse("plant");
    }

    window.stringifyNumber = function(i) {
        var j = i % 10,
        k = i % 100;
        if (j == 1 && k != 11) {
            return i + "st";
        }
        if (j == 2 && k != 12) {
            return i + "nd";
        }
        if (j == 3 && k != 13) {
            return i + "rd";
        }
        return i + "th";
    }

    const [spectating, setSpectating] = useState<boolean>(false);
    window.SpectatorEnabled = function(p_Enabled: boolean) {
        console.log('SpectatorEnabled ' + p_Enabled);
        setSpectating(p_Enabled);
    }

    const [spectatorTarget, setSpectatorTarget] = useState<string>("");
    window.SpectatorTarget = function(p_TargetName: string) {
        console.log('SpectatorTarget ' + p_TargetName);
        setSpectatorTarget(p_TargetName);
    }

    const GameStatesPage = () => {
        if(!showHud){
            return <></>;
        }
        switch (scene) {
            default:
            case GameStates.None:
                return <></>;

            case GameStates.Warmup:
                return <WarmupScene rupProgress={rupProgress} players={players} clientPlayer={clientPlayer} />;

            case GameStates.EndGame:
                return <EndgameScene
                    roundWon={roundWon}
                    winningTeam={winningTeam}
                    teamAttackersScore={teamAttackersScore}
                    teamDefendersScore={teamDefendersScore}
                />;
        }
    }

    return (
        <div className="App">
            
            {debugMode &&
                <style dangerouslySetInnerHTML={{__html: `
                    body {
                        background: #8e8e8e;
                    }

                    #debug {
                        display: block !important;
                        opacity: 0.1;
                    }
                `}} />
            }
            
            <div id="debug" className="global">
                <button onClick={() => setScene(GameStates.Warmup)}>Warmup</button>
                <button onClick={() => setScene(GameStates.EndGame)}>EndGame</button>
                <button onClick={() => setShowHud(prevState => !prevState)}>ShowHeader On / Off</button>
                <button onClick={() => setShowScoreboard(prevState => !prevState)}>Scoreboard On / Off</button>
                <button onClick={() => SetDummyPlayers()}>Set dummy players</button>
                <br />
                <button onClick={() => setShowRoundEndInfoBox(prevState => !prevState)}>RoundEndInfo On / Off</button>
                <button onClick={() => setGameWon(true)}>setGameWon</button>
                <button onClick={() => setGameWinningTeam(Teams.Attackers)}>Attackers won the game</button>
                <button onClick={() => setBombPlantedOn("B")}>Set bomb planted</button>
                <br />
                <button onClick={() => setRoundWon(true)}>Win</button>
                <button onClick={() => setRoundWon(false)}>Lose</button>
                <button onClick={() => setWinningTeam(Teams.Attackers)}>Attackers Win</button>
                <button onClick={() => setWinningTeam(Teams.Defenders)}>Defenders Win</button>
                <button onClick={() => setTeamAttackersScore(prevState => prevState + 1)}>Attackers +1</button>
                <button onClick={() => setTeamDefendersScore(prevState => prevState + 1)}>Defenders +1</button>
            </div>

            <div className="window">
                <Header
                    showHud={showHud}
                    clientPlayer={clientPlayer}
                />
                <GameStatesPage />
                <TeamsScene
                    show={showTeamsPage && showHud}
                    selectedTeam={selectedTeam}
                    setSelectedTeam={(team: Teams) => setTeam(team)}
                    gameType={gameType}
                />
                <LoadoutScene
                    show={showLoadoutPage && showHud}
                    setShowLoadoutPage={(show) => setShowLoadoutPage(show)}
                />
                <Scoreboard 
                    showScoreboard={showScoreboard && showHud}
                    teamAttackersScore={teamAttackersScore}
                    teamDefendersScore={teamDefendersScore}
                    players={players}
                    clientPlayer={clientPlayer}
                    gameState={scene}
                    round={round}
                    maxRounds={maxRounds}
                    roundsList={roundsList}
                />
                <PlantOrDefuseProgress 
                    plantProgress={plantProgress}
                    plantOrDefuse={plantOrDefuse}
                />
                <Spectator
                    spectating={spectating}
                    spectatorTarget={spectatorTarget}
                />
                
                {bombPlanted !== null &&
                    <BombPlantInfoBox bombSite={bombPlanted} afterInterval={() => setBombPlanted(null)} />
                }

                {gameWon !== null 
                ?
                    <GameEndInfoBox
                        gameWon={gameWon}
                        winningTeam={gameWinningTeam}
                        afterInterval={() => {
                            setShowRoundEndInfoBox(false);
                            setGameWon(null);
                            setGameWinningTeam(null);
                        }}
                        />
                :
                    <>
                        {showRoundEndInfoBox &&
                            <RoundEndInfoBox 
                                roundWon={roundWon}
                                winningTeam={winningTeam}
                                afterDisaper={() => setShowRoundEndInfoBox(false)}
                                />
                        }
                    </>
                }
            </div>
        </div>
    );
};

export default App;

declare global {
    interface Window {
        ChangeState: (p_GameState: GameStates) => void;
        ChangeType: (p_GameType: GameTypes) => void;
        //UpdateRoundEndStatus: (p_RoundWon: boolean, p_WinningTeam: Teams, p_Team1Score: number, p_Team2Score: number) => void;
        OpenCloseLoadoutMenu: () => void;
        OpenCloseTeamMenu: (forceOpen?: boolean) => void;
        UpdatePlayers: (p_Players: any, p_ClientPlayer: any) => void;
        OpenCloseScoreboard: (open: boolean) => void;
        RupInteractProgress: (m_RupHeldTime: number, MaxReadyUpTime: number) => void
        UpdateHeader: (p_AttackerPoints: number, p_DefenderPoints: number, p_Rounds: number, p_BombSite?: string) => void;
        ShowHideRoundEndInfoBox: (open: boolean) => void;
        UpdateRoundEndInfoBox: (p_RoundWon: boolean, p_WinningTeam: string) => void;
        SetGameEnd: (p_GameWon: boolean, p_WinningTeam: string) => void;
        BombPlanted: (p_BombSite: string|null) => void;
        PlantInteractProgress: (m_PlantOrDefuseHeldTime: number, PlantTime: number, plantOrDefuse: string) => void
        ResetUI: () => void;
        RoundCount: (p_Count: number) => void;
        stringifyNumber: (i: number) => string;

        //Spectator
        SpectatorTarget: (p_TargetName: string) => void;
        SpectatorEnabled: (p_Enabled: boolean) => void;
    }
}
