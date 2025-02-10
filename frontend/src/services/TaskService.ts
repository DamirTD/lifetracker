import axios from "axios";
import type {Task} from "../types/task.ts";

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

export const TaskService = {
    async getTasks() {
        return api.get('/tasks');
    },
    async createTask(task: Task) {
        return api.post('/tasks', task);
    },
    async markTaskCompleted(taskId: number) {
        return api.post(`/tasks/${taskId}/complete`);
    },
    async deleteTask(taskId: number) {
        return api.delete(`/tasks/${taskId}`);
    },
};
