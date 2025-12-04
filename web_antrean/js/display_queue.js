// js/display_queue.js - Versi kompak untuk 1 layar
import { initializeApp } from "firebase/app";
import { getDatabase, ref, onValue } from "firebase/database";

// Konfigurasi Firebase
const firebaseConfig = {
    databaseURL: "https://antrian-rumah-sakit-pbl-default-rtdb.asia-southeast1.firebasedatabase.app/"
    // Tambahkan config lainnya jika perlu
};

// Inisialisasi Firebase
const app = initializeApp(firebaseConfig);
const db = getDatabase(app);

// State untuk mencegah notifikasi ganda
let lastCallTimestamp = 0;
let isSpeaking = false;

// ====================================================================
// 🎧 FUNGSI NOTIFIKASI AUDIO
// ====================================================================
function playNotification(nomor, loket) {
    if (!nomor || nomor === '-' || isSpeaking) return;
    
    if ('speechSynthesis' in window) {
        speechSynthesis.cancel();
        
        // Pesan yang lebih panjang untuk perhatian lebih
        const message = `Nomor antrian ${nomor}, harap menuju ${loket}. Nomor antrian ${nomor}, harap menuju ${loket}.`;
        const utterance = new SpeechSynthesisUtterance(message);

        utterance.lang = 'id-ID';
        utterance.volume = 1;
        utterance.rate = 0.85;

        isSpeaking = true;

        utterance.onend = () => {
            isSpeaking = false;
        };

        utterance.onerror = () => {
            isSpeaking = false;
        };

        speechSynthesis.speak(utterance);

        console.log(`🔊 PANGGILAN AUDIO: ${message}`);
    }
}

// ====================================================================
// 🕒 FUNGSI UPDATE WAKTU REAL-TIME
// ====================================================================
function updateDateTime() {
    const now = new Date();
    
    // Format waktu HH:MM:SS
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
    const time = `${hours}:${minutes}:${seconds}`;

    // Format tanggal Indonesia
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
                    'Agustus', 'September', 'Oktober', 'November', 'Desember'];

    const day = days[now.getDay()];
    const date = now.getDate();
    const month = months[now.getMonth()];
    const year = now.getFullYear();
    const dateStr = `${day}, ${date} ${month} ${year}`;
    
    // Update elemen waktu
    const timeElement = document.getElementById('currentTime');
    const dateElement = document.getElementById('currentDate');
    
    if (timeElement) timeElement.textContent = time;
    if (dateElement) dateElement.textContent = dateStr;
}

// ====================================================================
// 💫 FUNGSI HIGHLIGHT UPDATE
// ====================================================================
function highlightElement(elementId) {
    const element = document.getElementById(elementId);
    if (element) {
        element.classList.remove('highlight');
        void element.offsetWidth; // Trigger reflow
        element.classList.add('highlight');
        
        // Tambahkan efek blink untuk panggilan baru
        if (elementId === 'mainNumber') {
            element.classList.add('blink');
            setTimeout(() => {
                element.classList.remove('blink');
            }, 3000);
        }
    }
}

// ====================================================================
// 📡 FUNGSI UPDATE DATA DARI FIREBASE
// ====================================================================
function updateDisplayData(displayData) {
    if (!displayData) return;
    
    // 1. UPDATE ANTRIAN SEDANG DIPANGGIL (UTAMA)
    if (displayData.current_call) {
        const current = displayData.current_call;
        const mainNumber = document.getElementById('mainNumber');
        const mainLoket = document.getElementById('mainLoket');
        
        if (mainNumber && mainLoket) {
            if (mainNumber.textContent !== current.nomor) {
                mainNumber.textContent = current.nomor;
                highlightElement('mainNumber');
            }
            
            if (mainLoket.textContent !== current.loket) {
                mainLoket.textContent = current.loket;
                highlightElement('mainLoket');
                
                // Cek jika ini panggilan baru
                if (current.timestamp && current.timestamp > lastCallTimestamp) {
                    playNotification(current.nomor, current.loket);
                    lastCallTimestamp = current.timestamp;
                }
            }
        }
    }
    
    // 2. UPDATE DATA PER POLI
    const polis = ['umum', 'gigi', 'anak', 'bedah'];
    
    polis.forEach(poli => {
        if (displayData[poli]) {
            const data = displayData[poli];
            
            // Update antrian sekarang
            const sekarangEl = document.getElementById(`${poli}-sekarang`);
            const loketSekarangEl = document.getElementById(`${poli}-loket-sekarang`);

            if (sekarangEl && data.sekarang) {
                sekarangEl.textContent = data.sekarang.nomor || '-';
            }
            if (loketSekarangEl && data.sekarang) {
                loketSekarangEl.textContent = data.sekarang.loket || 'LOKET -';
            }

            // Update antrian selanjutnya
            const selanjutnyaEl = document.getElementById(`${poli}-selanjutnya`);
            const loketSelanjutnyaEl = document.getElementById(`${poli}-loket-selanjutnya`);
            
            if (selanjutnyaEl && data.selanjutnya) {
                selanjutnyaEl.textContent = data.selanjutnya.nomor || '-';
            }
            if (loketSelanjutnyaEl && data.selanjutnya) {
                loketSelanjutnyaEl.textContent = data.selanjutnya.loket || 'LOKET -';
            }
        }
    });
}

