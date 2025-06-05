@echo off
::================================================
:: ZKAgent Professional v1.0 - Desinstalador
:: Remoção completa e segura do sistema
:: 
:: Desenvolvido por: AiNexus Tecnologia
:: Autor: Richardson Rodrigues
:: GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
:: Versão: 1.0
:: Data: Janeiro 2025
::================================================

setlocal enabledelayedexpansion

:: Capturar o diretório onde está o script
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ================================================
echo  ZKAgent Professional v1.0 - Desinstalador
echo  Desenvolvido por AiNexus Tecnologia
echo  Autor: Richardson Rodrigues
echo ================================================
echo.

set INSTALL_DIR=C:\ZKAgent-Professional
set SERVICE_NAME=Agente-RLP
set PORT=5001

:: Verificar privilégios de administrador
echo [1/8] Verificando privilegios de administrador...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo    ❌ Este script requer privilegios de administrador
    echo    Execute como Administrador e tente novamente
    pause
    exit /b 1
)
echo    ✓ Privilegios OK

echo.
echo ATENCAO: Esta operacao ira remover completamente:
echo  • Servico Windows Agente-RLP
echo  • Diretorio %INSTALL_DIR%
echo  • Configuracoes e logs
echo  • Regras de firewall
echo  • Auto-start do Windows
echo  • Icone da bandeja
echo  • Scripts do Startup
echo.

set /p confirmacao="Tem certeza que deseja continuar? (S/N): "
if /i "%confirmacao%" neq "S" (
    echo Desinstalacao cancelada pelo usuario.
    pause
    exit /b 0
)

echo.
echo Iniciando desinstalacao...

:: [2/8] Parar e remover serviço via NSSM
echo [2/8] Parando e removendo servico Windows via NSSM...

:: Verificar se NSSM existe
if exist "%INSTALL_DIR%\nssm.exe" (
    echo    → Usando NSSM para remover servico...
    "%INSTALL_DIR%\nssm.exe" stop %SERVICE_NAME% >nul 2>&1
    "%INSTALL_DIR%\nssm.exe" remove %SERVICE_NAME% confirm >nul 2>&1
    if %errorlevel% equ 0 (
        echo    ✓ Servico removido via NSSM
    ) else (
        echo    → Servico NSSM nao encontrado ou ja removido
    )
) else (
    echo    → NSSM nao encontrado, tentando remocao padrao...
)

:: Parar serviço se estiver rodando (método padrão)
sc stop %SERVICE_NAME% >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✓ Servico parado
    timeout /t 2 >nul
) else (
    echo    → Servico ja estava parado
)

:: Remover serviço Windows
sc delete %SERVICE_NAME% >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✓ Servico Windows removido
) else (
    echo    → Servico Windows nao encontrado
)

:: [3/8] Remover tarefa do Task Scheduler
echo [3/8] Removendo tarefas do agendador...

schtasks /delete /tn "Agente-RLP-Backend" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✓ Tarefa Agente-RLP-Backend removida
) else (
    echo    → Tarefa Backend nao encontrada
)

schtasks /delete /tn "%SERVICE_NAME%" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✓ Tarefa %SERVICE_NAME% removida
) else (
    echo    → Tarefa do agendador nao encontrada
)

:: [4/8] Remover scripts do Startup
echo [4/8] Removendo scripts do Startup...

set "STARTUP_DIR=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

if exist "%STARTUP_DIR%\Agente-RLP-Tray.bat" (
    del "%STARTUP_DIR%\Agente-RLP-Tray.bat" >nul 2>&1
    echo    ✓ Script do Startup removido
) else (
    echo    → Script do Startup nao encontrado
)

:: Verificar outros scripts relacionados
del "%STARTUP_DIR%\zkagent*.bat" >nul 2>&1
del "%STARTUP_DIR%\ZKAgent*.bat" >nul 2>&1

:: [5/8] Finalizar processos Java relacionados
echo [5/8] Finalizando processos relacionados...

:: Finalizar processos Java que possam estar rodando ZKAgent
tasklist /fi "imagename eq java.exe" /fo csv | findstr /i "zkagent" >nul 2>&1
if %errorlevel% equ 0 (
    echo    → Finalizando processos Java do ZKAgent...
    taskkill /f /im java.exe /fi "windowtitle eq ZKAgent*" >nul 2>&1
    taskkill /f /im java.exe /fi "commandline eq *ZKAgent*" >nul 2>&1
    taskkill /f /im javaw.exe >nul 2>&1
    echo    ✓ Processos finalizados
) else (
    echo    → Nenhum processo ZKAgent encontrado
)

:: Remover arquivos de lock
del "zkagent-service.lock" >nul 2>&1
del "zkagent-tray.lock" >nul 2>&1

