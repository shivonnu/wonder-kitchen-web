# Godot 版（試作）

ほししおの台所の Godot 4.7 移植です。公開中の GitHub Pages は、いまも React 版のままです。

## 動かし方

Godot 4.7 安定版を入れ、このフォルダを開きます。

```
godot --path godot
```

HTML5（スレッドなし）への書き出し:

```
godot --headless --path godot --export-release Web godot/export/web/index.html
```

ブラウザでは `file://` ではなく、ローカルサーバで `export/web/` を開いてください。
