const sqlite3 = require('sqlite3').verbose();
const express = require('express');
const app = express();
const PORT = 3000;

// Conexão com o banco de dados (arquivo local)
const db = new sqlite3.Database('./estufa.db');

// Criação da tabela com ID e TIMESTAMP automático
db.run(`
  CREATE TABLE IF NOT EXISTS leituras (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    temperatura REAL,
    umidade_solo REAL,
    luminosidade REAL,
    umidade_ar REAL,
    co2 REAL,
    ventilador BOOLEAN,
    irrigacao BOOLEAN,
    luz_artificial BOOLEAN,
    monitorar_umidade_ar BOOLEAN,
    monitorar_co2 BOOLEAN,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
  )
`);

// Função que gera 0 ou 1 aleatoriamente
function gerarBooleano() {
  return Math.random() > 0.5 ? 1 : 0;
}

// Gera e insere os dados simulados
function gerarDadosSimulados() {
  const dados = {
    temperatura: (20 + Math.random() * 10).toFixed(2),
    umidade_solo: (30 + Math.random() * 40).toFixed(2),
    luminosidade: (100 + Math.random() * 900).toFixed(2),
    umidade_ar: (40 + Math.random() * 20).toFixed(2),
    co2: (0.5 + Math.random() * 1.5).toFixed(2),
    ventilador: gerarBooleano(),
    irrigacao: gerarBooleano(),
    luz_artificial: gerarBooleano(),
    monitorar_umidade_ar: gerarBooleano(),
    monitorar_co2: gerarBooleano()
  };

  db.run(`
    INSERT INTO leituras (
      temperatura, umidade_solo, luminosidade, umidade_ar, co2,
      ventilador, irrigacao, luz_artificial, monitorar_umidade_ar, monitorar_co2
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `,
    [
      dados.temperatura, dados.umidade_solo, dados.luminosidade, dados.umidade_ar, dados.co2,
      dados.ventilador, dados.irrigacao, dados.luz_artificial, dados.monitorar_umidade_ar, dados.monitorar_co2
    ],
    function (err) {
      if (err) return console.error("Erro ao inserir:", err.message);
      console.log(`[${new Date().toLocaleTimeString()}] Dados inseridos com ID ${this.lastID}`);
      mostrarUltimosDados(); // Mostra os últimos registros após inserção
    }
  );
}

// Exibe os últimos 5 registros inseridos
function mostrarUltimosDados() {
  db.all("SELECT * FROM leituras ORDER BY id DESC LIMIT 5", (err, rows) => {
    if (err) return console.error("Erro ao listar:", err.message);
    console.table(rows);
  });
}

// Executa a cada 5 segundos
setInterval(gerarDadosSimulados, 5000);

// Endpoint para obter o último registro
app.get('/dados', (req, res) => {
  db.get("SELECT * FROM leituras ORDER BY id DESC LIMIT 1", (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(row); // Retorna apenas o último registro
  });
});

// Inicia o servidor
app.listen(PORT, 'localhost', () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});

console.log("Simulador de CLP rodando... Inserindo dados a cada 5 segundos.");