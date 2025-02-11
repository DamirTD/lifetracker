<script setup lang="ts">
import type { Task } from "../../types/task";

defineProps<{ task: Task }>();

const emit = defineEmits(["edit", "complete", "delete"]);
</script>

<template>
  <li class="flex justify-between items-center p-4 border-b" :class="{ 'line-through': task.is_completed }">
    <div>
      <h3 class="font-bold">{{ task.title }}</h3>
      <p class="text-sm text-gray-500">
        Категория: {{ task.category }} | Приоритет: {{ task.priority }}
      </p>
    </div>
    <div>
      <button v-if="!task.is_completed" @click="emit('complete')" class="mr-2 bg-green-500 text-white px-3 py-1 rounded">
        ✅ Завершить
      </button>
      <button @click="emit('edit')" class="mr-2 bg-yellow-500 text-white px-3 py-1 rounded hover:bg-yellow-600">
        ✏️ Редактировать
      </button>
      <button @click="emit('delete')" class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600">
        🗑 Удалить
      </button>
    </div>
  </li>
</template>
