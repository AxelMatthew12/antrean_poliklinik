// Import Firebase modules
import { initializeApp } from "https://www.gstatic.com/firebasejs/12.6.0/firebase-app.js";
import { getDatabase } from "https://www.gstatic.com/firebasejs/12.6.0/firebase-database.js";

// Konfigurasi Firebase
export const firebaseConfig = {
  apiKey: "AIzaSyDIi-pPLioV9QtELo8vsbwd8E5LzcR9zDU",
  authDomain: "antrian-rumah-sakit-pbl.firebaseapp.com",
  databaseURL: "https://antrian-rumah-sakit-pbl-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "antrian-rumah-sakit-pbl",
  storageBucket: "antrian-rumah-sakit-pbl.firebasestorage.app",
  messagingSenderId: "877393119251",
  appId: "1:877393119251:web:fb23a049b89aac9ac617e6",
  measurementId: "G-71EKLNBRW9"
};

// Inisialisasi Firebase
export const app = initializeApp(firebaseConfig);

// Inisialisasi Realtime Database
export const db = getDatabase(app);
