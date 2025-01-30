import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../store/authStore';
import Home from '../components/Home.vue';
import Login from '../components/Login.vue';
import Register from '../components/Register.vue';

const routes = [
    { path: '/', component: Home },
    { path: '/login', component: Login, meta: { requiresGuest: true } },
    { path: '/register', component: Register, meta: { requiresGuest: true } },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach((to, _from, next) => {
    const authStore = useAuthStore();

    if (to.meta.requiresGuest && authStore.user) {
        return next('/');
    }

    next();
});

export default router;