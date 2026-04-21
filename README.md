# CI/CD Pipeline · High-Availability Docker Deployment on AWS

> Pipeline de entrega contínua de nível corporativo para aplicações Node.js — do commit ao container em produção em menos de 60 segundos.

[![CI/CD Status](https://github.com/seu-usuario/seu-repositorio/actions/workflows/deploy.yml/badge.svg)](https://github.com/seu-usuario/seu-repositorio/actions)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat-square&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![GitHub Actions](https://img.shields.io/badge/github%20actions-%232088FF.svg?style=flat-square&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Node.js](https://img.shields.io/badge/node.js-18-6DA55F?style=flat-square&logo=node.js&logoColor=white)](https://nodejs.org/)

---

## O que este projeto resolve

Processos de deploy manual são lentos, inconsistentes e introduzem risco humano. Este projeto elimina esses problemas ao automatizar todo o ciclo de vida do software — desde o `git push` até o container rodando em produção na AWS — com foco em **segurança**, **imutabilidade** e **rastreabilidade**.

Qualquer merge na branch `main` dispara automaticamente: validação de código → build da imagem Docker → scan de vulnerabilidades → push para o ECR com dupla tag → resumo auditável na interface do GitHub Actions.

---

## Arquitetura

```
Developer → GitHub (main) → GitHub Actions ─────────────────────────────┐
                                   │                                      │
                            [test] → [build] → [push]                    │
                                                  │                       │
                                            Amazon ECR ← IAM Role ← EC2 ASG
                                            (Registry)   (Least    (Container
                                                          Privilege) Runtime)
                                                                    │
                                                              Internet (port 80)
```

**Decisões de arquitetura e trade-offs:**

| Decisão | Alternativa considerada | Por que esta escolha |
|---|---|---|
| Amazon ECR | Docker Hub | Latência zero dentro da AWS, controle de acesso via IAM, imutabilidade de imagens nativa |
| EC2 + ASG | ECS / EKS | Menor overhead operacional para o escopo do projeto; ECS seria a próxima evolução natural |
| Multi-stage Dockerfile | Build único | Imagem de produção ~60% menor, sem ferramentas de dev expostas em runtime |
| SHA tag + latest | Apenas latest | Permite rollback preciso para qualquer commit sem ambiguidade |
| GitHub Secrets + IAM Role | Credenciais hardcoded | Superfície de ataque de credenciais reduzida a zero |

---

## Stack

- **Runtime**: Node.js 18 (LTS)
- **Containerização**: Docker com multi-stage build
- **CI/CD**: GitHub Actions
- **Registry**: Amazon ECR (privado, imagens imutáveis)
- **Compute**: Amazon EC2 dentro de Auto Scaling Group
- **Segurança**: IAM Roles, Resource-based Policies no ECR, GitHub Secrets
- **Qualidade**: Hadolint (lint de Dockerfile), Trivy (scan de vulnerabilidades)

---

## Estrutura do projeto

```
.
├── index.js                        # Aplicação Node.js
├── package.json
├── Dockerfile                      # Multi-stage build (builder → production)
└── .github/
    └── workflows/
        └── deploy.yml              # Pipeline completo (test → build → push)
```

---

## Pipeline em detalhe

O workflow é dividido em dois jobs independentes:

**Job 1 — `test`** (roda em PRs e pushes):
1. Setup Node.js com cache de dependências
2. `npm ci` — instalação determinística
3. Lint do Dockerfile com Hadolint

**Job 2 — `build-and-push`** (apenas em merge na `main`):
1. Configuração de credenciais AWS via GitHub Secrets
2. Login no Amazon ECR
3. Geração de tags: `latest` + SHA curto do commit (ex: `a1b2c3d`)
4. Build com Docker Buildx + cache entre runs (reduz tempo de CI em até 70%)
5. Push das imagens para o ECR
6. Scan de vulnerabilidades com Trivy (CRITICAL e HIGH)
7. Resumo auditável publicado na interface do GitHub Actions

**Controle de concorrência**: `cancel-in-progress: true` garante que apenas um deploy rode por vez — pushes rápidos consecutivos não geram race conditions.

---

## Dockerfile: multi-stage build

```dockerfile
# Stage 1 — builder: instala todas as dependências, executa validações
FROM node:18-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# Stage 2 — production: apenas o necessário para rodar
FROM node:18-slim AS production
ENV NODE_ENV=production PORT=8080
COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=builder /app/index.js ./
USER node                           # Não roda como root
EXPOSE 8080
HEALTHCHECK ...                     # Orquestrador sabe se o container está vivo
CMD ["node", "index.js"]
```

A separação em stages garante que ferramentas de desenvolvimento, cache do npm e arquivos temporários do build **nunca** chegam à imagem de produção.

---

## Segurança

| Controle | Implementação |
|---|---|
| Credenciais AWS | GitHub Secrets — nunca em arquivos ou logs |
| Acesso ECR | IAM Role na EC2 + Resource-based Policy no repositório |
| Princípio do menor privilégio | IAM policies granulares: EC2 lê ECR, não escreve |
| Runtime | Container roda como usuário `node`, não `root` |
| Imagens | Tags imutáveis no ECR — uma tag = um artefato exato |
| Vulnerabilidades | Scan automático com Trivy a cada build |

---

## Desafios técnicos resolvidos

### 1. `Access Denied` no `docker pull` mesmo com credenciais configuradas

A instância EC2 tinha uma IAM Role com permissão `ecr:GetAuthorizationToken`, mas o repositório ECR tinha uma Resource-based Policy que não listava explicitamente a entidade principal da EC2 como permitida. O erro aparecia apenas no pull, não no login — o que tornou o diagnóstico não trivial.

**Resolução**: adicionei a ARN da IAM Role da EC2 na Resource-based Policy do ECR com as ações mínimas necessárias (`ecr:BatchGetImage`, `ecr:GetDownloadUrlForLayer`). Isso separou claramente o controle de identidade (IAM Role) do controle de recurso (ECR Policy).

### 2. Container falhava na inicialização após injeção de variáveis no pipeline

O container subia, passava pelo health check inicial e falhava alguns segundos depois com um erro de sintaxe. O problema era uma variável de ambiente injetada via `ENV` no Dockerfile que sobrescrevia um valor esperado pelo `JSON.parse()` interno da aplicação.

**Resolução**: `docker logs -f` + `docker inspect` para isolar a variável problemática. Corrigi localmente em ambiente isolado antes de commitar — reduzindo o ciclo de feedback de "push → aguardar CI → falha" para segundos.

### 3. Exposição da aplicação na porta 80 com runtime na 8080

Regra de segurança da instância EC2 expunha apenas a porta 80. A aplicação Node.js escutava na 8080. Abrir a 8080 no Security Group aumentaria a superfície de ataque desnecessariamente.

**Resolução**: mapeamento de portas nativo do Docker (`-p 80:8080`) — a porta 80 é exposta pelo host, o container permanece isolado na 8080. Sem mudanças no Security Group.

---

## Como executar localmente

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio

# Build da imagem
docker build -t projeto-docker-cicd .

# Execute o container
docker run -p 8080:8080 projeto-docker-cicd

# Acesse
curl http://localhost:8080
```

---

## Secrets necessários

Configure os seguintes secrets no repositório GitHub (Settings → Secrets → Actions):

| Secret | Finalidade |
|---|---|
| `AWS_ACCESS_KEY_ID` | Autenticação programática na AWS |
| `AWS_SECRET_ACCESS_KEY` | Chave privada para assinatura de requisições |
| `AWS_REGION` | Região do ECR e da EC2 (ex: `us-east-1`) |
| `ECR_REPOSITORY` | Nome do repositório no ECR (ex: `projeto-docker-cicd`) |

---

## Resultados

- Deploy automatizado: de 20 minutos manuais para menos de 60 segundos
- Zero credenciais AWS expostas em código, logs ou máquinas locais
- Rastreabilidade completa: cada imagem em produção é mapeável a um commit exato via SHA tag
- Ambientes imutáveis: a imagem que passa nos testes é exatamente a que vai para produção

---

**Autor**: Gustavo Gomes · Cloud & DevOps
