@echo off
:: ══════════════════════════════════════════════════════════════════════
::  Syntax Ware — Script de publicación de actualizaciones
::  Uso: publish_update.bat <nueva_version>
::  Ejemplo: publish_update.bat 1.1
::
::  Este script:
::  1. Copia el nuevo SyntaxWare Loader.exe compilado al repo
::  2. Actualiza loader_version.txt con la nueva versión
::  3. Hace force-push con un solo commit (sin historial de versiones)
:: ══════════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

:: ── Configuración ──────────────────────────────────────────────────────
set "REPO_DIR=C:\Users\Anonymous\Documents\GitHub\Syntax Ware Updater"
set "BUILD_EXE=C:\Users\Anonymous\Desktop\PROYECTO FIVEM\MECCHA ACABADO\Syntax Ware\Proyecto SW\Fivem-main\cheat\bin\Release\SyntaxWare Loader.exe"
set "REPO_EXE=%REPO_DIR%\SyntaxWare.exe"
set "VERSION_FILE=%REPO_DIR%\loader_version.txt"

:: ── Verificar argumento de versión ─────────────────────────────────────
if "%~1"=="" (
    echo [ERROR] Debes indicar la nueva version.
    echo Uso: publish_update.bat 1.1
    pause
    exit /b 1
)
set "NEW_VERSION=%~1"

echo.
echo  ┌─────────────────────────────────────────┐
echo  │      SYNTAX WARE — PUBLICAR UPDATE       │
echo  └─────────────────────────────────────────┘
echo.
echo  Nueva version  : %NEW_VERSION%
echo  Exe fuente     : %BUILD_EXE%
echo  Repo destino   : %REPO_DIR%
echo.

:: ── Verificar que el exe compilado existe ──────────────────────────────
if not exist "%BUILD_EXE%" (
    echo [ERROR] No se encontro el ejecutable compilado:
    echo         %BUILD_EXE%
    echo.
    echo Compila primero el proyecto en Visual Studio ^(Release x64^).
    pause
    exit /b 1
)

:: ── Confirmar ──────────────────────────────────────────────────────────
set /p CONFIRM="Publicar v%NEW_VERSION%? (s/n): "
if /i not "%CONFIRM%"=="s" (
    echo Cancelado.
    exit /b 0
)

echo.
echo [1/4] Copiando ejecutable...
copy /y "%BUILD_EXE%" "%REPO_EXE%" >nul 2>nul
if errorlevel 1 (
    echo [ERROR] No se pudo copiar el ejecutable.
    pause
    exit /b 1
)
echo       OK — SyntaxWare.exe actualizado

echo [2/4] Actualizando loader_version.txt...
echo %NEW_VERSION%> "%VERSION_FILE%"
echo       OK — version: %NEW_VERSION%

echo [3/4] Preparando git (force-push sin historial)...
cd /d "%REPO_DIR%"

:: Eliminar historial y crear commit único (orphan)
git checkout --orphan temp_branch_update >nul 2>nul
git add -A >nul 2>nul
git commit -m "release" >nul 2>nul

:: Eliminar rama main y renombrar
git branch -D main >nul 2>nul
git branch -m main >nul 2>nul

echo [4/4] Publicando en GitHub (force-push)...
git push origin main --force >nul 2>nul
if errorlevel 1 (
    echo [ERROR] No se pudo hacer push. Comprueba tu conexion y credenciales de GitHub.
    pause
    exit /b 1
)

echo.
echo  ┌─────────────────────────────────────────┐
echo  │   ✓  v%NEW_VERSION% publicada correctamente     │
echo  │      Sin historial anterior en GitHub    │
echo  └─────────────────────────────────────────┘
echo.
echo  Los usuarios recibirán la actualización
echo  automaticamente la proxima vez que lancen
echo  el loader.
echo.
pause
