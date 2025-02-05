<script setup lang="ts">
import { useAuthStore } from '../store/authStore';

const authStore = useAuthStore();
</script>

<template>
  <aside class="w-64 bg-white shadow-md p-4 flex flex-col">
    <router-link to="/" class="text-blue-600 hover:underline mb-4">Главная</router-link>

    <div class="mt-4">
      <p class="font-semibold">Добро пожаловать, {{ authStore.user?.name }}!</p>
      <button @click="authStore.logout()" class="mt-2 text-red-500 hover:underline">Выйти</button>
    </div>
  </aside>
</template>
