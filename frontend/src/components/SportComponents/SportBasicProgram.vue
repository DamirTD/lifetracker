<script setup lang="ts">
import { ref, watch, onMounted } from "vue";
import { SportService } from "../../services/sportService.ts";

const sports        = ref<{ id: number; name: string }[]>([]);
const selectedSport = ref<{ id: number; name: string } | null>(null);

const goal           = ref("");
const BasicProgram   = ref<string | null>(null);

const goalsBySport: Record<number, string[]> = {
  1: ["Набрать массу", "Похудеть", "Повысить выносливость"],
  2: ["Набрать массу", "Похудеть", "Повысить выносливость"],
  3: ["Набрать массу", "Похудеть", "Повысить выносливость"],
  4: ["Набрать массу", "Похудеть", "Повысить выносливость"],
};

const BasicProgramRecommendation = async () => {
  if (selectedSport.value && goal.value) {
    await SportService.selectSport(selectedSport.value.id, goal.value);
    const result = await SportService.BasicProgramRecommendation(selectedSport.value.id, goal.value);
    BasicProgram.value = result.advice;
  }
};

onMounted(async () => {
  sports.value = await SportService.fetchSports();
});

watch(selectedSport, () => {
  goal.value           = "";
  BasicProgram.value = null;
});
</script>

<template>
  <div class="p-6">
    <h1 class="text-xl font-bold mb-4">Базовая тренировка</h1>

    <div class="mb-4">
      <label class="block text-sm font-medium">Спорт:</label>
      <select v-model="selectedSport" class="mt-1 block w-full border p-2 rounded">
        <option disabled value="">Выберите спорт</option>
        <option v-for="s in sports" :key="s.id" :value="s">{{ s.name }}</option>
      </select>
    </div>

    <div class="mb-4" v-if="selectedSport">
      <label class="block text-sm font-medium">Цель:</label>
      <select v-model="goal" class="mt-1 block w-full border p-2 rounded">
        <option disabled value="">Выберите цель</option>
        <option v-for="g in goalsBySport[selectedSport?.id]" :key="g" :value="g">
          {{ g }}
        </option>
      </select>
    </div>

    <button @click="BasicProgramRecommendation" class="bg-blue-500 text-white p-2 rounded mt-4" :disabled="!selectedSport || !goal">
      Получить
    </button>

    <div v-if="BasicProgram" class="mt-4 p-4 border rounded bg-green-100">
      <p><strong>Рекомендация:</strong> {{ BasicProgram }}</p>
    </div>
  </div>
</template>
