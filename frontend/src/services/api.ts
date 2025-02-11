import axios from "axios";
import type {
    AxiosInstance,
    InternalAxiosRequestConfig,
    AxiosResponse,
    AxiosError
} from "axios";

const API_URL = import.meta.env.VITE_API_URL;

export const getAuthToken = (): string | null => localStorage.getItem("token");

export const createApiInstance = (): AxiosInstance => {
    const instance = axios.create({
        baseURL: API_URL,
        headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
    });

    setupInterceptors(instance);
    return instance;
};

const setupInterceptors = (instance: AxiosInstance): void => {
    instance.interceptors.request.use(
        (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
            const token = getAuthToken();
            if (token) {
                config.headers.Authorization = `Bearer ${token}`;
            }
            return config;
        },
        (error: AxiosError): Promise<AxiosError> => Promise.reject(error)
    );

    instance.interceptors.response.use(
        (response: AxiosResponse): AxiosResponse => response,
        async (error: AxiosError): Promise<never> => {
            if (error.response?.status === 401) {
                localStorage.removeItem("token");
                localStorage.removeItem("user");
                window.location.href = "/login";
            }
            return Promise.reject(error);
        }
    );
};

export const api: AxiosInstance = createApiInstance();
