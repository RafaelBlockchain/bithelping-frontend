// src/context/UserContext.js
import React, { createContext, useState, useContext } from 'react';

// Crear el contexto
const UserContext = createContext();

// Crear el proveedor del contexto
export const UserProvider = ({ children }) => {
  // Estado global para el usuario
  const [user, setUser] = useState(null); // Por ejemplo, usuario no autenticado al principio

  // Funciones para actualizar el estado
  const login = (userData) => setUser(userData);
  const logout = () => setUser(null);

  return (
    <UserContext.Provider value={{ user, login, logout }}>
      {children}
    </UserContext.Provider>
  );
};

// Custom hook para usar el contexto
export const useUser = () => useContext(UserContext);

