# ほししおの台所

夜の塩の島を舞台にした、ポイント＆クリックの小さな料理体験です。
キッチンから月のうら側へ行き、食材を集めて **月あかりポタージュ** をつくります。

マヨネーズや既存キャラクターは出てきません。特製調味料は星しおです。

## 遊ぶ

公開 URL: https://shivonnu.github.io/wonder-kitchen-web/

Godot 4 の HTML5 書き出しです。初回は wasm と pck でおよそ 55MB 読み込みます。
クリックで進みます。失敗はありません。タイトルは「はじめる」または Enter です。
料理は左の棚の食材を持って、まな板・蛇口・鍋へ置きます。スマホは縦でも横でも、キッチン全体が画面に収まります。横画面では操作を右に寄せて、絵を16:9のままフィットさせます。

進行はブラウザ内（Godot の `user://`）に保存されます。

## ローカル（Godot）

[Godot 4.7](https://godotengine.org/download) で:

```
godot --path godot
```

GitHub Pages と同じ HTML5 を書き出すには:

```
BASE_PATH=/wonder-kitchen-web/ ./scripts/export-godot-web.sh
mkdir -p /tmp/pages/wonder-kitchen-web
cp -a build/web/. /tmp/pages/wonder-kitchen-web/
python3 -m http.server 8088 --directory /tmp/pages
```

ブラウザで http://127.0.0.1:8088/wonder-kitchen-web/ を開きます。

## React 試作

以前の React 版は [`src/`](src/) に残っています。

```
npm install
npm run dev
```

## GitHub Pages

`main` への push で GitHub Actions が Godot の Web 書き出しを GitHub Pages に載せます。
GitHub Pages は COOP/COEP を付けないため、HTML5 はスレッドなし（`web_nothreads_release`）です。PWA にはしていません。

### 初回だけ必要な設定

Actions だけでは Pages をオンにできないので、オーナーが一度だけ UI で有効化します。

1. https://github.com/shivonnu/wonder-kitchen-web/settings/pages を開く
2. **Build and deployment → Source** を **GitHub Actions** にする
3. Actions の失敗した **Deploy GitHub Pages** を **Re-run all jobs** する

デプロイログに `Failed to create deployment (status: 404)` と出る場合は、この設定がまだです。
