import React from "react";
import RealTimeLineChart from "./charts/RealTimeLineChart";

const Analytics = ({ realTimeData }) => {
  return (
    <div>
      <h1>Análisis de Datos</h1>
      <RealTimeLineChart data={realTimeData} />
    </div>
  );
};

export default Analytics;

