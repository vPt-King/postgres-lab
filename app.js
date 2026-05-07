const express = require("express");
const bodyParser = require("body-parser");
const exphbs = require("express-handlebars");
const pool = require("./db");
const cookieParser = require("cookie-parser");

const app = express();
app.use(cookieParser());

// static files
app.use(express.static('public'));

// view engine
app.engine("handlebars", exphbs.engine({
  layoutsDir: 'views/layouts',
  partialsDir: 'views/layouts'
}));
app.set("view engine", "handlebars");

// middleware
app.use(bodyParser.urlencoded({ extended: false }));

// ===== ROUTES =====

app.get("/login", (req, res) => {
  res.render("login");
});


app.get("/register", (req, res) => {
  res.render("register");
});

// xử lý register
app.post("/register", async (req, res) => {
  const { username, password } = req.body;

  try {
    const result = await pool.query(
      "SELECT register_user($1, $2)",
      [username, password]
    );

    res.send(result.rows[0].register_user);
  } catch (err) {
    console.error(err);
    res.send("Error");
  }
});


app.post("/login", async (req, res) => {
  const { username, password } = req.body;

  try {
    const result = await pool.query(
      "SELECT login_user($1, $2)",
      [username, password]
    );

    const result_mess = result.rows[0].login_user;
    if (result_mess && result_mess.length > 20) {
      res.cookie("session_id", result_mess, {
        httpOnly: true,     // tránh XSS
        secure: false,      // true nếu dùng HTTPS
        maxAge: 60 * 60 * 1000, // 1 giờ
      });

      return res.send("Login success");
    }

    return res.send(result_mess);

  } catch (err) {
    console.error(err);
    res.send("Error");
  }
});

app.get("/admin", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM products");
    res.render("admin", {
      products: result.rows,
    });
  } catch (err) {
    console.error(err);
    res.send("Error loading products");
  }
});


app.post("/admin/add-product", async (req, res) => {
  const { name, price, quantity, description } = req.body;
  try {
    const result = await pool.query(
      "SELECT add_product($1, $2, $3, $4)",
      [name, price, quantity, description]
    );
    const result_mess = result.rows[0].add_product;
    return res.send(result_mess);
  } catch (err) {
    console.error(err);
    res.send("Error");
  }
});

app.get("/admin/edit-product/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query("SELECT * FROM products WHERE id = $1", [id]);
    if (result.rows.length === 0) {
      return res.send("Product not found");
    }
    res.render("edit_product", { product: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.send("Error");
  }
});

app.post("/admin/edit-product/:id", async (req, res) => {
  const { id } = req.params;
  const { name, price, quantity, description } = req.body;
  try {
    const result = await pool.query(
      "SELECT edit_product($1, $2, $3, $4, $5)",
      [id, name, price, quantity, description]
    );
    res.redirect("/admin");
  } catch (err) {
    console.error(err);
    res.send("Error updating product");
  }
});

app.post("/admin/delete-product/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      "CALL delete_product($1)",
      [id]
    );
    res.redirect("/admin");
  } catch (err) {
    console.error(err);
    res.send("Error updating product");
  }
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});