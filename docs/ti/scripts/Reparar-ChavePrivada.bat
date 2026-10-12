@echo off
REM Atalho para rodar o Reparar-ChavePrivada.ps1.
REM Clique duas vezes. Ele mantem a janela aberta no fim para voce ler o resultado.
REM Para reparar todos de uma vez, crie um atalho e acrescente  -Todos  no destino.

setlocal
set "SCRIPT=%~dp0Reparar-ChavePrivada.ps1"

REM Observacao: rode com a MESMA conta que usa o assinador.
REM Se elevar com outra conta de administrador, o repositorio de certificados muda.

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*

echo.
echo ---------------------------------------------
echo Terminou. Leia o resultado acima e o arquivo
echo Reparar-ChavePrivada.log na Area de Trabalho.
pause
