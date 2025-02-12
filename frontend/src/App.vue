<script setup lang="ts">
import { useAuthStore } from "./store/authStore";
import { onMounted } from "vue";

const authStore = useAuthStore();

onMounted(async () => {
  await authStore.checkAuth();
});
</script>

<template>
  <router-view />
</template>
