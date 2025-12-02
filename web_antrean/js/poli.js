// Import Firebase
import { db } from "./firebase_configure.js";
import {
  ref,
  onValue,
  set,
  update,
  remove,
} from "https://www.gstatic.com/firebasejs/12.6.0/firebase-database.js";

let isEdit = false;
let editKey = "";

// Tunggu halaman poli.html selesai dimuat
// document.addEventListener("DOMContentLoaded", () => {
//     loadPoliData();
//     setupEvents();
// });
loadPoliData();
setupEvents();

// ================================
// LOAD DATA POLI
// ================================
function loadPoliData() {
  const tableBody = document.getElementById("poliTableBody");
  const layananRef = ref(db, "layanan");

  onValue(layananRef, (snapshot) => {
    tableBody.innerHTML = "";

    if (!snapshot.exists()) {
      tableBody.innerHTML = `<tr><td colspan="4">Belum ada data poli.</td></tr>`;
      return;
    }

    snapshot.forEach((child) => {
      const key = child.key;
      const data = child.val();

      tableBody.innerHTML += `
                <tr>
                    <td>${data.id}</td>
                    <td>${data.nama}</td>
                    <td>${data.deskripsi}</td>
                    <td>
                        <div class="action-buttons">
                            <button class="btn-success" onclick="editPoli('${key}')">Edit</button>
                            <button class="btn-danger" onclick="deletePoli('${key}')">Hapus</button>
                        </div>
                    </td>
                </tr>
            `;
    });
  });
}

// ======== SEMUA MODAL ========
const modalForm = document.getElementById("modalForm");
const modalDelete = document.getElementById("modalDelete");

isEdit = false;
editKey = null;
let deleteKey = null;

// =============================
// EVENT HANDLER
// =============================
function setupEvents() {
  // OPEN ADD MODAL
  document.getElementById("btnAdd").onclick = () => {
    isEdit = false;
    modalForm.style.display = "flex";
    document.getElementById("formTitle").innerText = "Tambah Poli";

    // Reset form
    document.getElementById("poliId").value = "";
    document.getElementById("poliNama").value = "";
    document.getElementById("poliDeskripsi").value = "";
  };

  // SAVE
  document.getElementById("btnSave").onclick = savePoli;

  // CANCEL FORM
  document.getElementById("btnCancel").onclick = () => {
    modalForm.style.display = "none";
  };

  // CANCEL DELETE
  document.getElementById("btnDeleteCancel").onclick = () => {
    modalDelete.style.display = "none";
  };

  // CONFIRM DELETE
  document.getElementById("btnDeleteOk").onclick = () => {
    const poliRef = ref(db, "layanan/" + deleteKey);
    remove(poliRef);
    modalDelete.style.display = "none";
  };
}

// =============================
// SAVE POLI
// =============================
function savePoli() {
  const id = document.getElementById("poliId").value;
  const nama = document.getElementById("poliNama").value;
  const deskripsi = document.getElementById("poliDeskripsi").value;

  if (!id || !nama) {
    alert("ID dan Nama wajib diisi!");
    return;
  }

  const data = { id, nama, deskripsi };

  if (isEdit) {
    update(ref(db, "layanan/" + editKey), data);
  } else {
    set(ref(db, "layanan/" + id), data);
  }

  modalForm.style.display = "none";
}

// =============================
// EDIT
// =============================
window.editPoli = (key) => {
  isEdit = true;
  editKey = key;

  modalForm.style.display = "flex";
  document.getElementById("formTitle").innerText = "Edit Poli";

  onValue(
    ref(db, "layanan/" + key),
    (snap) => {
      const p = snap.val();
      document.getElementById("poliId").value = p.id;
      document.getElementById("poliNama").value = p.nama;
      document.getElementById("poliDeskripsi").value = p.deskripsi;
    },
    { onlyOnce: true }
  );
};

// =============================
// DELETE (open modal)
// =============================
window.deletePoli = (key) => {
  deleteKey = key;
  modalDelete.style.display = "flex";
};
