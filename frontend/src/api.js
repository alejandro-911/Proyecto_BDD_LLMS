const apiUrl = import.meta.env.VITE_API_URL;

// --- AUTENTICACIÓN ---

export async function login(email, pass) {
  const response = await fetch(`${apiUrl}/rpc/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, pass }),
  });
  if (!response.ok) throw new Error("Credenciales incorrectas");
  return await response.json(); // Devuelve el token JWT
}

/*
 Adaptado a 03_auth.sql: Ahora recibe nombre y nivel
 */
export async function signup(email, pass, nombre, nivel) {
  const response = await fetch(`${apiUrl}/rpc/signup`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ 
      email, 
      pass, 
      nombre, 
      nivel: parseFloat(nivel) // Aseguramos que sea decimal
    }),
  });
  if (!response.ok) throw new Error("Error en el registro: el usuario ya existe");
}

// --- RESERVAS (PARTIDAS) ---

export async function getReservas() {
  // PostgREST permite traer datos relacionados (Clubs, Pistas) en una sola consulta
  const response = await fetch(`${apiUrl}/reservas?select=*,pista(nombre_pista,clubs(nombre_club))`);
  return await response.json();
}

export async function addReserva(reservaData) {
  const token = localStorage.getItem("token");
  const response = await fetch(`${apiUrl}/reservas`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${token}`,
      "Prefer": "return=minimal",
    },
    body: JSON.stringify(reservaData)
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(JSON.stringify(errorData));
  }
  return true;
}

export async function deleteReserva(id) {
  const token = localStorage.getItem("token");
  const response = await fetch(`${apiUrl}/reservas?id_reserva=eq.${id}`, {
    method: "DELETE",
    headers: { "Authorization": `Bearer ${token}` },
  });
  if (!response.ok) throw new Error(`Error al borrar: ${response.status}`);
}

// --- CLUBS Y PISTAS (Para los desplegables del formulario) ---

export async function getClubs() {
  const response = await fetch(`${apiUrl}/clubs`);
  return await response.json();
}

export async function getPistas() {
  const response = await fetch(`${apiUrl}/pista`);
  return await response.json();
}