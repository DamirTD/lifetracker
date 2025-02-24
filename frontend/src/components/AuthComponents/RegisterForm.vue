<script setup lang="ts">
import { ref } from "vue";
import { useAuthStore } from "../../store/authStore.ts";
import { useRouter } from "vue-router";
import type { RegisterRequest } from "../../types/auth.ts";

const authStore = useAuthStore();
const router = useRouter();
const isLoading = ref(false);
const errors = ref<{ [key: string]: string }>({});

const registerData = ref<RegisterRequest>({
  name: "",
  surname: "",
  login: "",
  email: "",
  password: "",
  password_confirmation: "",
});

// Валидация
const validateForm = () => {
  errors.value = {};

  if (!registerData.value.name) errors.value.name = "Введите имя";
  if (!registerData.value.surname) errors.value.surname = "Введите фамилию";
  if (!registerData.value.login) errors.value.login = "Введите логин";
  if (!registerData.value.email) errors.value.email = "Введите email";
  if (!registerData.value.password) errors.value.password = "Введите пароль";
  if (registerData.value.password.length < 6)
    errors.value.password = "Пароль должен быть от 6 символов";
  if (registerData.value.password !== registerData.value.password_confirmation)
    errors.value.password_confirmation = "Пароли не совпадают";

  return Object.keys(errors.value).length === 0;
};

const handleRegister = async () => {
  if (!validateForm()) return;

  try {
    isLoading.value = true;
    await authStore.register(registerData.value);
    await router.push("/dashboard");
  } catch (error) {
    console.error("Ошибка регистрации:", (error as any).response?.data);
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <div class="w-full max-w-md p-8 bg-white shadow-lg rounded-xl">
    <h2 class="text-2xl font-semibold text-center mb-6">Создать аккаунт</h2>

    <form @submit.prevent="handleRegister" class="flex flex-col gap-4">
      <div class="input-group">
        <input v-model="registerData.name" placeholder="Имя *" class="input-field" />
        <span v-if="errors.name" class="error-text">{{ errors.name }}</span>
      </div>

      <div class="input-group">
        <input v-model="registerData.surname" placeholder="Фамилия *" class="input-field" />
        <span v-if="errors.surname" class="error-text">{{ errors.surname }}</span>
      </div>

      <div class="input-group">
        <input v-model="registerData.login" placeholder="Логин *" class="input-field" />
        <span v-if="errors.login" class="error-text">{{ errors.login }}</span>
      </div>

      <div class="input-group">
        <input v-model="registerData.email" type="email" placeholder="Email *" class="input-field" />
        <span v-if="errors.email" class="error-text">{{ errors.email }}</span>
      </div>

      <div class="input-group">
        <input v-model="registerData.password" type="password" placeholder="Пароль *" class="input-field" />
        <span v-if="errors.password" class="error-text">{{ errors.password }}</span>
      </div>

      <div class="input-group">
        <input v-model="registerData.password_confirmation" type="password" placeholder="Подтвердите пароль *" class="input-field" />
        <span v-if="errors.password_confirmation" class="error-text">{{ errors.password_confirmation }}</span>
      </div>

      <button type="submit" class="btn-primary" :disabled="isLoading">
        {{ isLoading ? "Загрузка..." : "Зарегистрироваться" }}
      </button>

      <p class="text-center text-gray-600">
        Уже есть аккаунт?
        <router-link to="/login" class="text-blue-600 hover:underline">Войти</router-link>
      </p>
    </form>
  </div>
</template>

<style scoped>
.input-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.input-field {
  padding: 12px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  transition: 0.2s;
}

.input-field:focus {
  border-color: #1e88e5;
  outline: none;
  box-shadow: 0 0 5px rgba(30, 136, 229, 0.3);
}

.error-text {
  color: #d32f2f;
  font-size: 12px;
}

.btn-primary {
  background-color: #1e88e5;
  color: white;
  padding: 12px;
  border-radius: 8px;
  font-weight: bold;
  transition: background 0.3s;
}

.btn-primary:hover {
  background-color: #0d47a1;
}

.btn-primary:disabled {
  background-color: #90caf9;
  cursor: not-allowed;
}
</style>
