// ./i18n.js

import i18n from "i18next";
import { initReactI18next } from "react-i18next";

// Importa los archivos de traducción para cada idioma
import enTranslation from "./locales/en/translation.json";
import esTranslation from "./locales/es/translation.json";
import frTranslation from "./locales/fr/translation.json"; // Opcional, añade más idiomas

// Configuración de i18n
const resources = {
  en: {
    translation: enTranslation,
  },
  es: {
    translation: esTranslation,
  },
  fr: {
    translation: frTranslation,
  },
};

i18n
  .use(initReactI18next) // Enlaza con React
  .init({
    resources,
    lng: "en", // Idioma predeterminado
    fallbackLng: "en", // Idioma usado si el actual no está disponible
    interpolation: {
      escapeValue: false, // React ya maneja el escape de valores
    },
    debug: process.env.NODE_ENV === "development", // Depuración en modo desarrollo
  });

export default i18n;
