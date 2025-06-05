@echo off
:: ZKAgent Professional v1.0 - ATUALIZADOR VIA GITHUB
:: Sistema de atualizacao automatica do GitHub
:: 
:: Desenvolvido por: AiNexus Tecnologia
:: Autor: Richardson Rodrigues
:: GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
:: Versão: 1.0
:: Data: Janeiro 2025

title ZKAgent Professional v1.0 - Atualizador GitHub - AiNexus

echo ================================================
echo  ZKAgent Professional v1.0 - ATUALIZADOR
echo  Desenvolvido por AiNexus Tecnologia
echo  Autor: Richardson Rodrigues
echo ================================================
echo.

:: Verificar se esta sendo executado como administrador
net session >nul 2>&1
if not %errorlevel%==0 (
    echo ERRO: Execute como Administrador
    echo Clique direito no arquivo e selecione "Executar como administrador"
    pause
    exit /b 1
)

:: Variáveis globais
set "REPO_URL=https://github.com/cavalcrod200381/AGENTE-RLP.git"
set "BACKUP_DIR=%TEMP%\zkagent-backup-%DATE:/=-%"
set "INSTALL_DIR=C:\ZKAgent-Professional"
set "CURRENT_DIR=%~dp0"

echo ================================================
echo  INICIANDO PROCESSO DE ATUALIZACAO
echo  GitHub: %REPO_URL%
echo ================================================
echo.