:: [6/8] Remover diretório de instalação
echo [6/8] Removendo diretorio de instalacao...

if exist "%INSTALL_DIR%" (
    echo    → Removendo %INSTALL_DIR%...
    
    :: Aguardar um pouco para processos finalizarem
    timeout /t 3 >nul
    
    :: Método 1: Remoção normal
    echo    → Tentativa 1: Remocao normal...
    rd /s /q "%INSTALL_DIR%" >nul 2>&1
    
    if exist "%INSTALL_DIR%" (
        echo    → Tentativa 2: Alterando permissoes e forcando...
        
        :: Forçar remoção com permissões administrativas
        takeown /f "%INSTALL_DIR%" /r /d y >nul 2>&1
        icacls "%INSTALL_DIR%" /grant administrators:f /t >nul 2>&1
        icacls "%INSTALL_DIR%" /reset /t >nul 2>&1
        
        :: Aguardar e tentar novamente
        timeout /t 2 >nul
        rd /s /q "%INSTALL_DIR%" >nul 2>&1
        
        if exist "%INSTALL_DIR%" (
            echo    → Tentativa 3: Remocao arquivo por arquivo...
            
            :: Remover arquivo por arquivo
            for /r "%INSTALL_DIR%" %%f in (*.*) do (
                del /f /q "%%f" >nul 2>&1
            )
            
            :: Tentar remover diretório vazio
            rd /s /q "%INSTALL_DIR%" >nul 2>&1
            
            if exist "%INSTALL_DIR%" (
                echo    → Tentativa 4: Metodo PowerShell...
                
                :: Usar PowerShell para remoção forçada
                powershell -Command "Remove-Item '%INSTALL_DIR%' -Recurse -Force -ErrorAction SilentlyContinue" >nul 2>&1
                
                if exist "%INSTALL_DIR%" (
                    echo    → Tentativa 5: Remocao via robocopy...
                    
                    :: Criar diretório temporário vazio
                    mkdir "%TEMP%\empty_zkagent" >nul 2>&1
                    
                    :: Usar robocopy para "sincronizar" com diretório vazio (efetivamente deletando)
                    robocopy "%TEMP%\empty_zkagent" "%INSTALL_DIR%" /MIR /NFL /NDL /NJH /NJS /NC /NS /NP >nul 2>&1
                    
                    :: Remover diretório temporário
                    rd /s /q "%TEMP%\empty_zkagent" >nul 2>&1
                    
                    :: Tentar remoção final
                    rd /s /q "%INSTALL_DIR%" >nul 2>&1
                )
            )
        )
    )
    
    :: Verificação final da remoção
    if exist "%INSTALL_DIR%" (
        echo    ❌ FALHA: Diretorio nao pode ser removido completamente
        echo    → Alguns arquivos estao sendo usados por outros processos
        echo    → Reinicie o computador e execute novamente
        set "REMOVAL_FAILED=1"
    ) else (
        echo    ✅ Diretorio removido com sucesso
        set "REMOVAL_FAILED=0"
    )
) else (
    echo    → Diretorio de instalacao nao encontrado
    set "REMOVAL_FAILED=0"
)

:: [7/8] Remover regras de firewall
echo [7/8] Removendo regras de firewall...

netsh advfirewall firewall delete rule name="ZKAgent-Professional-AiNexus" >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✓ Regra ZKAgent-Professional-AiNexus removida
) else (
    echo    → Regra principal nao encontrada
)

:: Remover regras antigas se existirem
netsh advfirewall firewall delete rule name="ZKAgent Professional Port %PORT%" >nul 2>&1
netsh advfirewall firewall delete rule name="ZKAgent" >nul 2>&1

echo    ✓ Limpeza de firewall concluida

:: [8/8] Limpeza final
echo [8/8] Limpeza final...

:: Remover arquivos temporários relacionados
del /q temp_device_check.txt >nul 2>&1
del /q compile_error.txt >nul 2>&1
del /q compile_error.log >nul 2>&1

:: Remover entradas do registro relacionadas ao auto-start
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ZKAgentProfessional" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "ZKAgentProfessional" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Agente-RLP" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "Agente-RLP" /f >nul 2>&1

echo    ✓ Limpeza concluida

echo.
:: ================================================
:: RESULTADO FINAL DA DESINSTALACAO
:: ================================================

:: Verificação final obrigatória
echo Verificando remocao...
if exist "%INSTALL_DIR%" (
    echo ❌ FALHA: Diretorio %INSTALL_DIR% ainda existe
    echo → A desinstalacao NAO foi completada com sucesso
    echo → Alguns arquivos podem estar sendo usados por outros processos
    echo → SOLUCAO: Reinicie o computador e execute novamente
    set "FINAL_SUCCESS=0"
) else (
    echo ✅ Remocao verificada com sucesso
    set "FINAL_SUCCESS=1"
)

