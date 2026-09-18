# ほししおの台所

夜の塩の島を舞台にした、ポイント＆クリックの小さな料理体験です。
キッチンから月のうら側へ行き、食材を集めて **月あかりポタージュ** をつくります。

マヨネーズや既存キャラクターは出てきません。特製調味料は星しおです。

## 遊ぶ

公開 URL: https://shivonnu.github.io/wonder-kitchen-web/

ローカルでは:

1. `npm install`
2. `npm run dev`
3. 画面の気になるところをクリック（失敗はありません）
4. ルナのメモ、星いも、月たまねぎ、月牛乳、星しおを集める
5. 「料理をはじめる」で手順どおりにクリック

進行はブラウザの `localStorage` に保存されます。

## Godot 版（移植中）

同じ物語を Godot 4.7 に移植した試作が [`godot/`](godot/) にあります。料理はボタン順ではなく、手に持って蛇口・まな板・包丁・鍋へ使います。公開サイトはまだ React 版です。

```
godot --path godot
```

## GitHub Pages

公開 URL: https://shivonnu.github.io/wonder-kitchen-web/

`main` への push で GitHub Actions が `dist/` を GitHub Pages に載せます。

### 初回だけ必要な設定

Actions だけでは Pages をオンにできないので、オーナーが一度だけ UI で有効化します。

1. https://github.com/shivonnu/wonder-kitchen-web/settings/pages を開く
2. **Build and deployment → Source** を **GitHub Actions** にする
3. Actions の失敗した **Deploy GitHub Pages** を **Re-run all jobs** する

デプロイログに `Failed to create deployment (status: 404)` と出る場合は、この設定がまだです。
