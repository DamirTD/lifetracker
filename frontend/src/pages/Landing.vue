<template>
  <div class="relative min-h-screen bg-white">
    <header class="fixed top-0 left-0 right-0 w-full h-16 backdrop-blur-md bg-white/90 border-b border-gray-100 z-50">
      <div class="max-w-7xl mx-auto px-6 h-full flex items-center justify-between">
        <RouterLink to="/" class="text-2xl font-semibold">LifeTech</RouterLink>

        <!-- Desktop nav -->
        <nav class="hidden md:flex gap-8 items-center justify-center">
          <RouterLink to="/features" class="text-gray-600 hover:text-black transition-all px-3 py-2 text-sm font-medium">
            Возможности
          </RouterLink>
          <button @click="showPricing = true"
                  class="text-gray-600 hover:text-black transition-all px-3 py-2 text-sm font-medium">
            Тарифы
          </button>
        </nav>

        <!-- Mobile Menu Button -->
        <button @click="mobileMenuOpen = !mobileMenuOpen" class="md:hidden text-gray-600">
          ☰
        </button>
      </div>

      <!-- Mobile Menu -->
      <div v-if="mobileMenuOpen" class="md:hidden absolute top-16 left-0 w-full bg-white border-t border-gray-200 shadow-md">
        <nav class="flex flex-col gap-4 p-4 text-center">
          <RouterLink to="/features" @click="mobileMenuOpen = false" class="text-gray-600 hover:text-black">
            Возможности
          </RouterLink>
          <button @click="showPricing = true; mobileMenuOpen = false" class="text-gray-600 hover:text-black">
            Тарифы
          </button>
        </nav>
      </div>
    </header>

    <main class="pt-20 px-4 flex flex-col md:flex-row items-center justify-center max-w-7xl mx-auto gap-10">
      <!-- Форма регистрации -->
      <div class="w-full md:w-1/2">
        <RegisterForm />
      </div>

      <!-- Картинка -->
      <div class="w-full md:w-1/2 flex justify-center">
        <img src="/assets/img/hero-bg.jpeg" alt="Регистрация" class="w-full h-auto max-w-lg">
      </div>
    </main>

    <!-- Попап с тарифами -->
    <PricingModal v-if="showPricing" @close="showPricing = false" />
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import PricingModal from "../components/PricingModal.vue";
import RegisterForm from "../components/AuthComponents/RegisterForm.vue";

const showPricing = ref(false);
const mobileMenuOpen = ref(false);
</script>