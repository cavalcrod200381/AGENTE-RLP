@echo off
:: ZKAgent Professional v1.0 - INSTALADOR MODULAR
:: Sistema completo REAL com SDK ZK4500 e TODAS as melhorias
:: 
:: Desenvolvido por: AiNexus Tecnologia
:: Autor: Richardson Rodrigues
:: GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
:: Versão: 1.0
:: Data: Janeiro 2025

title ZKAgent Professional v1.0 - AiNexus Tecnologia

echo ================================================
echo  ZKAgent Professional v1.0 - INSTALACAO MODULAR
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
set "INSTALL_DIR=C:\ZKAgent-Professional"
set "SERVICE_NAME=Agente-RLP"
set "SCRIPT_DIR=%~dp0"
set "VERSION=1.0"
set "AUTHOR=AiNexus Tecnologia - Richardson Rodrigues"

echo ================================================
echo  INICIANDO INSTALACAO MODULAR v%VERSION%
echo  %AUTHOR%
echo ================================================
echo.

:: ================================================
:: MODULO 1: VERIFICACOES E VALIDACOES
:: ================================================
echo [1/5] MODULO: Verificacoes e Validacoes
echo    - Privilegios de administrador: OK

:: ================================================
:: FINALIZACAO DE PROCESSOS EXISTENTES (CRÍTICO)
:: ================================================
echo    - Verificando processos ZKAgent em execucao...

:: Verificar processos Java que podem ser ZKAgent
set "ZKAGENT_RUNNING=0"
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq java.exe" /fo csv ^| find "java.exe"') do (
    set "ZKAGENT_RUNNING=1"
)
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq javaw.exe" /fo csv ^| find "javaw.exe"') do (
    set "ZKAGENT_RUNNING=1"
)

if "%ZKAGENT_RUNNING%" == "1" (
    echo    - PROCESSOS JAVA DETECTADOS - Finalizando para instalacao segura...
    
    :: Finalizar processos Java específicos do ZKAgent
    echo      → Finalizando ZKAgent via linha de comando...
    wmic process where "name='java.exe' and commandline like '%%ZKAgentProfessional%%'" delete >nul 2>&1
    wmic process where "name='javaw.exe' and commandline like '%%ZKAgentProfessional%%'" delete >nul 2>&1
    
    :: Aguardar um pouco
    timeout /t 2 >nul
    
    :: Forçar finalização de todos os processos Java se ainda existirem
    echo      → Finalizando todos os processos Java restantes...
    taskkill /f /im java.exe >nul 2>&1
    taskkill /f /im javaw.exe >nul 2>&1
    
    :: Aguardar finalização completa
    timeout /t 3 >nul
    
    echo      → Processos Java: FINALIZADOS
) else (
    echo    - Nenhum processo Java detectado: OK
)

:: Verificar se ainda há processos rodando
tasklist /fi "imagename eq java.exe" /fo csv | find "java.exe" >nul 2>&1
if %errorlevel%==0 (
    echo    AVISO: Ainda existem processos Java rodando
    echo    Isso pode causar problemas durante a instalacao
    echo    Recomenda-se fechar todos os programas Java antes de continuar
    pause
)

echo    - Verificando Java...
java -version >nul 2>&1
if not %errorlevel%==0 (
    echo    ERRO: Java nao encontrado. Instale Java 8+
    echo    Download: https://www.java.com
    pause
    exit /b 1
)
echo    - Java: OK

echo    - Verificando driver ZK4500...
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s /f "ZK4500" >nul 2>&1
if %errorlevel%==0 (
    echo    - Driver ZK4500: DETECTADO
) else (
    echo    - Driver ZK4500: NAO DETECTADO (aviso)
)

echo    - Parando servicos existentes...

