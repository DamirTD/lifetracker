import { defineStore } from "pinia";
import { authService } from "../services/api";
import type { User, RegisterRequest, LoginRequest } from "../types/auth";

export const useAuthStore = defineStore("auth", {
    state: () => ({
        user: null as User | null,
    }),
    actions: {
        async register(formData: RegisterRequest) {
            try {
                const response = await authService.register(formData);
                this.user = response.user;
            } catch (error) {
                console.error("Ошибка регистрации:", (error as any).response?.data);
                throw error;
            }
        },
        async login(formData: LoginRequest) {
            try {
                const response = await authService.login(formData);
                this.user = response.user;
            } catch (error) {
                console.error("Ошибка входа:", (error as any).response?.data);
                throw error;
            }
        },
        async logout() {
            try {
                await authService.logout();
                this.user = null;
            } catch (error) {
                console.error("Ошибка выхода:", (error as any).response?.data);
                throw error;
            }
        },
    },
});
