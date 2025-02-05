<script setup lang="ts">
import { ref } from 'vue';
import LoginForm from './LoginForm.vue';
import RegisterForm from './RegisterForm.vue';

const showLogin = ref(false);
const showRegister = ref(false);

const closeModal = () => {
  showLogin.value = false;
  showRegister.value = false;
};
</script>

<template>
  <div class="fixed inset-0 bg-black/50 backdrop-blur-md z-10"></div>

  <div class="fixed inset-0 flex items-center justify-center z-20">
    <div class="bg-white p-6 rounded-lg shadow-lg max-w-sm w-full text-center relative">
      <h2 class="text-xl font-semibold mb-4">Добро пожаловать!</h2>
      <p class="text-gray-600 mb-4">Войдите или зарегистрируйтесь, чтобы продолжить.</p>

      <button @click="showLogin = true" class="w-full bg-blue-500 text-white py-2 rounded-md mb-2 hover:bg-blue-600">
        Вход
      </button>
      <button @click="showRegister = true" class="w-full bg-green-500 text-white py-2 rounded-md hover:bg-green-600">
        Регистрация
      </button>
    </div>
  </div>

  <div v-if="showLogin || showRegister" class="fixed inset-0 bg-black/50 backdrop-blur-sm z-30" @click="closeModal"></div>

  <div v-if="showLogin" class="fixed inset-0 flex items-center justify-center z-40">
    <div class="bg-white p-6 rounded-lg shadow-lg relative max-w-md w-full">
      <button @click="closeModal" class="absolute top-2 right-2 text-gray-600 text-xl">&times;</button>
      <LoginForm />
    </div>
  </div>

  <div v-if="showRegister" class="fixed inset-0 flex items-center justify-center z-40">
    <div class="bg-white p-6 rounded-lg shadow-lg relative max-w-md w-full">
      <button @click="closeModal" class="absolute top-2 right-2 text-gray-600 text-xl">&times;</button>
      <RegisterForm />
    </div>
  </div>
</template>
