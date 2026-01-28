require('dotenv').config(); // Load variables from .env
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcrypt');

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Database Connection Pool
const db = mysql.createPool({
    host: process.env.DB_HOST,      // Will be 'database' in Docker
    user: process.env.DB_USER,      // Will be 'root'
    password: process.env.DB_PASS,  // Will be 'Rohit@123'
    database: process.env.DB_NAME,  // Will be 'inventory_db'
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test Database Connection on startup
db.getConnection((err, connection) => {
    if (err) {
        console.error("❌ Database connection failed:", err.message);
    } else {
        console.log("✅ Connected to MySQL Database");
        connection.release();
    }
});

// --- HELPER: Health Check ---
app.get('/', (req, res) => {
    res.send("Backend Server is running and healthy!");
});

// --- AUTH ROUTES ---

// 1. REGISTER
app.post('/register', async (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) return res.status(400).send({ message: "Fields missing" });

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const sql = 'INSERT INTO users (username, password) VALUES (?, ?)';
        
        db.query(sql, [username, hashedPassword], (err, result) => {
            if (err) {
                if (err.code === 'ER_DUP_ENTRY') return res.status(400).send({ message: "Username exists" });
                return res.status(500).send(err);
            }
            res.send({ message: "Registered Successfully" });
        });
    } catch (error) {
        res.status(500).send({ message: "Server error" });
    }
});

// 2. LOGIN
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    
    db.query('SELECT * FROM users WHERE username = ?', [username], async (err, result) => {
        if (err) return res.status(500).send(err);
        if (result.length === 0) return res.status(404).send({ message: "User not found" });

        const match = await bcrypt.compare(password, result[0].password);
        if (match) {
            res.send({ message: "Login Successful", user: result[0].username });
        } else {
            res.status(401).send({ message: "Wrong password" });
        }
    });
});

// --- INVENTORY ROUTES ---

// 3. GET ALL ITEMS
app.get('/inventory', (req, res) => {
    db.query('SELECT * FROM products', (err, result) => {
        if (err) return res.status(500).send(err);
        res.send(result);
    });
});

// 4. ADD ITEM
app.post('/inventory', (req, res) => {
    const { name, quantity, price } = req.body;
    const sql = 'INSERT INTO products (name, quantity, price) VALUES (?,?,?)';
    db.query(sql, [name, quantity, price], (err, result) => {
        if (err) return res.status(500).send(err);
        res.send({ message: "Item added", id: result.insertId });
    });
});

// 5. DELETE ITEM
app.delete('/inventory/:id', (req, res) => {
    const id = req.params.id;
    db.query('DELETE FROM products WHERE id = ?', [id], (err, result) => {
        if (err) return res.status(500).send(err);
        res.send({ message: "Item deleted" });
    });
});

// Listen on Port (Docker will map this)
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`✅ Server is running on port ${PORT}`);
});