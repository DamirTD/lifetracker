export interface Task {
    title:        string;
    priority:     "low" | "medium" | "high";
    category:     "work" | "study" | "personal";
    description?: string;
    due_date?:    string;
}