// ====================================================================
// 📡 LISTENER FIREBASE REALTIME
// ====================================================================
function setupFirebaseListener() {
    const displayRef = ref(db, 'display');
    
    onValue(displayRef, (snapshot) => {
        const displayData = snapshot.val();
        console.log('📡 Data dari Firebase:', displayData);
        
        if (displayData) {
            updateDisplayData(displayData);
        } else {
            console.warn('⚠ Tidak ada data display di Firebase');
            // Tampilkan data placeholder
            showPlaceholderData();
        }
    }, (error) => {
        console.error('❌ Firebase read error:', error);
        showPlaceholderData();
    });
}

// ====================================================================
// 📏 FUNGSI ADAPTASI UKURAN LAYAR
// ====================================================================
function adaptDisplayForScreen() {
    const viewportHeight = window.innerHeight;
    const viewportWidth = window.innerWidth;
    
    console.log(`📏 Viewport: ${viewportWidth}x${viewportHeight}px`);
    
    // Sesuaikan ukuran font berdasarkan tinggi layar
    const mainNumber = document.querySelector('.main-number');
    if (mainNumber) {
        if (viewportHeight < 700) {
            mainNumber.style.fontSize = '55px';
        } else if (viewportHeight < 900) {
            mainNumber.style.fontSize = '65px';
        } else {
            mainNumber.style.fontSize = '70px';
        }
    }
    
    // Sesuaikan padding container
    const container = document.querySelector('.display-container');
    if (container) {
        if (viewportHeight < 600) {
            container.style.padding = '3px';
            container.style.gap = '4px';
        } else if (viewportHeight < 800) {
            container.style.padding = '5px';
            container.style.gap = '8px';
        } else {
            container.style.padding = '10px';
            container.style.gap = '10px';
        }
    }
}

// ====================================================================
// 📋 TAMPILKAN DATA PLACEHOLDER
// ====================================================================
function showPlaceholderData() {
    console.log('📋 Menampilkan data placeholder');
    
    const placeholderData = {
        current_call: {
            nomor: 'A012',
            loket: 'LOKET 3',
            timestamp: Date.now()
        },
        umum: {
            sekarang: { nomor: 'U007', loket: 'LOKET 1' },
            selanjutnya: { nomor: 'U008', loket: 'LOKET 1' }
        },
        gigi: {
            sekarang: { nomor: 'G005', loket: 'LOKET 2' },
            selanjutnya: { nomor: 'G006', loket: 'LOKET 2' }
        },
        anak: {
            sekarang: { nomor: 'A012', loket: 'LOKET 3' },
            selanjutnya: { nomor: 'A013', loket: 'LOKET 3' }
        },
        bedah: {
            sekarang: { nomor: 'B003', loket: 'LOKET 4' },
            selanjutnya: { nomor: 'B004', loket: 'LOKET 4' }
        }
    };
    
    updateDisplayData(placeholderData);
}

// ====================================================================
// 🚀 INISIALISASI
// ====================================================================
document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 Display Antrian dimuat dalam mode kompak');
    
    // Aktifkan mode display
    document.body.classList.add('display-mode');
    
    // 0. Adaptasi ukuran layar
    adaptDisplayForScreen();
    window.addEventListener('resize', adaptDisplayForScreen);
    
    // 1. Update waktu setiap detik
    updateDateTime();
    setInterval(updateDateTime, 1000);
    
    // 2. Setup Firebase listener
    setupFirebaseListener();
    
    // 3. Load data awal setelah delay kecil
    setTimeout(() => {
        showPlaceholderData();
        console.log('✅ Data placeholder dimuat');
    }, 500);
    
    // 4. Auto-refresh untuk adaptasi layar
    setInterval(() => {
        adaptDisplayForScreen();
    }, 30000);
});

// ====================================================================
// 🎵 FUNGSI TEST
// ====================================================================
window.testNotification = function() {
    playNotification('TEST01', 'LOKET 1');
    console.log('🔊 Test notification diputar');
};

window.toggleFullscreen = function() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.log(`Error fullscreen: ${err.message}`);
        });
    } else {
        if (document.exitFullscreen) {
            document.exitFullscreen();
        }
    }
};