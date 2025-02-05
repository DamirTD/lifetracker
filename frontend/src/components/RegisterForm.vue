<script lang="ts" setup>
import { ref } from "vue";
import { useAuthStore } from "../store/authStore";
import { useRouter } from "vue-router";
import type { RegisterRequest } from "../types/auth";

const authStore = useAuthStore();
const router = useRouter();
const registerData = ref<RegisterRequest>({
  name: "",
  surname: "",
  login: "",
  email: "",
  password: "",
  password_confirmation: "",
});

const handleRegister = async () => {
  try {
    await authStore.register(registerData.value);
    await router.push("/");
  } catch (error) {
    console.error("Ошибка регистрации:", (error as any).response?.data);
  }
};
</script>

<template>
  <div class="max-w-md mx-auto mt-8 p-8 bg-[#F8F9FA] rounded-lg shadow-md">
    <form @submit.prevent="handleRegister" class="flex flex-col gap-4">
      <input
          v-model="registerData.name"
          placeholder="Имя"
          required
          class="p-3 border border-[#E3F2FD] rounded-md text-lg transition focus:outline-none focus:border-[#1E88E5] focus:ring-2 focus:ring-[#1E88E5]/20"
      />
      <input
          v-model="registerData.surname"
          placeholder="Фамилия"
          required
          class="p-3 border border-[#E3F2FD] rounded-md text-lg transition focus:outline-none focus:border-[#1E88E5] focus:ring-2 focus:ring-[#1E88E5]/20"
      />
      <input
          v-model="registerData.login"
          placeholder="Логин"
          required
          class="p-3 border border-[#E3F2FD] rounded-md text-lg transition focus:outline-none focus:border-[#1E88E5] focus:ring-2 focus:ring-[#1E88E5]/20"
      />
      <input
          v-model="registerData.email"
          type="email"
          placeholder="Email"
          required
          class="p-3 border border-[#E3F2FD] rounded-md text-lg transition focus:outline-none focus:border-[#1E88E5] focus:ring-2 focus:ring-[#1E88E5]/20"
      />
      <input
          v-model="registerData.password"
          type="password"
          placeholder="Пароль"
          required
          class="p-3 border border-[#E3F2FD] rounded-md text-lg transition focus:outline-none focus:border-[#1E88E5] focus:ring-2 focus:ring-[#1E88E5]/20"
      />
      <input
          v-model="registerData.password_confirmation"
          type="password"
          placeholder="Подтвердите пароль"
          required
          class="p-3 border border-[#E3F2FD] rounded-md text-lg transition focus:outline-none focus:border-[#1E88E5] focus:ring-2 focus:ring-[#1E88E5]/20"
      />
      <button
          type="submit"
          class="bg-[#1E88E5] text-white p-3 rounded-md text-lg cursor-pointer transition hover:bg-[#0D47A1]"
      >
        Зарегистрироваться
      </button>
    </form>
  </div>
</template>

