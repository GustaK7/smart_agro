const sqlite3 = require('sqlite3').verbose();
const express = require('express');
const cors = require('cors'); // Importa o pacote cors
const app = express();
const PORT = 3000;

// Habilita CORS para todas as origens
app.use(cors());

// Conexão com o banco de dados (arquivo local)
const db = new sqlite3.Database('./estufa.db');

// Criação da tabela de usuários
db.run(`
  CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
  )
`);

// Criação da tabela de leituras com FK para usuários
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
    data DATE DEFAULT (DATE('now')),
    hora TIME DEFAULT (TIME('now')),
    fk_usuarios INTEGER,
    FOREIGN KEY (fk_usuarios) REFERENCES usuarios (id)
  )
`);

// Adiciona índices para os campos data e hora
db.run(`CREATE INDEX IF NOT EXISTS idx_leituras_data ON leituras (data)`);
db.run(`CREATE INDEX IF NOT EXISTS idx_leituras_hora ON leituras (hora)`);

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
    monitorar_co2: gerarBooleano(),
    fk_usuarios: 1 // Exemplo: associar ao usuário com ID 1
  };

  db.run(`
    INSERT INTO leituras (
      temperatura, umidade_solo, luminosidade, umidade_ar, co2,
      ventilador, irrigacao, luz_artificial, monitorar_umidade_ar, monitorar_co2,
      fk_usuarios
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `,
    [
      dados.temperatura, dados.umidade_solo, dados.luminosidade, dados.umidade_ar, dados.co2,
      dados.ventilador, dados.irrigacao, dados.luz_artificial, dados.monitorar_umidade_ar, dados.monitorar_co2,
      dados.fk_usuarios
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

// Executa a cada 1 minutos
setInterval(gerarDadosSimulados, 60000);

// Endpoint para obter o último registro
app.get('/dadosone', (req, res) => {
  db.get("SELECT * FROM leituras ORDER BY id DESC LIMIT 1", (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json(row); // Retorna apenas o último registro
  });
});


// receber os dados por data
app.get('/dadosdata', (req, res) => {
  const { dataInicio, dataFim } = req.query;

  // Verificação simples dos parâmetros
  if (!dataInicio || !dataFim) {
    return res.status(400).json({ error: 'Parâmetros dataInicio e dataFim são obrigatórios.' });
  }

  const query = `
  SELECT 
    temperatura,
    umidade_ar,
    umidade_solo,
    luminosidade,
    co2,
    ventilador,
    irrigacao,
    luz_artificial,
    monitorar_umidade_ar,
    monitorar_co2,
    data,
    hora 
  FROM leituras 
    WHERE data BETWEEN ? AND ? 
    ORDER BY id DESC
  `;

  db.all(query, [dataInicio, dataFim], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.json(rows); // Retorna todos os registros no intervalo
  });
});


app.get('/dadosdatamedia', (req, res) => {
  const { dataInicio, dataFim } = req.query;

  // Verificação simples dos parâmetros
  if (!dataInicio || !dataFim) {
    return res.status(400).json({ error: 'Parâmetros dataInicio e dataFim são obrigatórios.' });
  }

  const query = `
  SELECT 
    avg(temperatura) as temperatura,
    avg(umidade_ar) as umidade_ar,
    avg(umidade_solo) as umidade_solo,
    avg(luminosidade) as luminosidade,
    avg(co2) as co2 
  FROM leituras 
    WHERE data BETWEEN ? AND ? 
    ORDER BY id DESC
  `;

  db.all(query, [dataInicio, dataFim], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.json(rows); // Retorna todos os registros no intervalo
  });
});



// Inicia o servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor rodando em http://localhost:${PORT}`);
});

console.log("Simulador de CLP rodando... Inserindo dados a cada 60 Segundos.");