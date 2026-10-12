# Certificados digitais, tokens e assinatura no PJe

Guia de referência para configurar e reparar a assinatura eletrônica usada na JLP. Cobre os tokens Aladdin e GD, o erro clássico do AssinadorLivre e o motivo do PJe pedir Firefox.

## 1. Ativar o certificado do token no Windows

A JLP usa tokens de dois fabricantes. Cada um tem o seu middleware (o programa que faz o Windows enxergar o token). Instale a versão de 64 bits, baixada pelo site da Autoridade Certificadora (Certisign).

### Token Aladdin (eToken / SafeNet)

1. Instale o **SafeNet Authentication Client (SAC)**.
2. Reinicie o PC e conecte o token.
3. Abra o **SafeNet Authentication Client Tools** e clique na engrenagem para entrar na visão avançada.
4. Em **Client Settings > Advanced**, deixe marcada a opção de copiar os certificados do usuário para a memória local (propagação para o repositório do Windows).
5. Se o certificado ainda não aparecer, expanda o token, clique com o botão direito no certificado e escolha **Set as Default** ou **Export / Register**.

### Token GD (StarSign)

1. Instale o **SafeSign Identity Client**.
2. Reinicie o PC e conecte o token.
3. Abra o **Token Administration Utility**.
4. Vá em **Digital IDs > Show Registered Digital IDs** e clique em **Register** para registrar o certificado no Windows.

### Conferir se funcionou

- `Win+R` > `certmgr.msc` > **Pessoal > Certificados**. O certificado deve estar lá.
- Com os dois tokens, conecte um de cada vez na primeira configuração, para os middlewares não conflitarem.

### Problemas comuns

- **Token não reconhecido**: troque de porta USB, de preferência uma traseira e sem hub.
- **O certificado some ao remover o token**: é normal, ele só fica disponível com o token conectado.
- **PIN bloqueado**: após algumas tentativas erradas, só desbloqueia com o PUK ou pela AC.

## 2. Erro "não existe chave privada associada ao certificado" (AssinadorLivre)

Esse erro quase nunca é do assinador. É do Windows: o certificado está no repositório, mas a chave privada correspondente não está mais acessível. Por isso reinstalar o app ou limpar com Revo não resolve (e limpar com Revo pode piorar, se apagou a pasta de chaves em `%APPDATA%\Microsoft\Crypto`).

### Diagnóstico

Abra `certmgr.msc` > **Pessoal > Certificados**, dê dois cliques no certificado. Na aba **Geral** deve aparecer "Você tem uma chave privada que corresponde a este certificado". Se não aparecer, é esse o problema.

### Solução por tipo de certificado

- **A1 (arquivo)**: você provavelmente importou só o `.cer` (parte pública). Reimporte o `.pfx` / `.p12` original com dois cliques, escolha **Usuário Atual**, marque "Marcar esta chave como exportável" e envie para o repositório **Pessoal**.
- **A3 (token / cartão)**: reinstale o middleware do fabricante (SafeNet, SafeSign, Watchdata, Gemalto/Thales, conforme o modelo) e confira no gerenciador dele se o token é reconhecido. Sem o driver certo, o Windows vê o certificado mas não a chave.
- **MobileID (nuvem)**: não usa certificado do repositório local. No AssinadorLivre escolha a opção MobileID e autentique pelo app no celular. Selecionar o certificado local dá exatamente esse erro.

### Reparar o vínculo (A1 ou A3 já instalado)

No certificado, aba **Detalhes**, copie o **Número de série** (sem espaços). No **CMD, como o mesmo usuário** (não como administrador, senão ele olha outro perfil):

```
certutil -repairstore my <numero_de_serie>
```

O script em [`scripts/Reparar-ChavePrivada.ps1`](scripts/Reparar-ChavePrivada.ps1) automatiza esse diagnóstico e reparo (inclusive em lote, com `-Todos`).

### Se ainda falhar

**Painel de Controle > Programas > Ativar ou desativar recursos do Windows**: marque **.NET Framework 3.5** e, dentro do 4.x, **Ativação HTTP** e **Ativação não HTTP**. Reinicie. Esse é um conserto conhecido do AssinadorLivre no Windows 11.

