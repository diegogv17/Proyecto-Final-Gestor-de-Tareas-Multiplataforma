@echo off
setlocal enabledelayedexpansion

set "BASE_PATH=C:\Users\DG648\OneDrive\Escritorio\Repositorio\Nueva carpeta\flutter_application_1\lib"

cd /d "%BASE_PATH%"

mkdir utils
mkdir config
mkdir models
mkdir services
mkdir providers
mkdir widgets
mkdir screens\auth
mkdir screens\tasks
mkdir screens\categories

echo Directories created successfully!
pause
