import { db } from "./firebase_configure.js";
import { ref, onValue } from "https://www.gstatic.com/firebasejs/12.6.0/firebase-database.js";

// Mapping layanan → elemen HTML
const poliMap = {
    "POLI_UMUM": { nomor: "umum-sekarang", loket_id: "umum-loket-sekarang" },
    "POLI_GIGI": { nomor: "gigi-sekarang", loket_id: "gigi-loket-sekarang" },
    "POLI_ANAK": { nomor: "anak-sekarang", loket_id: "anak-loket-sekarang" },
    "POLI_BEDAH": { nomor: "bedah-sekarang", loket_id: "bedah-loket-sekarang" }
};

onValue(ref(db, "antrean"), (snapshot) => {
    const data = snapshot.val();
    if (!data) return;

    console.log("RAW DATA:", data);

    // Reset
    Object.values(poliMap).forEach(p => {
        document.getElementById(p.nomor).innerText = "-";
        document.getElementById(p.loket_id).innerText = "LOKET -";
    });

    // Kumpulkan data dari struktur 2-level
    const antreanList = [];

    Object.keys(data).forEach(layananKey => {
        const group = data[layananKey];

        // group = { X001: {...}, X002: {...} }
        Object.keys(group).forEach(antrianKey => {
            antreanList.push(group[antrianKey]);
        });
    });

    console.log("PROCESSED LIST:", antreanList);

    // Filter yang sedang dilayani
    const sedangDilayani = antreanList.filter(a => a.status === "dilayani");

    // Pilih yang terbaru di tiap layanan
    const grouped = {};

    sedangDilayani.forEach(item => {
        const waktu = new Date(item.waktu_panggil).getTime() || 0;

        if (!grouped[item.layanan_id] ||
            waktu > (new Date(grouped[item.layanan_id].waktu_panggil).getTime() || 0)
        ) {
            grouped[item.layanan_id] = item;
        }
    });

    // Update UI
    Object.keys(grouped).forEach(layanan => {
        const item = grouped[layanan];
        const map = poliMap[layanan];
        if (!map) return;

        document.getElementById(map.nomor).innerText = item.nomor;
        document.getElementById(map.loket_id).innerText = `LOKET ${item.loket_id?.replace("LKTO","") ?? "-"}`;

        const nomorEl = document.getElementById(map.nomor);
        nomorEl.classList.add("blink");
        setTimeout(() => nomorEl.classList.remove("blink"), 1200);
    });

});
