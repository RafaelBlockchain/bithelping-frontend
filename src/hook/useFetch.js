import { useState, useEffect } from "react";

const useFetch = (endpoint, options = {}) => {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const API_BASE_URL = "https://api.bithelping.org"; // Cambia a la URL base de tu API

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const url = `${API_BASE_URL}${endpoint}`;
        const response = await fetch(url, options);
        if (!response.ok) {
          throw new Error(`Error: ${response.status} ${response.statusText}`);
        }
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    if (endpoint) {
      fetchData();
    }
  }, [endpoint, options]);

  return { data, error, loading };
};

export default useFetch;

