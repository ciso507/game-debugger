# 🎮 Godot 4 Game Debugger Plugin

[![Godot Version](https://img.shields.io/badge/Godot-v4.x-blue.svg)](https://godotengine.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Plugin Version](https://img.shields.io/badge/Version-1.0.0-purple.svg)]()

🌐 **Select Language / Seleccionar Idioma**:  
<a href="#-english-en-default"><img src="https://img.shields.io/badge/Language-English_(EN)-blue?style=for-the-badge&logo=godotengine" alt="English (EN)"></a>
<a href="#-español-es-clic-para-desplegar"><img src="https://img.shields.io/badge/Idioma-Espa%C3%B1ol_(ES)-orange?style=for-the-badge&logo=godotengine" alt="Español (ES)"></a>

---

<details open>
<summary><h2>🇬🇧 English (EN) (Default)</h2></summary>

**Game Debugger** is a modern, real-time in-engine debug options manager built for **Godot Engine 4**. It allows game developers to dynamically create, reorder, modify, and persist custom debug settings (Boolean toggles, Integer counters, Float sliders, String inputs, Enum dropdowns, and Array list items) directly within the Godot editor and project settings.

### 🌟 Key Features

* **⚡ Dynamic Debug Setting Creation**:
  * Create custom debug options on the fly under the `Game/Debug/` project settings namespace.
  * Supports 6 distinct parameter types: **Bool**, **Int**, **Float**, **String**, **Enum**, and **Array (PackedStringArray)**.
* **🎨 One-Click Presets**:
  * Quick preset selector automatically configures types, hints, and default values.
* **≡ Real-Time Drag & Drop Reordering**:
  * Hold **Right Click** on any setting row or the `≡` handle to visually drag and swap setting positions in real time.
  * Setting order is automatically persisted to disk (`custom_setting_res.tres`).
* **🗑️ Permanent Setting Deletion**:
  * Click the red 🗑 **Delete Button** on the right side of any setting row to erase it completely from the UI, `ProjectSettings`, and saved resource data.
* **📑 Interactive Item Creator (Enum & Array)**:
  * Click the **"Create Items..."** button (with red/green outline validation) to open a right-side panel for entering enum dropdown choices or string array elements line-by-line.
* **✨ Live ProjectSettings Synchronization**:
  * Any value change (toggle, number change, text edit, dropdown selection) immediately updates `ProjectSettings` and saves configuration to disk.
* **📖 Built-in Interactive Guide**:
  * Click the **`Info...`** button to open/close an in-engine summary panel with full usage instructions.
* **🖱️ Smooth Canvas Navigation**:
  * Hold **Left Click** on empty canvas space to pan around.
  * Double-click Left Click to reset the canvas view.

### 📥 Installation

1. **Download / Clone** this repository into your Godot project.
2. Ensure the plugin folder is placed at `res://addons/game_debugger/`.
3. In Godot Engine, go to **Project -> Project Settings -> Plugins**.
4. Locate **Game Debugger** and set its status to **Enable**.
5. The **Game Debugger** main panel will now appear in your editor docks.

### 🚀 How to Use

#### 1. Creating a New Debug Setting
1. Click **`Create new custom setting...`** to open the setting creator panel.
2. Enter a setting name (e.g., `GodMode`, `PlayerSpeed`, `Difficulty`).
3. Select a **Preset** from the dropdown:
   * **Bool**: Simple true/false CheckButton.
   * **Int / Float**: Numeric SpinBox value.
   * **String**: Text input field.
   * **Enum**: Dropdown selection menu.
   * **Array**: Multi-item string array.
4. For **Enum** or **Array** settings:
   * Click **`Create Items...`** to open the items panel on the right.
   * Type each choice on a new line (e.g. `Easy`, `Normal`, `Hard`).
5. Click **`Create`** to save and register your new setting!

#### 2. Reordering Settings
* Hold **Right Click** on the `≡` drag handle button (or anywhere on a setting row) and drag up or down.
* The rows will swap visually in real time, and the new sequence will save automatically when released.

#### 3. Deleting a Setting
* Click the red 🗑 **Delete Button** on the far right of any setting row.
* The setting will be removed from your game's settings and disk storage immediately.

### 💻 Querying Debug Settings in GDScript

Accessing your custom debug settings in your game code is seamless using Godot's built-in `ProjectSettings` API:

```gdscript
extends Node

func _process(delta: float) -> void:
	# Read Boolean debug setting
	var god_mode: bool = ProjectSettings.get_setting("Game/Debug/GodMode", false)
	if god_mode:
		# Apply god mode logic...
		pass

	# Read Numeric debug setting
	var player_speed: float = ProjectSettings.get_setting("Game/Debug/PlayerSpeed", 300.0)

	# Read Enum debug setting
	var difficulty: String = ProjectSettings.get_setting("Game/Debug/Difficulty", "Normal")
	match difficulty:
		"Easy":
			print("Easy mode active")
		"Normal":
			print("Normal mode active")
		"Hard":
			print("Hard mode active")
```

</details>

---

<details>
<summary><h2>🇪🇸 Español (ES) (Clic para desplegar)</h2></summary>

**Game Debugger** es un administrador de opciones de depuración moderno en tiempo real desarrollado para **Godot Engine 4**. Permite a los desarrolladores de videojuegos crear, reordenar, modificar y guardar de forma dinámica configuraciones de depuración personalizadas (interruptores booleanos, contadores enteros, deslizadores flotantes, entradas de texto, menús desplegables Enum y listas de arreglos Array) directamente dentro del editor de Godot y ProjectSettings.

### 🌟 Características Principales

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

### 📥 Instalación

1. **Descarga / Clona** este repositorio dentro de tu proyecto de Godot.
2. Asegúrate de que la carpeta del plugin esté ubicada en `res://addons/game_debugger/`.
3. En Godot Engine, ve a **Proyecto -> Configuración del Proyecto -> Plugins**.
4. Localiza **Game Debugger** y cambia su estado a **Activo**.
5. El panel principal de **Game Debugger** aparecerá en los muelles de tu editor.

### 🚀 Modo de Uso

#### 1. Crear una Nueva Configuración de Depuración
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

#### 2. Reordenar Configuraciones
* Mantén presionado **Clic Derecho** en el botón `≡` (o en cualquier lugar de la fila) y arrastra hacia arriba o abajo.
* Las filas cambiarán de posición en tiempo real y el nuevo orden se guardará automáticamente al soltar.

#### 3. Eliminar una Configuración
* Haz clic en el botón rojo 🗑 **Eliminar** a la derecha de cualquier fila.
* La configuración se eliminará inmediatamente del proyecto y del almacenamiento.

### 💻 Consultar Configuraciones en GDScript

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

</details>

---

## 🔗 Follow & Connect / Redes y Contacto

Stay connected for updates, games, and Godot tools:

* 📺 **YouTube**: [Samurai Kina](https://youtube.com/@samuraikina5908?si=XgnADjqgPl9r4gkE)
* 🎵 **TikTok**: [@samuraikina_anticodec](https://www.tiktok.com/@samuraikina_anticodec?_r=1&_t=ZS-99Kq2eaTilh)
* 📸 **Instagram**: [@anticodec507](https://www.instagram.com/anticodec507?igsi=MWExbjk3cWI1aHp1MQ==)
* 💬 **Reddit**: [u/Ciso507](https://www.reddit.com/u/Ciso507/s/4LknXFIVvX)
* 🐦 **X (Twitter)**: [@CiisoB](https://x.com/CiisoB)
* ⚔️ **Steam Wishlist**: [Bounty Hunters on Steam](https://store.steampowered.com/app/2507500/Bounty_Hunters/)

---

## 📜 License / Licencia

Distributed under the **MIT License**. See `LICENSE` for more information.
