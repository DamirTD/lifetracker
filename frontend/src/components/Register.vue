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
  <form @submit.prevent="handleRegister">
    <input v-model="registerData.name" placeholder="Имя" required />
    <input v-model="registerData.surname" placeholder="Фамилия" required />
    <input v-model="registerData.login" placeholder="Логин" required />
    <input v-model="registerData.email" type="email" placeholder="Email" required />
    <input v-model="registerData.password" type="password" placeholder="Пароль" required />
    <input v-model="registerData.password_confirmation" type="password" placeholder="Подтвердите пароль" required />
    <button type="submit">Зарегистрироваться</button>
  </form>
</template>