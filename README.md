# ⚓ CI/CD Pipeline: Docker + GitHub Actions + AWS (ECR/EC2)

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)

Este projeto implementa uma esteira de automação completa (CI/CD) para uma aplicação Node.js. O objetivo é demonstrar o fluxo de entrega contínua, onde cada atualização no código é automaticamente transformada em uma imagem Docker, armazenada no Amazon ECR e disponibilizada em uma instância EC2.

## 🏗️ Arquitetura do Projeto
![Arquitetura do Projeto](img/arquitetura-profissional.png)

A arquitetura segue o fluxo:
1. **GitHub**: Armazenamento do código-fonte e controle de versão.
2. **GitHub Actions**: Pipeline de CI que realiza o build e push da imagem Docker.
3. **Amazon ECR**: Registro privado para gerenciamento de imagens conteinerizadas.
4. **Amazon EC2**: Servidor de produção rodando a aplicação via Docker.

## 🚀 Tecnologias Utilizadas
* **Runtime:** Node.js
* **Container:** Docker
* **CI/CD:** GitHub Actions
* **Cloud (AWS):** EC2, ECR, IAM Roles e Security Groups.

## 🧠 Lições Aprendidas e Troubleshooting

Durante o desenvolvimento, enfrentei desafios técnicos que consolidaram meu conhecimento em infraestrutura:

### 1. Gestão de Permissões Docker (Linux Post-Install)
Ao rodar o container na EC2, encontrei o erro de `Permission Denied` no socket do Docker. 
* **Solução:** Em vez de usar `sudo` (má prática), adicionei o usuário `ec2-user` ao grupo `docker` e recarreguei as permissões. Isso garantiu o princípio de menor privilégio.

### 2. Segurança com GitHub Secrets
Para evitar a exposição de `Access Keys` da AWS, utilizei **GitHub Secrets**. Isso garante que credenciais sensíveis nunca fiquem expostas no código, seguindo os padrões de segurança da indústria.

### 3. Conectividade de Rede (Security Groups)
Configurei as regras de entrada (Inbound Rules) no Firewall da AWS para permitir tráfego na porta 80, realizando o mapeamento correto para a porta 8080 do container Docker.

## 🛠️ Como Reproduzir
1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/gustavogomes43/Projeto-AWS-Docker-CICD.git](https://github.com/gustavogomes43/Projeto-AWS-Docker-CICD.git)
