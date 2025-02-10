import axios from "axios";
import type { Task, CreateTask } from "../types/task";

const API_URL = "http://localhost/api";

const axiosInstance = axios.create({
    baseURL: API_URL,
    headers: {
        Authorization: `Bearer ${localStorage.getItem("token")}`,
        "Content-Type": "application/json",
    },
});

export const TaskService = {
    async getTasks() {
        return await axiosInstance.get<{ data: Task[] }>("/tasks");
    },
    async createTask(task: CreateTask) {
        return await axiosInstance.post<Task>("/tasks", task);
    },
    async markTaskCompleted(taskId: number, data: { is_completed: boolean }) {
        return axiosInstance.patch(`/tasks/${taskId}/complete`, data);
    },
    async updateTask(taskId: number, updatedData: Partial<Task>) {
        return axiosInstance.put(`/tasks/${taskId}`, updatedData);
    },
    async deleteTask(taskId: number) {
        return await axiosInstance.delete(`/tasks/${taskId}`);
    },
};
