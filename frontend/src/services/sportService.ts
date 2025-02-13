import { api } from "./api";
import type { Sport, SelectedSport, BasicProgram, UserTrainingProgram, UserSport } from "../serviceInterfaces/sportInterface.ts";

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
    },

    async addUserTrainingProgram(sport_id: number, goal: string, name: string, recommendation?: string): Promise<UserTrainingProgram> {
        const response = await api.post<{ data: UserTrainingProgram }>("/sport/user-training-program", {
            sport_id,
            goal,
            name,
            recommendation
        });
        return response.data.data;
    },

    async getUserSport(): Promise<UserSport[]> {
        const response = await api.get("/sport/user-sport");
        return response.data.data;
    },

    async updateSport(id: number, data: { name: string, goal: string }) {
        const response = await api.put(`/sport/edit/${id}`, data);
        return response.data;
    },

    async deleteUserSport(sportId: number): Promise<void> {
        await api.delete(`/sport/user-sport/${sportId}`);
    }
};
