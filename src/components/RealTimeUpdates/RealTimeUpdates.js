// src/components/RealTimeUpdates/RealTimeUpdates.js
import React, { useEffect, useState } from 'react';

const RealTimeUpdates = ({ contract, account }) => {
  const [updates, setUpdates] = useState([]);

  useEffect(() => {
    const handleNewUpdate = (update) => {
      setUpdates((prevUpdates) => [...prevUpdates, update]);
    };

    contract.events
      .Transfer({ filter: { from: account } })
      .on('data', (event) => handleNewUpdate(event));

    return () => {
      contract.events.Transfer.removeListener('data', handleNewUpdate);
    };
  }, [contract, account]);

  return (
    <div className="real-time-updates">
      <h2>Actualizaciones en Tiempo Real</h2>
      <ul>
        {updates.map((update, index) => (
          <li key={index}>{update.returnValues.value} tokens enviados a {update.returnValues.to}</li>
        ))}
      </ul>
    </div>
  );
};

export default RealTimeUpdates;

