<template>
  <div class="bg-[#F8F9FA] text-[#1E88E5]">
    <header class="bg-[#4A90E2] text-white py-4 px-8 flex justify-between items-center shadow-md">
      <h1 class="text-2xl font-bold">LifeTech</h1>
      <nav class="hidden md:flex gap-6">
        <router-link to="/" class="hover:text-[#90CAF9]">Главная</router-link>
        <router-link to="/not-login" class="hover:text-[#90CAF9]">Функции</router-link>
        <router-link to="/not-login" class="hover:text-[#90CAF9]">Контакты</router-link>
      </nav>
      <div class="flex gap-4">
        <router-link to="/login" class="bg-[#1E88E5] px-4 py-2 rounded-lg hover:bg-[#90CAF9]">
          Вход
        </router-link>
        <router-link to="/register" class="bg-[#90CAF9] px-4 py-2 rounded-lg hover:bg-[#E3F2FD] text-[#1E88E5]">
          Регистрация
        </router-link>
      </div>
    </header>

    <section class="h-screen flex flex-col justify-center items-center text-center p-6">
      <h2 class="text-4xl font-bold mb-4">Улучшите свою жизнь с LifeTech</h2>
      <p class="text-lg text-gray-700 mb-6 max-w-2xl">
        Сон, еда, спорт, финансы — всё под контролем! Наш сервис поможет вам выстроить здоровый образ жизни и достичь целей.
      </p>
      <router-link to="/not-login" class="bg-[#1E88E5] text-white px-6 py-3 rounded-lg hover:bg-[#90CAF9]">
        Начать бесплатно
      </router-link>
    </section>

    <section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 p-10">
      <router-link to="/not-login" class="bg-[#E3F2FD] p-6 rounded-lg text-center hover:bg-[#90CAF9]">
        <h3 class="text-xl font-semibold">Сон</h3>
        <p class="text-gray-700">Анализируйте и улучшайте качество сна</p>
      </router-link>
      <router-link to="/not-login" class="bg-[#E3F2FD] p-6 rounded-lg text-center hover:bg-[#90CAF9]">
        <h3 class="text-xl font-semibold">Еда</h3>
        <p class="text-gray-700">Следите за питанием и калориями</p>
      </router-link>
      <router-link to="/not-login" class="bg-[#E3F2FD] p-6 rounded-lg text-center hover:bg-[#90CAF9]">
        <h3 class="text-xl font-semibold">Спорт</h3>
        <p class="text-gray-700">Тренировки и физическая активность</p>
      </router-link>
      <router-link to="/not-login" class="bg-[#E3F2FD] p-6 rounded-lg text-center hover:bg-[#90CAF9]">
        <h3 class="text-xl font-semibold">Финансы</h3>
        <p class="text-gray-700">Контроль доходов и расходов</p>
      </router-link>
    </section>

    <section class="p-10 bg-[#90CAF9] flex flex-col items-center">
      <h2 class="text-3xl font-semibold mb-6 text-white">Как это работает?</h2>
      <iframe
          class="w-full md:w-3/4 h-64 md:h-96 rounded-lg shadow-lg"
          src="https://www.youtube.com/embed/dQw4w9WgXcQ"
          allowfullscreen
      ></iframe>
    </section>

    <footer class="bg-[#4A90E2] text-white p-6 text-center">
      <p>&copy; 2024 LifeTech. Все права защищены.</p>
    </footer>
  </div>
</template>
