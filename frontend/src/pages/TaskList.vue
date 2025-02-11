<script setup lang="ts">
import { ref, onMounted } from "vue";
import { TaskService } from "../services/taskService.ts";
import Sidebar from "../components/Sidebar.vue";
import TaskForm from "../components/TasksComponents/TaskForm.vue";
import EditTaskForm from "../components/TasksComponents/EditTaskForm.vue";
import type { Task, CreateTask } from "../types/task.ts";

const tasks = ref<Task[]>([]);
const editTask = ref<Task | null>(null);

const loadTasks = async () => {
  try {
    const response = await TaskService.getTasks();
    tasks.value = response.data.map((task: any): Task => ({
      ...task,
      is_completed: Boolean(task.is_completed),
    }));
    sortTasks();
  } catch (error) {
    console.error("Ошибка загрузки задач:", error);
  }
};

const addTask = async (taskData: CreateTask) => {
  try {
    const response = await TaskService.createTask(taskData);
    tasks.value.push({ ...response.data, is_completed: Boolean(response.data.is_completed) });
    sortTasks();
  } catch (error) {
    console.error("Ошибка добавления задачи:", error);
  }
};

const setEditTask = (task: Task) => {
  editTask.value = { ...task };
};

const updateTask = async (updatedTask: Task) => {
  try {
    await TaskService.updateTask(updatedTask.id, {
      title: updatedTask.title,
      description: updatedTask.description,
      priority: updatedTask.priority,
      category: updatedTask.category,
      due_date: updatedTask.due_date,
      is_completed: updatedTask.is_completed
    });

    tasks.value = tasks.value.map(task => (task.id === updatedTask.id ? updatedTask : task));
    editTask.value = null;
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

onMounted(loadTasks);
</script>

<template>
  <div class="flex min-h-screen">
    <Sidebar />

    <main class="flex-1 p-6">
      <TaskForm @addTask="addTask" />

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

      <EditTaskForm v-if="editTask" :task="editTask" @updateTask="updateTask" @cancel="editTask = null" />
    </main>
  </div>
</template>
