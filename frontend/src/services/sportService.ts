import { api } from "./api";
import type { Sport, SelectedSport, BasicProgram } from "../serviceInterfaces/sportInterface.ts";

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

    async BasicProgramRecommendation(sport_id: number, goal: string): Promise<BasicProgram> {
        const response = await api.post<{ advice: string }>("/sport/basic-training-program", {
            sport_id,
            goal
        });
        return response.data;
    }
};
