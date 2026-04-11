Amazon EC2const http = require('http');
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Projeto 1: Docker CI/CD na AWS com App Amazon EC2 - Funcionando!\n');
});
server.listen(8080, '0.0.0.0');
