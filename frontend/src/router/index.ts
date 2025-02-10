import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from "../store/authStore";
import Landing from "../pages/Landing.vue";
import Home from "../components/Home.vue";
import LoginForm from "../components/LoginForm.vue";
import RegisterForm from "../components/RegisterForm.vue";
import TaskList from "../components/TaskList.vue";

const routes = [
    { path: "/", component: Landing },
    { path: "/dashboard", component: Home, meta: { requiresAuth: true } },
    { path: "/login", component: LoginForm },
    { path: "/register", component: RegisterForm },
    { path: "/tasks", component: TaskList, meta: { requiresAuth: true } },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach(async (to, _from, next) => {
    const authStore = useAuthStore();

    if (!authStore.isAuthChecked) {
        await authStore.checkAuth();
    }

    if (to.meta.requiresAuth && !authStore.user) {
        next("/login");
    } else {
        next();
    }
});

export default router;
