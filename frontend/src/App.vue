<script setup lang="ts">
import { useAuthStore } from './store/authStore';
import {computed, onMounted} from 'vue';

const authStore = useAuthStore();
const isAuthenticated = computed(() => !!authStore.user);

onMounted(async () => {
  await authStore.checkAuth();
});
</script>

<template>
  <div>
    <header>
      <nav>
        <router-link to="/">Главная</router-link>
        <router-link to="/login">Вход</router-link>
        <router-link to="/register">Регистрация</router-link>
      </nav>

      <div v-if="isAuthenticated">
        <p>Добро пожаловать, {{ authStore.user?.name }}!</p>
        <button @click="authStore.logout()">Выйти</button>
      </div>
    </header>

    <main>
      <router-view />
    </main>
  </div>
</template>

<style scoped>
/* Глобальные стили */
body {
  background: #FFFFFF;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  line-height: 1.6;
  margin: 0;
  padding: 0;
}

/* Для всех кнопок сохраняем единый стиль */
button {
  font-family: inherit;
  font-weight: 500;
}
</style>