-- Quartos
CREATE TABLE IF NOT EXISTS quartos (
    id INTEGER PRIMARY KEY,
    number INTEGER UNIQUE,
    occupancy INTEGER,
    status TEXT DEFAULT "LIVRE"
);

-- Hospedes
CREATE TABLE IF NOT EXISTS hospedes (
    id INT PRIMARY KEY,
    nome TEXT UNIQUE,
    documento TEXT,
    telefone TEXT,
    empresa BOOLEAN
);

-- Pagamentos
CREATE TABLE IF NOT EXISTS pagamentos (
    id INT PRIMARY KEY,
    valor REAL,
    data INT,
    metodo TEXT,
    pagante TEXT DEFAULT "[]"
);

-- Entradas
CREATE TABLE IF NOT EXISTS entradas (
    id INT PRIMARY KEY,
    checkin INT,
    checkout INT,
    quartos TEXT DEFAULT "[]",
    hospedes TEXT DEFAULT "[]",
    diaria REAL,
    total REAL,
    paga BOOLEAN
);