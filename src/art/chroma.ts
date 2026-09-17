import { useEffect, useState } from 'react'

const cache = new Map<string, string>()

function keyMagenta(src: string): Promise<string> {
  const hit = cache.get(src)
  if (hit) return Promise.resolve(hit)
  return new Promise((resolve) => {
    const img = new Image()
    img.decoding = 'async'
    img.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = img.naturalWidth
      canvas.height = img.naturalHeight
      const ctx = canvas.getContext('2d')
      if (!ctx) {
        resolve(src)
        return
      }
      ctx.drawImage(img, 0, 0)
      const data = ctx.getImageData(0, 0, canvas.width, canvas.height)
      const px = data.data
      for (let i = 0; i < px.length; i += 4) {
        const r = px[i]
        const g = px[i + 1]
        const b = px[i + 2]
        if (r > 150 && b > 150 && g < 140 && r + b > g * 2 + 80) px[i + 3] = 0
      }
      ctx.putImageData(data, 0, 0)
      canvas.toBlob((blob) => {
        if (!blob) {
          resolve(src)
          return
        }
        const url = URL.createObjectURL(blob)
        cache.set(src, url)
        resolve(url)
      })
    }
    img.onerror = () => resolve(src)
    img.src = src
  })
}

export function useChroma(src: string) {
  const [url, setUrl] = useState<string | null>(null)
  useEffect(() => {
    let cancelled = false
    setUrl(null)
    void keyMagenta(src).then((next) => {
      if (!cancelled) setUrl(next)
    })
    return () => {
      cancelled = true
    }
  }, [src])
  return url
}
