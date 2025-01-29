<?php

namespace App\Providers;

use App\Modules\Auth\Query\UserQuery;
use App\Modules\Auth\QueryInterface\UserQueryInterface;
use App\Modules\Auth\Repository\UserRepository;
use App\Modules\Auth\RepositoryInterface\UserRepositoryInterface;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use App\Modules\Auth\Services\AuthService;
use App\Modules\Finance\Query\FinanceRecordQuery;
use App\Modules\Finance\QueryInterfaces\FinanceRecordQueryInterface;
use App\Modules\Finance\ServiceInterfaces\FinanceAdviceServiceInterface;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFAnalyzerServiceInterface;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFServiceInterface;
use App\Modules\Finance\Services\FinanceAdviceService;
use App\Modules\Finance\Services\KaspiPDFAnalyzerService;
use App\Modules\Finance\Services\KaspiPDFService;
use App\Modules\Health\Repository\SleepRepository;
use App\Modules\Health\RepositoryInterfaces\SleepRepositoryInterface;
use App\Modules\Health\ServiceInterfaces\SleepServiceInterface;
use App\Modules\Health\ServiceInterfaces\WaterServiceInterface;
use App\Modules\Health\Services\SleepService;
use App\Modules\Health\Services\WaterService;
use App\Modules\Task\Query\TaskQuery;
use App\Modules\Task\QueryInterfaces\TaskQueryInterface;
use App\Modules\Task\Repository\TaskRepository;
use App\Modules\Task\RepositoryInterfaces\TaskRepositoryInterface;
use App\Modules\Task\ServiceInterfaces\TaskServiceInterface;
use App\Modules\Task\Services\TaskService;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{

    public function register(): void
    {
        // SERVICES
        $this->app->bind(AuthServiceInterface::class, AuthService::class);
        $this->app->bind(WaterServiceInterface::class, WaterService::class);
        $this->app->bind(KaspiPDFServiceInterface::class, KaspiPDFService::class);
        $this->app->bind(KaspiPDFAnalyzerServiceInterface::class, KaspiPDFAnalyzerService::class);
        $this->app->bind(FinanceAdviceServiceInterface::class, FinanceAdviceService::class);
        $this->app->bind(SleepServiceInterface::class, SleepService::class);
        $this->app->bind(TaskServiceInterface::class, TaskService::class);

        // Repositories
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);
        $this->app->bind(SleepRepositoryInterface::class, SleepRepository::class);
        $this->app->bind(TaskRepositoryInterface::class, TaskRepository::class);

        // Query
        $this->app->bind(UserQueryInterface::class, UserQuery::class);
        $this->app->bind(FinanceRecordQueryInterface::class, FinanceRecordQuery::class);
        $this->app->bind(TaskQueryInterface::class, TaskQuery::class);
    }
}
