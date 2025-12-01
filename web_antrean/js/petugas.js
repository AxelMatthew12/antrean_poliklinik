// ===============================
// IMPORT FIREBASE
// ===============================
import { db } from "./firebase_configure.js";
import {
    ref,
    onValue,
    set,
    update,
    remove
} from "https://www.gstatic.com/firebasejs/12.6.0/firebase-database.js";

// ===============================
// VARIABEL GLOBAL
// ===============================
let isEdit = false;
let editKey = null;
let deleteKey = null;

// Load saat halaman dibuka
loadPetugasData();
setupEvents();

// ===============================
// FUNGSI GENERATE UID OTOMATIS
// ===============================
async function getNextUID() {
    try {
        const petugasRef = ref(db, "petugas");

        return new Promise((resolve) => {
            onValue(
                petugasRef,
                (snapshot) => {
                    let maxNum = 0;

                    snapshot.forEach((child) => {
                        const key = child.key; // contoh: UID_P005

                        if (!key.startsWith("UID_P")) return;

                        // Ambil angka → 005
                        const num = parseInt(key.replace("UID_P", ""));
                        if (num > maxNum) maxNum = num;
                    });

                    const nextNum = maxNum + 1;

                    // Buat UID baru: UID_P001
                    const nextUID = "UID_P" + String(nextNum).padStart(3, "0");

                    resolve(nextUID);
                },
                { onlyOnce: true }
            );
        });
    } catch (err) {
        alert("Gagal membuat UID Petugas!\n" + err.message);
    }
}


// ===============================
// LOAD DATA PETUGAS
// ===============================
function loadPetugasData() {
    const tableBody = document.getElementById("petugasTableBody");
    const petugasRef = ref(db, "petugas");

    onValue(
        petugasRef,
        (snapshot) => {
            tableBody.innerHTML = "";

            if (!snapshot.exists()) {
                tableBody.innerHTML = `
                    <tr>
                        <td colspan="5" style="text-align:center;">Belum ada data petugas.</td>
                    </tr>`;
                return;
            }

            snapshot.forEach((child) => {
                const key = child.key;
                const data = child.val();

                tableBody.innerHTML += `
                    <tr>
                        <td>${key}</td>
                        <td>${data.nama}</td>
                        <td>${data.email}</td>
                        <td>${data.loket_id}</td>
                        <td style="text-align:center;">
                            <button class="btn-success" onclick="editPetugas('${key}')">Edit</button>
                            <button class="btn-danger" onclick="deletePetugas('${key}')">Hapus</button>
                        </td>
                    </tr>`;
            });
        },
        (error) => {
            alert("Gagal memuat data petugas!\n" + error.message); // ALERT DITAMBAHKAN
        }
    );
}

// ===============================
// MODAL
// ===============================
const modalForm = document.getElementById("modalForm");
const modalDelete = document.getElementById("modalDelete");

// ===============================
// EVENT HANDLER
// ===============================
function setupEvents() {
    // Tombol Tambah
    document.getElementById("btnAdd").onclick = () => {
        isEdit = false;
        editKey = null;

        document.getElementById("formTitle").innerText = "Tambah Petugas";
        modalForm.style.display = "flex";

        // reset input
        document.getElementById("petugasNama").value = "";
        document.getElementById("petugasEmail").value = "";
        document.getElementById("petugasPassword").value = "";
        document.getElementById("petugasLoket").value = "";
    };

    // SAVE
    document.getElementById("btnSave").onclick = savePetugas;

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
        remove(ref(db, "petugas/" + deleteKey))
            .then(() => {
                alert("Petugas berhasil dihapus!"); // ALERT SUKSES
            })
            .catch((err) => {
                alert("Gagal menghapus petugas!\n" + err.message); // ALERT GAGAL
            });

        modalDelete.style.display = "none";
    };
}

// ===============================
// SAVE PETUGAS (EDIT / TAMBAH)
// ===============================
import { 
    getAuth, 
    createUserWithEmailAndPassword 
} from "https://www.gstatic.com/firebasejs/12.6.0/firebase-auth.js";

async function savePetugas() {
    const nama = document.getElementById("petugasNama").value.trim();
    const email = document.getElementById("petugasEmail").value.trim();
    const password = document.getElementById("petugasPassword").value.trim();
    const loket_id = document.getElementById("petugasLoket").value.trim();

    // Validasi input
    if (!nama || !email || !loket_id) {
        alert("Nama, Email, dan Loket wajib diisi!");
        return;
    }

    if (!isEdit && !password) {
        alert("Password wajib diisi saat tambah petugas!");
        return;
    }

    // Tentukan UID custom (UID_P001, dll)
    let uid = isEdit ? editKey : await getNextUID();

    // Data dasar untuk penyimpanan database
    const data = { nama, email, loket_id };

    const auth = getAuth();

    try {
        if (!isEdit) {
            // ===============================
            // REGISTER USER FIREBASE AUTH
            // ===============================
            const userCredential = await createUserWithEmailAndPassword(auth, email, password);
            const uidAuth = userCredential.user.uid;

            // Tambahkan UID auth ke data
            data.uid_auth = uidAuth;
        }

        // ===============================
        // SIMPAN / UPDATE REALTIME DATABASE
        // ===============================
        if (isEdit) {
            await update(ref(db, "petugas/" + uid), data);
            alert("Petugas berhasil diperbarui!");
        } else {
            await set(ref(db, "petugas/" + uid), data);
            alert("Petugas berhasil ditambahkan & Akun Auth dibuat!");
        }

        modalForm.style.display = "none";

    } catch (err) {
        alert("Gagal menyimpan data / Auth!\n" + err.message);
    }
}

// ===============================
// EDIT PETUGAS
// ===============================
window.editPetugas = (key) => {
    isEdit = true;
    editKey = key;

    modalForm.style.display = "flex";
    document.getElementById("formTitle").innerText = "Edit Petugas";

    onValue(
        ref(db, "petugas/" + key),
        (snap) => {
            const p = snap.val();

            document.getElementById("petugasNama").value = p.nama;
            document.getElementById("petugasEmail").value = p.email;
            document.getElementById("petugasLoket").value = p.loket_id;

            document.getElementById("petugasPassword").value = "";
        },
        { onlyOnce: true }
    );
};

// ===============================
// DELETE PETUGAS
// ===============================
window.deletePetugas = (key) => {
    deleteKey = key;
    modalDelete.style.display = "flex";
};
