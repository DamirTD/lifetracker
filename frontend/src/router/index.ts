import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../store/authStore';
import Landing from '../pages/Landing.vue';
import Home from '../components/Home.vue';
import LoginForm from '../components/LoginForm.vue';
import RegisterForm from '../components/RegisterForm.vue';

const routes = [
    { path: '/', component: Landing },
    { path: '/home', component: Home, meta: { requiresAuth: true } },
    { path: '/login', component: LoginForm, meta: { requiresGuest: true } },
    { path: '/register', component: RegisterForm, meta: { requiresGuest: true } },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach(async (to, _from, next) => {
    const authStore = useAuthStore();
    await authStore.checkAuth();

    if (to.meta.requiresAuth && !authStore.user) {
        return next('/register');
    }

    if (to.meta.requiresGuest && authStore.user) {
        return next('/home');
    }

    next();
});

export default router;
