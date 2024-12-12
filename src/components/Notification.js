// src/components/Notification.js
import React, { useEffect } from 'react';
import { useNotifications } from '../context/NotificationContext';

const Notification = () => {
  const { notifications } = useNotifications();

  useEffect(() => {
    // Podrías agregar lógica para ocultar notificaciones después de un tiempo
  }, [notifications]);

  return (
    <div>
      {notifications.map((notif, index) => (
        <div key={index} className={`notification ${notif.type}`}>
          {notif.message}
        </div>
      ))}
    </div>
  );
};

export default Notification;

