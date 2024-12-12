import React, { useState, useEffect } from "react";

const Marketplace = ({ contract }) => {
  const [items, setItems] = useState([]);

  useEffect(() => {
    const fetchItems = async () => {
      const itemList = await contract.methods.getListedItems().call();
      setItems(itemList);
    };
    fetchItems();
  }, [contract]);

  const buyItem = async (itemId) => {
    await contract.methods.buyItem(itemId).send({ from: account });
  };

  return (
    <div>
      <h2>Marketplace</h2>
      <ul>
        {items.map((item) => (
          <li key={item.id}>
            {item.name} - {item.price} ETH
            <button onClick={() => buyItem(item.id)}>Comprar</button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default Marketplace;

