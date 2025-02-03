<script setup lang="ts">
import { useAuthStore } from '../store/authStore';
import { computed } from 'vue';

const authStore = useAuthStore();
const isAuthenticated = computed(() => !!authStore.user);
</script>

<template>
  <div>
    <h1>Добро пожаловать на главную страницу!</h1>
    <p v-if="isAuthenticated">Вы вошли как {{ authStore.user?.name }}.</p>
  </div>
</template>

<style scoped>
div {
  max-width: 800px;
  margin: 2rem auto;
  padding: 2rem;
  text-align: center;
}

h1 {
  color: #0D47A1;
  margin-bottom: 1.5rem;
  font-size: 2rem;
}

p {
  color: #2A2A2A;
  font-size: 1.1rem;
  padding: 1rem;
  background: #E3F2FD;
  border-radius: 4px;
  display: inline-block;
}
</style>