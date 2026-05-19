import { getReservas, deleteReserva } from "./api.js";

// Leemos el token y sacamos el email y el id usuario logueado
const token = localStorage.getItem("token");

// Función para leer el email del token JWT
function getEmailFromToken(token) {
    if(!token) {
        return null;
    }
    // EL token tiene 3 partes separadas por puntos, la del medio es el payload
    const payload = JSON.parse(atob(token.split(".")[1]));
    return payload.email;
}

const emailUsuario = getEmailFromToken(token);

// Función principal que carga y pinta las reservas 
async function cargarReservas() {
    const reservas = await getReservas();
    const lista = document.getElementById("lista-partidas");
    lista.innerHTML = ""; // Limpiamos ants de repintar

    reservas.forEach(function(reserva) {
        // contamos los huecos libres
        const juugadores = [reserva.id_jd2, reserva.id_jd3, reserva.id_jd4];
        const huecos = jugadores.filter(function(j) { return j === null; }).length;
        // ... falta
        // esta parte controlar y entender bien
    })

}