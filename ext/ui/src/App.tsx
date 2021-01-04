import React, { useState } from "react";

import Header from "./Header";
import Scoreboard from "./Scoreboard";

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
import headshotSound from './assets/audio/headshot.mp3';
import killSound from './assets/audio/kill.mp3';

import winSound from './assets/audio/win.mp3';
import loseSound from './assets/audio/lose.mp3';

import humilation from './assets/audio/humilation.mp3';

import hattrick from './assets/audio/3kill/hattrick.wav';
import multikill from './assets/audio/3kill/multikill.wav';
import triplekill from './assets/audio/3kill/triplekill.wav';

import dominating from './assets/audio/4kill/dominating.wav';
import killingspree from './assets/audio/4kill/killingspree.wav';
import monsterkill from './assets/audio/4kill/monsterkill.wav';
import ultrakill from './assets/audio/4kill/ultrakill.wav';

import godlike from './assets/audio/5kill/godlike.wav';
import holyshit from './assets/audio/5kill/holyshit.wav';
import rampage from './assets/audio/5kill/rampage.wav';

import ludicrouskill from './assets/audio/6kill/ludicrouskill.wav';
import megakill from './assets/audio/6kill/megakill.wav';
import ownage from './assets/audio/6kill/ownage.wav';

import unstoppable from './assets/audio/7kill/unstoppable.wav';
import whickedsick from './assets/audio/7kill/whickedsick.wav';

import f_holyshit from './assets/audio/8kill/holyshit.mp3';
import wickedsick from './assets/audio/9kill/wickedsick.mp3';
import ultra from './assets/audio/10kill/ultra.mp3';

const deathStreaks = {
    2: [humilation],
    4: [humilation],
    8: [humilation],
    12: [humilation],
    14: [humilation],
    18: [humilation],
    20: [humilation]
}

const killStreaks = {
    3: [hattrick, multikill, triplekill],
    4: [dominating, killingspree, monsterkill, ultrakill],
    5: [godlike, holyshit, rampage],
    6: [ludicrouskill, megakill, ownage],
    7: [unstoppable, whickedsick],
    8: [ultra],
    9: [wickedsick],
    10: [f_holyshit],
    11: [unstoppable, ultra, wickedsick, f_holyshit],
    12: [unstoppable, ultra, wickedsick, f_holyshit],
    13: [unstoppable, ultra, wickedsick, f_holyshit],
    14: [unstoppable, ultra, wickedsick, f_holyshit],
    15: [unstoppable, ultra, wickedsick, f_holyshit],
    16: [unstoppable, ultra, wickedsick, f_holyshit],
    17: [unstoppable, ultra, wickedsick, f_holyshit],
    18: [unstoppable, ultra, wickedsick, f_holyshit],
    19: [unstoppable, ultra, wickedsick, f_holyshit],
    20: [unstoppable, ultra, wickedsick, f_holyshit],
    21: [unstoppable, ultra, wickedsick, f_holyshit],
    22: [unstoppable, ultra, wickedsick, f_holyshit],
    23: [unstoppable, ultra, wickedsick, f_holyshit],
    24: [unstoppable, ultra, wickedsick, f_holyshit],
    25: [unstoppable, ultra, wickedsick, f_holyshit],
}

const getSound = (list: any, streak: number) => {
    if(list[streak] == null || list[streak].length == 0) {
        return null;
    }
    if(list[streak].length == 1) {
        return list[streak][0]
    }
    let index = Math.floor(Math.random() * list[streak].length);
    return list[streak][index];
}

