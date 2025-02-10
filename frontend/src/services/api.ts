import axios from "axios";
import type { RegisterRequest, LoginRequest, AuthResponse, User } from "../types/auth";

export const api = axios.create({
    baseURL: "http://localhost/api/",
    headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
    },
});

api.interceptors.request.use((config) => {
    const token = localStorage.getItem("token");
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

api.interceptors.response.use(
    (response) => response,
    async (error) => {
        if (error.response?.status === 401) {
            console.warn("Сессия истекла. Автоматический выход...");
            localStorage.removeItem("token");
            localStorage.removeItem("user");
            window.location.href = "/login"; // Перенаправляем на логин
        }
        return Promise.reject(error);
    }
);

export const authService = {
    async register(data: RegisterRequest): Promise<AuthResponse> {
        const response = await api.post("/register", data);
        return response.data;
    },
    async login(data: LoginRequest): Promise<AuthResponse> {
        const response = await api.post("/login", data);
        return response.data;
    },
    async logout(): Promise<void> {
        await api.post("/logout");
        localStorage.removeItem("token");
        localStorage.removeItem("user");
    },
    async getAuthUser(): Promise<User> {
        const response = await api.get("/user");
        return response.data;
    }
};
