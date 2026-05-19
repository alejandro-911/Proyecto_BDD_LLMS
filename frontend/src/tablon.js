import { getReservas, deleteReserva } from "./api.js";

// Leemos el token y sacamos el email y el id del usuario logueado
const token = localStorage.getItem("token");

// Función para leer el email del token JWT
function getEmailFromToken(token) {
    if (!token) return null;
    // El token tiene 3 partes separadas por puntos, la del medio es el payload
    const payload = JSON.parse(atob(token.split(".")[1]));
    return payload.email;
}

const emailUsuario = getEmailFromToken(token);

// Función principal que carga y pinta las reservas
async function cargarReservas() {
    const reservas = await getReservas();
    const lista = document.getElementById("lista-partidas");
    lista.innerHTML = ""; // Limpiamos antes de repintar

    reservas.forEach(function(reserva) {
        // Contamos los huecos libres
        const jugadores = [reserva.id_jd2, reserva.id_jd3, reserva.id_jd4];
        const huecos = jugadores.filter(function(j) { return j === null; }).length;

        // Creamos la tarjeta de la partida
        const div = document.createElement("div");
        div.innerHTML = `
            <h3>${reserva.pista.clubs.nombre_club} - ${reserva.pista.nombre_pista}</h3>
            <p>Fecha: ${reserva.fecha} | Hora: ${reserva.hora}</p>
            <p>Nivel: ${reserva.nivel_partida}</p>
            <p>Huecos libres: ${huecos}/3</p>
        `;

        // Botón cancelar — solo si eres el creador
        // Por ahora lo dejamos preparado, lo conectaremos cuando tengamos
        // la página de crear partida y sepamos el id del usuario

        lista.appendChild(div);
    });
}

// Cargamos las partidas al entrar
cargarReservas();

// Polling: recargamos cada 5 segundos
setInterval(cargarReservas, 5000);