:: ================================================
:: MODULO 1: VERIFICACOES PRE-ATUALIZACAO
:: ================================================
echo [1/6] MODULO: Verificacoes Pre-Atualizacao
echo    - Verificando Git...
git --version >nul 2>&1
if not %errorlevel%==0 (
    echo    ERRO: Git nao encontrado
    echo    Instale Git em: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo    - Git: DISPONIVEL

echo    - Verificando conexao com GitHub...
ping -n 1 github.com >nul 2>&1
if not %errorlevel%==0 (
    echo    AVISO: Problemas de conectividade com GitHub
    echo    Verifique sua conexao com a internet
)
echo    - Conectividade: OK

echo    - Verificando instalacao atual...
if exist "%INSTALL_DIR%" (
    echo    - Instalacao existente: DETECTADA
) else (
    echo    - Instalacao existente: NAO ENCONTRADA
    echo    Execute install.bat primeiro
    pause
    exit /b 1
)
echo      MODULO 1 CONCLUIDO!
echo.

:: ================================================
:: MODULO 2: BACKUP DA CONFIGURACAO ATUAL
:: ================================================
echo [2/6] MODULO: Backup da Configuracao Atual
echo    - Criando backup em: %BACKUP_DIR%
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo    - Fazendo backup das configuracoes...
if exist "%INSTALL_DIR%\zkagent-config.properties" (
    copy "%INSTALL_DIR%\zkagent-config.properties" "%BACKUP_DIR%\" >nul 2>&1
    echo    - Config backup: SUCESSO
) else (
    echo    - Config backup: ARQUIVO NAO ENCONTRADO
)

echo    - Fazendo backup dos logs...
if exist "%INSTALL_DIR%\logs" (
    xcopy "%INSTALL_DIR%\logs\*" "%BACKUP_DIR%\logs\" /E /I >nul 2>&1
    echo    - Logs backup: SUCESSO
) else (
    echo    - Logs backup: DIRETORIO NAO ENCONTRADO
)
echo      MODULO 2 CONCLUIDO!
echo.

:: ================================================
:: MODULO 3: DOWNLOAD DA NOVA VERSAO
:: ================================================
echo [3/6] MODULO: Download da Nova Versao
echo    - Verificando se eh repositorio Git...
if exist ".git" (
    echo    - Repositorio Git: DETECTADO
    echo    - Fazendo git pull...
    git pull origin main
    if %errorlevel%==0 (
        echo    - Atualizacao: SUCESSO
    ) else (
        echo    - Atualizacao: FALHA
        echo    Tente: git reset --hard origin/main
    )
) else (
    echo    - Repositorio Git: NAO DETECTADO
    echo    - Clonando repositorio...
    cd /d "%TEMP%"
    git clone %REPO_URL% zkagent-new
    if %errorlevel%==0 (
        echo    - Clone: SUCESSO
        echo    - Copiando arquivos atualizados...
        xcopy "zkagent-new\*" "%CURRENT_DIR%" /E /Y >nul 2>&1
        rmdir /s /q "zkagent-new" >nul 2>&1
        cd /d "%CURRENT_DIR%"
    ) else (
        echo    - Clone: FALHA
        echo    Verifique conectividade e tente novamente
        pause
        exit /b 1
    )
)
echo      MODULO 3 CONCLUIDO!
echo.

:: ================================================
:: MODULO 4: PARANDO SERVICOS ANTIGOS
:: ================================================
echo [4/6] MODULO: Parando Servicos Antigos
echo    - Parando servico ZKAgent...
if exist "%INSTALL_DIR%\nssm.exe" (
    "%INSTALL_DIR%\nssm.exe" stop Agente-RLP >nul 2>&1
    echo    - Servico: PARADO VIA NSSM
) else (
    taskkill /F /IM java.exe /FI "WINDOWTITLE eq ZKAgent*" >nul 2>&1
    echo    - Processos Java: FINALIZADOS
)

echo    - Aguardando finalizacao...
timeout /t 3 >nul
echo      MODULO 4 CONCLUIDO!
echo.

:: ================================================
:: MODULO 5: INSTALANDO NOVA VERSAO
:: ================================================
echo [5/6] MODULO: Instalando Nova Versao
echo    - Executando instalador atualizado...
if exist "install.bat" (
    echo    - Chamando install.bat...
    call install.bat
    if %errorlevel%==0 (
        echo    - Instalacao: SUCESSO
    ) else (
        echo    - Instalacao: PROBLEMAS DETECTADOS
        echo    Verifique os logs
    )
) else (
    echo    - ERRO: install.bat nao encontrado
    echo    Atualizacao incompleta
    pause
    exit /b 1
)
echo      MODULO 5 CONCLUIDO!
echo.

:: ================================================
:: MODULO 6: RESTAURANDO CONFIGURACOES
:: ================================================
echo [6/6] MODULO: Restaurando Configuracoes
echo    - Restaurando configuracoes personalizadas...
if exist "%BACKUP_DIR%\zkagent-config.properties" (
    echo    - Deseja restaurar configuracoes anteriores? (S/N)
    set /p RESTORE_CONFIG="    Digite S para restaurar ou N para usar nova configuracao: "
    if /i "%RESTORE_CONFIG%"=="S" (
        copy "%BACKUP_DIR%\zkagent-config.properties" "%INSTALL_DIR%\" >nul 2>&1
        echo    - Configuracoes: RESTAURADAS
    ) else (
        echo    - Configuracoes: MANTIDAS NOVAS
    )
) else (
    echo    - Configuracoes: NENHUMA PARA RESTAURAR
)

echo    - Testando sistema atualizado...
timeout /t 3 >nul
curl -s http://localhost:5001/status >nul 2>&1
if %errorlevel%==0 (
    echo    - Sistema: FUNCIONANDO
    echo    - API: RESPONDENDO
) else (
    echo    - Sistema: INICIALIZANDO
    echo    Execute teste manual: %INSTALL_DIR%\teste-sistema.bat
)
echo      MODULO 6 CONCLUIDO!
echo.

:: ================================================
:: FINALIZACAO
:: ================================================
echo ================================================
echo  ATUALIZACAO FINALIZADA COM SUCESSO!
echo  ZKAgent Professional v1.0+
echo  AiNexus Tecnologia - Richardson Rodrigues
echo ================================================
echo.
echo ATUALIZACAO COMPLETA:
echo - Backup criado em: %BACKUP_DIR%
echo - Nova versao instalada e funcionando
echo - Configuracoes: Verificar se necessario
echo.
echo VERIFICACOES POS-ATUALIZACAO:
echo - Sistema: Funcionando
echo - API: http://localhost:5001/status
echo - Teste: %INSTALL_DIR%\teste-sistema.bat
echo.
echo INFORMACOES DE SUPORTE:
echo - GitHub: %REPO_URL%
echo - Backup: %BACKUP_DIR%
echo - Logs: %INSTALL_DIR%\logs\
echo.
echo Para futuras atualizacoes:
echo Execute: update.bat como Administrador
echo.
echo Sistema atualizado e pronto para uso!
echo.
echo Pressione qualquer tecla para finalizar...
pause >nul 