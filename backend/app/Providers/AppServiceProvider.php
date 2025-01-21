<?php

namespace App\Providers;

use App\Modules\Auth\Query\UserQuery;
use App\Modules\Auth\QueryInterface\UserQueryInterface;
use App\Modules\Auth\Repository\UserRepository;
use App\Modules\Auth\RepositoryInterface\UserRepositoryInterface;
use App\Modules\Auth\ServiceInterfaces\AuthServiceInterface;
use App\Modules\Auth\Services\AuthService;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFAnalyzerServiceInterface;
use App\Modules\Finance\ServiceInterfaces\KaspiPDFServiceInterface;
use App\Modules\Finance\Services\KaspiPDFAnalyzerService;
use App\Modules\Finance\Services\KaspiPDFService;
use App\Modules\Health\ServiceInterfaces\WaterServiceInterface;
use App\Modules\Health\Services\WaterService;
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

        // Repositories
        $this->app->bind(UserRepositoryInterface::class, UserRepository::class);

        // Query
        $this->app->bind(UserQueryInterface::class, UserQuery::class);
    }
}
