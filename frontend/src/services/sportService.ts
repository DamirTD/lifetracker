import { api } from "./api";

interface Sport {
    id: number;
    name: string;
}

interface SelectedSport {
    sport_id: number;
    goal: string;
}

interface Analysis {
    advice: string;
}

export const SportService = {
    async fetchSports(): Promise<Sport[]> {
        const response = await api.get<{ sports: Sport[] }>("/sport/types");
        return response.data.sports;
    },

    async selectSport(sport_id: number, goal: string): Promise<SelectedSport> {
        const response = await api.post<{ data: SelectedSport }>("/sport/select", {
            sport_id,
            goal,
        });
        return response.data.data;
    },

    async analyzeSport(sport_id: number, goal: string): Promise<Analysis> {
        const response = await api.post<{ advice: string }>("/sport/analyze", {
            sport_id,
            goal
        });
        return response.data;
    }
};
