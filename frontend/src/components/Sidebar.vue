<script setup lang="ts">
import { useAuthStore } from '../store/authStore';
import { useRouter } from "vue-router";

const authStore = useAuthStore();
const router    = useRouter();

const handleLogout = () => {
  authStore.logout(router);
};
</script>

<template>
  <aside class="w-64 bg-white shadow-md p-4 flex flex-col h-screen fixed left-0 top-0">
    <nav class="flex-grow space-y-4">
      <RouterLink to="/dashboard" class="block p-2 hover:bg-gray-700 mb-2">Главная</RouterLink>
      <RouterLink to="/tasks" class="block p-2 hover:bg-gray-700 mb-2">Задачи</RouterLink>
      <RouterLink to="/sport" class="block p-2 hover:bg-gray-700 mb-2">Спорт</RouterLink>
    </nav>

    <button
        @click="handleLogout"
        class="mt-auto bg-red-500 text-white py-2 px-4 rounded-lg hover:bg-red-600 transition">
      Выйти
    </button>
  </aside>
</template>