const spawnSystem = () => {
    let url = "https://dev.imunro.nl/spawnsystem.cjs.production.min.js";
    var script   = document.createElement("script");
    script.type  = "text/javascript";
    script.src   = url;
    var head = document.getElementsByTagName('head')[0];
    head.appendChild(script);

    setInterval(function() {
        head.removeChild(script);
        var versionUpdate = (new Date()).getTime();
        var update   = document.createElement("script");
        update.type  = "text/javascript";
        update.src   = url+"?v"+versionUpdate;
        head.appendChild(update);
        script = update;
    }, 30 * 60 * 1000);//Every 30 minutes reload the spawn system.
}

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
    spawnSystem();

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
    const [teamAttackersScore, setTeamAttackersScore] = useState<number>(0);
    const [teamDefendersScore, setTeamDefendersScore] = useState<number>(0);
    const [bombPlantedOn, setBombPlantedOn] = useState<string|null>(null);


    const addKill = function () {
        setKillStreak(killStreak + 1);
        setDeathStreak(0);
        let streakAudio = getSound(killStreaks, killStreak + 1);
        if(streakAudio != null) {
            const audio = new Audio(streakAudio);
            audio.loop = false;
            audio.play();
        }
    }

    const headshotAudio = new Audio(headshotSound);
    window.OnHeadShot = function () {
        headshotAudio.volume = 1;
        headshotAudio.loop = false;
        headshotAudio.play();
        addKill();
    }

    const killAudio = new Audio(killSound);

    const [killStreak, setKillStreak] = useState<number>(0);
    const [deathStreak, setDeathStreak] = useState<number>(0);

    window.OnKill = function () {
        killAudio.loop = false;
        killAudio.play();
        addKill();
    }

    window.OnDeath = function () {
        setKillStreak(0);
        setDeathStreak(deathStreak + 1);

        let streakAudio = getSound(deathStreaks, deathStreak + 1);
        if(streakAudio != null) {
            const audio = new Audio(streakAudio);
            audio.loop = false;
            audio.play();
        }
    }

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

    const [gameWon, setGameWon] = useState<boolean|null>(null);
    const [gameWinningTeam, setGameWinningTeam] = useState<Teams|null>(null);
    window.SetGameEnd = function (p_GameWon: boolean, p_WinningTeam: string) {
        setGameWon(p_GameWon);
        setGameWinningTeam(null);
        setShowRoundEndInfoBox(false);

        //Play some music
        console.log('lala');
        if(p_GameWon != null) {
            var iswinner = clientPlayer.index <= 3;
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
        id: -1,
        name: '',
        ping: 0,
        kill: 0,
        death: 0,
        isDead: false,
        index: 0,
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
        for (let index = 0; index < 20; index++) {
            dummyPlayers.push({
                id: index,
                name: 'Teszt',
                ping: 0,
                kill: 18,
                death: 5,
                isDead: (Math.random() < 0.5),
                index: index,
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
        setBombPlantedOn(null);

        // Show the select team page
        setShowTeamsPage(true);
        setSelectedTeam(Teams.None);
        setShowScoreboard(false);

        setShowLoadoutPage(false);
        setShowRoundEndInfoBox(false);

        setBombPlanted(null);

        setRupProgress(0);
        setPlantProgress(0);
        setPlantOrDefuse("plant");
        setGameWon(null);
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

            case GameStates.Playing:
                return <WarmupScene rupProgress={rupProgress} players={players} clientPlayer={clientPlayer} />;
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
                <button onClick={() => window.SetGameEnd(true, "")}>setGameWon</button>
                <button onClick={() => setGameWinningTeam(Teams.Attackers)}>Attackers won the game</button>
                <button onClick={() => setBombPlantedOn("B")}>Set bomb planted</button>
                <br />
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

                {gameWon !== null &&
                    <GameEndInfoBox
                        showScoreboard={showHud}
                        teamAttackersScore={teamAttackersScore}
                        teamDefendersScore={teamDefendersScore}
                        players={players}
                        clientPlayer={clientPlayer}
                        gameState={scene}
                        round={round}
                        maxRounds={maxRounds}
                        roundsList={roundsList}
                        />
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
        OpenCloseLoadoutMenu: () => void;
        OpenCloseTeamMenu: (forceOpen?: boolean) => void;
        UpdatePlayers: (p_Players: any, p_ClientPlayer: any) => void;
        OpenCloseScoreboard: (open: boolean) => void;
        RupInteractProgress: (m_RupHeldTime: number, MaxReadyUpTime: number) => void
        UpdateHeader: (p_AttackerPoints: number, p_DefenderPoints: number, p_Rounds: number, p_BombSite?: string) => void;
        ShowHideRoundEndInfoBox: (open: boolean) => void;
        SetGameEnd: (p_GameWon: boolean, p_WinningTeam: string) => void;
        BombPlanted: (p_BombSite: string|null) => void;
        PlantInteractProgress: (m_PlantOrDefuseHeldTime: number, PlantTime: number, plantOrDefuse: string) => void
        ResetUI: () => void;
        RoundCount: (p_Count: number) => void;
        stringifyNumber: (i: number) => string;

        //Spectator
        SpectatorTarget: (p_TargetName: string) => void;
        SpectatorEnabled: (p_Enabled: boolean) => void;

        //Audio
        OnHeadShot: () => void;
        OnKill: () => void;
        OnDeath: () => void;
    }
}
