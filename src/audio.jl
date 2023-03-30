using FileIO: load, loadstreaming
import LibSndFile
using PortAudio

x0 = loadstreaming("audio\\test.wav")

# d = PortAudioStream(0,2)

PortAudioStream(0,2; samplerate=44100) do stream
    write(stream,x0)
end