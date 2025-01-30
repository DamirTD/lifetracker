<script lang="ts" setup>
import { ref } from "vue";
import { useAuthStore } from "../store/authStore";
import { useRouter } from "vue-router";
import type { LoginRequest } from "../types/auth";

const authStore = useAuthStore();
const router = useRouter();
const loginData = ref<LoginRequest>({ login: "", password: "" });

const handleLogin = async () => {
  try {
    await authStore.login(loginData.value);
    await router.push("/");
  } catch (error) {
    console.error("Ошибка входа:", (error as any).response?.data);
  }
};
</script>

<template>
  <form @submit.prevent="handleLogin">
    <input v-model="loginData.login" placeholder="Логин" />
    <input v-model="loginData.password" type="password" placeholder="Пароль" />
    <button type="submit">Войти</button>
  </form>
</template>