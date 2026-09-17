/** Public files under `public/art`, respecting Vite `base` (GitHub Pages subpath). */
export function artUrl(file: string) {
  return `${import.meta.env.BASE_URL}art/${file}`
}
