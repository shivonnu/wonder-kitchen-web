import { useGame } from '../state/GameState'

function Star({ className }: { className?: string }) {
  return <span className={`star ${className ?? ''}`} aria-hidden />
}

export function KitchenArt() {
  const { hasFlag, hasItem, canCook } = useGame()
  return (
    <div className="art kitchen-art">
      <div className="wall" />
      <div className="counter" />
      <div className="backsplash" />
      <div className="window-frame">
        <div className="moon" />
        <Star className="s1" />
        <Star className="s2" />
        <Star className="s3" />
      </div>
      <div className="clock">☉</div>
      <div className="shelf">
        <span />
        <span />
        <span />
      </div>
      <div className="lamp" />
      <div className="pot" />
      <div className="sink" />
      <div className="table" />
      {!hasFlag('lunaLeft') && (
        <div className="luna" title="ルナ">
          <div className="ear left" />
          <div className="ear right" />
          <div className="body" />
        </div>
      )}
      <div className="shion">
        <div className="halo">✦</div>
        <div className="crystal" />
      </div>
      <div className={`salt-jar ${hasFlag('saltTaken') ? 'empty' : ''}`} />
      <div className="floor-gem" />
      {hasItem('memo') && hasFlag('lunaLeft') && <div className="memo-paper">MEMO</div>}
      {canCook && <div className="cook-glow">つくれる！</div>}
    </div>
  )
}

export function StarRoadArt() {
  return (
    <div className="art road-art">
      <div className="galaxy" />
      <div className="path" />
      <div className="meteor" />
      <div className="paws" />
      <div className="moon-gate" />
    </div>
  )
}

export function MoonFieldArt() {
  const { hasItem } = useGame()
  return (
    <div className="art field-art">
      <div className="horizon" />
      <div className="earth" />
      <div className={`crop potato ${hasItem('potato') ? 'gone' : ''}`} />
      <div className={`crop onion ${hasItem('onion') ? 'gone' : ''}`} />
      <div className="crater" />
      <div className="cave-mouth" />
    </div>
  )
}

export function MoonCaveArt() {
  const { hasItem } = useGame()
  return (
    <div className="art cave-art">
      <div className="drip left" />
      <div className="drip right" />
      <div className={`well ${hasItem('moonMilk') ? 'taken' : ''}`} />
      <div className="echo">しお</div>
    </div>
  )
}