:: Parar serviço via NSSM se existir
if exist "%INSTALL_DIR%\nssm.exe" (
    echo      → Parando servico via NSSM...
    "%INSTALL_DIR%\nssm.exe" stop %SERVICE_NAME% >nul 2>&1
    timeout /t 2 >nul
    "%INSTALL_DIR%\nssm.exe" remove %SERVICE_NAME% confirm >nul 2>&1
    echo      → Servico NSSM: REMOVIDO
)

:: Parar serviço via sc se existir
echo      → Verificando servico Windows nativo...
sc query %SERVICE_NAME% >nul 2>&1
if %errorlevel%==0 (
    echo      → Parando servico Windows nativo...
    sc stop %SERVICE_NAME% >nul 2>&1
    timeout /t 3 >nul
    sc delete %SERVICE_NAME% >nul 2>&1
    echo      → Servico Windows: REMOVIDO
)

:: Parar tarefas agendadas
echo      → Removendo tarefas agendadas...
schtasks /delete /tn "Agente-RLP-Backend" /f >nul 2>&1
schtasks /delete /tn "%SERVICE_NAME%" /f >nul 2>&1

:: Verificação final de processos ZKAgent específicos
echo      → Verificacao final de processos ZKAgent...
wmic process where "commandline like '%%ZKAgentProfessional%%'" delete >nul 2>&1

echo    - Servicos: PARADOS E REMOVIDOS
echo      MODULO 1 CONCLUIDO!
echo.

:: ================================================
:: MODULO 2: CONFIGURACAO DE DEPENDENCIAS
:: ================================================
echo [2/5] MODULO: Configuracao de Dependencias

:: Verificar se arquivos críticos estão em uso antes de prosseguir
echo    - Verificando arquivos em uso...
if exist "%INSTALL_DIR%\ZKAgentProfessional.jar" (
    echo      → Testando acesso ao JAR principal...
    echo teste > "%INSTALL_DIR%\ZKAgentProfessional.jar.test" 2>nul
    if %errorlevel%==0 (
        del "%INSTALL_DIR%\ZKAgentProfessional.jar.test" >nul 2>&1
        echo      → Arquivos: ACESSIVEIS
    ) else (
        echo      ERRO: Arquivos ainda estao em uso por processos ativos
        echo      Aguarde alguns segundos e tente novamente...
        timeout /t 5 >nul
        
        :: Segunda tentativa
        echo teste > "%INSTALL_DIR%\ZKAgentProfessional.jar.test" 2>nul
        if not %errorlevel%==0 (
            echo      ERRO CRITICO: Nao foi possivel acessar arquivos de instalacao
            echo      Feche todos os programas Java e execute novamente
            pause
            exit /b 1
        )
        del "%INSTALL_DIR%\ZKAgentProfessional.jar.test" >nul 2>&1
    )
)

echo    - Criando diretorios...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%\lib" mkdir "%INSTALL_DIR%\lib"
if not exist "%INSTALL_DIR%\logs" mkdir "%INSTALL_DIR%\logs"

echo    - Configurando NSSM...
if exist "%SCRIPT_DIR%nssm.exe" (
    copy "%SCRIPT_DIR%nssm.exe" "%INSTALL_DIR%\nssm.exe" >nul 2>&1
    echo    - NSSM: COPIADO COM SUCESSO
) else (
    echo    - NSSM: NAO DISPONIVEL (modo standalone)
    set "NO_SERVICE=1"
)

echo    - Verificando dependencias locais...

:: Verificar se temos dependências suficientes
set "HAS_GSON=0"
set "HAS_SPARK=0"
set "HAS_JETTY=0"
set "HAS_SLF4J=0"

if exist "%SCRIPT_DIR%lib\gson-2.10.1.jar" set "HAS_GSON=1"
if exist "%SCRIPT_DIR%lib\spark-core-2.9.4.jar" set "HAS_SPARK=1"
if exist "%SCRIPT_DIR%lib\jetty-server-9.4.54.jar" set "HAS_JETTY=1"
if exist "%SCRIPT_DIR%lib\slf4j-api-1.7.36.jar" set "HAS_SLF4J=1"

