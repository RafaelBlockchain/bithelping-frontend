import { useState, useEffect } from "react";

const useBlockchainData = (contract, methodName, params = []) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      if (contract && methodName) {
        try {
          setLoading(true);
          const result = await contract.methods[methodName](...params).call();
          setData(result);
        } catch (err) {
          setError(err.message);
        } finally {
          setLoading(false);
        }
      }
    };

    fetchData();
  }, [contract, methodName, params]);

  return { data, loading, error };
};

export default useBlockchainData;

