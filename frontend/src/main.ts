import { createApp } from 'vue'
import App from './App.vue'
import router from './router';
import { createPinia } from 'pinia';
import './main.css';
import { useAuthStore } from "./store/authStore";

const app = createApp(App);
app.use(createPinia());
app.use(router);

const authStore = useAuthStore();

authStore.checkAuth().then(() => {
    app.mount("#app");
});