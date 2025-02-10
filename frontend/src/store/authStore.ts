import { defineStore } from "pinia";
import { api } from "../services/api";
import { authService } from "../services/api";
import type { LoginRequest, RegisterRequest, User } from "../types/auth";
import { useRouter } from "vue-router";

export const useAuthStore = defineStore("auth", {
    state: () => ({
        user: (() => {
            try {
                return JSON.parse(localStorage.getItem("user") || "null") as User | null;
            } catch {
                return null;
            }
        })(),
        isAuthChecked: false,
    }),

    actions: {
        async register(formData: RegisterRequest) {
            try {
                const response = await authService.register(formData);
                this.setAuthData(response);
                window.location.href = "/dashboard";
            } catch (error) {
                console.error("Ошибка регистрации:", error);
                throw error;
            }
        },

        async login(formData: LoginRequest) {
            try {
                const response = await authService.login(formData);
                this.setAuthData(response);
                window.location.href = "/dashboard";
            } catch (error) {
                console.error("Ошибка входа:", error);
                throw error;
            }
        },

        async logout() {
            try {
                await authService.logout();
            } catch (error) {
                console.warn("Ошибка выхода, но мы всё равно выходим.", error);
            }
            this.clearAuthData();
            await useRouter().push("/");
        },

        async checkAuth() {
            const token = localStorage.getItem("token");
            const cachedUser = localStorage.getItem("user");

            if (!token) {
                this.clearAuthData();
                return;
            }

            if (cachedUser) {
                try {
                    this.user = JSON.parse(cachedUser);
                } catch {
                    this.user = null;
                }
                this.isAuthChecked = true;
            }

            try {
                const response = await api.get("/user");
                this.user = response.data;
                localStorage.setItem("user", JSON.stringify(response.data));
            } catch (error) {
                console.warn("Ошибка проверки аутентификации:", error);
                await this.logout();
            } finally {
                this.isAuthChecked = true;
            }
        },

        setAuthData(response: { user: User; token: string }) {
            localStorage.setItem("token", response.token);
            localStorage.setItem("user", JSON.stringify(response.user));
            this.user = response.user;
            this.isAuthChecked = true;
        },

        clearAuthData() {
            localStorage.removeItem("token");
            localStorage.removeItem("user");
            this.user = null;
            this.isAuthChecked = true;
        },
    },
});
