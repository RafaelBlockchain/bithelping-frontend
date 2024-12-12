// src/utils/dateUtils.js

import moment from "moment";

// Formatear un timestamp a un formato legible
export const formatTimestamp = (timestamp, format = "YYYY-MM-DD HH:mm:ss") => {
  return moment.unix(timestamp).format(format);
};

// Calcular la diferencia entre dos fechas en días, horas, etc.
export const calculateDateDifference = (date1, date2, unit = "days") => {
  return moment(date1).diff(moment(date2), unit);
};

// Obtener la fecha actual en un formato específico
export const getCurrentDate = (format = "YYYY-MM-DD") => {
  return moment().format(format);
};
