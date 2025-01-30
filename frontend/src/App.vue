<script setup lang="ts">
import { useAuthStore } from './store/authStore';
import { computed } from 'vue';

const authStore = useAuthStore();
const isAuthenticated = computed(() => !!authStore.user);
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

      <div v-else>
        <p>Пожалуйста, войдите или зарегистрируйтесь.</p>
      </div>
    </header>

    <main>
      <router-view />
    </main>
  </div>
</template>

<style scoped>
/* Стили компонента */
</style>