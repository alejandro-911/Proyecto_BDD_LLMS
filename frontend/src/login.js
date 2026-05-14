import { login } from "./api.js";

// Escuchamos el envío del formulario
document.getElementById("form-login").addEventListener("submit", async function(evento) {
    // Evitamos que la página se recargue
    evento.preventDefault();
    console.log("formulario enviado");

    // Recogemos los valores del formulario
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;
     console.log("email:", email, "password:", password); 

    try {
        // Llamamos a la función login de api.js
        // que llama a rpc/login y nos devuelve el token JWT
        const respuesta = await login(email, password);
        console.log("Respuesta del login:", respuesta); 

        // Guardamos el token en localStorage para usarlo después
        // en las peticiones que necesiten autenticación
        localStorage.setItem("token", respuesta.token);

        // Mandamos al usuario al tablón de partidas
        window.location.replace("/tablon/");

    } catch (error) {
        // Si las credenciales son incorrectas mostramos el error
        // en el párrafo del HTML en vez de un alert
        console.log("Error:", error.message);
        document.getElementById("mensaje-error").textContent = error.message;
    }
});