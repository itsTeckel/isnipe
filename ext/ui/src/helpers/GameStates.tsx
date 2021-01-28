export enum GameStates {
    None = 0,
    Warmup = 1,
    Playing = 2,
    EndGame = 4,
}

export var GameStatesRoundString = {
    [GameStates.None]: '',
    [GameStates.Warmup]: 'Warmup',
    [GameStates.Playing]: 'Playing',
    [GameStates.EndGame]: 'End',
}
