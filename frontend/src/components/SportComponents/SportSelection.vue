<script setup lang="ts">
import { ref, onMounted, watch } from "vue";
import { SportService } from "../../services/sportService.ts";

const sports = ref<{ id: number; name: string }[]>([]);
const selectedSport = ref<number | null>(null);
const goal = ref("");
const selectedSportData = ref<{ sport_id: number; goal: string } | null>(null);

const goalsBySport: Record<number, string[]> = {
  1: ["Набрать массу", "Похудеть", "Повысить выносливость"],
  2: ["Набрать массу", "Похудеть", "Повысить выносливость"],
  3: ["Набрать массу", "Похудеть", "Повысить выносливость"],
  4: ["Набрать массу", "Похудеть", "Повысить выносливость"],
};

onMounted(async () => {
  try {
    sports.value = await SportService.fetchSports();
  } catch (error) {
    console.error("Ошибка при загрузке видов спорта:", error);
  }
});

watch(selectedSport, () => {
  goal.value = "";
});

const selectSport = async () => {
  if (selectedSport.value && goal.value) {
    try {
      selectedSportData.value = await SportService.selectSport(selectedSport.value, goal.value);
    } catch (error) {
      console.error("Ошибка при выборе спорта:", error);
    }
  }
};
</script>

<template>
  <div class="p-6">
    <h1 class="text-xl font-bold mb-4">Выбор вида спорта</h1>

    <div class="mb-4">
      <label for="sport" class="block text-sm font-medium">Выберите спорт:</label>
      <select v-model="selectedSport" id="sport" class="mt-1 block w-full border p-2 rounded">
        <option disabled value="">Выберите спорт</option>
        <option v-for="sport in sports" :key="sport.id" :value="sport.id">
          {{ sport.name }}
        </option>
      </select>
    </div>

    <div class="mb-4" v-if="selectedSport">
      <label for="goal" class="block text-sm font-medium">Выберите цель:</label>
      <select v-model="goal" id="goal" class="mt-1 block w-full border p-2 rounded">
        <option disabled value="">Выберите цель</option>
        <option v-for="g in goalsBySport[selectedSport]" :key="g" :value="g">
          {{ g }}
        </option>
      </select>
    </div>

    <button @click="selectSport" class="bg-blue-500 text-white p-2 rounded" :disabled="!selectedSport || !goal">
      Выбрать
    </button>

    <div v-if="selectedSportData" class="mt-4 p-4 border rounded bg-green-100">
      <p>Вы выбрали:</p>
      <p><strong>Спорт (ID):</strong> {{ selectedSportData.sport_id }}</p>
      <p><strong>Цель:</strong> {{ selectedSportData.goal }}</p>
    </div>
  </div>
</template>
