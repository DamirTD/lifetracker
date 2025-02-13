<script setup lang="ts">
import { ref, onMounted } from "vue";
import { SportService } from "../../services/sportService.ts";

const sports         = ref<{ id: number; name: string }[]>([]);
const sport_id       = ref<number | null>(null);
const goal           = ref("");
const name           = ref("");
const recommendation = ref("");
const successMessage = ref("");

const fetchSports = async () => {
  sports.value = await SportService.fetchSports();
};

const addProgram = async () => {
  await SportService.addUserTrainingProgram(sport_id.value!, goal.value, name.value, recommendation.value);
  successMessage.value = "Тренировочная программа успешно добавлена!";
  sport_id.value       = null;
  goal.value           = "";
  name.value           = "";
  recommendation.value = "";
}

onMounted(fetchSports);
</script>

<template>
  <div class="p-6">
    <h1 class="text-xl font-bold mb-4">Добавить тренировочную программу</h1>

    <div class="mb-4">
      <label for="sport" class="block text-sm font-medium">Выберите спорт:</label>
      <select v-model="sport_id" id="sport" class="mt-1 block w-full border p-2 rounded">
        <option disabled value="">Выберите спорт</option>
        <option v-for="sport in sports" :key="sport.id" :value="sport.id">
          {{ sport.name }}
        </option>
      </select>
    </div>

    <div class="mb-4">
      <label for="goal" class="block text-sm font-medium">Цель:</label>
      <input type="text" v-model="goal" id="goal" class="mt-1 block w-full border p-2 rounded" placeholder="Введите цель" />
    </div>

    <div class="mb-4">
      <label for="name" class="block text-sm font-medium">Название программы:</label>
      <input type="text" v-model="name" id="name" class="mt-1 block w-full border p-2 rounded" placeholder="Введите название" />
    </div>

    <div class="mb-4">
      <label for="recommendation" class="block text-sm font-medium">Рекомендации (необязательно):</label>
      <input type="text" v-model="recommendation" id="recommendation" class="mt-1 block w-full border p-2 rounded" placeholder="Введите рекомендации" />
    </div>

    <button @click="addProgram" class="bg-blue-500 text-white p-2 rounded" :disabled="!sport_id || !goal || !name">
      Добавить программу
    </button>

    <div v-if="successMessage" class="mt-4 p-4 border rounded bg-green-100">
      {{ successMessage }}
    </div>
  </div>
</template>
