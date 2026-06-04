import { signupClub } from "./api.js";

document.getElementById("form-registro-club").addEventListener("submit", async function(evento) {
    evento.preventDefault();
    console.log("fromulario enviado");

    const nombre_club = document.getElementById("nombre_club").value;
    const ciudad = document.getElementById("ciudad").value;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    try {
        await signupClub(email, password, nombre_club, ciudad);
        console.log("registro ok");
        window.location.replace("/login/");
    } catch (error) {
        console.log("error:", error.message);
        document.getElementById("mensaje-error").textContent = error.message;
    }
});