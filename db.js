const { Pool } = require("pg");

const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "project",
  password: "123",
  port: 5432,
});

module.exports = pool;