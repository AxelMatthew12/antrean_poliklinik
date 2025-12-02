// ===============================
// LOAD STATIC COMPONENTS
// ===============================
document.addEventListener("DOMContentLoaded", () => {
  loadComponent("components/sidebar.html", "sidebarContainer", () => {
    initSidebarToggle();
    initMenuEvents(); // <-- aktifkan klik menu setelah sidebar selesai dimuat
    loadPage("display"); // <-- default halaman pertama
  });

  loadComponent("components/header.html", "header");
  loadComponent("components/footer.html", "footer");
});

function loadComponent(file, targetId, callback = null) {
  fetch(file)
    .then((res) => res.text())
    .then((html) => {
      document.getElementById(targetId).innerHTML = html;

      if (callback) callback();
    });
}

// ===============================
// SIDEBAR TOGGLE
// ===============================
function initSidebarToggle() {
  const toggleBtn = document.getElementById("toggleBtn");
  const sidebar = document.getElementById("sidebar");
  const mainContent = document.querySelector(".main-content");

  if (toggleBtn) {
    toggleBtn.addEventListener("click", () => {
      sidebar.classList.toggle("collapsed");
      mainContent.classList.toggle("shifted");
    });
  }
}

// ===============================
// DYNAMIC PAGE LOADER (SPA)
// ===============================
// function loadPage(pageName) {
//     const target = document.getElementById("content");

//     fetch(`pages/${pageName}.html`)
//         .then(res => res.text())
//         .then(html => {
//             target.innerHTML = html;
//         })
//         .catch(err => {
//             target.innerHTML = `<p style="padding:20px; color:red;">
//                 Halaman <strong>${pageName}</strong> tidak ditemukan.
//             </p>`;
//         });
// }

// modifikasi loadpage
function loadPage(pageName) {
  const target = document.getElementById("content");

  fetch(`pages/${pageName}.html`)
    .then((res) => res.text())
    .then((html) => {
      target.innerHTML = html;

      // Jika halaman poli diload → load poli.js
      if (pageName === "poli") {
        if (pageName === "poli") {
          import("./poli.js");
        }
      }
      // Jika halaman petugas diload → load petugas.js
      if (pageName === "petugas") {
        if (pageName === "petugas") {
          import("./petugas.js");
        }
      }
    })
    .catch((err) => {
      target.innerHTML = `<p style="padding:20px; color:red;">
                Halaman <strong>${pageName}</strong> tidak ditemukan.
            </p>`;
    });
}

// ===============================
// SIDEBAR MENU CLICK HANDLER
// ===============================
function initMenuEvents() {
  const items = document.querySelectorAll(".menu-item");

  items.forEach((item) => {
    item.addEventListener("click", () => {
      // Hapus class active di semua menu
      items.forEach((i) => i.classList.remove("active"));

      // Tambahkan active ke menu yang diklik
      item.classList.add("active");

      // Ambil nama halaman dari data-page=""
      const page = item.dataset.page;

      // Load halaman
      loadPage(page);
    });
  });
}

// ===============================
// UPDATE TIME
// ===============================
function updateTime() {
  const now = new Date();
  document.getElementById("time").innerText = now.toLocaleTimeString("id-ID", {
    hour12: false,
  });
  document.getElementById("date").innerText = now.toLocaleDateString("id-ID", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}

setInterval(updateTime, 1000);
updateTime();
