<script setup lang="ts">
import { ref } from "vue";
import { useAuthStore } from "../../store/authStore.ts";
import { useRouter } from "vue-router";
import type { LoginRequest } from "../../types/auth.ts";

const authStore = useAuthStore();
const router = useRouter();
const isLoading = ref(false);
const errors = ref<{ [key: string]: string }>({});

const loginData = ref<LoginRequest>({
  login: "",
  password: "",
});

const validateForm = () => {
  errors.value = {};

  if (!loginData.value.login) errors.value.login = "Введите логин";
  if (!loginData.value.password) errors.value.password = "Введите пароль";

  return Object.keys(errors.value).length === 0;
};

const handleLogin = async () => {
  if (!validateForm()) return;

  try {
    isLoading.value = true;
    await authStore.login(loginData.value);
    await router.push("/dashboard");
  } catch (error) {
    console.error("Ошибка входа:", (error as any).response?.data);
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <div class="w-full max-w-md p-8 bg-white shadow-lg rounded-xl">
    <h2 class="text-2xl font-semibold text-center mb-6">Вход в аккаунт</h2>

    <form @submit.prevent="handleLogin" class="flex flex-col gap-4">
      <div class="input-group">
        <input v-model="loginData.login" placeholder="Логин *" class="input-field" />
        <span v-if="errors.login" class="error-text">{{ errors.login }}</span>
      </div>

      <div class="input-group">
        <input v-model="loginData.password" type="password" placeholder="Пароль *" class="input-field" />
        <span v-if="errors.password" class="error-text">{{ errors.password }}</span>
      </div>

      <button type="submit" class="btn-primary" :disabled="isLoading">
        {{ isLoading ? "Загрузка..." : "Войти" }}
      </button>

      <p class="text-center text-gray-600">
        Нет аккаунта?
        <router-link to="/register" class="text-blue-600 hover:underline">Зарегистрироваться</router-link>
      </p>
    </form>
  </div>
</template>
