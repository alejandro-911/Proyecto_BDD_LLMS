import { signup } from "./api.js";
// Escuchamos el envío del formulario
document.getElementById('form-registro').addEventListener('submit', async function(evento) {
    // Evitamos que la página se recargue
    evento.preventDefault();

    // Recogemos los valores del formulario
    const nombre = document.getElementById('nombre').value;
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const nivel = document.getElementById('nivel').value;

    //console.log('Datos del formulario:', nombre, email, nivel);
    // comprobamos que el usuario ha selecionado un nivel
    if(!nivel) {
        alert("Por favor selecciona tu nivel de juego");
        return;
    }

    // Llamamos a la función signup de api.js
    // que se encarga de llamar a la BDD
    try {
        await signup(email, password, nombre, nivel);
        // Si todo va bien, mandamos al usuario a la página de login
        window.location.replace("/login/");
    } catch (error) {
        // Si algo falla, mostramos el error
        alert(error.message);
    }
});

// La diferencia principal con lo que había antes es que ya no hacemos el fetch a mano aquí
// eso lo hace api.js 
// Este archivo solo recoge los datos del formulario y llama a signup().

// window, es el objeto global del navegador
// representa la ventana/pestaña entera
// tiene métodos útiles como alert, console.log, localStorage.getItem(...)

// En este caso, window.location.replace("/login/") le dice al navegador
// lleva al usuario a la página /login/. 
// parecido a window.location.href = "/login/" pero replace() no guarda la actual en el historial, así que si el usuario pulsa "atrás",
// no vuelve al formulario de registro (tiene sentido ya que ya se ha registrado)
