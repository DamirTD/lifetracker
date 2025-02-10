<script setup lang="ts">
import { ref } from "vue";
import {TaskService} from "../services/TaskService";

const newTaskTitle       = ref("");
const newTaskPriority    = ref<"low" | "medium" | "high">("medium");
const newTaskCategory    = ref<"work" | "study" | "personal">("work");
const newTaskDescription = ref("");
const newTaskDueDate     = ref("");

const addTask = async () => {
  if (!newTaskTitle.value.trim()) return;

  const taskData = {
    title:       newTaskTitle.value,
    priority:    newTaskPriority.value,
    category:    newTaskCategory.value,
    description: newTaskDescription.value || undefined,
    due_date:    newTaskDueDate.value || undefined,
  };

  try {
    await TaskService.createTask(taskData);
    newTaskTitle.value       = "";
    newTaskDescription.value = "";
    newTaskDueDate.value     = "";
  } catch (error: any) {
    console.error("Ошибка добавления задачи:", error);
    console.log(error.response?.data);
  }
};
</script>

<template>
  <div>
    <input v-model="newTaskTitle" placeholder="Название задачи" />

    <select v-model="newTaskPriority">
      <option value="low">Низкий</option>
      <option value="medium">Средний</option>
      <option value="high">Высокий</option>
    </select>

    <select v-model="newTaskCategory">
      <option value="work">Работа</option>
      <option value="study">Учеба</option>
      <option value="personal">Личное</option>
    </select>

    <input v-model="newTaskDescription" placeholder="Описание (необязательно)" />
    <input v-model="newTaskDueDate" type="datetime-local" />

    <button @click="addTask">Добавить задачу</button>
  </div>
</template>