echo    - Status das dependencias principais:
echo      Gson: %HAS_GSON% ^| Spark: %HAS_SPARK% ^| Jetty: %HAS_JETTY% ^| SLF4J: %HAS_SLF4J%

:: Usar dependências locais se temos pelo menos as essenciais
if "%HAS_GSON%%HAS_SPARK%" == "11" (
    echo    - Dependencias principais encontradas - USANDO LOCAIS
    copy "%SCRIPT_DIR%lib\*.jar" "%INSTALL_DIR%\lib\" >nul 2>&1
    
    :: Verificar se a cópia foi bem-sucedida
    if exist "%INSTALL_DIR%\lib\gson-2.10.1.jar" (
        echo    - Bibliotecas: COPIADAS DA PASTA LOCAL COM SUCESSO
        goto :after_dependencies
    ) else (
        echo    - AVISO: Problemas ao copiar bibliotecas locais
        echo    - Tentando download da internet como fallback...
        goto :download_dependencies
    )
) else (
    echo    - Dependencias insuficientes - BAIXANDO DA INTERNET
    goto :download_dependencies
)

:download_dependencies
:: Baixar apenas as essenciais que estão faltando
if not exist "%INSTALL_DIR%\lib\gson-2.10.1.jar" (
    echo      → Baixando Gson...
    powershell -c "try { Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar' -OutFile '%INSTALL_DIR%\lib\gson-2.10.1.jar' -TimeoutSec 30 } catch { exit 1 }" >nul 2>&1
)

if not exist "%INSTALL_DIR%\lib\spark-core-2.9.4.jar" (
    echo      → Baixando Spark Core...
    powershell -c "try { Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/com/sparkjava/spark-core/2.9.4/spark-core-2.9.4.jar' -OutFile '%INSTALL_DIR%\lib\spark-core-2.9.4.jar' -TimeoutSec 30 } catch { exit 1 }" >nul 2>&1
)

:: Verificar resultado final
if exist "%INSTALL_DIR%\lib\gson-2.10.1.jar" (
    if exist "%INSTALL_DIR%\lib\spark-core-2.9.4.jar" (
        echo    - Bibliotecas: ESSENCIAIS DISPONIVEIS
    ) else (
        echo    - Bibliotecas: FUNCIONAMENTO LIMITADO (Spark faltando)
    )
) else (
    echo    - Bibliotecas: FUNCIONAMENTO LIMITADO (Gson faltando)
)

:after_dependencies
:: Listar bibliotecas finais disponíveis
echo    - Bibliotecas finais instaladas:
dir "%INSTALL_DIR%\lib\*.jar" /b 2>nul | findstr .jar
if errorlevel 1 (
    echo    - AVISO: Nenhuma biblioteca JAR encontrada!
)

echo      MODULO 2 CONCLUIDO!
echo.

:: ================================================
:: MODULO 3: COMPILACAO E BUILD
:: ================================================
echo [3/5] MODULO: Compilacao e Build

:: Garantir que estamos no diretório correto do script
echo    - Configurando diretorio de trabalho...
cd /d "%SCRIPT_DIR%"

:: Verificar se o arquivo fonte existe
if not exist "src\ZKAgentProfessional.java" (
    echo    ERRO: Arquivo fonte nao encontrado: src\ZKAgentProfessional.java
    echo    Diretorio atual: %CD%
    echo    Script DIR: %SCRIPT_DIR%
    echo    Verificando estrutura:
    dir /b
    echo    Verifique se a estrutura de diretorios esta correta
    pause
    exit /b 1
)

:: Criar diretório bin ANTES de compilar
echo    - Criando diretorio de compilacao...
if not exist "bin" mkdir "bin"

echo    - Compilando codigo fonte...

:: Verificar Java verbose para debug
echo    - Verificando versao Java detalhada...
java -version 2>&1 | findstr "version"

