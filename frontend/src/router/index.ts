import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from "../store/authStore";

import Landing from "../pages/Landing.vue";
import Home from "../components/Home.vue";
import LoginForm from "../components/LoginForm.vue";
import RegisterForm from "../components/RegisterForm.vue";
import TaskList from "../pages/TaskList.vue";

const publicRoutes = [
    { path: "/",         component: Landing },
    { path: "/login",    component: LoginForm },
    { path: "/register", component: RegisterForm },
];

const privateRoutes = [
    { path: "/dashboard", component: Home, meta: { requiresAuth: true } },
    { path: "/tasks",     component: TaskList, meta: { requiresAuth: true } },
];

const routes = [...publicRoutes, ...privateRoutes];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach((to, _, next) => {
    const authStore = useAuthStore();
    if (to.meta.requiresAuth && !authStore.user) {
        next("/login");
    } else {
        next();
    }
});

export default router;
