# ⚓ CI/CD Pipeline: Docker + GitHub Actions + AWS (ECR/EC2)

Este projeto implementa uma esteira de automação completa (CI/CD) para uma aplicação Node.js. O objetivo é demonstrar o fluxo de entrega contínua, onde cada atualização no código é automaticamente transformada em uma imagem Docker, armazenada no Amazon ECR e disponibilizada em uma instância EC2.

## 🏗️ Arquitetura do Projeto
![Arquitetura do Projeto](img/arquitetura-profissional.png)

A arquitetura segue o fluxo:
1. **GitHub**: Armazenamento do código-fonte.
2. **GitHub Actions**: Pipeline de CI que realiza o build da imagem Docker.
3. **Amazon ECR**: Registro privado para gerenciamento de versões das imagens.
4. **Amazon EC2**: Servidor de produção rodando a aplicação via Docker Containers.

## 🚀 Tecnologias Utilizadas
* **Runtime:** Node.js
* **Container:** Docker
* **CI/CD:** GitHub Actions
* **Cloud (AWS):** EC2, ECR, IAM Roles
* **OS:** Amazon Linux 2023

## 🛠️ Configuração e Execução

### Pré-requisitos
* Conta na AWS com permissões de IAM.
* Repositório no Amazon ECR criado.
* GitHub Secrets configurados (`AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`).

### Passos para Reproduzir
1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/seu-usuario/seu-repositorio.git](https://github.com/seu-usuario/seu-repositorio.git)
