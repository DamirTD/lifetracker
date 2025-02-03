import axios from "axios";
import type {RegisterRequest, LoginRequest, AuthResponse} from "../types/auth";

const api = axios.create({
    baseURL: "http://localhost/api/",
    headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
    },
});

api.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

export const authService = {
    async register(data: RegisterRequest): Promise<AuthResponse> {
        const response = await api.post("/register", data);
        localStorage.setItem('token', response.data.token);
        return response.data;
    },
    async login(data: LoginRequest): Promise<AuthResponse> {
        const response = await api.post("/login", data);
        localStorage.setItem('token', response.data.token);
        return response.data;
    },
    async logout(): Promise<void> {
        await api.post("/logout");
        localStorage.removeItem('token');
    },
};