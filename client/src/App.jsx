import React, { useState, useEffect } from 'react';
import axios from 'axios';

// Since Nginx is proxying /api to the backend, we use a relative path
const API_BASE_URL = "/api";

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [inventory, setInventory] = useState([]);
  const [form, setForm] = useState({ name: '', quantity: 0, price: 0 });
  const [credentials, setCredentials] = useState({ username: '', password: '' });

  // Fetch Inventory Data
  const fetchItems = () => {
    axios.get(`${API_BASE_URL}/inventory`)
      .then(res => setInventory(res.data))
      .catch(err => console.error("Error fetching data:", err));
  };

  // Auth Functions
  const handleRegister = () => {
    axios.post(`${API_BASE_URL}/register`, credentials)
      .then(res => alert("Success: " + res.data.message))
      .catch(err => alert("Registration failed."));
  };

  const handleLogin = () => {
    axios.post(`${API_BASE_URL}/login`, credentials)
      .then(() => {
        setIsLoggedIn(true);
        fetchItems(); 
      })
      .catch(err => alert("Login Failed: Check credentials"));
  };

  // Inventory Actions
  const addItem = () => {
    axios.post(`${API_BASE_URL}/inventory`, form).then(() => {
      fetchItems();
      setForm({ name: '', quantity: 0, price: 0 });
    });
  };

  const deleteItem = (id) => {
    axios.delete(`${API_BASE_URL}/inventory/${id}`).then(() => {
      fetchItems();
    });
  };

  // --- VIEW LOGIC ---

  if (!isLoggedIn) {
    return (
      <div style={{ padding: '50px', textAlign: 'center', fontFamily: 'sans-serif' }}>
        <h2>Inventory System</h2>
        <div style={{ marginBottom: '10px' }}>
          <input 
            placeholder="Username" 
            autoComplete="username"
            onChange={e => setCredentials({...credentials, username: e.target.value})} 
          />
        </div>
        <div style={{ marginBottom: '10px' }}>
          <input 
            type="password" 
            placeholder="Password" 
            autoComplete="current-password"
            onChange={e => setCredentials({...credentials, password: e.target.value})} 
          />
        </div>
        <button onClick={handleLogin} style={{ marginRight: '10px', cursor: 'pointer' }}>Login</button>
        <button onClick={handleRegister} style={{ backgroundColor: '#e1e1e1', cursor: 'pointer' }}>Register</button>
      </div>
    );
  }

  return (
    <div style={{ padding: '20px', fontFamily: 'sans-serif' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1>📦 Inventory Dashboard</h1>
        <button onClick={() => setIsLoggedIn(false)} style={{ height: '30px' }}>Logout</button>
      </div>
      <hr />
      
      <h3>Add New Item</h3>
      <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        <input placeholder="Item Name" value={form.name} onChange={e => setForm({...form, name: e.target.value})} />
        <input type="number" placeholder="Qty" value={form.quantity} onChange={e => setForm({...form, quantity: Number(e.target.value)})} />
        <input type="number" placeholder="Price" value={form.price} onChange={e => setForm({...form, price: Number(e.target.value)})} />
        <button onClick={addItem} style={{ backgroundColor: '#4CAF50', color: 'white', border: 'none', padding: '5px 15px', cursor: 'pointer' }}>Add Item</button>
      </div>

      <table border="1" style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
        <thead style={{ backgroundColor: '#f2f2f2' }}>
          <tr>
            <th style={{ padding: '10px' }}>ID</th>
            <th>Name</th>
            <th>Qty</th>
            <th>Price</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {inventory.map(item => (
            <tr key={item.id}>
              <td style={{ padding: '10px' }}>{item.id}</td>
              <td>{item.name}</td>
              <td>{item.quantity}</td>
              <td>${item.price}</td>
              <td>
                <button onClick={() => deleteItem(item.id)} style={{ color: 'red', cursor: 'pointer' }}>Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default App;