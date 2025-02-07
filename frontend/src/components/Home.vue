<script setup lang="ts">
import { useAuthStore } from '../store/authStore';
import Sidebar from "./Sidebar.vue";

const authStore = useAuthStore();
</script>

<template>
  <div class="flex min-h-screen">
    <Sidebar />

    <main class="flex-1 p-6">
      <h1 class="text-2xl font-bold">Добро пожаловать на главную страницу!</h1>
      <p>Вы вошли как <span class="font-semibold">{{ authStore.user?.name }}</span>.</p>
    </main>
  </div>
</template>
