import axios from "axios";
import type { RegisterRequest, LoginRequest, AuthResponse } from "../types/auth";

const api = axios.create({
    baseURL: "http://localhost/api/",
    withCredentials: true,
    headers: { "Content-Type": "application/json" },
});

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
    },
};
