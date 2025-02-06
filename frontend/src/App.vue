<script setup lang="ts">
import { computed, onMounted } from 'vue';
import { useAuthStore } from './store/authStore';
import { useRoute } from 'vue-router';
import Sidebar from "./components/Sidebar.vue";
import NotLogin from "./components/NotLogin.vue";

const authStore = useAuthStore();
const route     = useRoute();

const isAuthenticated = computed(() => !!authStore.user);
const isProtectedPage = computed(() => route.meta.requiresAuth);

onMounted(async () => {
  await authStore.checkAuth();
});
</script>

<template>
  <div class="min-h-screen bg-[#F8F9FA] relative flex">
    <Sidebar v-if="isAuthenticated" />

    <main class="p-6 flex-1 relative">
      <div v-if="isProtectedPage && !isAuthenticated" class="absolute inset-0 backdrop-blur-md z-10"></div>
      <router-view />
    </main>

    <div v-if="isProtectedPage && !isAuthenticated" class="fixed inset-0 flex items-center justify-center z-20">
      <NotLogin />
    </div>
  </div>
</template>
