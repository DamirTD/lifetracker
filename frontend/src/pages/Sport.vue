<script setup lang="ts">
import Sidebar from "../components/Sidebar.vue";
import SportSelection from "../components/SportComponents/SportSelection.vue";
import SportAnalysis from "../components/SportComponents/SportAnalysis.vue";
</script>

<template>
  <div class="flex">
    <Sidebar />
    <div class="ml-64 p-6 w-full">
      <h1 class="text-2xl font-bold mb-4">Спорт</h1>

      <div class="grid grid-cols-2 gap-6">
        <div class="bg-white p-6 shadow-md rounded">
          <SportSelection />
        </div>

        <div class="bg-white p-6 shadow-md rounded">
          <SportAnalysis />
        </div>
      </div>
    </div>
  </div>
</template>
