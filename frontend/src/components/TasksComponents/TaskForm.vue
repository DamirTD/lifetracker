<script setup lang="ts">
import { ref } from "vue";
import type { CreateTask } from "../../types/task.ts";

const emit = defineEmits(["addTask"]);

const newTask = ref<CreateTask>({
  title:        "",
  priority:     "medium",
  category:     "work",
  description:  "",
  due_date:     null,
  is_completed: false,
});

const addTask = () => {
  if (!newTask.value.title.trim()) return;
  emit("addTask", { ...newTask.value });

  newTask.value.title       = "";
  newTask.value.description = "";
  newTask.value.due_date    = null;
};
</script>

<template>
  <div class="p-4 bg-gray-100 rounded-lg mb-6">
    <h1 class="text-2xl font-bold mb-4">Добавить новую задачу</h1>
    <input v-model="newTask.title" placeholder="Название задачи" class="border p-2 mr-2" />
    <select v-model="newTask.priority" class="border p-2 mr-2">
      <option value="low">Низкий</option>
      <option value="medium">Средний</option>
      <option value="high">Высокий</option>
    </select>
    <select v-model="newTask.category" class="border p-2 mr-2">
      <option value="work">Работа</option>
      <option value="study">Учеба</option>
      <option value="personal">Личное</option>
    </select>
    <input v-model="newTask.description" placeholder="Описание" class="border p-2 mr-2" />
    <input v-model="newTask.due_date" type="datetime-local" class="border p-2 mr-2" />
    <button @click="addTask" class="bg-blue-500 text-white px-4 py-2 rounded">
      ➕ Добавить
    </button>
  </div>
</template>
