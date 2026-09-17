import { useChroma } from './chroma'

type PixelSpriteProps = {
  src: string
  x: number
  y: number
  w: number
  h?: number
  frames?: 2
  className?: string
}

export function PixelSprite({
  src,
  x,
  y,
  w,
  h,
  frames = 2,
  className,
}: PixelSpriteProps) {
  const keyed = useChroma(src)
  return (
    <div
      className={`pixel-sprite ${className ?? ''}`}
      style={{
        left: `${x}%`,
        top: `${y}%`,
        width: `${w}%`,
        height: h ? `${h}%` : undefined,
        aspectRatio: h ? undefined : '1',
        backgroundImage: `url(${keyed})`,
        backgroundSize: `${frames * 100}% 100%`,
      }}
      aria-hidden
    />
  )
}

export function PixelStill({
  src,
  x,
  y,
  w,
  h,
  className,
}: Omit<PixelSpriteProps, 'frames'>) {
  const keyed = useChroma(src)
  return (
    <img
      className={`sprite pixelated ${className ?? ''}`}
      src={keyed}
      alt=""
      draggable={false}
      style={{
        left: `${x}%`,
        top: `${y}%`,
        width: `${w}%`,
        height: h ? `${h}%` : undefined,
      }}
    />
  )
}

export function Backdrop({ src }: { src: string }) {
  return <img className="art-bg pixelated" src={src} alt="" draggable={false} />
}

export function ChromaImg({ src, className }: { src: string; className?: string }) {
  const keyed = useChroma(src)
  return <img className={className} src={keyed} alt="" draggable={false} />
}
