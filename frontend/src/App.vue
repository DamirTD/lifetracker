<script setup lang="ts">
import { useAuthStore } from "./store/authStore";
import { onMounted } from "vue";

const authStore = useAuthStore();

onMounted(async () => {
  if (!authStore.isAuthChecked) {
    await authStore.checkAuth();
  }
});
</script>

<template>
  <router-view v-if="authStore.isAuthChecked" />
</template>
