<script setup lang="ts">
import { computed, onMounted } from 'vue';
import { useAuthStore } from './store/authStore';
import Sidebar from "./components/Sidebar.vue";
import NotLogin from "./components/NotLogin.vue";

const authStore = useAuthStore();
const isAuthenticated = computed(() => !!authStore.user);

onMounted(async () => {
  await authStore.checkAuth();
});
</script>

<template>
  <div class="min-h-screen bg-[#F8F9FA] relative flex">
    <Sidebar v-if="isAuthenticated" />

    <main class="p-6 flex-1 relative">
      <!-- Затемнение и размытие, если пользователь не залогинен -->
      <div v-if="!isAuthenticated" class="absolute inset-0 backdrop-blur-md z-10"></div>

      <router-view />
    </main>

    <!-- Центрируем NotLogin.vue -->
    <div v-if="!isAuthenticated" class="fixed inset-0 flex items-center justify-center z-20">
      <NotLogin />
    </div>
  </div>
</template>
