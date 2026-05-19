import { getClubs, getPistas, addReserva } from "./api.js";

// Cargamos los clubs al entrar en la página
async function cargarClubs() {
    const clubs = await getClubs();
    const selectClub = document.getElementById("club");

    clubs.forEach(function(club) {
        const option = document.createElement("option");
        option.value = club.id_club;
        option.textContent = club.nombre_club;
        selectClub.appendChild(option);
    });
}

// Cuando el usuario elige un club, cargamos sus pistas
document.getElementById("club").addEventListener("change", async function() {
    const idClub = this.value;
    console.log("Club seleccionado:", idClub); // 
    const selectPista = document.getElementById("pista");

    // Limpiamos las pistas anteriores
    selectPista.innerHTML = '<option value="">Selecciona una pista</option>';

    if (!idClub) return;

    // Filtramos las pistas por club
    const pistas = await getPistas();
        console.log("Pistas recibidas:", pistas); // 👈

    const pistasFiltradas = pistas.filter(function(p) {
        return p.id_club == idClub;
    });

    pistasFiltradas.forEach(function(pista) {
        const option = document.createElement("option");
        option.value = pista.id_pista;
        option.textContent = pista.nombre_pista;
        selectPista.appendChild(option);
    });
});

// Enviamos el formulario
document.getElementById("form-crear").addEventListener("submit", async function(evento) {
    evento.preventDefault();

    const token = localStorage.getItem("token");

    // Si no está logueado lo mandamos al login
    if (!token) {
        window.location.replace("/login/");
        return;
    }

    // Sacamos el id del usuario del token
    const payload = JSON.parse(atob(token.split(".")[1]));
    const email = payload.email;

    // Buscamos el id_usuario por email
    const apiUrl = import.meta.env.VITE_API_URL;
    const respuesta = await fetch(`${apiUrl}/usuarios?email_usuario=eq.${email}&select=id_usuario`, {
        headers: {
            "authorization": `Bearer ${token}`
        }
    });
    const datos = await respuesta.json();
    const idUsuario = datos[0].id_usuario;

    const reserva = {
        id_pista: parseInt(document.getElementById("pista").value),
        id_usuario_creador: idUsuario,
        fecha: document.getElementById("fecha").value,
        hora: document.getElementById("hora").value,
        nivel_partida: parseFloat(document.getElementById("nivel").value)
    };

    try {
        await addReserva(reserva);
        // Si se crea bien, volvemos al tablón
        window.location.replace("/tablon/");
    } catch (error) {
        document.getElementById("mensaje-error").textContent = "Error al crear la partida: " + error.message;
    }
});

// Arrancamos cargando los clubs
cargarClubs();