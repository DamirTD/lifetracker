<template>
  <div class="min-h-screen bg-gradient-to-b from-gray-900 to-gray-800 flex flex-col items-center px-4 text-white">
    <!-- Header -->
    <header class="w-full max-w-7xl py-8 flex justify-between items-center animate__animated animate__fadeInDown">
      <div class="flex items-center space-x-2">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-indigo-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
        <h1 class="text-3xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-indigo-400 to-purple-500">LifeTracker</h1>
      </div>
      <span class="text-gray-400 hidden md:block text-sm font-medium">Цифровой сервис для улучшения качества жизни</span>
    </header>

    <!-- Hero -->
    <section class="text-center my-12 max-w-2xl animate__animated animate__fadeIn">
      <h2 class="text-4xl md:text-5xl font-extrabold leading-tight">
        Улучшай <span class="text-indigo-400">здоровье</span>, <span class="text-teal-400">продуктивность</span> и <span class="text-emerald-400">финансы</span> — всё в одном месте.
      </h2>
      <p class="mt-6 text-gray-300 text-lg max-w-xl mx-auto">
        Используй трекеры, чтобы жить осознанно, экономно и здорово.
      </p>
    </section>

    <!-- Трекеры -->
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6 max-w-5xl w-full px-4 animate__animated animate__fadeInUp">
      <button
          v-for="tracker in trackers"
          :key="tracker.key"
          @click="selectTracker(tracker)"
          class="bg-gray-700 hover:bg-gray-600 border border-gray-600 rounded-2xl shadow-lg p-6 text-center transition-all cursor-pointer transform hover:-translate-y-1 hover:shadow-2xl duration-300"
      >
        <div class="w-14 h-14 bg-gray-800 rounded-full flex items-center justify-center mx-auto mb-4 text-2xl">
          {{ tracker.icon }}
        </div>
        <h3 class="text-xl font-semibold mb-1">{{ tracker.name }}</h3>
        <p class="text-sm text-gray-400">{{ tracker.subtitle }}</p>
      </button>
    </div>

    <!-- Попап -->
    <div v-if="selectedTracker" class="fixed inset-0 bg-black/70 backdrop-blur-sm flex justify-center items-center z-50 px-4">
      <div class="bg-gray-800 rounded-xl p-8 max-w-md w-full relative shadow-2xl border border-gray-700 animate__animated animate__zoomIn">
        <button @click="selectedTracker = null" class="absolute top-4 right-4 text-gray-400 hover:text-white transition-colors">
          ✖
        </button>
        <div class="flex items-center mb-4">
          <div class="w-10 h-10 rounded-full bg-indigo-900/50 flex items-center justify-center mr-3 text-xl">
            {{ selectedTracker.icon }}
          </div>
          <h2 class="text-2xl font-bold">{{ selectedTracker.name }}</h2>
        </div>
        <p class="text-gray-300 text-md leading-relaxed">{{ selectedTracker.message }}</p>
        <button
            @click="selectedTracker = null"
            class="mt-6 w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-lg transition-colors"
        >
          Понятно
        </button>
      </div>
    </div>

    <!-- Footer -->
    <footer class="mt-20 py-10 w-full border-t border-gray-700 text-center text-gray-500 text-sm animate__animated animate__fadeInUp">
      <p>© {{ new Date().getFullYear() }} LifeTracker. Все права защищены.</p>
      <p class="mt-2">Создано для заботы о здоровье, времени и кошельке.</p>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

interface Tracker {
  key: string;
  name: string;
  subtitle: string;
  message: string;
  icon: string;
}

const selectedTracker = ref<null | Tracker>(null);

const trackers: Tracker[] = [
  {
    key: 'water',
    name: 'Трекер воды 💧',
    subtitle: 'Следи за уровнем гидратации и напоминаниями',
    message: '30 дней регулярного питья воды могут снизить усталость, улучшить цвет лица и нормализовать давление.',
    icon: '💧',
  },
  {
    key: 'sleep',
    name: 'Трекер сна 😴',
    subtitle: 'Анализируй фазы сна и улучшай режим',
    message: 'Сон от 7 до 9 часов в течение месяца улучшает память, настроение и снижает риск выгорания.',
    icon: '😴',
  },
  {
    key: 'sport',
    name: 'Трекер спорта 🏋️',
    subtitle: 'Следи за активностью, прогрессом и мотивацией',
    message: 'Регулярные тренировки 20+ минут в день поднимают уровень энергии и укрепляют сердце.',
    icon: '🏋️',
  },
  {
    key: 'finance',
    name: 'Трекер финансов 💰',
    subtitle: 'Фиксируй расходы и следи за бюджетом',
    message: 'Осознанный контроль трат — это путь к накоплениям и уверенности в завтрашнем дне.',
    icon: '💰',
  },
  {
    key: 'diet',
    name: 'Трекер диеты 🥗',
    subtitle: 'Следи за рационом, калориями и витаминами',
    message: 'Рациональное питание помогает контролировать вес, улучшает пищеварение и сон.',
    icon: '🥗',
  },
];

function selectTracker(tracker: Tracker) {
  selectedTracker.value = tracker;
}
</script>

<style scoped>
@import 'https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css';

@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}
</style>
