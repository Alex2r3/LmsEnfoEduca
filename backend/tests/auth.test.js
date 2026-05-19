const bcrypt = require('bcryptjs');

describe('Pruebas Unitarias - Seguridad y Autenticación', () => {
  
  test('Debería cifrar correctamente una contraseña', async () => {
    const plainPassword = 'Mypassword123!';
    const saltRounds = 10;
    
    // Cifrar contraseña
    const hashedPassword = await bcrypt.hash(plainPassword, saltRounds);
    
    // Verificaciones
    expect(hashedPassword).toBeDefined();
    expect(hashedPassword).not.toBe(plainPassword); // No debe ser igual a la original
    expect(hashedPassword.length).toBeGreaterThan(20); // El hash es largo
  });

  test('Debería comparar y validar una contraseña cifrada correctamente', async () => {
    const plainPassword = 'PruebaSegura2026';
    const hashedPassword = await bcrypt.hash(plainPassword, 10);
    
    // Simular el inicio de sesión exitoso
    const isMatch = await bcrypt.compare(plainPassword, hashedPassword);
    expect(isMatch).toBe(true);
    
    // Simular contraseña incorrecta
    const isNotMatch = await bcrypt.compare('ContraseñaEquivocada', hashedPassword);
    expect(isNotMatch).toBe(false);
  });
});
