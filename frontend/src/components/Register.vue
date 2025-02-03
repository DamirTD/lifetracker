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
  <div class="form-container">
    <form @submit.prevent="handleRegister">
      <input v-model="registerData.name" placeholder="Имя" required />
      <input v-model="registerData.surname" placeholder="Фамилия" required />
      <input v-model="registerData.login" placeholder="Логин" required />
      <input v-model="registerData.email" type="email" placeholder="Email" required />
      <input v-model="registerData.password" type="password" placeholder="Пароль" required />
      <input v-model="registerData.password_confirmation" type="password" placeholder="Подтвердите пароль" required />
      <button type="submit">Зарегистрироваться</button>
    </form>
  </div>

</template>

<style scoped>
.form-container {
  max-width: 400px;
  margin: 2rem auto;
  padding: 2rem;
  background: #F8F9FA;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(30, 136, 229, 0.1);
}

form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

input {
  padding: 12px;
  border: 1px solid #E3F2FD;
  border-radius: 4px;
  font-size: 16px;
  transition: border-color 0.3s ease;
}

input:focus {
  outline: none;
  border-color: #1E88E5;
  box-shadow: 0 0 0 2px rgba(30, 136, 229, 0.2);
}

button[type="submit"] {
  background: #1E88E5;
  color: white;
  padding: 12px;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.3s ease;
}

button[type="submit"]:hover {
  background: #0D47A1;
}

@media (max-width: 480px) {
  .form-container {
    margin: 1rem;
    padding: 1.5rem;
  }
}
</style>