// src/context/NotificationContext.js
import React, { createContext, useState, useContext } from 'react';

// Crear el contexto
const NotificationContext = createContext();

// Crear el proveedor del contexto
export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([]);

  const addNotification = (message, type) => {
    setNotifications((prev) => [...prev, { message, type }]);
  };

  return (
    <NotificationContext.Provider value={{ notifications, addNotification }}>
      {children}
    </NotificationContext.Provider>
  );
};

// Custom hook para usar el contexto
export const useNotifications = () => useContext(NotificationContext);

