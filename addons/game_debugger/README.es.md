# 🎮 Godot 4 Game Debugger Plugin

🌐 **Idioma / Language**:  
[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge&logo=godotengine)](README.md)
[![Español](https://img.shields.io/badge/Idioma-Espa%C3%B1ol-orange?style=for-the-badge&logo=godotengine)](README.es.md)

[![Godot Version](https://img.shields.io/badge/Godot-v4.x-blue.svg)](https://godotengine.org)
[![Licencia](https://img.shields.io/badge/Licencia-MIT-green.svg)](LICENSE)
[![Versión Plugin](https://img.shields.io/badge/Versi%C3%B3n-1.0.0-purple.svg)]()

**Game Debugger** es un administrador de opciones de depuración moderno en tiempo real desarrollado para **Godot Engine 4**. Permite a los desarrolladores de videojuegos crear, reordenar, modificar y guardar de forma dinámica configuraciones de depuración personalizadas (interruptores booleanos, contadores enteros, deslizadores flotantes, entradas de texto, menús desplegables Enum y listas de arreglos Array) directamente dentro del editor de Godot y ProjectSettings.

---

## 🌟 Características Principales

* **⚡ Creación Dinámica de Configuraciones de Depuración**:
  * Crea opciones de depuración personalizadas al instante bajo el espacio de nombres `Game/Debug/`.
  * Soporta 6 tipos de parámetros: **Bool**, **Int**, **Float**, **String**, **Enum** y **Array (PackedStringArray)**.
* **🎨 Ajustes Predeterminados (Presets)**:
  * El selector de ajustes predeterminados configura automáticamente tipos, sugerencias y valores por defecto.
* **≡ Reordenamiento por Arrastrar y Soltar en Tiempo Real**:
  * Mantén presionado el **Clic Derecho** en cualquier fila o manipulador `≡` para arrastrar y cambiar posiciones en tiempo real.
  * El orden se guarda automáticamente en el disco (`custom_setting_res.tres`).
* **🗑️ Eliminación Permanente de Configuraciones**:
  * Haz clic en el botón rojo 🗑 **Eliminar** a la derecha para borrar completamente la configuración de la interfaz, de `ProjectSettings` y de los datos guardados.
* **📑 Creador Interactivo de Elementos (Enum y Array)**:
  * Haz clic en el botón **"Crear Elementos..."** (con validación de borde rojo/verde) para abrir el panel lateral derecho e ingresar opciones o elementos línea por línea.
* **✨ Sincronización en Tiempo Real con ProjectSettings**:
  * Cualquier cambio (interruptor, número, texto o menú desplegable) actualiza inmediatamente `ProjectSettings` y lo guarda en disco.
* **📖 Guía Interactiva Integrada**:
  * Haz clic en el botón **`Información...`** para abrir/cerrar un panel con instrucciones completas de uso.
* **🖱️ Navegación Fluida en el Lienzo**:
  * Mantén presionado **Clic Izquierdo** en un espacio vacío para moverte por el lienzo.
  * Doble clic izquierdo para reiniciar la vista.

---

## 📥 Instalación

1. **Descarga / Clona** este repositorio dentro de tu proyecto de Godot.
2. Asegúrate de que la carpeta del plugin esté ubicada en `res://addons/game_debugger/`.
3. En Godot Engine, ve a **Proyecto -> Configuración del Proyecto -> Plugins**.
4. Localiza **Game Debugger** y cambia su estado a **Activo**.
5. El panel principal de **Game Debugger** aparecerá en los muelles de tu editor.

---

## 🚀 Modo de Uso

### 1. Crear una Nueva Configuración de Depuración
1. Haz clic en **`Crear nueva configuración...`** para abrir el panel creador.
2. Ingresa un nombre para la configuración (ej. `GodMode`, `PlayerSpeed`, `Difficulty`).
3. Selecciona un **Ajuste Tipo (Preset)** del menú desplegable:
   * **Bool**: Interruptor verdadero/falso.
   * **Int / Float**: Valor numérico SpinBox.
   * **String**: Campo de entrada de texto.
   * **Enum**: Menú desplegable de selección.
   * **Array**: Arreglo de cadenas multilínea.
4. Para opciones **Enum** o **Array**:
   * Haz clic en **`Crear Elementos...`** para abrir el panel a la derecha.
   * Escribe cada opción en una nueva línea (ej. `Easy`, `Normal`, `Hard`).
5. ¡Haz clic en **`Crear`** para guardar y registrar tu nueva configuración!

### 2. Reordenar Configuraciones
* Mantén presionado **Clic Derecho** en el botón `≡` (o en cualquier lugar de la fila) y arrastra hacia arriba o abajo.
* Las filas cambiarán de posición en tiempo real y el nuevo orden se guardará automáticamente al soltar.

### 3. Eliminar una Configuración
* Haz clic en el botón rojo 🗑 **Eliminar** a la derecha de cualquier fila.
* La configuración se eliminará inmediatamente del proyecto y del almacenamiento.

---

## 💻 Consultar Configuraciones en GDScript

Acceder a tus opciones de depuración en tu código de juego es muy sencillo usando la API nativa de `ProjectSettings`:

```gdscript
extends Node

func _process(delta: float) -> void:
	# Leer configuración booleana de depuración
	var god_mode: bool = ProjectSettings.get_setting("Game/Debug/GodMode", false)
	if god_mode:
		# Aplicar lógica de modo dios...
		pass

	# Leer configuración numérica
	var player_speed: float = ProjectSettings.get_setting("Game/Debug/PlayerSpeed", 300.0)

	# Leer configuración Enum
	var difficulty: String = ProjectSettings.get_setting("Game/Debug/Difficulty", "Normal")
	match difficulty:
		"Easy":
			print("Modo Fácil activo")
		"Normal":
			print("Modo Normal activo")
		"Hard":
			print("Modo Difícil activo")
```

---

## 🔗 Redes y Contacto

Sigue y conecta para ver actualizaciones, juegos y herramientas para Godot:

* 📺 **YouTube**: [Samurai Kina](https://youtube.com/@samuraikina5908?si=XgnADjqgPl9r4gkE)
* 🎵 **TikTok**: [@samuraikina_anticodec](https://www.tiktok.com/@samuraikina_anticodec?_r=1&_t=ZS-99Kq2eaTilh)
* 📸 **Instagram**: [@anticodec507](https://www.instagram.com/anticodec507?igsi=MWExbjk3cWI1aHp1MQ==)
* 💬 **Reddit**: [u/Ciso507](https://www.reddit.com/u/Ciso507/s/4LknXFIVvX)
* 🐦 **X (Twitter)**: [@CiisoB](https://x.com/CiisoB)
* ⚔️ **Steam Wishlist**: [Bounty Hunters en Steam](https://store.steampowered.com/app/2507500/Bounty_Hunters/)

---

## 📜 Licencia

Distribuido bajo la **Licencia MIT**. Consulta `LICENSE` para obtener más información.
