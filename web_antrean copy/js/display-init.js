// js/display-init.js
// Inisialisasi khusus untuk mode display fullscreen

// Fungsi untuk membuat display responsif
function initializeCompactDisplay() {
    // Hapus elemen yang tidak diperlukan untuk display
    const sidebar = document.getElementById('sidebarContainer');
    const header = document.getElementById('header');
    const footer = document.getElementById('footer');
    
    if (sidebar) sidebar.style.display = 'none';
    if (header) header.style.display = 'none';
    if (footer) footer.style.display = 'none';
    
    // Set main content full width
    const mainContent = document.querySelector('.main-content');
    if (mainContent) {
        mainContent.style.marginLeft = '0';
        mainContent.style.width = '100%';
        mainContent.style.padding = '0';
    }
    
    // Force fullscreen mode
    document.body.style.overflow = 'hidden';
    document.documentElement.style.overflow = 'hidden';
    
    // Tambahkan class untuk mode display
    document.body.classList.add('display-mode');
    
    console.log('🎯 Mode display kompak diaktifkan');
}

// Jalankan saat DOM siap
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeCompactDisplay);
} else {
    initializeCompactDisplay();
}

// Tambahkan ke style.css
/*
.display-mode {
    overflow: hidden !important;
}

.display-mode body {
    background: #f0f2f5;
}

.display-mode .main-content {
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
*/