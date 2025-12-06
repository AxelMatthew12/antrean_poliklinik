import { db } from "./firebase_configure.js";
import { ref, onValue } from "https://www.gstatic.com/firebasejs/12.6.0/firebase-database.js";


// Mapping layanan → elemen HTML
const poliMap = {
    "POLI_UMUM": { nomor: "umum-sekarang", loket_id: "umum-loket-sekarang" },
    "POLI_GIGI": { nomor: "gigi-sekarang", loket_id: "gigi-loket-sekarang" },
    "POLI_ANAK": { nomor: "anak-sekarang", loket_id: "anak-loket-sekarang" },
    "POLI_BEDAH": { nomor: "bedah-sekarang", loket_id: "bedah-loket-sekarang" }
};
async function playTTS(text) {
    const url = "https://texttospeech.googleapis.com/v1/text:synthesize?key=YOUR_API_KEY";

    const body = {
        input: { text: text },
        voice: {
            languageCode: "id-ID",
            name: "id-ID-Wavenet-C"   // suara wanita mirip klinik
        },
        audioConfig: {
            audioEncoding: "MP3",
            speakingRate: 0.94,  // lebih lambat, lebih profesional
            pitch: -2.0          // lebih kalem
        }
    };

    const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });

    const data = await res.json();
    const audio = new Audio("data:audio/mp3;base64," + data.audioContent);
    audio.play();
}

let lastCalled = {};

// =========================
//  TEXT-TO-SPEECH QUEUE
// =========================
let audioQueue = [];
let isSpeaking = false;

function speak(text) {
    const utter = new SpeechSynthesisUtterance(text);
    utter.lang = "id-ID"; // Bahasa Indonesia
    utter.rate = 1;       // Kecepatan normal
    utter.pitch = 1;

    utter.onend = () => {
        isSpeaking = false;
        processQueue();
    };

    speechSynthesis.speak(utter);
}

function processQueue() {
    if (isSpeaking || audioQueue.length === 0) return;

    isSpeaking = true;
    const nextText = audioQueue.shift();
    speak(nextText);
}

function enqueueSpeak(text) {
    audioQueue.push(text);
    processQueue();
}

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
    
        // Efek blink
        const nomorEl = document.getElementById(map.nomor);
        nomorEl.classList.add("blink");
        setTimeout(() => nomorEl.classList.remove("blink"), 1200);
    
        // === TTS Browser ===
const kalimat = `Nomor antrian ${item.nomor}, menuju loket ${item.loket_id.replace("LKTO","")}, ${layanan.replace("POLI_","poli ")}.`;

enqueueSpeak(kalimat);

    });
    

});
