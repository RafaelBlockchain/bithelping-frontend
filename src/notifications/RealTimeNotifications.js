import React, { useEffect } from "react";
import { ToastContainer, toast } from "react-toastify";

const RealTimeNotifications = ({ contract, account }) => {
  useEffect(() => {
    if (contract) {
      // Escuchar eventos del contrato
      contract.events
        .Transfer({})
        .on("data", (event) => {
          const { from, to, value } = event.returnValues;
          if (to.toLowerCase() === account.toLowerCase()) {
            toast.success(`¡Recibiste ${value} BITH de ${from}!`);
          } else if (from.toLowerCase() === account.toLowerCase()) {
            toast.info(`Enviaste ${value} BITH a ${to}.`);
          }
        })
        .on("error", (error) => {
          console.error("Error en el evento Transfer:", error);
          toast.error("Hubo un error al procesar los eventos de transferencia.");
        });

      contract.events
        .Mint({})
        .on("data", (event) => {
          const { to, amount } = event.returnValues;
          toast.success(`¡Se mintieron ${amount} BITH para ${to}!`);
        })
        .on("error", (error) => {
          console.error("Error en el evento Mint:", error);
          toast.error("Hubo un error al procesar el evento de emisión.");
        });

      // Otros eventos relevantes pueden añadirse aquí
    }
  }, [contract, account]);

  return <ToastContainer />;
};

export default RealTimeNotifications;

