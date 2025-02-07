<script setup lang="ts">
import { useAuthStore } from '../store/authStore';

const authStore = useAuthStore();
</script>

<template>
  <aside class="w-64 bg-white shadow-md p-4 flex flex-col h-screen">

    <nav class="flex-grow space-y-4">
      <router-link to="/" class="block text-gray-700 hover:text-blue-500 transition">
        Главная
      </router-link>
      <router-link to="/features" class="block text-gray-700 hover:text-blue-500 transition">
        Функции
      </router-link>
      <router-link to="/about" class="block text-gray-700 hover:text-blue-500 transition">
        О нас
      </router-link>
      <router-link to="/contacts" class="block text-gray-700 hover:text-blue-500 transition">
        Контакты
      </router-link>
    </nav>

    <button
        @click="authStore.logout()"
        class="mt-auto bg-red-500 text-white py-2 px-4 rounded-lg hover:bg-red-600 transition">
      Выйти
    </button>
  </aside>
</template>
