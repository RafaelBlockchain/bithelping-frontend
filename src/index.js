import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import "./styles/global.css"; // Estilos globales
import "./index.css"; // Estilos específicos del index

// Context Providers
import { UserProvider } from "./context/UserContext";
import { Web3Provider } from "./context/Web3Context";
import { ThemeProvider } from "./context/ThemeContext"; // Suponiendo que usas un ThemeContext

// Routing
import { BrowserRouter } from "react-router-dom";

// Internacionalización (i18n)
import "./i18n"; // Archivo de configuración de i18next

// Redux (si es necesario)
import { Provider as ReduxProvider } from "react-redux";
import store from "./store"; // Archivo donde configuraste tu store de Redux

// Reporte de métricas de rendimiento
import reportWebVitals from "./reportWebVitals";

// Modo desarrollo/producción
if (process.env.NODE_ENV === "development") {
  console.log("🚀 La aplicación está en modo desarrollo");
}

// Renderizar la aplicación
ReactDOM.render(
  <React.StrictMode>
    <BrowserRouter>
      <ReduxProvider store={store}>
        <ThemeProvider>
          <UserProvider>
            <Web3Provider>
              <App />
            </Web3Provider>
          </UserProvider>
        </ThemeProvider>
      </ReduxProvider>
    </BrowserRouter>
  </React.StrictMode>,
  document.getElementById("root")
);

// Métricas de rendimiento (opcional)
reportWebVitals(console.log);
