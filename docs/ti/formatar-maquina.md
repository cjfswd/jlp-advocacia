# Formatar a máquina sem perder os certificados

Procedimento para reinstalar o Windows de uma máquina da JLP mantendo a assinatura eletrônica funcionando depois. A ideia é separar o que é token (fica no hardware) do que é arquivo (precisa de backup).

> Primeira versão do runbook. Ajuste os passos conforme a prática da JLP e adicione o que faltar.

## Antes de formatar

1. **Mapeie os certificados da máquina**: abra `certmgr.msc` > **Pessoal > Certificados** e anote cada certificado, se é A1 (arquivo) ou A3 (token) e a validade.
2. **A1 (arquivo)**: exporte com a chave privada. Dois cliques no certificado nao resolve; use **Botão direito > Todas as tarefas > Exportar > Sim, exportar a chave privada > formato .pfx**, defina uma senha e guarde o `.pfx` num local seguro (pen drive ou nuvem da JLP). Sem esse backup, um A1 some com a formatação.
3. **A3 (token)**: não precisa backup do certificado, ele vive no token. Garanta apenas que você tem o **instalador do middleware** (SafeNet Authentication Client para Aladdin, SafeSign Identity Client para GD) e sabe o **PIN** e o **PUK**.
4. **Anote os programas de assinatura**: PJeOffice, Shodo, AssinadorLivre, e qualquer configuração específica.
5. **Backup geral**: documentos, favoritos do Firefox (perfil do PJe), e-mails locais, e a pasta de trabalho.

## Depois de formatar

1. **Windows e atualizações** em dia.
2. **Middleware dos tokens** (64 bits, do site da Certisign): SafeNet para Aladdin, SafeSign para GD. Reinicie e conecte um token de cada vez para validar.
3. **Reimporte os A1**: dois cliques no `.pfx`, **Usuário Atual**, marque "Marcar esta chave como exportável", repositório **Pessoal**.
4. **Confira no `certmgr.msc`** se cada certificado mostra "Você tem uma chave privada que corresponde a este certificado".
5. **Serviços**: em `services.msc`, deixe **Cartão Inteligente** e **Propagação de Certificado** como **Automático** e **Em execução**.
6. **Se der o erro de chave privada**: rode [`scripts/Reparar-ChavePrivada.ps1`](scripts/Reparar-ChavePrivada.ps1) (veja [certificados-digitais.md](certificados-digitais.md), seção 2).
7. **PJe**: instale o **PJeOffice** (ou Shodo, na Justiça do Trabalho) e o **Firefox**. Teste login e assinatura num processo.
8. **Recursos do Windows** (se o AssinadorLivre reclamar): .NET Framework 3.5 e, no 4.x, Ativação HTTP e não HTTP.

## Checklist rápido

- [ ] A1 exportados em `.pfx` com senha, antes de formatar
- [ ] Instaladores de middleware e PINs/PUKs em mãos
- [ ] Middleware reinstalado e token reconhecido
- [ ] A1 reimportados e chave privada confirmada no certmgr
- [ ] Serviços de Cartão Inteligente e Propagação ativos
- [ ] PJeOffice + Firefox testados num processo real
