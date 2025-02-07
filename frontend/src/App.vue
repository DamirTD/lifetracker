<script setup lang="ts">
import { ref, computed, onMounted, watchEffect } from "vue";
import { useAuthStore } from "./store/authStore";
import { useRoute, useRouter } from "vue-router";

const authStore = useAuthStore();
const route = useRoute();
const router = useRouter();

const isAuthenticated = computed(() => !!authStore.user);
const isAuthChecked = ref(false);

onMounted(async () => {
  await authStore.checkAuth();
  isAuthChecked.value = true;
});

// Следим за авторизацией и перенаправляем на Home.vue после входа
watchEffect(() => {
  console.log("Auth checked:", isAuthChecked.value);
  console.log("Is authenticated:", isAuthenticated.value);
  console.log("Current route:", route.path);

  if (isAuthChecked.value && isAuthenticated.value && route.path === "/") {
    router.push("/home");
  }
});
</script>

<template>
  <div v-if="!isAuthChecked" class="fixed inset-0 flex items-center justify-center bg-white">
    <span class="text-gray-600 text-lg">Загрузка...</span>
  </div>

  <template v-else>
    <router-view />
  </template>
</template>
