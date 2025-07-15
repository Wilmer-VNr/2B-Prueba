# Registro de Visitantes - Flutter App

Esta aplicación permite registrar y gestionar visitantes en una oficina, cumpliendo con los siguientes requisitos:

## Funcionalidades

1. **Pantalla de Login**
   - Inicio de sesión con correo y contraseña usando Supabase (y Firebase para almacenamiento de visitantes).
   - Validación de campos y mensajes claros de error.

2. **Pantalla Principal**
   - Muestra una lista en tiempo real de los visitantes registrados.
   - Cada visitante muestra: nombre, motivo de la visita, hora y foto.

3. **Agregar Nuevo Visitante**
   - Botón flotante para abrir un formulario.
   - El formulario permite ingresar:
     - Nombre del visitante
     - Motivo de la visita
     - Hora (con DatePicker y TimePicker, o Timestamp actual)
     - Foto (subida a Supabase Storage, solo JPG/PNG, máximo 5MB)
   - Validaciones de campos obligatorios y tipo/tamaño de imagen.

4. **Almacenamiento y Actualización en Tiempo Real**
   - Los datos de visitantes se almacenan en la colección `visitas` de Firebase.
   - Las fotos se almacenan en el bucket `uploads` de Supabase Storage.
   - La lista de visitantes se actualiza automáticamente en tiempo real.

5. **Presentación de la Aplicación**
   - Interfaz clara, moderna y funcional.
   - Mensajes de éxito y error amigables.
   - Presentación introductoria en la pantalla principal.

## Requisitos Técnicos
- Uso de Supabase para autenticación y almacenamiento de imágenes.
- Uso de Firebase para la colección de visitantes y actualización en tiempo real.
- UI básica pero funcional, con validaciones de campos.

---

**¡Listo para registrar y gestionar visitantes de manera eficiente y moderna!**
