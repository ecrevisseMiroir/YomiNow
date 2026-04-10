import { RotateCcw } from "lucide-react"

interface ImageViewProps {
  imageData: string
  onRetake: () => void
}

export function ImageView({ imageData, onRetake }: ImageViewProps) {
  return (
    <div className="relative flex flex-1 flex-col bg-black">
      <img
        src={imageData}
        alt="Captured"
        className="h-full w-full object-contain"
      />

      <div className="absolute bottom-0 left-0 right-0 flex justify-center pb-10">
        <button
          onClick={onRetake}
          className="flex items-center gap-2 rounded-full bg-zinc-800/80 px-6 py-3 text-sm font-medium text-white backdrop-blur-sm transition-transform active:scale-95"
        >
          <RotateCcw className="h-4 w-4" />
          Retake
        </button>
      </div>
    </div>
  )
}
