:: Script para baixar e extrair as fontes (Windows)
@echo off
echo Baixando fontes Poppins e Montserrat...

:: Criando diretório temporário
mkdir temp_fonts
cd temp_fonts

:: Baixando as fontes (necessita curl)
echo Baixando Poppins...
curl -L -o poppins.zip "https://fonts.google.com/download?family=Poppins"

echo Baixando Montserrat...
curl -L -o montserrat.zip "https://fonts.google.com/download?family=Montserrat"

:: Extraindo arquivos
echo Extraindo arquivos...
tar -xf poppins.zip
tar -xf montserrat.zip

:: Movendo arquivos de fonte específicos para a pasta de destino
echo Copiando arquivos de fonte...
copy "Poppins\*.ttf" "..\assets\fonts\"
copy "Montserrat\*.ttf" "..\assets\fonts\"

:: Limpando arquivos temporários
cd ..
echo Limpando arquivos temporários...
rmdir /s /q temp_fonts

echo Fontes baixadas com sucesso!
echo.
echo Agora execute 'flutter pub get' para atualizar as dependências.
pause
