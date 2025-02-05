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
  <div class="max-w-md mx-auto mt-8 p-8 bg-[#F8F9FA] rounded-lg shadow-md">
    <form @submit.prevent="handleLogin" class="flex flex-col gap-4">
      <input
          v-model="loginData.login"
          placeholder="Логин"
          class="p-3 border border-[#E3F2FD] rounded-md text-lg transition focus:outline-none focus:border-[#1E88E5] focus:ring-2 focus:ring-[#1E88E5]/20"
      />
      <input
          v-model="loginData.password"
          type="password"
          placeholder="Пароль"
          class="p-3 border border-[#E3F2FD] rounded-md text-lg transition focus:outline-none focus:border-[#1E88E5] focus:ring-2 focus:ring-[#1E88E5]/20"
      />
      <button
          type="submit"
          class="bg-[#1E88E5] text-white p-3 rounded-md text-lg cursor-pointer transition hover:bg-[#0D47A1]"
      >
        Войти
      </button>
    </form>
  </div>
</template>