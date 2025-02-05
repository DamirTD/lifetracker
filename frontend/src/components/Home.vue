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
