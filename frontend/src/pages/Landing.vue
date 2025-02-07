<script setup lang="ts">
import { onMounted } from "vue";
import AOS from "aos";
import "aos/dist/aos.css";

onMounted(() => {
  AOS.init({
    duration: 1000, // Длительность анимации (1 секунда)
    once: true, // Анимация запускается только один раз
    easing: "ease-in-out", // Смягчённое появление
  });
});
</script>

<template>
  <div class="bg-[#0a0a12] text-[#E0F2FE] font-['Rajdhani']">
    <!-- Хедер -->
    <header class="bg-gradient-to-r from-[#1e293b]/80 to-[#334155]/80 backdrop-blur-md py-4 px-8 flex justify-between items-center shadow-[0_0_15px_#3b82f6] sticky top-0 z-50 border-b border-[#3b82f6]/40">
      <h1 class="text-2xl font-bold flex items-center gap-2 text-[#38bdf8]">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-[#7dd3fc]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
        </svg>
        <span class="bg-gradient-to-r from-[#7dd3fc] to-[#38bdf8] bg-clip-text text-transparent">LifeTech</span>
      </h1>

      <nav>
        <router-link to="/login" class="px-6 py-2 text-lg font-semibold rounded-full border border-[#3b82f6] text-[#3b82f6] hover:bg-[#3b82f6]/20 transition">Войти</router-link>
        <router-link to="/register" class="ml-4 px-6 py-2 text-lg font-semibold rounded-full bg-gradient-to-r from-[#3b82f6] to-[#7dd3fc] shadow-md hover:shadow-lg hover:scale-105 transition">Регистрация</router-link>
      </nav>
    </header>

    <!-- Герой-секция -->
    <section class="min-h-screen flex items-center justify-center relative overflow-hidden">
      <div class="absolute inset-0 bg-[url('/assets/img/matrix-grid.png')] opacity-20 z-0 animate-pulse"></div>
      <div class="max-w-6xl mx-auto px-4 text-center space-y-8" data-aos="fade-up">
        <h2 class="text-5xl font-bold bg-gradient-to-r from-[#7dd3fc] to-[#38bdf8] bg-clip-text text-transparent">Перезагрузите Свою Реальность</h2>
        <p class="text-xl text-[#94a3b8] max-w-3xl mx-auto">Киберпространство для синхронизации вашего здоровья, финансов и когнитивного развития.</p>
        <router-link to="/register" class="px-12 py-4 text-lg font-semibold rounded-full bg-gradient-to-r from-[#3b82f6] to-[#7dd3fc] shadow-md hover:shadow-xl hover:scale-105 transition">Начать</router-link>
      </div>
    </section>

    <!-- Наши технологии -->
    <section class="py-24 text-center bg-[#111827] border-t border-[#3b82f6]/20" data-aos="fade-up">
      <h2 class="text-4xl font-bold bg-gradient-to-r from-[#7dd3fc] to-[#38bdf8] bg-clip-text text-transparent">Наши технологии</h2>
      <div class="grid md:grid-cols-3 gap-8 mt-12">
        <div class="bg-gradient-to-b from-[#1e293b] to-[#273549] p-6 rounded-xl border border-[#3b82f6]/30 hover:scale-105 transition">
          <h3 class="text-2xl text-[#7dd3fc]">Искусственный интеллект</h3>
          <p class="text-[#cbd5e1]">Анализ данных и персонализированные рекомендации на основе AI.</p>
        </div>
        <div class="bg-gradient-to-b from-[#1e293b] to-[#273549] p-6 rounded-xl border border-[#3b82f6]/30 hover:scale-105 transition">
          <h3 class="text-2xl text-[#7dd3fc]">Кибербезопасность</h3>
          <p class="text-[#cbd5e1]">Защита личных данных и безопасное соединение с сервисами.</p>
        </div>
        <div class="bg-gradient-to-b from-[#1e293b] to-[#273549] p-6 rounded-xl border border-[#3b82f6]/30 hover:scale-105 transition">
          <h3 class="text-2xl text-[#7dd3fc]">Облачные технологии</h3>
          <p class="text-[#cbd5e1]">Доступ к данным и сервисам из любой точки мира.</p>
        </div>
      </div>
    </section>

    <!-- Поддержка и контакты -->
    <section class="py-24 text-center bg-[#0a0a12]" data-aos="fade-up">
      <h2 class="text-4xl font-bold bg-gradient-to-r from-[#7dd3fc] to-[#38bdf8] bg-clip-text text-transparent">Свяжитесь с нами</h2>
      <p class="text-lg text-[#cbd5e1] mt-4">Наша поддержка работает 24/7. Мы всегда готовы помочь!</p>
      <div class="mt-8">
        <a href="mailto:support@lifetech.com" class="text-[#7dd3fc] text-xl hover:underline">support@lifetech.com</a>
      </div>
    </section>

    <!-- Футер -->
    <footer class="bg-[#0f172a] py-8 text-center border-t border-[#3b82f6]/30">
      <p class="text-[#94a3b8]">&copy; 2025 LifeTech. Все права защищены.</p>
      <nav class="mt-4">
        <a href="/privacy" class="text-[#7dd3fc] mx-4 hover:underline">Политика конфиденциальности</a>
        <a href="/terms" class="text-[#7dd3fc] mx-4 hover:underline">Условия использования</a>
      </nav>
    </footer>
  </div>
</template>