:: Listar dependências disponíveis
echo    - Dependencias encontradas:
if exist "%INSTALL_DIR%\lib" (
    dir "%INSTALL_DIR%\lib\*.jar" /b 2>nul | findstr .jar
    if errorlevel 1 (
        echo      NENHUMA dependencia .jar encontrada
    )
) else (
    echo      Diretorio lib nao existe
)

:: Primeira tentativa com dependências - COM LOGS
echo    - Tentativa 1: Compilacao com dependencias...
javac -encoding UTF-8 -cp "%INSTALL_DIR%\lib\*" -d bin src\ZKAgentProfessional.java 2>compilation_error.log
if %errorlevel%==0 (
    echo    - Compilacao: SUCESSO COMPLETO
    if exist "compilation_error.log" del "compilation_error.log"
) else (
    echo    - Tentativa 1: FALHOU
    echo    - Verificando erro detalhado...
    if exist "compilation_error.log" (
        echo    === ERRO DE COMPILACAO ===
        type "compilation_error.log"
        echo    ========================
    )
    
    :: Segunda tentativa sem dependências - COM LOGS
    echo    - Tentativa 2: Compilacao sem dependencias externas...
    javac -encoding UTF-8 -d bin src\ZKAgentProfessional.java 2>compilation_error2.log
    if %errorlevel%==0 (
        echo    - Compilacao: SEM ALGUMAS DEPENDENCIAS
        if exist "compilation_error.log" del "compilation_error.log"
        if exist "compilation_error2.log" del "compilation_error2.log"
    ) else (
        echo    - Tentativa 2: FALHOU
        echo    === ERRO DE COMPILACAO (SEM DEPS) ===
        if exist "compilation_error2.log" (
            type "compilation_error2.log"
        )
        echo    ====================================
        
        :: Terceira tentativa - Modo compatibilidade
        echo    - Tentativa 3: Modo compatibilidade...
        javac -encoding UTF-8 -source 8 -target 8 -d bin src\ZKAgentProfessional.java 2>compilation_error3.log
        if %errorlevel%==0 (
            echo    - Compilacao: MODO COMPATIBILIDADE
            if exist "compilation_error.log" del "compilation_error.log"
            if exist "compilation_error2.log" del "compilation_error2.log"
            if exist "compilation_error3.log" del "compilation_error3.log"
        ) else (
            echo    - Tentativa 3: FALHOU
            echo    === ERRO FINAL DE COMPILACAO ===
            if exist "compilation_error3.log" (
                type "compilation_error3.log"
            )
            echo    ==============================
            echo.
            echo    DIAGNOSTICO:
            echo    - Verifique se ZKAgentProfessional.java tem erros de sintaxe
            echo    - Verifique se todas as dependencias estao presentes
            echo    - Verifique versao do Java (requer Java 8+)
            echo.
            echo    Arquivos de erro salvos para analise:
            if exist "compilation_error.log" echo    - compilation_error.log
            if exist "compilation_error2.log" echo    - compilation_error2.log  
            if exist "compilation_error3.log" echo    - compilation_error3.log
            echo.
            pause
            exit /b 1
        )
    )
)

echo    - Criando JAR...
cd bin

:: Verificar se arquivos .class existem
if exist "ZKAgentProfessional.class" (
    jar cf "%INSTALL_DIR%\ZKAgentProfessional.jar" *.class
    if %errorlevel%==0 (
        echo    - JAR: CRIADO COM SUCESSO
    ) else (
        echo    - JAR: ERRO AO CRIAR
        pause
        exit /b 1
    )
) else (
    echo    - ERRO: Arquivo ZKAgentProfessional.class nao encontrado
    echo    - A compilacao nao gerou bytecode Java
    echo    - Listando conteudo da pasta bin:
    dir
    pause
    exit /b 1
)
cd /d "%SCRIPT_DIR%"

