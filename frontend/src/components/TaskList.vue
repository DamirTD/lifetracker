<script setup lang="ts">
import { ref, onMounted } from "vue";
import { TaskService } from "../services/TaskService";
import Sidebar from "./Sidebar.vue";
import type { Task, CreateTask } from "../types/task";

const tasks              = ref<Task[]>([]);
const newTaskTitle       = ref("");
const newTaskPriority    = ref<"low" | "medium" | "high">("medium");
const newTaskCategory    = ref<"work" | "study" | "personal">("work");
const newTaskDescription = ref("");
const newTaskDueDate     = ref<string | null>(null);

const editTaskId          = ref<number | null>(null);
const editTaskTitle       = ref("");
const editTaskPriority    = ref<"low" | "medium" | "high">("medium");
const editTaskCategory    = ref<"work" | "study" | "personal">("work");
const editTaskDescription = ref("");
const editTaskDueDate     = ref<string | null>(null);

const loadTasks = async () => {
  try {
    const response = await TaskService.getTasks();
    tasks.value = response.data.data
        .map((task: any): Task => ({
          ...task,
          is_completed: Boolean(task.is_completed),
        }))
        .sort((a, b) => Number(a.is_completed) - Number(b.is_completed));
  } catch (error) {
    console.error("Ошибка загрузки задач:", error);
  }
};

const addTask = async () => {
  if (!newTaskTitle.value.trim()) return;

  const taskData: CreateTask = {
    title:        newTaskTitle.value,
    priority:     newTaskPriority.value,
    category:     newTaskCategory.value,
    description:  newTaskDescription.value || null,
    due_date:     newTaskDueDate.value ? new Date(newTaskDueDate.value).toISOString() : null,
    is_completed: false,
  };

  try {
    const response = await TaskService.createTask(taskData);
    tasks.value.push({ ...response.data, is_completed: Boolean(response.data.is_completed) });
    sortTasks();
    resetForm();
  } catch (error) {
    console.error("Ошибка добавления задачи:", error);
  }
};

const setEditTask = (task: Task) => {
  editTaskId.value          = task.id;
  editTaskTitle.value       = task.title;
  editTaskPriority.value    = task.priority;
  editTaskCategory.value    = task.category;
  editTaskDescription.value = task.description || "";
  editTaskDueDate.value     = task.due_date;
};

const updateTask = async () => {
  if (!editTaskId.value || !editTaskTitle.value.trim()) return;

  const updatedTask: Partial<Task> = {
    title:       editTaskTitle.value,
    priority:    editTaskPriority.value,
    category:    editTaskCategory.value,
    description: editTaskDescription.value || null,
    due_date:    editTaskDueDate.value ? new Date(editTaskDueDate.value).toISOString() : null,
  };

  try {
    await TaskService.updateTask(editTaskId.value, updatedTask);
    tasks.value = tasks.value.map(task =>
        task.id === editTaskId.value ? { ...task, ...updatedTask } : task
    );
    editTaskId.value = null;
    sortTasks();
  } catch (error) {
    console.error("Ошибка обновления задачи:", error);
  }
};

const markTaskCompleted = async (taskId: number) => {
  try {
    await TaskService.markTaskCompleted(taskId, { is_completed: true });
    tasks.value = tasks.value.map(task => (task.id === taskId ? { ...task, is_completed: true } : task));
    sortTasks();
  } catch (error) {
    console.error("Ошибка завершения задачи:", error);
  }
};

const deleteTask = async (taskId: number) => {
  try {
    await TaskService.deleteTask(taskId);
    tasks.value = tasks.value.filter(task => task.id !== taskId);
  } catch (error) {
    console.error("Ошибка удаления задачи:", error);
  }
};

const sortTasks = () => {
  tasks.value.sort((a, b) => Number(a.is_completed) - Number(b.is_completed));
};

const resetForm = () => {
  newTaskTitle.value = "";
  newTaskDescription.value = "";
  newTaskDueDate.value = null;
};

onMounted(loadTasks);
</script>

<template>
  <div class="flex min-h-screen">
    <Sidebar />

    <main class="flex-1 p-6">
      <div class="p-4 bg-gray-100 rounded-lg mb-6">
        <h1 class="text-2xl font-bold mb-4">Добавить новую задачу</h1>
        <input v-model="newTaskTitle" placeholder="Название задачи" class="border p-2 mr-2" />
        <select v-model="newTaskPriority" class="border p-2 mr-2">
          <option value="low">Низкий</option>
          <option value="medium">Средний</option>
          <option value="high">Высокий</option>
        </select>
        <select v-model="newTaskCategory" class="border p-2 mr-2">
          <option value="work">Работа</option>
          <option value="study">Учеба</option>
          <option value="personal">Личное</option>
        </select>
        <input v-model="newTaskDescription" placeholder="Описание" class="border p-2 mr-2" />
        <input v-model="newTaskDueDate" type="datetime-local" class="border p-2 mr-2" />
        <button @click="addTask" class="bg-blue-500 text-white px-4 py-2 rounded">
          ➕ Добавить
        </button>
      </div>

      <h1 class="text-2xl font-bold mb-4">Список задач</h1>
      <ul>
        <li
            v-for="task in tasks"
            :key="task.id"
            class="flex justify-between items-center p-4 border-b"
            :class="{ 'line-through': task.is_completed }"
        >
          <div>
            <h3 class="font-bold">{{ task.title }}</h3>
            <p class="text-sm text-gray-500">
              Категория: {{ task.category }} | Приоритет: {{ task.priority }}
            </p>
          </div>
          <div>
            <button
                v-if="!task.is_completed"
                @click="markTaskCompleted(task.id)"
                class="mr-2 bg-green-500 text-white px-3 py-1 rounded"
            >
              ✅ Завершить
            </button>
            <button
                @click="setEditTask(task)"
                class="mr-2 bg-yellow-500 text-white px-3 py-1 rounded hover:bg-yellow-600"
            >
              ✏️ Редактировать
            </button>
            <button
                @click="deleteTask(task.id)"
                class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
            >
              🗑 Удалить
            </button>
          </div>
        </li>
      </ul>

      <div v-if="editTaskId !== null" class="mt-6 p-4 bg-gray-100 rounded-lg">
        <h1 class="text-2xl font-bold mb-4">Редактирование задачи</h1>
        <input v-model="editTaskTitle" placeholder="Название задачи" class="border p-2 mr-2" />
        <select v-model="editTaskPriority" class="border p-2 mr-2">
          <option value="low">Низкий</option>
          <option value="medium">Средний</option>
          <option value="high">Высокий</option>
        </select>
        <select v-model="editTaskCategory" class="border p-2 mr-2">
          <option value="work">Работа</option>
          <option value="study">Учеба</option>
          <option value="personal">Личное</option>
        </select>
        <input v-model="editTaskDescription" placeholder="Описание" class="border p-2 mr-2" />
        <input v-model="editTaskDueDate" type="datetime-local" class="border p-2 mr-2" />
        <button @click="updateTask" class="bg-green-500 text-white px-4 py-2 rounded">
          💾 Сохранить
        </button>
        <button @click="editTaskId = null" class="bg-gray-500 text-white px-4 py-2 rounded ml-2">
          Отмена
        </button>
      </div>
    </main>
  </div>
</template>

