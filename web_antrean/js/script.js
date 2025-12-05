// ===============================
// LOAD STATIC COMPONENTS
// ===============================
document.addEventListener("DOMContentLoaded", () => {
  loadComponent("components/sidebar.html", "sidebarContainer", () => {
    initSidebarToggle();
    initMenuEvents();
    loadPage("display"); // default halaman pertama
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
function loadPage(pageName) {
  const target = document.getElementById("content");

  fetch(`pages/${pageName}.html`)
    .then((res) => res.text())
    .then((html) => {
      target.innerHTML = html;

      // Jika halaman display diload -> load display_audio.js & display_queue.js
      if (pageName === "display") {
        import("./display_audio.js")
          .catch((err) => console.error("Gagal memuat display_audio.js:", err));
        import("./display_queue.js")
          .catch((err) => console.error("Gagal memuat display_queue.js:", err));
      } else if (pageName === "poli") {
        import("./poli.js")
          .catch((err) => console.error("Gagal memuat poli.js:", err));
      } else if (pageName === "petugas") {
        import("./petugas.js")
          .catch((err) => console.error("Gagal memuat petugas.js:", err));
      }
    })
    .catch((err) => {
      target.innerHTML = `<p style="padding:20px; color:red;">
          Halaman <strong>${pageName}</strong> tidak ditemukan.
      </p>`;
      console.error("Error loadPage:", err);
    });
}

// ===============================
// SIDEBAR MENU CLICK HANDLER
// ===============================
function initMenuEvents() {
  const items = document.querySelectorAll(".menu-item");

  items.forEach((item) => {
    item.addEventListener("click", () => {
      items.forEach((i) => i.classList.remove("active"));
      item.classList.add("active");

      const page = item.dataset.page;
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
    hour12: false
  });
  document.getElementById("date").innerText = now.toLocaleDateString("id-ID", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric"
  });
}

setInterval(updateTime, 1000);
updateTime();
