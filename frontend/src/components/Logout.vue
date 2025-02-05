<script lang="ts" setup>
import { useAuthStore } from "../store/authStore";

const authStore = useAuthStore();

const handleLogout = async () => {
  try {
    await authStore.logout();
  } catch (error) {
    console.error("Ошибка выхода:", (error as any).response?.data);
  }
};
</script>

<template>
  <button
      @click="handleLogout"
      class="bg-blue-50 text-blue-800 px-4 py-2 border border-blue-200 rounded-md cursor-pointer transition-all duration-300 ease-in-out hover:bg-blue-600 hover:text-white hover:border-blue-600">
    Выйти
  </button>
</template>
