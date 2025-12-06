import { db } from "./firebase_configure.js";
import { ref, onValue } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-database.js";

// --- AUDIO ---
const bell = new Audio("sounds/bell.mp3");

function playBell() {
    bell.play();
}

// --- TTS OPTIONAL ---
function speak(text) {
    const speech = new SpeechSynthesisUtterance(text);
    speech.lang = "id-ID";
    speech.rate = 1;
    window.speechSynthesis.speak(speech);
}

function formatNomorForTTS(nomor) {
    const huruf = nomor.charAt(0);
    const angka = nomor.substring(1).split("").join(" ");
    return `${huruf} ${angka}`;
}

let lastCalled = "";

// === FIREBASE LISTENER LOKET 1 ===
onValue(ref(db, "antrian/loket1/current"), (snap) => {
    const nomor = snap.val();

    const el = document.getElementById("loket1-current");
    if (el) el.innerText = nomor;

    if (lastCalled !== nomor) {
        lastCalled = nomor;
        playBell();
        setTimeout(() => {
            speak(`Nomor antrian ${formatNomorForTTS(nomor)}, menuju loket satu`);
        }, 1200);
    }
});