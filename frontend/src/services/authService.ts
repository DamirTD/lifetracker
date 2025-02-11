import { api } from "./api";
import type { RegisterRequest, LoginRequest, AuthResponse, User } from "../types/auth";

export const AuthService = {
    register: (data: RegisterRequest): Promise<AuthResponse> => api.post("/register", data).then(res => res.data),
    login:    (data: LoginRequest): Promise<AuthResponse> => api.post("/login", data).then(res => res.data),
    logout:   async (): Promise<void> => {
        await api.post("/logout");
        localStorage.removeItem("token");
        localStorage.removeItem("user");
    },
    getAuthUser: (): Promise<User> => api.get("/user").then(res => res.data),
};
