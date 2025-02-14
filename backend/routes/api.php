<?php

foreach (glob(__DIR__ . '/api/*.php') as $routeFile) {
    require $routeFile;
}
