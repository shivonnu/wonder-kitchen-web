import { CookingView } from './components/CookingView'
import { Hud } from './components/Hud'
import { SceneView } from './components/SceneView'
import { EndingView, TitleView } from './components/TitleView'
import { GameProvider, useGame } from './state/GameState'

function Screen() {
  const { scene, fading } = useGame()
  return (
    <div className="app-shell">
      <Hud />
      {scene === 'title' && <TitleView />}
      {scene === 'cooking' && <CookingView />}
      {scene === 'ending' && <EndingView />}
      {scene !== 'title' && scene !== 'cooking' && scene !== 'ending' && (
        <SceneView />
      )}
      <div className={`scene-fade ${fading ? 'on' : ''}`} />
    </div>
  )
}

export default function App() {
  return (
    <GameProvider>
      <Screen />
    </GameProvider>
  )
}
