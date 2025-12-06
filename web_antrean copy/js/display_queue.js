// FINAL DISPLAY QUEUE JS

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js";
import { getDatabase, ref, onValue } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-database.js";

// =====================================
// 1. Firebase Config (ISI DENGAN PUNYAMU)
// =====================================
const firebaseConfig = {
  apiKey: "ISI",
  authDomain: "ISI",
  databaseURL: "ISI",
  projectId: "ISI",
  storageBucket: "ISI",
  messagingSenderId: "ISI",
  appId: "ISI"
};

const app = initializeApp(firebaseConfig);
const db = getDatabase(app);

// =====================================
// 2. TEXT-TO-SPEECH
// =====================================
function playNotification(nomor, poli) {
  const text = `Nomor antrean ${nomor}, silakan menuju loket ${poli}`;
  const msg = new SpeechSynthesisUtterance(text);
  msg.lang = "id-ID";
  speechSynthesis.speak(msg);
}

// =====================================
// 3. UPDATE UI
// =====================================
function updateUI(target, data, poli) {

  document.getElementById(`${target}-sekarang`).innerText = data.nomor ?? "-";
  document.getElementById(`${target}-loket-sekarang`).innerText = `LOKET ${poli}`;

  // next default
  document.getElementById(`${target}-selanjutnya`).innerText = "-";
  document.getElementById(`${target}-loket-selanjutnya`).innerText = "LOKET -";

  // blink
  const box = document.getElementById(`${target}-container`);
  box.classList.add("blink");
  setTimeout(() => box.classList.remove("blink"), 1500);

  // audio
  if (data.status === "dipanggil") {
    playNotification(data.nomor, poli);
  }
}

// =====================================
// 4. FIREBASE LISTENER
// Struktur: display/POLI
// =====================================
function setupListener() {
  const poliList = ["UMUM", "GIGI", "ANAK", "BEDAH"];

  const idMap = {
    "UMUM": "umum",
    "GIGI": "gigi",
    "ANAK": "anak",
    "BEDAH": "bedah"
  };

  poliList.forEach(poli => {
    const path = ref(db, `display/${poli}`);

    onValue(path, snapshot => {
      const data = snapshot.val();
      if (!data) return;

      console.log(`Update dari ${poli}:`, data);

      updateUI(idMap[poli], data, poli);
    });
  });
}

document.addEventListener("DOMContentLoaded", setupListener);
