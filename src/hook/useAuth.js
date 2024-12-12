import { useState, useEffect, useContext } from "react";
import { UserContext } from "../context/UserContext";
import axios from "axios"; // Importar Axios para realizar llamadas a la API

const useAuth = () => {
  const { user, setUser } = useContext(UserContext);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  // URL base de la API (ajústalo según tu backend)
  const API_URL = "https://api.bithelping.com/auth";

  // Inicio de sesión real con la API
  const login = async (credentials) => {
    try {
      setLoading(true);
      const response = await axios.post(`${API_URL}/login`, credentials);

      const { user, token } = response.data;

      // Guardar usuario y token en el contexto y almacenamiento local
      setUser(user);
      localStorage.setItem("user", JSON.stringify(user));
      localStorage.setItem("token", token);
      setIsAuthenticated(true);
    } catch (error) {
      console.error("Error al iniciar sesión:", error);
      setIsAuthenticated(false);
      throw error; // Permite manejar errores en el componente
    } finally {
      setLoading(false);
    }
  };

  // Cierre de sesión
  const logout = () => {
    setUser(null);
    setIsAuthenticated(false);
    localStorage.removeItem("user");
    localStorage.removeItem("token");
  };

  // Verificación de autenticación al cargar
  useEffect(() => {
    const checkAuth = async () => {
      try {
        setLoading(true);
        const storedUser = JSON.parse(localStorage.getItem("user"));
        const token = localStorage.getItem("token");

        if (storedUser && token) {
          // Verificar token con la API
          await axios.get(`${API_URL}/verify`, {
            headers: { Authorization: `Bearer ${token}` },
          });
          setUser(storedUser);
          setIsAuthenticated(true);
        }
      } catch (error) {
        console.error("Error al verificar la autenticación:", error);
        logout(); // Limpiar usuario si hay error de autenticación
      } finally {
        setLoading(false);
      }
    };

    checkAuth();
  }, [setUser]);

  return { user, isAuthenticated, loading, login, logout };
};

export default useAuth;

