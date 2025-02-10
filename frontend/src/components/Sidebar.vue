<script setup lang="ts">
import { useAuthStore } from '../store/authStore';

const authStore = useAuthStore();
</script>

<template>
  <aside class="w-64 bg-white shadow-md p-4 flex flex-col h-screen">

    <nav class="flex-grow space-y-4">
      <RouterLink to="/dashboard" class="block p-2 hover:bg-gray-700 mb-2">Главная</RouterLink>
      <RouterLink to="/tasks" class="block p-2 hover:bg-gray-700 mb-2">Задачи</RouterLink>
    </nav>

    <button
        @click="authStore.logout()"
        class="mt-auto bg-red-500 text-white py-2 px-4 rounded-lg hover:bg-red-600 transition">
      Выйти
    </button>
  </aside>
</template>
