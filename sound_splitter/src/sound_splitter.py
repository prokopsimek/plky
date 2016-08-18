from pydub import AudioSegment
from pydub.silence import split_on_silence
import os
import sys

print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv)

ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
INPUT_FOLDER = os.path.join(ROOT_DIR, 'input/')

set_min_silence_len = int(str(sys.argv[1]) or 200)
set_silence_thresh = int(str(sys.argv[2]) or -29)

sound_file = AudioSegment.from_mp3(os.path.join(ROOT_DIR, "input/input.mp3"))
audio_chunks = split_on_silence(sound_file, 
    # must be silent for at least half a second
    min_silence_len = set_min_silence_len,

    # consider it silent if quieter than -16 dBFS
    silence_thresh = set_silence_thresh
)

for i, chunk in enumerate(audio_chunks):

    out_file = os.path.join(ROOT_DIR, "output/output-{0}.flac".format(i))
    print "exporting", out_file
    chunk.export(out_file, format="flac", bitrate="44k" , parameters=["-ac", "1"])