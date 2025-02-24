<script setup lang="ts">
import { defineEmits } from "vue";

const emits = defineEmits(["close"]);

const plans = [
  {
    name: "Стартовый",
    price: 0,
    features: ["Базовые функции", "5 проектов", "1GB хранилища"],
  },
  {
    name: "Профессиональный",
    price: 990,
    features: ["Все функции", "Неограниченные проекты", "10GB хранилища"],
  },
];
</script>

<template>
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
       @click.self="emits('close')">
    <div class="bg-white p-6 rounded-lg shadow-lg w-full max-w-lg relative">
      <button @click="emits('close')" class="absolute top-3 right-3 text-gray-500 hover:text-black">✕</button>

      <h2 class="text-2xl font-bold text-center mb-6">Выберите тариф</h2>

      <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 text-center">
        <div v-for="(plan, index) in plans" :key="index"
             class="p-4 border rounded-xl hover:border-blue-500 transition-colors">
          <h3 class="text-xl font-bold mb-4">{{ plan.name }}</h3>
          <div class="text-3xl font-bold mb-6">
            {{ plan.price === 0 ? "Бесплатно" : `₽${plan.price}/мес` }}
          </div>
          <ul class="space-y-2 text-sm">
            <li v-for="(feature, i) in plan.features" :key="i" class="flex items-center justify-center">
              <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
              {{ feature }}
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>
