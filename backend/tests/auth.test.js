const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

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

  test('Debería generar y verificar un token JWT correctamente', () => {
    const payload = { id: 'test_user_id', role: 'alumno' };
    const secret = 'test_jwt_secret_key_2026';
    
    // Generar token JWT
    const token = jwt.sign(payload, secret, { expiresIn: '1h' });
    expect(token).toBeDefined();
    expect(typeof token).toBe('string');
    
    // Verificar token JWT
    const decoded = jwt.verify(token, secret);
    expect(decoded.id).toBe(payload.id);
    expect(decoded.role).toBe(payload.role);
  });
});
