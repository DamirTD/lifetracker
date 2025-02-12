import { api } from "./api";
import type { Task, CreateTask } from "../types/task";
import type { ITaskService } from "../serviceInterfaces/taskInterface";

export const TaskService: ITaskService = {
    getTasks: async () => {
        const response = await api.get<{ data: Task[] }>("/tasks");
        return response.data;
    },

    createTask: async (task: CreateTask) => {
        const response = await api.post<{ data: Task }>("/tasks", task);
        return response.data;
    },

    markTaskCompleted: async (taskId: number, data: { is_completed: boolean }) => {
        await api.patch(`/tasks/${taskId}/complete`, data); // Исправлено
    },

    updateTask: async (taskId: number, updatedData: Partial<Task>) => {
        await api.put(`/tasks/${taskId}`, updatedData); // Исправлено
    },

    deleteTask: async (taskId: number) => {
        await api.delete(`/tasks/${taskId}`); // Исправлено
    },
};
