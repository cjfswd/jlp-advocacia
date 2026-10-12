<#
Reparar-ChavePrivada.ps1
Diagnostica e repara o vinculo entre certificado e chave privada no Windows,
que causa o erro "nao existe chave privada associada ao certificado" no AssinadorLivre.

Uso:
  .\Reparar-ChavePrivada.ps1            repara os certificados do usuario que estiverem sem chave acessivel
  .\Reparar-ChavePrivada.ps1 -Todos     forca o reparo em todos os certificados, inclusive os que parecem ok
  .\Reparar-ChavePrivada.ps1 -Pfx "C:\caminho\cert.pfx"   reimporta um A1 antes de reparar

Rode como o MESMO usuario que usa o assinador (nao como outro administrador),
senao o script olha o repositorio de certificados de outra conta.
#>

param(
  [switch]$Todos,
  [string]$Pfx
)

$ErrorActionPreference = 'Continue'
$log = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Reparar-ChavePrivada.log'
function Registrar($txt){ $linha = "{0}  {1}" -f (Get-Date -Format 'HH:mm:ss'), $txt; Write-Host $linha; Add-Content -Path $log -Value $linha -Encoding UTF8 }

Set-Content -Path $log -Value "=== Reparar-ChavePrivada $(Get-Date) ===" -Encoding UTF8

# Aviso sobre conta elevada diferente da logada
$usuarioLogado = (Get-CimInstance Win32_ComputerSystem).UserName
$usuarioAtual  = "$env:USERDOMAIN\$env:USERNAME"
if($usuarioLogado -and ($usuarioLogado -ne $usuarioAtual)){
  Registrar "ATENCAO: a conta que esta rodando o script ($usuarioAtual) e diferente da logada no Windows ($usuarioLogado)."
  Registrar "O repositorio de certificados e por conta. Rode sem elevar, ou eleve com a MESMA conta."
}

# Reimportar A1 se informado
if($Pfx){
  if(Test-Path $Pfx){
    Registrar "Importando PFX: $Pfx"
    $senha = Read-Host "Senha do PFX" -AsSecureString
    try{
      Import-PfxCertificate -FilePath $Pfx -CertStoreLocation Cert:\CurrentUser\My -Password $senha -Exportable | Out-Null
      Registrar "PFX importado."
    }catch{ Registrar "Falha ao importar PFX: $($_.Exception.Message)" }
  } else { Registrar "PFX nao encontrado: $Pfx" }
}

# Servicos necessarios
foreach($svc in 'SCardSvr','CertPropSvc'){
  $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
  if($s){
    if($s.Status -ne 'Running'){ try{ Start-Service $svc; Registrar "Servico $svc iniciado." }catch{ Registrar "Nao consegui iniciar $svc (pode exigir elevacao)." } }
    else { Registrar "Servico $svc em execucao." }
  }
}

# Pasta de containers de chave (onde a limpeza do Revo costuma apagar)
$cripto = Join-Path $env:APPDATA 'Microsoft\Crypto'
if(Test-Path $cripto){
  $qtd = (Get-ChildItem $cripto -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
  Registrar "Containers em %APPDATA%\Microsoft\Crypto: $qtd arquivo(s)."
  if($qtd -eq 0){ Registrar "AVISO: pasta de containers vazia. Para A1, reimporte o .pfx original (parametro -Pfx)." }
} else { Registrar "Pasta de containers nao existe ainda." }

function ChaveAbre($cert){
  # HasPrivateKey mente em varios casos; tenta acessar a chave de verdade
  if(-not $cert.HasPrivateKey){ return $false }
  try{
    $k = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
    if($k){ return $true }
    $k2 = [System.Security.Cryptography.X509Certificates.ECDsaCertificateExtensions]::GetECDsaPrivateKey($cert)
    return [bool]$k2
  }catch{ return $false }
}

function Reparar($cert){
  $serie = $cert.SerialNumber
  Registrar "Reparando $($cert.Subject) (serie $serie)"
  & certutil -repairstore my $serie | Out-Null
  Start-Sleep -Milliseconds 300
  $novo = Get-Item ("Cert:\CurrentUser\My\" + $cert.Thumbprint) -ErrorAction SilentlyContinue
  if($novo -and (ChaveAbre $novo)){ return $true }
  # tenta pelo thumbprint
  & certutil -repairstore my $cert.Thumbprint | Out-Null
  Start-Sleep -Milliseconds 300
  $novo = Get-Item ("Cert:\CurrentUser\My\" + $cert.Thumbprint) -ErrorAction SilentlyContinue
  return ($novo -and (ChaveAbre $novo))
}

$certs = Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue
if(-not $certs){ Registrar "Nenhum certificado no repositorio Pessoal do usuario."; Registrar "Fim."; return }

$ok=0; $reparados=0; $falhou=0
foreach($c in $certs){
  $abre = ChaveAbre $c
  if($abre -and -not $Todos){ $ok++; Registrar "OK (ja funciona): $($c.Subject)"; continue }
  if($abre -and $Todos){ Registrar "Forcando reparo (modo -Todos): $($c.Subject)" }
  else { Registrar "Sem chave acessivel: $($c.Subject)" }
  if(Reparar $c){ $reparados++; Registrar "  -> reparado." }
  else { $falhou++; Registrar "  -> falhou. Se for A3, conecte o token; se for A1, use -Pfx com o arquivo original." }
}

Registrar "Resumo: $ok ja funcionavam, $reparados reparados, $falhou falharam."
Registrar "Log salvo em: $log"
Write-Host ""
Write-Host "Pronto. Abra o AssinadorLivre e teste a assinatura." -ForegroundColor Green
