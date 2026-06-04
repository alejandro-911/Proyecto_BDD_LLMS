const apiUrl = import.meta.env.VITE_API_URL;
const token = localStorage.getItem("token");

// Si no hay token o no es club_admin, mandamos al login
if (!token) {
    window.location.replace("/login/");
}

// Leemos el email del club desde el token JWT
const payload = JSON.parse(atob(token.split(".")[1]));
const emailClub = payload.email;
const rol = payload.role;

if (rol !== "club_admin") {
    window.location.replace("/login/");
}

// Botón de cerrar sesión
document.getElementById("btn-logout").addEventListener("click", function() {
    localStorage.removeItem("token");
    window.location.replace("/login/");
});

// Cargamos las pistas del club para el desplegable del formulario
async function cargarPistasDelClub() {
    // Primero obtenemos el id_club del club logueado
    const respClub = await fetch(`${apiUrl}/clubs?email_admin=eq.${emailClub}&select=id_club,nombre_club`, {
        headers: { "Authorization": `Bearer ${token}` }
    });
    const clubs = await respClub.json();
    const club = clubs[0];

    // Luego obtenemos sus pistas
    const respPistas = await fetch(`${apiUrl}/pista?id_club=eq.${club.id_club}&select=id_pista,nombre_pista`, {
        headers: { "Authorization": `Bearer ${token}` }
    });
    const pistas = await respPistas.json();

    // Rellenamos el desplegable
    const select = document.getElementById("pista");
    pistas.forEach(function(pista) {
        const option = document.createElement("option");
        option.value = pista.id_pista;
        option.textContent = pista.nombre_pista;
        select.appendChild(option);
    });

    return club.id_club;
}

// Cargamos las reservas de las pistas del club
async function cargarReservas(idClub) {
    // Traemos las reservas filtrando por las pistas del club
    const respuesta = await fetch(
        `${apiUrl}/reservas?select=*,pista(nombre_pista)&pista.id_club=eq.${idClub}`,
        { headers: { "Authorization": `Bearer ${token}` } }
    );
    const reservas = await respuesta.json();
    const lista = document.getElementById("lista-reservas");
    lista.innerHTML = "";

    reservas.forEach(function(reserva) {
        const div = document.createElement("div");
        div.innerHTML = `
            <p><strong>${reserva.pista.nombre_pista}</strong></p>
            <p>Fecha: ${reserva.fecha} | Hora: ${reserva.hora}</p>
            <p>Origen: ${reserva.origen === "club" ? "📞 Reserva telefónica" : "📱 Reserva desde la app"}</p>
        `;

        // Botón cancelar reserva
        const btnCancelar = document.createElement("button");
        btnCancelar.textContent = "Cancelar reserva";
        btnCancelar.addEventListener("click", async function() {
            await fetch(`${apiUrl}/reservas?id_reserva=eq.${reserva.id_reserva}`, {
                method: "DELETE",
                headers: { "Authorization": `Bearer ${token}` }
            });
            div.remove();
        });
        div.appendChild(btnCancelar);
        lista.appendChild(div);
    });
}

// Formulario de reserva manual (llamada telefónica)
document.getElementById("form-reserva-manual").addEventListener("submit", async function(evento) {
    evento.preventDefault();

    const reserva = {
        id_pista: parseInt(document.getElementById("pista").value),
        id_usuario_creador: 1, // reserva del club, usamos un id fijo
        fecha: document.getElementById("fecha").value,
        hora: document.getElementById("hora").value,
        nivel_partida: 0,
        origen: "club" // marcamos que viene del club
    };

    try {
        await fetch(`${apiUrl}/reservas`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`,
                "Prefer": "return=minimal"
            },
            body: JSON.stringify(reserva)
        });
        document.getElementById("mensaje-error").textContent = "Reserva añadida correctamente";
        // Recargamos las reservas para ver el cambio
        cargarReservas(idClub);
    } catch (error) {
        document.getElementById("mensaje-error").textContent = "Error al añadir la reserva";
    }
});

// Arrancamos cargando las pistas y las reservas
const idClub = await cargarPistasDelClub();
cargarReservas(idClub);