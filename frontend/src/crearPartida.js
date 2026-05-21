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
        //console.log("Pistas recibidas:", pistas); // 👈

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
        // Empezamos con un mensaje genérico por defecto
        // si algo falla antes de llegar al mensaje específico, se mostrará este
        // usamos let porque el valor de mensaje puede cambiar (empieza siendo genérico)
        let mensaje = "Error al crear la partida";

        // Comprobamos ue el error tiene mensaje
        // (por si acaso llega error vacío o raro)
        // Intentamos sacar el mensaje del error de PostgreSQL
        if(error.message) {

            // error.message llega así como texto:
            // '{"code":"P0001","message":"La pista ya está ocupada en ese horario"}'
            // JSON.parse lo convierte en un objeto JavaScript para poder leer sus propiedades
            const errObj = JSON.parse(error.message);

            // Ahora errObj es un objeto normal y podemos leer errObj.code y errObj.message
            // P0001 → error lanzado por el trigger de solapamiento
            // 23505 → error lanzado por la constraint UNIQUE de la BDD
            // 23505 es pista ya ocupada exacta
            if (errObj.code === "P0001" || errObj.code === "23505") {
                // Sobreescribimos el mensaje genérico con el mensaje específico de PostgreSQL
                mensaje = errObj.message;
            }
        }
        // Mostramos el mensaje en el párrafo del HTML
        // Será el específico si era un error conocido, o el genérico si no
        document.getElementById("mensaje-error").textContent = mensaje;
    
    }
});

// Arrancamos cargando los clubs
cargarClubs();