// src/services/UserService.js
import { getUserProfile, updateUserProfile } from '../utils/api'; // Suponiendo que hay una API para obtener y actualizar perfiles

class UserService {
  static async fetchUserProfile(userId) {
    try {
      const response = await getUserProfile(userId);
      return response.data;
    } catch (error) {
      console.error("Error al obtener el perfil de usuario:", error);
      throw error;
    }
  }

  static async updateUserProfile(userId, updatedData) {
    try {
      const response = await updateUserProfile(userId, updatedData);
      return response.data;
    } catch (error) {
      console.error("Error al actualizar el perfil de usuario:", error);
      throw error;
    }
  }
}

export default UserService;
