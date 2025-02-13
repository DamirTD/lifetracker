export interface Sport {
    id:   number;
    name: string;
}

export interface SelectedSport {
    sport_id: number;
    goal:     string;
}

export interface BasicProgram {
    advice: string;
}

export interface UserTrainingProgram {
    id:              number;
    user_id:         number;
    sport_id:        number;
    goal:            string;
    name:            string;
    recommendation?: string;
}

export interface UserSport {
    id:              number;
    user_id:         number;
    sport_id:        number;
    goal:            string;
    name:            string;
    recommendation?: string;
    created_at:      string;
    updated_at:      string;
    sport: {
        id:   number;
        name: string;
    };
}
