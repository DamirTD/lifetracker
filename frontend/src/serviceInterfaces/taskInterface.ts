import type { Task, CreateTask } from "../types/task";

export interface ITaskService {
    getTasks:   () => Promise<{ data: Task[] }>;
    createTask: (task: CreateTask) => Promise<{ data: Task }>;
    markTaskCompleted: (taskId: number, data: { is_completed: boolean }) => Promise<void>;
    updateTask: (taskId: number, updatedData: Partial<Task>) => Promise<void>;
    deleteTask: (taskId: number) => Promise<void>;
}