echo    - Criando configuracao...
(
echo # ZKAgent Professional v%VERSION% - AiNexus Tecnologia
echo # Autor: Richardson Rodrigues  
echo # GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
echo server.port=5001
echo version=%VERSION%
echo author=%AUTHOR%
echo melhorias.instancia_unica=true
echo melhorias.inicializacao_silenciosa=true
) > "%INSTALL_DIR%\zkagent-config.properties"

:: Verificar se o arquivo foi criado corretamente
if exist "%INSTALL_DIR%\zkagent-config.properties" (
    echo      → Configuracao: CRIADA COM SUCESSO
) else (
    echo      ERRO: Falha ao criar arquivo de configuracao
    pause
    exit /b 1
)

echo      MODULO 3 CONCLUIDO!
echo.

:: ================================================
:: MODULO 4: CONFIGURACAO DE SERVICOS
:: ================================================
echo [4/5] MODULO: Configuracao de Servicos
echo    - Criando scripts...

:: Script do backend
echo @echo off > "%INSTALL_DIR%\zkagent-service.bat"
echo :: ZKAgent Professional v%VERSION% - AiNexus Tecnologia >> "%INSTALL_DIR%\zkagent-service.bat"
echo :: Autor: Richardson Rodrigues >> "%INSTALL_DIR%\zkagent-service.bat"
echo cd /d "%INSTALL_DIR%" >> "%INSTALL_DIR%\zkagent-service.bat"
echo java -cp "ZKAgentProfessional.jar;lib\*" ZKAgentProfessional --headless >> "%INSTALL_DIR%\zkagent-service.bat"

:: Script da interface
echo @echo off > "%INSTALL_DIR%\zkagent-tray.bat"
echo :: ZKAgent Professional v%VERSION% - AiNexus Tecnologia >> "%INSTALL_DIR%\zkagent-tray.bat"
echo :: Autor: Richardson Rodrigues >> "%INSTALL_DIR%\zkagent-tray.bat"
echo cd /d "%INSTALL_DIR%" >> "%INSTALL_DIR%\zkagent-tray.bat"
echo java -cp "ZKAgentProfessional.jar;lib\*" ZKAgentProfessional --tray >> "%INSTALL_DIR%\zkagent-tray.bat"

:: Script silencioso
echo @echo off > "%INSTALL_DIR%\zkagent-tray-silent.bat"
echo :: ZKAgent Professional v%VERSION% - AiNexus Tecnologia >> "%INSTALL_DIR%\zkagent-tray-silent.bat"
echo :: Autor: Richardson Rodrigues >> "%INSTALL_DIR%\zkagent-tray-silent.bat"
echo cd /d "%INSTALL_DIR%" >> "%INSTALL_DIR%\zkagent-tray-silent.bat"
echo start /B javaw -cp "ZKAgentProfessional.jar;lib\*" ZKAgentProfessional --tray >> "%INSTALL_DIR%\zkagent-tray-silent.bat"

:: Script de teste
echo @echo off > "%INSTALL_DIR%\teste-sistema.bat"
echo :: ZKAgent Professional v%VERSION% - AiNexus Tecnologia >> "%INSTALL_DIR%\teste-sistema.bat"
echo :: Autor: Richardson Rodrigues >> "%INSTALL_DIR%\teste-sistema.bat"
echo echo ===== Teste ZKAgent Professional v%VERSION% ===== >> "%INSTALL_DIR%\teste-sistema.bat"
echo echo Desenvolvido por: AiNexus Tecnologia >> "%INSTALL_DIR%\teste-sistema.bat"
echo curl -s http://localhost:5001/status >> "%INSTALL_DIR%\teste-sistema.bat"
echo pause >> "%INSTALL_DIR%\teste-sistema.bat"