## 3. Por que o PJe pede Firefox

- Quando o PJe surgiu (por volta de 2010), a ponte entre o site e o token era feita por um **applet Java (NPAPI)** rodando dentro da página.
- Essa tecnologia foi abandonada por insegurança: o Chrome tirou o suporte em **outubro de 2015**; o Firefox foi o último a manter, até **2017-2018** (a versão 52 ESR foi a última com NPAPI; a de 64 bits nunca teve). Por anos o Firefox foi o único onde a assinatura do PJe funcionava, e virou o navegador oficial dos tribunais.
- O CNJ chegou a distribuir um **Navegador PJe**, um Firefox customizado com o plugin Java embutido e pop-ups já liberados.
- **Hoje** a assinatura não acontece mais no navegador: é feita por um programa instalado, o **PJeOffice** ou o **Shodo**, que conversa com o site e com o token. Isso funciona em qualquer navegador moderno (Firefox 58+ ou Chrome 64+).
- O Firefox segue "recomendado" por **homologação**: o tribunal testa e documenta só nele. No PJe 1.0 ainda há casos que dependem do Firefox.

### Efeito prático nos downloads do PJe

Fora do Firefox, o download da íntegra e de documentos pode falhar porque o sistema foi testado assumindo o comportamento dele:

1. **PDFs gerados pelo sistema** podem abrir em aba em branco, vir sem nome correto (tipo `documento.seam`) ou falhar sem avisar.
2. **Pop-ups**: muitos downloads abrem janela nova (links `.seam`). Navegadores bloqueiam pop-up de formas diferentes; fora do Firefox o download pode ser "engolido" sem aviso.
3. **Sessão / cookies**: em abas ou janelas novas, a política de cookies difere e o download pode cair na tela de login ou vir vazio.
4. **Assinatura do PDF**: se o visualizador interno do navegador "salvar" o PDF renderizado em vez do original, a validação da assinatura pode falhar depois.

Regra prática: se o PJe falhar em download, pop-up ou login inesperado em outro navegador, use o Firefox com o PJeOffice.

## 4. PJeOffice nao le o token ("modo Windows")

Sintoma: ao assinar, o PJeOffice Pro da erro de leitura do token. A propria mensagem sugere a saida: trocar a integracao de **Windows** para **PJeOffice**.

1. Clique em OK nos avisos. Perto do relogio, na setinha `^`, ache o icone do **PJeOffice Pro**.
2. Botao direito > configuracao de certificado/token (o nome varia por versao).
3. Onde estiver **Windows**, mude para **PJeOffice**.
4. Ele pede o driver (`.dll`) do token. Os mais comuns:
   - Token SafeNet / eToken (Aladdin): `C:\Windows\System32\eTPKCS11.dll`
   - Token GD / StarSign: `C:\Windows\System32\aetpkss1.dll`
   - Watchdata: `C:\Windows\System32\WDPKCS.dll`
5. Salve, tire e recoloque o token, feche e reabra o navegador e tente entrar com "Seu certificado digital".

Se nao souber a marca, ela costuma estar escrita no token ou aparece em Iniciar como o programa do token (ex.: "SafeNet Authentication Client"). Se nao funcionar, confirme no programa do token que o certificado aparece e reinstale o driver pelo site do fabricante/AC.

Enquanto isso, se a conta tiver senha cadastrada, da pra entrar no PDPJ por **CPF + senha** ou **gov.br** sem token; o token so e obrigatorio na hora de assinar/protocolar.


## Fontes do histórico do PJe

- Oracle / java.com: fim do NPAPI, Firefox 52 ESR como última versão com suporte.
- PJe Descomplicado (pje.org.br) e TJMG: congelamento de versões (Firefox 40 + Java 8) e o Navegador PJe do CNJ.
- Portais dos TRTs (compilado em Juristas): Shodo (CSJT) e PJeOffice substituindo o applet Java, com liberação de outros navegadores.
