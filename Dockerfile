FROM node:18-slim
WORKDIR /app
COPY index.js .
EXPOSE 8080
USER node
CMD ["node", "index.js"]