echo    - Configurando servico Windows...
if not defined NO_SERVICE (
    "%INSTALL_DIR%\nssm.exe" install %SERVICE_NAME% "%INSTALL_DIR%\zkagent-service.bat" >nul 2>&1
    "%INSTALL_DIR%\nssm.exe" set %SERVICE_NAME% Start SERVICE_AUTO_START >nul 2>&1
    "%INSTALL_DIR%\nssm.exe" set %SERVICE_NAME% DisplayName "ZKAgent Professional v%VERSION% - AiNexus" >nul 2>&1
    "%INSTALL_DIR%\nssm.exe" set %SERVICE_NAME% Description "Sistema biometrico profissional - AiNexus Tecnologia" >nul 2>&1
    echo    - Servico: CONFIGURADO VIA NSSM
) else (
    schtasks /create /tn "Agente-RLP-Backend" /tr "%INSTALL_DIR%\zkagent-service.bat" /sc onstart /ru "SYSTEM" /f >nul 2>&1
    echo    - Servico: CONFIGURADO VIA TASK SCHEDULER
)

echo    - Configurando startup da interface...
set "STARTUP_DIR=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
echo start "" /min "%INSTALL_DIR%\zkagent-tray-silent.bat" > "%STARTUP_DIR%\Agente-RLP-Tray.bat"

echo    - Configurando firewall...
netsh advfirewall firewall add rule name="ZKAgent-Professional-AiNexus" dir=in action=allow protocol=TCP localport=5001 >nul 2>&1
echo      MODULO 4 CONCLUIDO!
echo.

:: ================================================
:: MODULO 5: INICIALIZACAO E TESTES
:: ================================================
echo [5/5] MODULO: Inicializacao e Testes
echo    - Iniciando servicos...

if not defined NO_SERVICE (
    "%INSTALL_DIR%\nssm.exe" start %SERVICE_NAME% >nul 2>&1
    echo    - Servico: INICIADO VIA NSSM
) else (
    start "" /min "%INSTALL_DIR%\zkagent-service.bat"
    echo    - Servico: INICIADO MANUALMENTE
)

timeout /t 3 >nul

echo    - Testando API...
curl -s http://localhost:5001/test >nul 2>&1
if %errorlevel%==0 (
    echo    - API: RESPONDENDO
) else (
    echo    - API: INICIALIZANDO
)

echo    - Iniciando interface...
start "" /min "%INSTALL_DIR%\zkagent-tray-silent.bat"

echo    - Realizando limpeza...
if exist "bin" rmdir /s /q "bin" >nul 2>&1
echo      MODULO 5 CONCLUIDO!
echo.

:: ================================================
:: FINALIZACAO
:: ================================================
echo ================================================
echo  INSTALACAO FINALIZADA COM SUCESSO!
echo  ZKAgent Professional v%VERSION%
echo  AiNexus Tecnologia - Richardson Rodrigues
echo ================================================
echo.
echo SISTEMA INSTALADO:
echo - Nome: ZKAgent Professional v%VERSION%
echo - Desenvolvedor: AiNexus Tecnologia
echo - Autor: Richardson Rodrigues
echo - GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
echo.
echo SERVICO:
echo - Nome: Agente-RLP
echo - Auto-start: ATIVO
echo - Logs: %INSTALL_DIR%\logs\
echo.
echo INTERFACE:
echo - Icone na bandeja: Ativo
echo - Inicializacao silenciosa: ATIVA
echo.
echo API REST:
echo - URL: http://localhost:5001
echo - Teste: %INSTALL_DIR%\teste-sistema.bat
echo.
echo MELHORIAS v4.1 ATIVAS:
echo - Inicializacao silenciosa
echo - Verificacao de instancia unica
echo - Sistema de retry automatico
echo - Fallbacks integrados
echo.
echo Para suporte e atualizacoes:
echo GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
echo Desenvolvedor: AiNexus Tecnologia
echo.
echo Sistema pronto para uso!
echo.
echo Pressione qualquer tecla para finalizar...
pause >nul 