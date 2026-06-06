# 🏭 INDUSTRIAL FACTORY — Godot 4.6

## ▶ ABRIR EN GODOT
1. Abre Godot 4.6 → Importar → selecciona `project.godot`
2. Click ▶ (F5) — la escena principal es `scenes/main_menu.tscn`

## 🎮 CONTROLES
| Acción | J1 | J2 |
|--------|----|----|
| Mover  | A / D | ← / → |
| Saltar | W | ↑ |
| Guardar | H | H |
| Cargar  | J | J |

## 📁 ARQUITECTURA (todo en código GDScript)

La razón por la que TODO se construye en código (sin jerarquías .tscn complejas) es **evitar errores de nodos no encontrados**. Cada `.tscn` contiene solo el nodo raíz; el script crea dinámicamente los hijos.

```
scripts/
├── autoload/         ← Singletons (Guía 10)
│   ├── game_manager.gd   puntos, vidas, 2 jugadores
│   ├── sound_manager.gd  música + SFX generados
│   └── save_manager.gd   persistencia JSON (Guía 15)
├── player/player.gd      CharacterBody2D + Coyote Time (Guías 1,2,3)
├── enemies/
│   ├── robot.gd          Patrulla con RayCast2D (Guía 11)
│   └── drone.gd          Detección + persecución (Guía 12)
├── items/
│   ├── part.gd           Piezas + engranajes dorados (Guía 4)
│   ├── hazard.gd         Vapor/chispas/barriles
│   ├── exit_door.gd      Salida bloqueada (Guía 5)
│   └── lever.gd          Puzzle palancas Nivel 3
├── levels/level_builder.gd  ← CONSTRUYE TODO el nivel en código
├── ui/hud.gd              HUD con vidas ♥ (Guía 9)
│   main_menu.gd           Menú con fondo Kenney animado
│   game_over.gd           Pantalla final
│   tutorial.gd            Manual de controles
└── tests/
    ├── test_game_logic.gd  12 pruebas GUT (Guía 14)
    └── debug_example.gd    Breakpoints (Guía 13)
```

## 🔊 AUDIO
Los archivos WAV en `assets/audio/` fueron generados matemáticamente (ondas sinusoidales + síntesis procedural). Listos para usar sin descargas externas.

## 🎨 TILES
Todos los tiles de `assets/tiles/` son del paquete **Kenney Pixel Platformer Industrial Expansion** (CC0). Se usan directamente en el `level_builder.gd` para construir las plataformas.

## 🧪 TESTS (Guía 14)
1. AssetLib → instalar "GUT"
2. Activar en Proyecto → Configuración → Plugins
3. Panel GUT → añadir `res://scripts/tests` → Run All

## 📦 EXPORTAR (Guía 16)
Proyecto → Exportar → Windows Desktop → Descargar plantillas → Exportar Proyecto
