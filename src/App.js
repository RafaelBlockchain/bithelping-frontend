import React from "react";
import Header from "./components/Header";
import Footer from "./components/Footer";
import Dashboard from "./components/Dashboard";
import ContractsManagement from "./components/ContractsManagement";
import Staking from "./components/Staking";

const App = () => {
  return (
    <div>
      <Header />
      <Dashboard />
      <ContractsManagement />
      <Staking />
      <Footer />
    </div>
  );
};

export default App;

