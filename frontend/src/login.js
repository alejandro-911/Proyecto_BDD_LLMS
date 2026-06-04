import { login } from "./api.js";

// Escuchamos el envío del formulario
document.getElementById("form-login").addEventListener("submit", async function(evento) {
    // Evitamos que la página se recargue al enviar el formulario
    evento.preventDefault();

    // Recogemos los valores del formulario
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    try {
        // Llamamos a la función login de api.js
        // que hace un POST a rpc/login y nos devuelve el token JWT
        const respuesta = await login(email, password);

        // Guardamos el token en localStorage para usarlo después
        // en las peticiones que necesiten autenticación
        localStorage.setItem("token", respuesta.token);

        // Leemos el rol del usuario desde el token JWT
        // el token tiene 3 partes separadas por puntos: cabecera.payload.firma
        // atob() decodifica la parte del medio (payload) que está en base64
        // y JSON.parse() lo convierte en un objeto JavaScript
        const payload = JSON.parse(atob(respuesta.token.split(".")[1]));
        const rol = payload.role;
        console.log("payload:", payload);
        console.log("rol:", rol);
        console.log("payload completo:", payload);

        // Redirigimos según el rol:
        // los clubs van a su panel de gestión
        // los jugadores van al tablón de partidas
        if (rol === "club_admin") {
            window.location.replace("/panel-club/");
        } else {
            window.location.replace("/tablon/");
        }

    } catch (error) {
        // Si las credenciales son incorrectas mostramos el error
        // en el párrafo del HTML en vez de un alert
        document.getElementById("mensaje-error").textContent = error.message;
    }
});