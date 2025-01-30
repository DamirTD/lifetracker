<script lang="ts" setup>
import { useAuthStore } from "../store/authStore";

const authStore = useAuthStore();

const handleLogout = async () => {
  try {
    await authStore.logout();
  } catch (error) {
    console.error("Ошибка выхода:", (error as any).response?.data);
  }
};
</script>

<template>
  <button @click="handleLogout">Выйти</button>
</template>
