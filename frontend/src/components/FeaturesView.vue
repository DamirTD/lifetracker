<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

const sections = ref([
  { id: 'tasks', title: 'Таск-менеджер' },
  { id: 'finance', title: 'Финансы' },
  { id: 'health', title: 'Здоровье' },
]);

const activeSection = ref('tasks');
</script>

<template>
  <div class="max-w-7xl mx-auto px-6 py-20">
    <!-- Кнопка возврата -->
    <button @click="router.push('/')" class="mb-6 px-6 py-3 bg-gray-200 hover:bg-gray-300 rounded-full">
      ⬅ Вернуться на главную
    </button>

    <!-- Внутренняя навигация -->
    <nav class="flex gap-6 mb-12 overflow-x-auto">
      <button
          v-for="section in sections"
          :key="section.id"
          @click="activeSection = section.id"
          class="px-6 py-3 rounded-full"
          :class="activeSection === section.id
          ? 'bg-blue-600 text-white'
          : 'bg-gray-100 text-gray-600 hover:bg-gray-200'">
        {{ section.title }}
      </button>
    </nav>

    <!-- Динамический контент -->

      <div :key="activeSection" class="space-y-8">
        <div v-if="activeSection === 'tasks'">
          <h2 class="text-4xl font-bold mb-6">Управление задачами</h2>
          <p class="text-lg text-gray-700">Создавайте, редактируйте и отслеживайте свои задачи в удобном интерфейсе.</p>
        </div>

        <div v-if="activeSection === 'finance'">
          <h2 class="text-4xl font-bold mb-6">Финансовый трекинг</h2>
          <p class="text-lg text-gray-700">Анализируйте расходы и доходы, планируйте бюджет и контролируйте финансы.</p>
        </div>

        <div v-if="activeSection === 'health'">
          <h2 class="text-4xl font-bold mb-6">Трекинг здоровья</h2>
          <p class="text-lg text-gray-700">Отслеживайте физическую активность, питание и общее состояние здоровья.</p>
        </div>
      </div>

  </div>
</template>

