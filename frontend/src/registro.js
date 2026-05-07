document.getElementById('form-registro').addEventListener('submit', function(evento) {
    evento.preventDefault();

    const nombre = document.getElementById('nombre').value;
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const nivel = document.getElementById('nivel').value;

    //console.log('Datos del formulario:', nombre, email, nivel);
    fetch('http://localhost:3000/usuarios', {
        method: 'POST', 
        headers: {
            'Content-Type': 'application/json'

        },
        body: JSON.stringify({
            nombre_usuario: nombre,
            email_usuario: email,
            password_usuario: password,
            nivel: nivel
        })
    })
    .then(function(respuesta) {
        if (respuesta.ok) {
            alert('Usuario registrado correctamente')
        } else {
            alert('Error al registrar el usuario');
        }
    })
    .catch(function(error){
        console.error('Error:', error)
    });

});