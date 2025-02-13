<script setup lang="ts">
import { onMounted, ref } from "vue";
import { SportService } from "../../services/sportService.ts";
import type { UserSport } from "../../serviceInterfaces/sportInterface.ts";

const userSports = ref<UserSport[]>([]);
const editingSport = ref<UserSport | null>(null);

onMounted(async () => {
  userSports.value = await SportService.getUserSport();
});

const startEditing = (sport: UserSport) => {
  editingSport.value = { ...sport };
};

const stopEditing = () => {
  editingSport.value = null;
};

const updateSport = async () => {
  if (editingSport.value) {
    await SportService.updateSport(editingSport.value.id, {
      name: editingSport.value.name,
      goal: editingSport.value.goal,
    });
    const index = userSports.value.findIndex(sport => sport.id === editingSport.value?.id);
    if (index !== -1) {
      userSports.value[index] = {...editingSport.value};
    }
    stopEditing();
  }
};

const deleteSport = async (sportId: number) => {
  await SportService.deleteUserSport(sportId);
  userSports.value = userSports.value.filter(sport => sport.id !== sportId);
};
</script>

<template>
  <div class="p-6 bg-gray-50 min-h-screen">
    <h2 class="text-3xl font-bold mb-6 text-center text-gray-800">Мои программы тренировок</h2>

    <ul v-if="userSports.length" class="space-y-6">
      <li
          v-for="sport in userSports"
          :key="sport.id"
          class="bg-white shadow-lg rounded-xl p-6 border border-gray-200"
      >
        <div class="flex items-center justify-between">
          <h3 class="text-xl font-semibold text-gray-800">{{ sport.name }}</h3>
          <span class="text-sm text-gray-500">{{ new Date(sport.created_at).toLocaleDateString() }}</span>
        </div>
        <p class="text-sm text-gray-600 mt-2">Категория: {{ sport.sport.name }}</p>
        <p class="text-sm text-gray-600">Цель: {{ sport.goal }}</p>
        <p
            v-if="sport.recommendation"
            class="mt-3 text-sm text-green-600 font-medium"
        >
          Рекомендация: {{ sport.recommendation }}
        </p>

        <div class="mt-4 flex space-x-4">
          <button
              @click="startEditing(sport)"
              class="bg-blue-500 hover:bg-blue-600 text-white py-1 px-4 rounded-md"
          >
            Редактировать
          </button>
          <button
              @click="deleteSport(sport.id)"
              class="bg-red-500 hover:bg-red-600 text-white py-1 px-4 rounded-md"
          >
            Удалить
          </button>
        </div>
      </li>
    </ul>

    <p v-else class="text-center text-gray-500">Нет данных о видах спорта.</p>

    <div v-if="editingSport" class="mt-6 p-4 bg-white shadow-lg rounded-xl border border-gray-200">
      <h3 class="text-xl font-semibold text-gray-800 mb-4">Редактировать программу</h3>
      <form @submit.prevent="updateSport">
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700">Название:</label>
          <input
              v-model="editingSport.name"
              type="text"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          >
        </div>
        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700">Цель:</label>
          <input
              v-model="editingSport.goal"
              type="text"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          >
        </div>
        <button
            type="submit"
            class="bg-green-500 hover:bg-green-600 text-white py-1 px-4 rounded-md"
        >
          Сохранить
        </button>
        <button
            type="button"
            @click="stopEditing"
            class="ml-2 bg-gray-500 hover:bg-gray-600 text-white py-1 px-4 rounded-md"
        >
          Отмена
        </button>
      </form>
    </div>
  </div>

</template>

