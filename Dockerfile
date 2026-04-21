# =============================================================================
# Stage 1: builder
# Instala dependências e valida o código antes de gerar a imagem final.
# Esta camada é descartada — suas ferramentas não chegam à produção.
# =============================================================================
FROM node:18-slim AS builder

WORKDIR /app

# Copia apenas o manifesto de dependências para aproveitar o cache do Docker.
# A camada de npm install só é reexecutada se package.json mudar.
COPY package*.json ./

# Instala TODAS as dependências (incluindo devDependencies para lint/test)
RUN npm ci

# Copia o restante do código
COPY . .

# (Opcional) Execute aqui seus scripts de build, lint ou testes:
# RUN npm run lint
# RUN npm test

# =============================================================================
# Stage 2: production
# Imagem final enxuta — apenas o runtime necessário.
# Resultado: imagem ~60% menor que um build único.
# =============================================================================
FROM node:18-slim AS production

# Metadados da imagem (boas práticas OCI)
LABEL org.opencontainers.image.title="projeto-docker-cicd"
LABEL org.opencontainers.image.description="Node.js app · CI/CD pipeline on AWS ECR + EC2"
LABEL org.opencontainers.image.source="https://github.com/seu-usuario/seu-repositorio"

# Variáveis de ambiente de produção
ENV NODE_ENV=production \
    PORT=8080

WORKDIR /app

# Copia apenas dependências de produção do stage anterior
COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copia o código-fonte validado
COPY --from=builder /app/index.js ./

# Princípio do menor privilégio: não roda como root
USER node

EXPOSE 8080

# Health check: o orquestrador sabe se o container está saudável
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080', r => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

CMD ["node", "index.js"]
