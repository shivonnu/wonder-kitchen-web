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

## GitHub Pages

`main` への push で GitHub Actions が `dist/` を GitHub Pages に載せます。

初回だけリポジトリ設定が必要です。

1. この PR を `main` にマージする
2. GitHub の **Settings → Pages → Build and deployment → Source** を **GitHub Actions** にする
3. Actions の **Deploy GitHub Pages** が成功すると、上の URL で公開される
