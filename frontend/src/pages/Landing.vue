<script setup lang="ts">
import { ref, onMounted } from "vue";
import AOS from "aos";
import "aos/dist/aos.css";

const isMenuOpen = ref(false);

onMounted(() => {
  AOS.init({
    duration: 1000,
    once: true,
    easing: "ease-in-out",
  });
});
</script>

<template>
  <div class="bg-white text-black font-['Inter'] overflow-x-hidden">
    <header class="fixed top-0 left-0 right-0 w-full h-16 backdrop-blur-md bg-gradient-to-b from-white/80 to-white/50 border-b border-gray-200 py-4 z-50">
      <div class="w-full max-w-7xl mx-auto px-6 flex justify-between items-center h-full">

        <h1 class="text-2xl font-semibold">LifeTech</h1>

        <div class="hidden md:flex flex-1 justify-center">
          <nav class="flex gap-6 bg-gray-100 px-8 py-3 rounded-full shadow-md">
            <router-link to="/" class="text-gray-700 hover:text-black transition text-sm font-medium">Главная</router-link>
            <router-link to="/features" class="text-gray-700 hover:text-black transition text-sm font-medium">Возможности</router-link>
            <router-link to="/pricing" class="text-gray-700 hover:text-black transition text-sm font-medium">Тарифы</router-link>
          </nav>
        </div>

        <button class="md:hidden text-black" @click="isMenuOpen = !isMenuOpen">
          ☰
        </button>

      </div>

      <div v-show="isMenuOpen" class="fixed top-16 left-0 w-full bg-white shadow-md flex flex-col items-center py-4 transition-all duration-300">
        <router-link to="/" class="py-2 text-gray-700 hover:text-black transition text-sm font-medium" @click="isMenuOpen = false">Главная</router-link>
        <router-link to="/features" class="py-2 text-gray-700 hover:text-black transition text-sm font-medium" @click="isMenuOpen = false">Возможности</router-link>
        <router-link to="/pricing" class="py-2 text-gray-700 hover:text-black transition text-sm font-medium" @click="isMenuOpen = false">Тарифы</router-link>
      </div>
    </header>


    <section class="relative min-h-screen flex items-center pt-20">
      <div class="max-w-7xl mx-auto px-6 flex flex-col md:flex-row items-center gap-12">
        <div class="max-w-2xl" data-aos="fade-right">
          <h2 class="text-5xl font-bold leading-tight text-black">Digital Service for Quality of Life Improvement</h2>
          <p class="text-lg text-gray-700 mt-4">Управляйте задачами, финансами, здоровьем и физической активностью в одном месте.</p>
        </div>
        <div class="flex-1 flex items-center justify-center" data-aos="fade-left">
          <img src="/assets/img/hero-bg.jpeg" alt="LifeTech Illustration" class="max-w-full h-auto rounded-lg shadow-md" />
        </div>
      </div>
    </section>

    <section class="py-24 text-center border-t border-gray-200">
      <div class="max-w-7xl mx-auto px-6">
        <h2 class="text-3xl font-bold text-black" data-aos="fade-up">Функциональность</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mt-12">
          <div class="p-6 bg-gray-100 rounded-lg shadow-md hover:shadow-lg transition">
            <h3 class="text-xl font-semibold text-black">Таск менеджер</h3>
            <p class="text-gray-700 mt-2">Управление задачами, сортировка и отслеживание выполнения.</p>
          </div>
          <div class="p-6 bg-gray-100 rounded-lg shadow-md hover:shadow-lg transition">
            <h3 class="text-xl font-semibold text-black">Финансовый трекер</h3>
            <p class="text-gray-700 mt-2">Анализ транзакций, советы и цели накоплений.</p>
          </div>
          <div class="p-6 bg-gray-100 rounded-lg shadow-md hover:shadow-lg transition">
            <h3 class="text-xl font-semibold text-black">Трекер сна</h3>
            <p class="text-gray-700 mt-2">Анализ и улучшение качества сна.</p>
          </div>
          <div class="p-6 bg-gray-100 rounded-lg shadow-md hover:shadow-lg transition">
            <h3 class="text-xl font-semibold text-black">Трекер воды</h3>
            <p class="text-gray-700 mt-2">Напоминания и учет потребления воды.</p>
          </div>
          <div class="p-6 bg-gray-100 rounded-lg shadow-md hover:shadow-lg transition">
            <h3 class="text-xl font-semibold text-black">Трекер спорта</h3>
            <p class="text-gray-700 mt-2">Создание и отслеживание тренировок.</p>
          </div>
          <div class="p-6 bg-gray-100 rounded-lg shadow-md hover:shadow-lg transition">
            <h3 class="text-xl font-semibold text-black">Трекер калорий и диеты</h3>
            <p class="text-gray-700 mt-2">Контроль калорийности и планирование питания.</p>
          </div>
        </div>
      </div>
    </section>

    <footer class="bg-white py-6 text-center border-t border-gray-200">
      <div class="max-w-7xl mx-auto px-6">
        <p class="text-gray-700">&copy; 2025 LifeTech. Все права защищены.</p>
      </div>
    </footer>
  </div>
</template>
