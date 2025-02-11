import { defineStore } from "pinia";
import { api } from "../services/api";
import { AuthService } from "../services/authService.ts";
import type { LoginRequest, RegisterRequest, User } from "../types/auth";

const getStoredUser = (): User | null => JSON.parse(localStorage.getItem("user") || "null");

const saveAuthData = (user: User, token: string) => {
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify(user));
};

const clearAuthData = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
};

export const useAuthStore = defineStore("auth", {
    state: () => ({
        user: getStoredUser(),
        isAuthChecked: false,
    }),

    actions: {
        async register(formData: RegisterRequest) {
            await this.handleAuthRequest(() => AuthService.register(formData), "/dashboard");
        },

        async login(formData: LoginRequest) {
            await this.handleAuthRequest(() => AuthService.login(formData), "/dashboard");
        },

        async logout(router: any) {
            await AuthService.logout();
            this.clearUserState();
            await router.push("/");
        },

        async checkAuth() {
            const token = localStorage.getItem("token");

            if (!token) {
                this.clearUserState();
                return;
            }

            this.user          = getStoredUser();
            this.isAuthChecked = true;

            try {
                const response = await api.get("/user");
                this.user = response.data;
                localStorage.setItem("user", JSON.stringify(response.data));
            } catch (error) {
                this.clearUserState();
            }
        },

        async handleAuthRequest(authFunction: () => Promise<{ user: User; token: string }>, redirectPath: string) {
            const response = await authFunction();
            saveAuthData(response.user, response.token);
            this.user = response.user;
            this.isAuthChecked = true;
            window.location.href = redirectPath;
        },

        clearUserState() {
            clearAuthData();
            this.user = null;
            this.isAuthChecked = true;
        },
    },
});
