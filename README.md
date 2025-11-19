# DZ Fish It V2.1

**Roblox Fish It Script** dengan fitur lengkap untuk automated fishing, quest completion, dan player utilities.

**Developer:** @dzzzet  
**UI Library:** WindUI  
**Version:** 2.1

---

## 📋 Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Tab Overview](#tab-overview)
- [Instalasi](#instalasi)
- [Penggunaan](#penggunaan)
- [Fitur Detail](#fitur-detail)
- [Catatan Penting](#catatan-penting)

---

## 🎯 Fitur Utama

### 🎣 Auto Fishing
- **3 Mode Fishing:**
  - **Blatant Mode (Ultra Fishing):** High-speed fishing dengan burst casting dan spam reeling
  - **Normal Mode:** Instant recast dengan huge minigame values
  - **Legit Mode:** Auto-click minigame dengan kecepatan yang dapat disesuaikan

### 🤖 Automation
- **Auto Quest:** Otomatis menyelesaikan quest (Quest Artifact, Deepsea Quest, Element Quest)
- **Auto Sell:** Jual ikan secara otomatis dengan interval yang dapat disesuaikan
- **Auto Buy Weather:** Beli weather event otomatis
- **Auto Favorite:** Auto favorite ikan berdasarkan tier
- **Auto Trade:** Trading otomatis dengan 2 mode (V1 & V2)
- **Auto TP to Event:** Teleport otomatis ke event yang aktif

### 📍 Teleport
- **Teleport to Island:** Teleport ke berbagai pulau/lokasi
- **Teleport to Player:** Teleport ke player lain di server

### 🛒 Shop
- **Rod Shop:** Beli fishing rod langsung dari UI
- **Baits Shop:** Beli bait langsung dari UI
- **Traveling Merchant:** Beli item dari traveling merchant

### 👤 Player
- Walk Speed, Infinity Jump, Walk On Water
- God Mode, NoClip, Fly Mode
- Infinity Oxygen, Anti AFK
- Hide Name, Reload Character

### 🔔 Webhook
- **Discord Webhook:** Notifikasi ke Discord dengan embed yang informatif
- **Telegram Hook:** Notifikasi ke Telegram dengan support gambar
- **Tier Filtering:** Filter notifikasi berdasarkan tier ikan
- **Startup Notification:** Notifikasi otomatis saat script dijalankan

### ⚙️ Settings
- **Performance & Graphic:** Low Graphics, FPS Cap, GPU Saver
- **Server Management:** Auto Rejoin, Rejoin Server, Server Hop

---

## 📑 Tab Overview

### 1. Script Information
- Informasi Discord server
- Link GitHub
- Last update information
- Auto-open saat script dieksekusi

### 2. Developer Mode
- Copy CFrame + POV tools
- Debug utilities

### 3. Auto Fishing
- Mode selection (Normal, Blatant, Legit)
- Settings untuk setiap mode:
  - **Blatant Mode:** Charge Delay, Delay Recast, Spam Count, Worker Count, Reset Count, Reset Pause, Cycle Delay, Catch Timeout
  - **Normal Mode:** Recast Delay, Wait Delay
  - **Legit Mode:** Speed Legit

### 4. Automation
- **Auto Quest:**
  - Quest Artifact (4 artifacts di 4 spot berbeda)
  - Deepsea Quest (1 deepsea fish di Sisyphus)
  - Element Quest (2 SECRET fish di Ancient Jungle [Forest] & [Middle Temple])
  - Quest progress tracking dengan status bar
- **Auto Sell:** Interval-based selling (1-60 menit)
- **Auto Buy Weather:** Auto purchase weather events
- **Auto Favorite:** Auto favorite berdasarkan tier (Epic, Legendary, Mythic, Secret)
- **Auto Trade:** 
  - Mode V1: Simple trade dengan player selection
  - Mode V2: Advanced trade dengan inventory management
- **Auto TP to Event:** Multi-select event monitoring dengan platform teleport method

### 5. Teleport
- **Teleport to Island:** Dropdown dengan banyak lokasi (Esoteric Depths, Tropical Grove, Kohana Volcano, Crystalline Passage, dll)
- **Teleport to Player:** Dynamic player list dengan refresh button

### 6. Shop
- **Rod Shop:** Dropdown selection + Buy button
- **Baits Shop:** Dropdown selection + Buy button
- **Traveling Merchant:** Dropdown selection + Buy button

### 7. Player
- Walk Speed (16-150)
- Infinity Jump
- Walk On Water
- God Mode
- NoClip
- Fly Mode (dengan Fly Speed slider)
- Infinity Oxygen
- Anti AFK
- Hide Name
- Reload Character

### 8. Webhook
- **Tier Selection:** Shared dropdown untuk Discord & Telegram
- **Discord Webhook:**
  - Webhook URL input
  - Enable/Disable toggle
  - Connection status notification
- **Telegram Hook:**
  - Bot Token input
  - Chat ID input
  - Enable/Disable toggle
  - Image support (fallback ke text-only jika gambar tidak tersedia)
- **Status:** Connection status untuk kedua webhook

### 9. Settings
- **Performance & Graphic:**
  - Low Graphics toggle
  - FPS Cap dropdown (60, 90, 120, Max)
  - GPU Saver toggle
- **Server Management:**
  - Auto Rejoin on Disconnect toggle
  - Rejoin Server button
  - Server Hop button

---

## 🚀 Instalasi

1. Copy script dari file `DZ Fish IT [v2.1].lua`
2. Paste ke executor (Synapse X, Script-Ware, dll)
3. Execute script
4. Script Information tab akan auto-open

---

## 📖 Penggunaan

### Auto Fishing
1. Buka tab **Auto Fishing**
2. Pilih mode (Normal, Blatant, atau Legit)
3. Atur settings sesuai kebutuhan
4. Toggle **Enable Auto Fish**

### Auto Quest
1. Buka tab **Automation**
2. Pilih quest dari dropdown (Quest Artifact, Deepsea Quest, atau Element Quest)
3. Toggle **Enable Auto Quest**
4. Quest akan otomatis menyelesaikan dan restore position setelah selesai

### Auto TP to Event
1. Buka tab **Automation**
2. Pilih event(s) dari dropdown (multi-select)
3. Toggle **Enable Auto TP to Event**
4. Script akan otomatis teleport ke event yang muncul dan start Auto Fish

### Webhook Setup
1. Buka tab **Webhook**
2. Pilih tier yang ingin dikirim notifikasi
3. **Discord:**
   - Masukkan Discord webhook URL
   - Toggle **Enable Discord Webhook**
4. **Telegram:**
   - Masukkan Bot Token dan Chat ID
   - Toggle **Enable Telegram Hook**

---

## 🔧 Fitur Detail

### Auto Fish Modes

#### Blatant Mode (Ultra Fishing)
- High-speed fishing dengan multiple worker threads
- Burst casting dan spam reeling
- Auto equip rod
- Auto cancel fishing
- Configurable delays dan counts

#### Normal Mode
- Instant recast dengan huge minigame values
- Auto recast setelah fish caught
- Configurable recast dan wait delays

#### Legit Mode
- Auto-click minigame
- Configurable click speed
- Lebih human-like untuk menghindari detection

### Auto Quest

#### Quest Artifact
- Farm 4 artifacts di 4 spot berbeda
- Auto teleport ke spot berikutnya setelah dapat artifact
- Auto restart Auto Fish di setiap spot
- Auto unlock temple setelah semua artifacts terkumpul

#### Deepsea Quest
- Catch 1 deepsea fish di Sisyphus
- Auto teleport ke Lost Isle [Sisyphus]
- Progress tracking

#### Element Quest
- Catch 2 SECRET fish (tier 7)
- Lokasi 1: Ancient Jungle [Forest]
- Lokasi 2: Ancient Jungle [Middle Temple]
- Auto teleport sequential ke lokasi berikutnya

### Auto TP to Event
- Multi-select event monitoring
- Platform teleport method (50 unit di atas event)
- Auto Fish integration (mengikuti mode yang sedang berjalan)
- Return to original position setelah event selesai
- Support events: Shark Hunt, Ghost Shark Hunt, Worm Hunt, Black Hole, Meteor Rain, Ghost Worm, Shocked, Megalodon Hunt, Lochness Hunt

### Auto Trade
- **Mode V1:** Simple trade dengan player selection
- **Mode V2:** Advanced trade dengan:
  - Inventory dropdown (dynamic refresh)
  - Player selection dropdown
  - Trade status bar
  - Auto equip item untuk trade

---

## ⚠️ Catatan Penting

1. **Auto Fish Mode:** Pastikan memilih mode yang sesuai dengan kebutuhan
2. **Webhook:** Pastikan URL/token valid untuk menghindari error
3. **Auto Quest:** Quest akan otomatis stop dan restore position setelah selesai
4. **Auto TP Event:** Script akan mengikuti mode Auto Fish yang sedang berjalan
5. **Performance:** Gunakan Low Graphics dan FPS Cap untuk performa lebih baik

---

## 🐛 Troubleshooting

### Auto Fish tidak jalan
- Pastikan fishing rod sudah di-equip
- Cek apakah network folder ditemukan
- Restart script jika perlu

### Webhook tidak mengirim
- Cek URL/token valid
- Pastikan tier filter sudah di-set
- Cek connection status di tab Webhook

### Quest tidak pindah spot
- Pastikan Auto Fish berjalan
- Cek network events (RE/FishCaught)
- Restart quest jika stuck

---

## 📝 Changelog

### Version 2.1
- ✅ Added Deepsea Quest
- ✅ Added Element Quest
- ✅ Fixed Quest Artifact spot progression
- ✅ Improved Auto TP Event dengan platform method
- ✅ Auto Fish mode following untuk Auto TP Event
- ✅ Multi-select event monitoring
- ✅ Enhanced quest progress tracking

---

## 📞 Support

- **Discord:** Join server melalui Script Information tab
- **GitHub:** Check Script Information tab untuk link

---

## 📄 License

Script ini dibuat untuk personal use. Jangan redistribute tanpa izin developer.

---

**Made with ❤️ by @dzzzet**

Discord Server :
https://discord.gg/kRfMca3zUV

<img width="468" height="528" alt="image" src="https://github.com/user-attachments/assets/6aa6f375-d3e7-4fac-bf4e-95647f7f412c" />