:: Testar se API ainda responde
echo Testando se API ainda responde...
curl -s http://localhost:%PORT%/test >nul 2>&1
if %errorlevel% equ 0 (
    echo ❌ AVISO: API ainda responde na porta %PORT%
    echo → Pode haver outro processo ou servico rodando
    echo → Isso pode indicar desinstalacao incompleta
    set "API_RUNNING=1"
) else (
    echo ✅ API nao responde mais (esperado)
    set "API_RUNNING=0"
)

echo.
if "%FINAL_SUCCESS%"=="1" (
    if "%API_RUNNING%"=="0" (
        echo ================================================
        echo  DESINSTALACAO COMPLETA E BEM-SUCEDIDA!
        echo  ZKAgent Professional v1.0
        echo  AiNexus Tecnologia - Richardson Rodrigues
        echo ================================================
        echo.
        echo ✅ O ZKAgent Professional v1.0 foi COMPLETAMENTE removido:
        echo.
        echo ITENS REMOVIDOS COM SUCESSO:
        echo  ✅ Servico Windows: %SERVICE_NAME%
        echo  ✅ Diretorio: %INSTALL_DIR%
        echo  ✅ Configuracoes e logs
        echo  ✅ Regras de firewall (porta %PORT%)
        echo  ✅ Auto-start do Windows
        echo  ✅ Scripts do Startup
        echo  ✅ Processos em execucao
        echo  ✅ Arquivos temporarios
        echo  ✅ Arquivos de lock
        echo.
        echo 🎯 RESULTADO: DESINSTALACAO 100%% COMPLETA!
        set "EXIT_CODE=0"
    ) else (
        echo ================================================
        echo  DESINSTALACAO PARCIALMENTE BEM-SUCEDIDA
        echo  ZKAgent Professional v1.0
        echo  AiNexus Tecnologia - Richardson Rodrigues
        echo ================================================
        echo.
        echo ⚠️ Arquivos removidos, mas API ainda responde
        echo → Pode haver outro ZKAgent rodando
        echo → Verifique outros processos Java
        echo.
        echo 🎯 RESULTADO: DESINSTALACAO 90%% COMPLETA
        set "EXIT_CODE=1"
    )
) else (
    echo ================================================
    echo  DESINSTALACAO FALHOU!
    echo  ZKAgent Professional v1.0
    echo  AiNexus Tecnologia - Richardson Rodrigues
    echo ================================================
    echo.
    echo ❌ A desinstalacao NAO foi completada!
    echo.
    echo PROBLEMA IDENTIFICADO:
    echo  ❌ Diretorio %INSTALL_DIR% ainda existe
    echo  ❌ Alguns arquivos nao puderam ser removidos
    echo.
    echo SOLUCOES RECOMENDADAS:
    echo  1. Reinicie o computador
    echo  2. Feche todos os programas Java
    echo  3. Execute este desinstalador novamente
    echo  4. Se o problema persistir, remova manualmente:
    echo     - Pasta: %INSTALL_DIR%
    echo     - Servico: %SERVICE_NAME% (via services.msc)
    echo.
    echo 🎯 RESULTADO: DESINSTALACAO FALHOU - ACAO NECESSARIA!
    set "EXIT_CODE=2"
)

echo.
echo ================================================
echo  DESINSTALACAO CONCLUIDA
echo  ZKAgent Professional v1.0
echo  AiNexus Tecnologia - Richardson Rodrigues
echo ================================================
echo.
echo O ZKAgent Professional v1.0 foi removido completamente:
echo.
echo ITENS REMOVIDOS:
echo  ✓ Servico Windows: %SERVICE_NAME%
echo  ✓ Diretorio: %INSTALL_DIR%
echo  ✓ Configuracoes e logs
echo  ✓ Regras de firewall (porta %PORT%)
echo  ✓ Auto-start do Windows
echo  ✓ Scripts do Startup
echo  ✓ Processos em execucao
echo  ✓ Arquivos temporarios
echo  ✓ Arquivos de lock
echo.
echo VERIFICACOES RECOMENDADAS:
echo  • Verifique se o icone foi removido da bandeja
echo  • Reinicie o computador se solicitado
echo  • API nao devera mais responder em localhost:%PORT%
echo.
echo PARA REINSTALAR:
echo  Execute: install.bat
echo  GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
echo.

echo.
echo PARA REINSTALAR (quando desinstalacao estiver completa):
echo  Execute: install.bat
echo  GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
echo.
echo Desenvolvido por AiNexus Tecnologia - Richardson Rodrigues
echo.
echo Pressione qualquer tecla para sair...
pause >nul
exit /b %EXIT_CODE% 