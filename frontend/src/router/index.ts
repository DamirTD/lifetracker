import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../store/authStore';
import Home from '../components/Home.vue';
import LoginForm from '../components/LoginForm.vue';
import RegisterForm from '../components/RegisterForm.vue';

const routes = [
    { path: '/', component: Home },
    { path: '/login', component: LoginForm, meta: { requiresGuest: true } },
    { path: '/register', component: RegisterForm, meta: { requiresGuest: true } },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach(async (to, _from, next) => {
    const authStore = useAuthStore();

    if (to.meta.requiresAuth && !authStore.user) {
        await authStore.checkAuth();
        if (!authStore.user) return next('/login');
    }

    if (to.meta.requiresGuest && authStore.user) {
        return next('/');
    }

    next();
});

export default router;