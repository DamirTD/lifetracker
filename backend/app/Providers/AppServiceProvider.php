<?php

namespace App\Providers;

use App\Models\User;
use App\Modules\Auth\Query\UserQuery;
use App\Modules\Auth\QueryInterface\UserQueryInterface;
use App\Modules\Auth\Repository\UserRepository;
use App\Modules\Auth\RepositoryInterface\UserRepositoryInterface;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use App\Modules\Auth\Services\AuthService;
use App\Modules\Finance\Query\FinanceRecordQuery;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use App\Modules\Finance\ServiceInterfaces\BudgetServiceInterface;
use App\Modules\Finance\ServiceInterfaces\CategoryServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinanceAdviceServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinanceExportServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinanceImportServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinanceStatisticsServiceInterface;
use App\Modules\Finance\ServiceInterfaces\FinancialGoalServiceInterface;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFAnalyzerServiceInterface;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFServiceInterface;
use App\Modules\Finance\Services\BudgetService;
use App\Modules\Finance\Services\CategoryService;
use App\Modules\Finance\Services\FinanceAdviceService;
use App\Modules\Finance\Services\FinanceExportService;
use App\Modules\Finance\Services\FinanceImportService;
use App\Modules\Finance\Services\FinanceStatisticsService;
use App\Modules\Finance\Services\FinancialGoalService;
use App\Modules\Finance\Services\KaspiPDFAnalyzerService;
use App\Modules\Finance\Services\KaspiPDFService;
use App\Modules\Health\Repository\DietRepository;
use App\Modules\Health\Repository\SleepGoalRepository;
use App\Modules\Health\Repository\SleepRepository;
use App\Modules\Health\RepositoryInterfaces\DietRepositoryInterface;
use App\Modules\Health\RepositoryInterfaces\SleepGoalRepositoryInterface;
use App\Modules\Health\RepositoryInterfaces\SleepRepositoryInterface;
use App\Modules\Health\ServiceInterfaces\DietServiceInterface;
use App\Modules\Health\ServiceInterfaces\SleepServiceInterface;
use App\Modules\Health\ServiceInterfaces\WaterServiceInterface;
use App\Modules\Health\Services\DietService;
use App\Modules\Health\Services\SleepService;
use App\Modules\Health\Services\WaterService;
use App\Modules\Task\Query\TaskQuery;
use App\Modules\Task\QueryInterfaces\TaskQueryInterface;
use App\Modules\Task\Repositories\TaskCategoryRepository;
use App\Modules\Task\Repositories\TaskRepository;
use App\Modules\Task\RepositoryInterfaces\TaskCategoryRepositoryInterface;
use App\Modules\Task\RepositoryInterfaces\TaskRepositoryInterface;
use App\Modules\Task\ServiceInterfaces\TaskCategoryServiceInterface;
use App\Modules\Task\ServiceInterfaces\TaskServiceInterface;
use App\Modules\Task\Services\TaskCategoryService;
use App\Modules\Task\Services\TaskService;
use App\Observers\UserObserver;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{

    public function register(): void
    {
        // SERVICES
        $this->app->bind(AuthServiceInterface::class,              AuthService::class);
        $this->app->bind(WaterServiceInterface::class,             WaterService::class);
        $this->app->bind(KaspiPDFServiceInterface::class,          KaspiPDFService::class);
        $this->app->bind(KaspiPDFAnalyzerServiceInterface::class,  KaspiPDFAnalyzerService::class);
        $this->app->bind(FinanceAdviceServiceInterface::class,     FinanceAdviceService::class);
        $this->app->bind(SleepServiceInterface::class,             SleepService::class);
        $this->app->bind(TaskServiceInterface::class,              TaskService::class);
        $this->app->bind(TaskCategoryServiceInterface::class,      TaskCategoryService::class);
        $this->app->bind(FinanceExportServiceInterface::class,     FinanceExportService::class);
        $this->app->bind(FinanceImportServiceInterface::class,     FinanceImportService::class);
        $this->app->bind(FinanceStatisticsServiceInterface::class, FinanceStatisticsService::class);
        $this->app->bind(FinancialGoalServiceInterface::class,     FinancialGoalService::class);
        $this->app->bind(CategoryServiceInterface::class,          CategoryService::class);
        $this->app->bind(BudgetServiceInterface::class,            BudgetService::class);
        $this->app->bind(DietServiceInterface::class,              DietService::class);

        // Repositories
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);
        $this->app->bind(SleepRepositoryInterface::class, SleepRepository::class);
        $this->app->bind(TaskRepositoryInterface::class, TaskRepository::class);
        $this->app->bind(TaskCategoryRepositoryInterface::class, TaskCategoryRepository::class);
        $this->app->bind(DietRepositoryInterface::class, DietRepository::class);
        $this->app->bind(SleepGoalRepositoryInterface::class, SleepGoalRepository::class);

        // Query
        $this->app->bind(UserQueryInterface::class, UserQuery::class);
        $this->app->bind(FinanceRecordQueryInterface::class, FinanceRecordQuery::class);
        $this->app->bind(TaskQueryInterface::class, TaskQuery::class);
    }

    // Observers
    public function boot(): void
    {
        User::observe(UserObserver::class);
    }
}
