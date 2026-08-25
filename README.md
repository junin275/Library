# Shadow Hub V2

UI Library reutilizável + Script de Aimbot/ESP para Roblox.

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `ShadowHubLibrary.lua` | UI Library reutilizável (ModuleScript) |
| `SonicHubV2.lua` | Script principal (requer a library) |
| `SonicHubDiagnostico.lua` | Script de diagnóstico |
| `SonicHubColetor.lua` | Script coletor de dados |

## Como usar

1. Coloque `ShadowHubLibrary.lua` no `PlayerGui` do jogador
2. Execute `SonicHubV2.lua` (LocalScript)
3. Aperte **RightCtrl** para abrir o menu

## Features

### Library (ShadowHubLibrary)
- Window com loading screen animado
- Sections colapsáveis com animação
- Toggles com slide animation
- Sliders suaves
- Buttons com hover/pulse
- Color picker
- Drag com threshold (não ativa toggle ao arrastar)
- Status bar

### Script (SonicHubV2)
- **ESP** - Box, Tracer, Dot, HP bar, nome, distância
- **Aim Assist** - Smooth aim com target lock
- **Crosshair** - 4 estilos, tamanho/gap/cor customizáveis
- **GPS** - Mini bússola apontando pro inimigo mais próximo
- **Kill Notifications** - Streak tracking com som
- **Noclip** - Atravessar paredes
- **Fullbright** - Iluminação total
- **Speed Boost** - Velocidade aumentada
- **Spin Bot** - Rotação automática
- **FOV Slider** - Campo de visão customizável
- **Teleport** - Teleportar pro inimigo mais próximo
- **Auto Headshot** - Mira sempre na cabeça

## Requisitos

- Roblox Studio ou executor compatible
- Lua/Luau

## License

MIT
