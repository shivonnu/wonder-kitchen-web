import { useGame } from '../state/GameState'

export function TitleView() {
  const { startNew, continueGame, hasSave } = useGame()
  return (
    <div className="title-screen">
      <div className="title-sky">
        <span className="big-star" />
        <span className="big-star delay" />
      </div>
      <h1>ほししおの台所</h1>
      <p className="tagline">夜の島で、月あかりポタージュをつくる。</p>
      <div className="title-actions">
        <button type="button" className="primary" onClick={startNew}>
          はじめる
        </button>
        {hasSave && (
          <button type="button" onClick={continueGame}>
            つづきから
          </button>
        )}
      </div>
      <p className="credit">クリックして、気になるところを探してね。失敗はないよ。</p>
    </div>
  )
}

export function EndingView() {
  const { reset } = useGame()
  return (
    <div className="title-screen ending-screen">
      <div className="bowl finished huge" />
      <h1>おしまい</h1>
      <p className="tagline">
        しおんは空になった器を抱えて、窓の外の月に手を振った。星しおの島の夜は、まだ続く。
      </p>
      <div className="title-actions">
        <button type="button" className="primary" onClick={reset}>
          タイトルへ
        </button>
      </div>
    </div>
  )
}
