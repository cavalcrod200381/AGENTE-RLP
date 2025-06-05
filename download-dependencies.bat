@echo off
::================================================
:: ZKAgent Professional v1.0 - Download de Dependências
:: Script para baixar todas as bibliotecas necessárias
:: 
:: Desenvolvido por: AiNexus Tecnologia
:: Autor: Richardson Rodrigues
:: GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
:: Versão: 1.0
:: Data: Janeiro 2025
::================================================

setlocal enabledelayedexpansion
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ================================================
echo  ZKAgent Professional v1.0 - Download Dependencias
echo  Desenvolvido por AiNexus Tecnologia
echo  Autor: Richardson Rodrigues
echo ================================================
echo.

:: Criar pasta lib se não existir
if not exist "lib" mkdir "lib"

echo [1/8] Baixando dependencias essenciais...
echo.

:: 1. Gson (JSON processing)
echo    → Baixando Gson 2.10.1...
powershell -c "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar' -OutFile 'lib/gson-2.10.1.jar'" >nul 2>&1
if exist "lib\gson-2.10.1.jar" (
    echo      ✅ Gson baixado com sucesso
) else (
    echo      ❌ Falha ao baixar Gson
)

:: 2. Spark Core (Web framework)
echo    → Baixando Spark Core 2.9.4...
powershell -c "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/com/sparkjava/spark-core/2.9.4/spark-core-2.9.4.jar' -OutFile 'lib/spark-core-2.9.4.jar'" >nul 2>&1
if exist "lib\spark-core-2.9.4.jar" (
    echo      ✅ Spark Core baixado com sucesso
) else (
    echo      ❌ Falha ao baixar Spark Core
)

:: 3. Jetty Server
echo    → Baixando Jetty Server 9.4.54...
powershell -c "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-server/9.4.54.v20240208/jetty-server-9.4.54.v20240208.jar' -OutFile 'lib/jetty-server-9.4.54.jar'" >nul 2>&1
if exist "lib\jetty-server-9.4.54.jar" (
    echo      ✅ Jetty Server baixado com sucesso
) else (
    echo      ❌ Falha ao baixar Jetty Server
)

:: 4. Jetty HTTP
echo    → Baixando Jetty HTTP 9.4.54...
powershell -c "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-http/9.4.54.v20240208/jetty-http-9.4.54.v20240208.jar' -OutFile 'lib/jetty-http-9.4.54.jar'" >nul 2>&1
if exist "lib\jetty-http-9.4.54.jar" (
    echo      ✅ Jetty HTTP baixado com sucesso
) else (
    echo      ❌ Falha ao baixar Jetty HTTP
)

:: 5. Jetty IO
echo    → Baixando Jetty IO 9.4.54...
powershell -c "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-io/9.4.54.v20240208/jetty-io-9.4.54.v20240208.jar' -OutFile 'lib/jetty-io-9.4.54.jar'" >nul 2>&1
if exist "lib\jetty-io-9.4.54.jar" (
    echo      ✅ Jetty IO baixado com sucesso
) else (
    echo      ❌ Falha ao baixar Jetty IO
)

:: 6. Jetty Util
echo    → Baixando Jetty Util 9.4.54...
powershell -c "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util/9.4.54.v20240208/jetty-util-9.4.54.v20240208.jar' -OutFile 'lib/jetty-util-9.4.54.jar'" >nul 2>&1
if exist "lib\jetty-util-9.4.54.jar" (
    echo      ✅ Jetty Util baixado com sucesso
) else (
    echo      ❌ Falha ao baixar Jetty Util
)

:: 7. SLF4J API
echo    → Baixando SLF4J API 1.7.36...
powershell -c "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.36/slf4j-api-1.7.36.jar' -OutFile 'lib/slf4j-api-1.7.36.jar'" >nul 2>&1
if exist "lib\slf4j-api-1.7.36.jar" (
    echo      ✅ SLF4J API baixado com sucesso
) else (
    echo      ❌ Falha ao baixar SLF4J API
)

:: 8. SLF4J Simple
echo    → Baixando SLF4J Simple 1.7.36...
powershell -c "Invoke-WebRequest -Uri 'https://repo1.maven.org/maven2/org/slf4j/slf4j-simple/1.7.36/slf4j-simple-1.7.36.jar' -OutFile 'lib/slf4j-simple-1.7.36.jar'" >nul 2>&1
if exist "lib\slf4j-simple-1.7.36.jar" (
    echo      ✅ SLF4J Simple baixado com sucesso
) else (
    echo      ❌ Falha ao baixar SLF4J Simple
)

echo.
echo [2/8] Verificando dependencias baixadas...

:: Contagem de arquivos baixados
set DOWNLOADED=0
if exist "lib\gson-2.10.1.jar" set /a DOWNLOADED+=1
if exist "lib\spark-core-2.9.4.jar" set /a DOWNLOADED+=1
if exist "lib\jetty-server-9.4.54.jar" set /a DOWNLOADED+=1
if exist "lib\jetty-http-9.4.54.jar" set /a DOWNLOADED+=1
if exist "lib\jetty-io-9.4.54.jar" set /a DOWNLOADED+=1
if exist "lib\jetty-util-9.4.54.jar" set /a DOWNLOADED+=1
if exist "lib\slf4j-api-1.7.36.jar" set /a DOWNLOADED+=1
if exist "lib\slf4j-simple-1.7.36.jar" set /a DOWNLOADED+=1

echo    → Dependencias baixadas: %DOWNLOADED%/8

echo.
echo [3/8] Limpando arquivos duplicados...

:: Remover arquivo duplicado se existir
if exist "lib\jetty-server-9.4.54.v20240208.jar" (
    del "lib\jetty-server-9.4.54.v20240208.jar" >nul 2>&1
    echo    → Arquivo duplicado removido
)

echo.
echo ================================================
echo  DOWNLOAD DE DEPENDENCIAS CONCLUIDO!
echo  ZKAgent Professional v1.0
echo  AiNexus Tecnologia - Richardson Rodrigues
echo ================================================
echo.

if %DOWNLOADED% equ 8 (
    echo ✅ SUCESSO COMPLETO!
    echo.
    echo DEPENDENCIAS BAIXADAS ^(8/8^):
    echo  ✅ gson-2.10.1.jar
    echo  ✅ spark-core-2.9.4.jar
    echo  ✅ jetty-server-9.4.54.jar
    echo  ✅ jetty-http-9.4.54.jar
    echo  ✅ jetty-io-9.4.54.jar
    echo  ✅ jetty-util-9.4.54.jar
    echo  ✅ slf4j-api-1.7.36.jar
    echo  ✅ slf4j-simple-1.7.36.jar
    echo.
    echo TAMANHO TOTAL: ~2.2MB
    echo.
    echo PROXIMOS PASSOS:
    echo  1. Execute: install.bat
    echo  2. O instalador usara as dependencias locais
    echo  3. Nao precisara mais de internet!
) else (
    echo ⚠️ DOWNLOAD PARCIAL!
    echo.
    echo → %DOWNLOADED%/8 dependencias baixadas
    echo → Verifique sua conexao com internet
    echo → Execute novamente se necessario
    echo.
    echo NOTA: O instalador funcionara mesmo com dependencias parciais
    echo mas algumas funcionalidades podem estar limitadas.
)

echo.
echo GitHub: https://github.com/cavalcrod200381/AGENTE-RLP.git
echo Desenvolvido por AiNexus Tecnologia - Richardson Rodrigues
echo.
echo Pressione qualquer tecla para sair...
pause >nul 