// src/components/UserProfile.js
import React from 'react';
import { useUser } from '../context/UserContext';

const UserProfile = () => {
  const { user, login, logout } = useUser();

  return (
    <div>
      {user ? (
        <div>
          <p>Bienvenido, {user.name}!</p>
          <button onClick={logout}>Cerrar sesión</button>
        </div>
      ) : (
        <div>
          <p>No has iniciado sesión</p>
          <button onClick={() => login({ name: 'Juan' })}>Iniciar sesión</button>
        </div>
      )}
    </div>
  );
};

export default UserProfile;
