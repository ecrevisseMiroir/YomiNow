import { useEffect, useRef } from "react"
import { Camera, ImagePlus } from "lucide-react"
import { useCamera } from "@/hooks/useCamera"

interface CameraViewProps {
  onCapture: (imageData: string) => void
}

export function CameraView({ onCapture }: CameraViewProps) {
  const { videoRef, isActive, error, start, capture } = useCamera()
  const fileInputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    start()
  }, [start])

  const handleCapture = () => {
    const imageData = capture()
    if (imageData) {
      onCapture(imageData)
    }
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = () => {
      if (typeof reader.result === "string") {
        onCapture(reader.result)
      }
    }
    reader.readAsDataURL(file)
    e.target.value = ""
  }

  const uploadButton = (
    <button
      onClick={() => fileInputRef.current?.click()}
      className="flex items-center gap-2 rounded-full bg-zinc-800/80 px-6 py-3 text-sm font-medium text-white backdrop-blur-sm transition-transform active:scale-95"
    >
      <ImagePlus className="h-4 w-4" />
      Upload image
    </button>
  )

  return (
    <div className="relative flex flex-1 flex-col items-center justify-center bg-black">
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        className="hidden"
      />

      {error ? (
        <div className="flex flex-col items-center gap-4 p-8 text-center">
          <p className="text-red-400">{error}</p>
          <div className="flex gap-3">
            <button
              onClick={start}
              className="rounded-full bg-zinc-800/80 px-6 py-3 text-sm font-medium text-white"
            >
              Retry camera
            </button>
            {uploadButton}
          </div>
        </div>
      ) : (
        <>
          <video
            ref={videoRef}
            autoPlay
            playsInline
            muted
            className="h-full w-full object-cover"
          />

          {isActive && (
            <div className="absolute bottom-0 left-0 right-0 flex items-center justify-center gap-4 pb-10">
              <button
                onClick={handleCapture}
                className="flex h-18 w-18 items-center justify-center rounded-full border-4 border-white bg-white/20 backdrop-blur-sm transition-transform active:scale-90"
                aria-label="Take photo"
              >
                <Camera className="h-8 w-8 text-white" />
              </button>
              <div className="absolute right-6">{uploadButton}</div>
            </div>
          )}
        </>
      )}
    </div>
  )
}
