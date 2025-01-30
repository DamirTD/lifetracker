export interface RegisterRequest {
    name:                  string;
    surname:               string;
    login:                 string;
    email:                 string;
    password:              string;
    password_confirmation: string;
}

export interface LoginRequest {
    login:    string;
    password: string;
}

export interface User {
    id:         number;
    name:       string;
    surname:    string;
    login:      string;
    email:      string;
    created_at: string;
    updated_at: string;
}

export interface AuthResponse {
    user:  User;
    token: string;
}
