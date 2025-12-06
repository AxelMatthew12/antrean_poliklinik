// ======================================================
// Import Supabase + Firebase
// ======================================================
import { supabase } from "./supabasse_configure.js";
import { db } from "./firebase_configure.js";
import {
  ref,
  onValue,
  set,
  update,
  remove,
} from "https://www.gstatic.com/firebasejs/12.6.0/firebase-database.js";

// ======================================================
// GLOBAL STATE
// ======================================================
let isEdit = false;
let editKey = "";
let existingImage = null;
let deleteKey = "";

// ======================================================
// INIT
// ======================================================
loadPoliData();
setupEvents();

// ======================================================
// LOAD DATA ke TABEL
// ======================================================
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
          <td style="text-align:center">
            ${
              data.gambar
                ? `<img src="${data.gambar}" style="width:80px; height:80px; object-fit:cover; border-radius:10px;" />`
                : `<span style="color:#aaa">Tidak ada gambar</span>`
            }
          </td>
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

// ======================================================
// SETUP MODAL EVENTS
// ======================================================
function setupEvents() {
  document.getElementById("btnAdd").onclick = () => {
    isEdit = false;
    editKey = "";
    existingImage = null;

    modalForm.style.display = "flex";
    document.getElementById("formTitle").innerText = "Tambah Poli";

    // Reset form
    document.getElementById("poliId").value = "";
    document.getElementById("poliNama").value = "";
    document.getElementById("poliDeskripsi").value = "";
    document.getElementById("imageInput").value = "";
    document.getElementById("previewImage").style.display = "none";
  };

  document.getElementById("btnSave").onclick = savePoli;
  document.getElementById("btnCancel").onclick = () =>
    (modalForm.style.display = "none");

  document.getElementById("btnDeleteCancel").onclick = () =>
    (modalDelete.style.display = "none");

  document.getElementById("btnDeleteOk").onclick = () => {
    remove(ref(db, "layanan/" + deleteKey));
    modalDelete.style.display = "none";
  };
}

// ======================================================
// UPLOAD IMAGE to SUPABASE
// ======================================================
async function uploadImage() {
  const file = document.getElementById("imageInput").files[0];
  if (!file) return null;

  const fileName = `${Date.now()}_${file.name}`;

  const { error } = await supabase.storage
    .from("images_poli")
    .upload(fileName, file, {
      contentType: file.type,
      upsert: false,
    });

  if (error) {
    console.error("Upload gagal:", error);
    alert("Gagal upload gambar.");
    return null;
  }

  const { data: urlData } = supabase.storage
    .from("images_poli")
    .getPublicUrl(fileName);

  return urlData.publicUrl;
}

// ======================================================
// SAVE / UPDATE DATA POLI
// ======================================================
async function savePoli() {
  const id = document.getElementById("poliId").value.trim();
  const nama = document.getElementById("poliNama").value.trim();
  const deskripsi = document.getElementById("poliDeskripsi").value.trim();

  if (!id || !nama) {
    alert("ID dan Nama wajib diisi!");
    return;
  }

  // Upload gambar jika user memilih file baru
  let imageUrl = existingImage;
  const newFile = document.getElementById("imageInput").files[0];

  if (newFile) {
    const uploadedUrl = await uploadImage();
    if (uploadedUrl) imageUrl = uploadedUrl;
  }

  const data = { id, nama, deskripsi, gambar: imageUrl };

  if (isEdit) {
    update(ref(db, "layanan/" + editKey), data);
  } else {
    set(ref(db, "layanan/" + id), data);
  }

  modalForm.style.display = "none";
}

// ======================================================
// EDIT POLI
// ======================================================
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

      existingImage = p.gambar || null;

      if (existingImage) {
        const preview = document.getElementById("previewImage");
        preview.src = existingImage;
        preview.style.display = "block";
      }
    },
    { onlyOnce: true }
  );
};

// ======================================================
// DELETE POLI (open modal)
// ======================================================
window.deletePoli = (key) => {
  deleteKey = key;
  modalDelete.style.display = "flex";
};
