<script lang="ts" setup>
import { ref } from "vue";
import { useAuthStore } from "../../store/authStore.ts";
import { useRouter } from "vue-router";
import type { RegisterRequest } from "../../types/auth.ts";

const authStore    = useAuthStore();
const router       = useRouter();
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
    await router.push("/dashboard");
  } catch (error) {
    console.error("Ошибка регистрации:", (error as any).response?.data);
  }
};
</script>

<template>
  <div class="max-w-md mx-auto mt-8 p-8 bg-[#F8F9FA] rounded-lg shadow-md">
    <form @submit.prevent="handleRegister" class="flex flex-col gap-4">
      <input v-model="registerData.name" placeholder="Имя" required class="p-3 border border-gray-300 rounded-md" />
      <input v-model="registerData.surname" placeholder="Фамилия" required class="p-3 border border-gray-300 rounded-md" />
      <input v-model="registerData.login" placeholder="Логин" required class="p-3 border border-gray-300 rounded-md" />
      <input v-model="registerData.email" type="email" placeholder="Email" required class="p-3 border border-gray-300 rounded-md" />
      <input v-model="registerData.password" type="password" placeholder="Пароль" required class="p-3 border border-gray-300 rounded-md" />
      <input v-model="registerData.password_confirmation" type="password" placeholder="Подтвердите пароль" required class="p-3 border border-gray-300 rounded-md" />
      <button type="submit" class="bg-blue-600 text-white p-3 rounded-md">Зарегистрироваться</button>
    </form>
  </div>
</template>
