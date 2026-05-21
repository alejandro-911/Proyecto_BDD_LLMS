import { getReservas, deleteReserva } from "./api.js";

// Si no hay token, mandamos al login 
const token = localStorage.getItem("token");
// Comprobamos antes de cargar nada 
if (!token) {
    window.location.replace("/login/");
}
const apiUrl = import.meta.env.VITE_API_URL;

// Función para leer el email del token JWT
function getEmailFromToken(token) {
    if (!token) return null;
    const payload = JSON.parse(atob(token.split(".")[1]));
    return payload.email;
}

const emailUsuario = getEmailFromToken(token);

// Obtenemos el id_usuario del usuario logueado
async function getIdUsuario() {
    if (!token || !emailUsuario) return null;
    const respuesta = await fetch(`${apiUrl}/usuarios?email_usuario=eq.${emailUsuario}&select=id_usuario`, {
        headers: { "Authorization": `Bearer ${token}` }
    });
    const datos = await respuesta.json();
    return datos[0]?.id_usuario;
}

// Función principal que carga y pinta las reservas
async function cargarReservas() {
    const reservas = await getReservas();
    console.log("Resrvas recibidas:", reservas);
    const idUsuario = await getIdUsuario();
    const lista = document.getElementById("lista-partidas");
    lista.innerHTML = "";

    reservas.forEach(function(reserva) {
        // Contamos los huecos libres
        const jugadores = [reserva.id_jd2, reserva.id_jd3, reserva.id_jd4];
        const huecos = jugadores.filter(function(j) { return j === null; }).length;

        const div = document.createElement("div");
        div.innerHTML = `
            <h3>${reserva.pista.clubs.nombre_club} - ${reserva.pista.nombre_pista}</h3>
            <p>Fecha: ${reserva.fecha} | Hora: ${reserva.hora}</p>
            <p>Nivel: ${reserva.nivel_partida}</p>
            <p>Huecos libres: ${huecos}/3</p>
        `;

        // Botón cancelar — solo si eres el creador
        if (idUsuario && reserva.id_usuario_creador === idUsuario) {
            const btnCancelar = document.createElement("button");
            btnCancelar.textContent = "Cancelar partida";
            btnCancelar.addEventListener("click", async function() {
                try {
                    await deleteReserva(reserva.id_reserva);
                    div.remove();
                } catch (error) {
                    alert("Error al cancelar: " + error.message);
                }
            });
            div.appendChild(btnCancelar);
        }

        // Botón unirse — solo si hay huecos y no eres el creador
        const yaApuntado = [reserva.id_jd2, reserva.id_jd3, reserva.id_jd4].includes(idUsuario);

       if (idUsuario && reserva.id_usuario_creador !== idUsuario && huecos > 0 && !yaApuntado) {
            const btnUnirse = document.createElement("button");
            btnUnirse.textContent = "Unirse";
            btnUnirse.addEventListener("click", async function() {
                // Buscamos el primer hueco libre
                const hueco = jugadores.indexOf(null);
                const columnas = ["id_jd2", "id_jd3", "id_jd4"];
                const columna = columnas[hueco];

                try {
                    await fetch(`${apiUrl}/reservas?id_reserva=eq.${reserva.id_reserva}`, {
                        method: "PATCH",
                        headers: {
                            "Content-Type": "application/json",
                            "Authorization": `Bearer ${token}`
                        },
                        body: JSON.stringify({ [columna]: idUsuario })
                    });
                    // Recargamos para ver el cambio
                    cargarReservas();
                } catch (error) {
                    alert("Error al unirse: " + error.message);
                }
            });
            div.appendChild(btnUnirse);
        }
        // BOtón abandonar - solo si estás apuntado y no eres el creador
        if(idUsuario && reserva.id_usuario_creador !== idUsuario && yaApuntado) {
            const btnAbandonar = document.createElement("button");
            btnAbandonar.textContent = "abandonar";
            btnAbandonar.addEventListener("click", async function() {
                //Buscamos en que hueco está el usuario
                const columnas = ["id_jd2", "id_jd3", "id_jd4"];
                const valores = [reserva.id_jd2, reserva.id_jd3, reserva.id_jd4];
                const indice = valores.indexOf(idUsuario);
                const columna = columnas[indice];

                try {
                    await fetch(`${apiUrl}/reservas?id_reserva=eq.${reserva.id_reserva}`, {
                        method: "PATCH",
                        headers: {
                            "Content-Type": "application/json",
                            "Authorization": `Bearer ${token}`
                        },
                        // Ponemos el hueco a null para lierarlo
                        body: JSON.stringify({ [columna]: null })
                    });
                    cargarReservas();
                } catch (error) {
                    alert("Error al abandonar: " + error.message);
                }
            });
            div.appendChild(btnAbandonar);
            
        }

        lista.appendChild(div);
    });
}
// cargamos las resrevas al entrar
cargarReservas();
// polling que refresca cada 5 segundos
setInterval(cargarReservas, 5000);