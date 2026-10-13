# Breezing Dimension

Game puzzle-platformer 2D berbasis Godot 4.x tentang satu dunia yang terbelah menjadi dimensi **STILL** dan **BREEZE**. Proyek ini tidak membutuhkan aset eksternal: art, ambience, music layers, dan SFX dibuat secara prosedural saat runtime.

## Menjalankan game

1. Impor `project.godot` melalui Godot 4.6, versi yang tercatat di konfigurasi proyek.
2. Jalankan project dengan `F5`. Main scene adalah `scenes/menu/MainMenu.tscn`.

Resolusi desain adalah 1152×648. Input keyboard dan controller sudah terdaftar di `project.godot`.

| Aksi | Keyboard | Controller |
|---|---|---|
| Bergerak | A/D atau ←/→ | Left Stick / D-Pad |
| Lompat | Space | A / Cross |
| Dimension Shift | E | X / Square |
| Interact/dialogue | F atau Space | — |
| Restart level | R | — |
| Pause | Esc | Start |

## Mengedit level tanpa Godot Editor

Semua layout berada di [`data/levels`](data/levels). Copy salah satu `.txt`, ubah metadata dan bagian `[MAP]`, lalu tambahkan record seperti:

```text
[WIND]
zone=10,6,4,2,RIGHT,350,BREEZE

[FRAGMENT]
id=L1_F1,pos=7,6

[MEMORY]
id=L1_MEMORY,pos=18,2,text=Your editable lore text.

[MOVING]
platform=pos=24,9,offset=5,-3,speed=86,dimension=STILL

[SWITCH]
switch=pos=16,12,link=A,crate_only=true

[DOOR]
door=pos=20,11,link=A,dimension=ANY
```

Legenda map: `#` normal platform, `S` still platform, `B` breeze platform, `^` spike, `P` spawn, `G` goal, `C` checkpoint, `W` wind crate, `D` door, dan `T` pressure switch. Satu tile berukuran 32×32 px.

`crate_only=true` membuat pressure switch hanya menerima Wind Crate. Tanpa properti itu, player maupun crate dapat mengaktifkannya. Platform ASCII yang bersebelahan otomatis digabung menjadi satu collider agar crate tidak tersangkut di sambungan tile.

## Mengedit cerita

Semua naskah berada di [`data/story`](data/story). Baris dialogue menggunakan `CHARACTER|TEXT`; `\\n` membuat baris baru. Destination setelah story ditentukan oleh `[END] next=...`.

## Save dan settings

- Progress: `user://savegame.json`
- Settings: `user://settings.cfg`
- True ending: minimal 18/21 fragments dan 5/5 memory echoes

## Validasi

Smoke test menginstansiasi semua menu, enam level, semua collectible, player, dan sembilan file story/ending:

```powershell
godot --headless --path . --script res://tests/smoke_test.gd
```
