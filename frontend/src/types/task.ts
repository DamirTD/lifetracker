export interface Task {
    id:           number;
    title:        string;
    description:  string | null;
    priority:     "low" | "medium" | "high";
    category:     "work" | "study" | "personal";
    due_date:     string | null;
    is_completed: boolean;
}

export type CreateTask = Omit<Task, "id">;
