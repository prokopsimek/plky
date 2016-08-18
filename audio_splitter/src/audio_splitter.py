from pydub import AudioSegment
from pydub.silence import split_on_silence
import os
import sys
import glob

print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv)

ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
INPUT_FOLDER = os.path.join(ROOT_DIR, 'input/')
OUTPUT_FOLDER = os.path.join(ROOT_DIR, 'output/')

set_min_silence_len = int(str(sys.argv[1]) or 200)
set_silence_thresh = int(str(sys.argv[2]) or -29)

video_dir = '/home/johndoe/downloaded_videos/'  # Path where the videos are located
extension_list = ('*.mp4', '*.flv', '*.flac', '*.mp3', '*.wma')

os.chdir(OUTPUT_FOLDER)
for extension in extension_list:
	for f in glob.glob(extension):
	    os.remove(f)

os.chdir(INPUT_FOLDER)
for extension in extension_list:
    for audio in glob.glob(extension):
    	print ''
	print 'Splitting file', audio
	
	sound_file = AudioSegment.from_file(os.path.join(INPUT_FOLDER, audio))
	audio_chunks = split_on_silence(sound_file, 
	    # must be silent for at least half a second
	    min_silence_len = set_min_silence_len,

	    # consider it silent if quieter than -16 dBFS
	    silence_thresh = set_silence_thresh
	)

	for i, chunk in enumerate(audio_chunks):

	    out_file = os.path.join(OUTPUT_FOLDER, audio.split('.')[0] + "-out-{0}.flac".format(i))
	    print "Exporting", out_file
	    chunk.export(out_file, format="flac", bitrate="44k" , parameters=["-ac", "1"])