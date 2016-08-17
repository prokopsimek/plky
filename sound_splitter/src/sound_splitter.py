from pydub import AudioSegment
from pydub.silence import split_on_silence

sound_file = AudioSegment.from_mp3("../input/input.mp3")
audio_chunks = split_on_silence(sound_file, 
    # must be silent for at least half a second
    min_silence_len=200,

    # consider it silent if quieter than -16 dBFS
    silence_thresh=-26
)

for i, chunk in enumerate(audio_chunks):

    out_file = "../output/output{0}.mp3".format(i)
    print "exporting", out_file
    chunk.export(out_file, format="mp3")