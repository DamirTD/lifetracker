<script setup lang="ts">
import { ref, watch } from "vue";
import type { Task } from "../../types/task.ts";

const props = defineProps<{ task: Task }>();
const emit  = defineEmits(["updateTask", "cancel"]);

const editTask = ref<Task>({ ...props.task });

watch(() => props.task, (newTask) => {
  editTask.value = { ...newTask };
});

const updateTask = () => {
  emit("updateTask", editTask.value);
};
</script>

<template>
  <div class="mt-6 p-4 bg-gray-100 rounded-lg">
    <h1 class="text-2xl font-bold mb-4">Редактирование задачи</h1>

    <label class="block mb-2">
      Название:
      <input v-model="editTask.title" placeholder="Название" class="border p-2 w-full" />
    </label>

    <label class="block mb-2">
      Описание:
      <textarea v-model="editTask.description" placeholder="Описание" class="border p-2 w-full"></textarea>
    </label>

    <label class="block mb-2">
      Дата выполнения:
      <input type="date" v-model="editTask.dueDate" class="border p-2 w-full" />
    </label>

    <label class="block mb-2">
      Статус:
      <select v-model="editTask.status" class="border p-2 w-full">
        <option value="pending">В ожидании</option>
        <option value="in_progress">В процессе</option>
        <option value="completed">Завершено</option>
      </select>
    </label>

    <label class="block mb-4">
      Приоритет:
      <select v-model="editTask.priority" class="border p-2 w-full">
        <option value="low">Низкий</option>
        <option value="medium">Средний</option>
        <option value="high">Высокий</option>
      </select>
    </label>

    <button @click="updateTask" class="bg-green-500 text-white px-4 py-2 rounded">💾 Сохранить</button>
    <button @click="emit('cancel')" class="bg-gray-500 text-white px-4 py-2 rounded ml-2">Отмена</button>
  </div>
</template>
