# ⚓ CI/CD Pipeline: High-Availability Docker Deployment na AWS

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![GitHub Actions](https://img.shields.io/badge/github%20actions-%232088FF.svg?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)

## 📝 Descrição do Projeto
Este projeto implementa uma esteira de **CI/CD (Continuous Integration & Continuous Deployment)** robusta para uma aplicação Node.js. A solução foca na automação total: desde o *commit* no GitHub até a disponibilização em ambiente de produção na **AWS**, utilizando containers Docker para garantir paridade de ambientes e isolamento.

## 🏗️ Arquitetura e Stack Tecnológica
A arquitetura foi desenhada para ser escalável e segura:

* **Runtime:** Node.js (Servidor Web leve e assíncrono).
* **Containerização:** Docker (Isolamento de dependências e portabilidade).
* **CI/CD Engine:** GitHub Actions (Automação de Build, Tag e Push).
* **Registry:** Amazon ECR (Gerenciamento de imagens privadas de alta disponibilidade).
* **Compute:** Amazon EC2 (Instância Linux otimizada para containers).
* **Security:** IAM Roles e Resource-based Policies.

---

## 🧠 Desafios Técnicos e Resolução de Problemas (Troubleshooting)

Este projeto não foi apenas uma implementação "de livro". Enfrentou desafios reais de infraestrutura que exigiram análise profunda:

### 1. Comunicação Cross-Account & IAM Policies
* **Desafio:** Erros de `Access Denied` ao tentar realizar o `docker pull` entre diferentes contextos de contas AWS.
* **Solução:** Implementação de uma **Resource-based Policy** no Amazon ECR para autorizar especificamente a **IAM Role** da instância EC2. Isso aplicou o princípio de privilégio mínimo, garantindo que apenas recursos autorizados pudessem consumir as imagens.

### 2. Depuração de Runtime em Containers
* **Desafio:** O container iniciava, mas encerrava imediatamente devido a erros de sintaxe no código fonte injetado.
* **Solução:** Utilização estratégica de `docker logs` para diagnóstico em tempo real. Correção realizada via CLI diretamente no ambiente de staging, demonstrando agilidade em operações críticas de terminal (Linux/Unix).

### 3. Gerenciamento de Portas e Redes
* **Desafio:** Mapeamento de tráfego entre a porta padrão HTTP (80) e a porta interna da aplicação (8080).
* **Solução:** Configuração de Port Forwarding via Docker, permitindo que a aplicação fosse acessível externamente sem expor portas desnecessárias do servidor.

---

## ⚙️ Configuração do Ambiente

### Pré-requisitos
* AWS CLI configurado.
* Instância EC2 com Docker instalado.
* Repositório ECR criado na AWS.

### Variáveis de Ambiente (GitHub Secrets)
Para rodar este pipeline, as seguintes chaves devem ser configuradas na aba **Settings > Secrets > Actions**:

| Secret | Descrição |
| :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Chave de acesso IAM com permissão de ECR. |
| `AWS_SECRET_ACCESS_KEY` | Chave secreta IAM correspondente. |
| `AWS_REGION` | Região AWS (ex: us-east-1). |
| `ECR_REPOSITORY` | Nome do repositório no Amazon ECR. |

---

## 🚀 Como Executar

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/gustavogomes43/Projeto-AWS-Docker-CICD.git](https://github.com/gustavogomes43/Projeto-AWS-Docker-CICD.git)
    ```
2.  **Trigger do Pipeline:**
    Realize qualquer alteração no código e faça o `git push`. O GitHub Actions iniciará automaticamente o processo de Build e Push para o ECR.
3.  **Deploy na EC2:**
    Na instância, execute o comando de pull para atualizar a aplicação com a versão mais recente:
    ```bash
    docker pull <aws_account_id>[.dkr.ecr.us-east-1.amazonaws.com/projeto-docker-cicd:latest](https://.dkr.ecr.us-east-1.amazonaws.com/projeto-docker-cicd:latest)
    ```
4.  **Execução do Container:**
    ```bash
    docker run -d -p 80:8080 --name meu-app <aws_account_id>[.dkr.ecr.us-east-1.amazonaws.com/projeto-docker-cicd:latest](https://.dkr.ecr.us-east-1.amazonaws.com/projeto-docker-cicd:latest)
    ```

---

## 📈 Impacto de Negócio
* **Agilidade:** Redução do tempo de deploy manual para segundos.
* **Segurança:** Zero exposição de credenciais através do uso de Secrets e IAM Roles.
* **Confiabilidade:** Ambientes idênticos (Dev/Prod) eliminam o erro "na minha máquina funciona".

---

> **"A automação é o que permite que a tecnologia escale, mas a capacidade de resolver problemas é o que garante que ela continue rodando."**
