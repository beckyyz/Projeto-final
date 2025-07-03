# Script para baixar e extrair as fontes (PowerShell)

Write-Host "Baixando fontes Poppins e Montserrat..." -ForegroundColor Cyan

# Criando diretório temporário
$tempDir = "temp_fonts"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Set-Location $tempDir

# Baixando as fontes
Write-Host "Baixando Poppins..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://fonts.google.com/download?family=Poppins" -OutFile "poppins.zip"

Write-Host "Baixando Montserrat..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://fonts.google.com/download?family=Montserrat" -OutFile "montserrat.zip"

# Extraindo arquivos
Write-Host "Extraindo arquivos..." -ForegroundColor Yellow
Expand-Archive -Path "poppins.zip" -DestinationPath ".\Poppins" -Force
Expand-Archive -Path "montserrat.zip" -DestinationPath ".\Montserrat" -Force

# Criando diretório de fontes se não existir
$fontsDir = "..\assets\fonts"
if (-not (Test-Path $fontsDir)) {
    New-Item -ItemType Directory -Path $fontsDir -Force | Out-Null
}

# Movendo arquivos de fonte específicos para a pasta de destino
Write-Host "Copiando arquivos de fonte..." -ForegroundColor Yellow

# Poppins
Copy-Item -Path ".\Poppins\static\Poppins-Regular.ttf" -Destination "$fontsDir\Poppins-Regular.ttf" -Force
Copy-Item -Path ".\Poppins\static\Poppins-Medium.ttf" -Destination "$fontsDir\Poppins-Medium.ttf" -Force
Copy-Item -Path ".\Poppins\static\Poppins-SemiBold.ttf" -Destination "$fontsDir\Poppins-SemiBold.ttf" -Force
Copy-Item -Path ".\Poppins\static\Poppins-Bold.ttf" -Destination "$fontsDir\Poppins-Bold.ttf" -Force
Copy-Item -Path ".\Poppins\static\Poppins-Italic.ttf" -Destination "$fontsDir\Poppins-Italic.ttf" -Force

# Montserrat
Copy-Item -Path ".\Montserrat\static\Montserrat-Regular.ttf" -Destination "$fontsDir\Montserrat-Regular.ttf" -Force
Copy-Item -Path ".\Montserrat\static\Montserrat-Medium.ttf" -Destination "$fontsDir\Montserrat-Medium.ttf" -Force
Copy-Item -Path ".\Montserrat\static\Montserrat-Bold.ttf" -Destination "$fontsDir\Montserrat-Bold.ttf" -Force

# Limpando arquivos temporários
Set-Location ..
Write-Host "Limpando arquivos temporários..." -ForegroundColor Yellow
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "Fontes baixadas com sucesso!" -ForegroundColor Green
Write-Host "Agora execute 'flutter pub get' para atualizar as dependências." -ForegroundColor Cyan

Read-Host "Pressione ENTER para sair"
