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

<style scoped>

button {
  background: #E3F2FD;
  color: #0D47A1;
  padding: 8px 16px;
  border: 1px solid #90CAF9;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
}

button:hover {
  background: #1E88E5;
  color: white;
  border-color: #1E88E5;
}

</style>
