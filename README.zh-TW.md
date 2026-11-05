[Switch to English](README.md)

# kindle-kual-bt-page-turner

讓藍牙翻頁遙控器在越獄 Kindle 的**原生閱讀器**裡翻頁的 KUAL 插件。不用 SSH、不用 KOReader：把資料夾複製進 Kindle，在 KUAL 點一下安裝。

藍牙與翻頁的功能全部來自 Lucas Zampieri 的 [kindle-hid-passthrough](https://github.com/zampierilucas/kindle-hid-passthrough) 與 [kindle-button-mapper-rs](https://github.com/zampierilucas/kindle-button-mapper-rs)。這個插件只負責：

- 把上游的程式一起打包，不用另外去下載
- 用 KUAL 按鈕完成上游原本要 SSH 的安裝步驟
- 配對、按鍵對應的觸控介面改從 KUAL 開，**書庫裡不會多出任何書**
- 一鍵移除，以及 Kindle 進不了書庫時用 USB 救回的方法
- 附上 Kindle Oasis 2 韌體 5.13.5 用的核心模組（上游沒有這一版）

> **實測機型：** Kindle Oasis 2，韌體 5.13.5（build 371676），自訂兩鍵藍牙鍵盤：KUAL 安裝、從 KUAL 開配對與按鍵對應介面、原生閱讀器翻頁都已驗證（2026-11-05）。上游列出的其他機型理論上也能用，見 [Notes for AI](#notes-for-ai)。

## 需要的東西

- 已**越獄**的 Kindle，已安裝 **KUAL**
- 一個藍牙翻頁遙控器（上游的[相容清單](https://github.com/zampierilucas/kindle-hid-passthrough/blob/main/docs/compatibility.md)；有些遙控器要切成 BLE 模式才有反應）
- USB 線

## 安裝

1. 到 [Releases](../../releases/latest) 下載 **`bt-page-turner.zip`**，解壓縮。
2. Kindle 接電腦，把解出來的 **`extensions`** 資料夾複製到 Kindle 磁碟的根目錄（跟裡面原有的 `extensions` 合併）。
3. 退出 Kindle，打開 KUAL ▸ **藍牙翻頁器** ▸ **安裝／更新**。
4. 等約一分鐘，畫面會跳出「Installed」。

更新：照同樣步驟複製新版，再按一次**安裝／更新**。已配對的裝置和按鍵對應會保留。

## 第一次使用（只做一次）

### 0. 先決定遙控器送什麼鍵（可以自訂按鍵的遙控器／小鍵盤才需要）

建議：**下一頁的鍵＝ Page Down，上一頁的鍵＝ Page Up**。其實送什麼鍵都可以（下面第 2 步會記下你按的鍵），選這兩個是因為萬一按鍵對應沒在跑，它們也不會在搜尋框裡打出字來。不能自訂的翻頁遙控器就照原樣用。

### 1. 配對

1. 遙控器進入配對模式（通常是長按某個鍵到燈號快閃，請看遙控器說明）。
2. KUAL ▸ 藍牙翻頁器 ▸ **配對藍牙裝置**，KUAL 會關掉、開出配對介面（BT Manager）。
3. 掃描，在清單裡點你的遙控器，配對。清單上同一個裝置若同時出現 BLE 與 Classic，先選 BLE。

### 2. 設定哪顆鍵翻頁

1. KUAL ▸ 藍牙翻頁器 ▸ **設定按鍵對應**，開出 Mapper Manager。
2. **Bindings** 分頁 ▸ **+ Add** ▸ **Capture btn**，然後按一下遙控器上要當「下一頁」的鍵。
3. 跳出動作清單後，選上方的 **Kindle** 分頁 ▸ 選**下一頁**（`next_page`）。
4. 再做一次：**+ Add** ▸ **Capture btn** ▸ 按「上一頁」的鍵 ▸ **Kindle** 分頁 ▸ **上一頁**（`prev_page`）。

注意：
- **不要**選 **Keyboard** 分頁裡的 Page Up／Page Down：那是「再送出一個按鍵」，不是翻頁。
- `next_page_tap`／`prev_page_tap`（模擬點螢幕左右邊）只在一般翻頁沒反應時才用。
- 也會用 KOReader 的話，選 **Auto** 分頁的下一頁／上一頁：它會看畫面上是哪個閱讀器自動送對的指令。
- **按一下翻兩頁**的話：到 **Device** 分頁把這個遙控器設成獨佔（grab），系統就只收到一次。

### 之後平常怎麼用

- 藍牙背景程式在跑的時候，遙控器一開機就會自動連上，不用再配對。
- 開機自動啟動預設是**關**：重開機後要先按 KUAL ▸ 藍牙翻頁器 ▸ **啟動藍牙**。不想每次按，就打開「開機自動啟動」。
- 按鍵對應程式（上游設計）每次開機都會自己啟動，不受這個開關控制；它很輕量，只是在等輸入。

## 選單

KUAL ▸ **藍牙翻頁器**：

| 項目 | 作用 |
| --- | --- |
| 安裝／更新 | 安裝或更新全部（在背景跑，完成會跳出提示） |
| 配對藍牙裝置 | 開啟上游的 BT Manager：掃描、配對、連線、移除裝置 |
| 設定按鍵對應 | 開啟上游的 Mapper Manager：哪顆鍵＝下一頁／上一頁 |
| 啟動藍牙／停止藍牙 | 現在啟動或停止藍牙背景程式 |
| 開機自動啟動：開／關 | 開機時自動啟動藍牙背景程式。預設**關**：要用時先按「啟動藍牙」 |
| Diagnose | 把系統資訊寫進 `diagnose.txt`（只讀取、不改東西） |
| 全部移除 | 移除上游裝的所有東西（保留已配對的裝置清單） |

## 出問題時

| 狀況 | 做法 |
| --- | --- |
| 能進書庫、KUAL | KUAL ▸ 藍牙翻頁器 ▸ **全部移除** |
| 進不了書庫（白畫面、一直重開） | 接 USB，在 Kindle 磁碟根目錄建一個空檔 **`BT_DISABLE`**（沒有副檔名），然後重開機。藍牙和按鍵對應的背景程式都不會啟動。進得去之後再按「全部移除」，最後刪掉 `BT_DISABLE` |

另外上游本身有保護：開機自動啟動時，連續 3 次沒能穩定執行就會自己停掉開機自動啟動。

已知做不到的：如果 Kindle 壞到連 USB 磁碟都不出現，上面的方法都用不上，只能用上游說的 SSH（舊機型是 [usbnetlite](https://github.com/notmarek/kindle-usbnetlite)）或原廠重置。照上游的架構，它的程式在開機後段才啟動，走到這一步的機會很低，但不是零。

## 它會建立的檔案

| 檔案 | 位置 | 說明 |
| --- | --- | --- |
| `bt-page-turner.log` | `extensions/bt-page-turner/` | 每次操作的紀錄（英文＋中文），包含上游安裝程式的輸出 |
| `diagnose.txt` | `extensions/bt-page-turner/` | Diagnose 的輸出 |
| `kindle_hid_passthrough/`、`kindle-button-mapper/` | Kindle 磁碟根目錄 | 上游的程式與設定（已配對裝置在 `kindle_hid_passthrough/devices.conf`） |
| udev 規則、`hid-passthrough.conf`、`kindle-button-mapper.conf` | `/etc/`（系統分區，USB 看不到） | 上游安裝；插件在兩個開機設定裡加了 `BT_DISABLE` 檢查 |

## 已知限制

- 藍牙背景程式在跑的時候，Kindle 原本的藍牙（Audible 聽書）不能用（上游的限制）。
- 背景程式一直開著的耗電、休眠喚醒後遙控器能不能直接用，還沒實測。
- 用不同 USB 線傳檔時，若出現「小檔可以、幾 MB 的檔就卡住、Kindle 磁碟反覆斷線重連」，通常是線材問題，換一條線即可（實際發生過）。

## 移除

KUAL ▸ 藍牙翻頁器 ▸ **全部移除**，然後用 USB 刪掉 `extensions/bt-page-turner/`。

## Notes for AI

見 [CLAUDE.md](CLAUDE.md)：機型相依的部分、上游版本怎麼換、模組怎麼編。

## 授權

GPL-3.0，見 [LICENSE](LICENSE)。內含的上游程式與核心模組見 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)；兩個上游的原始碼附在每個 Release 裡。
