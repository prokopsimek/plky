from pydub import AudioSegment
from pydub.silence import split_on_silence
import os
import sys
import glob

ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
INPUT_FOLDER = os.path.join(ROOT_DIR, 'input/')
OUTPUT_FOLDER = os.path.join(ROOT_DIR, 'output/')


input_set_min_silence_len = raw_input("Set 'min_silence_len' (default: 200):")
set_min_silence_len = int(input_set_min_silence_len or 200)
print "Value 'set_min_silence_len':", set_min_silence_len

input_set_silence_thresh = raw_input("Set 'silence_thresh' (default: -16):")
set_silence_thresh = int(input_set_silence_thresh or -16)
print "Value 'set_silence_thresh':", set_silence_thresh

input_set_keep_silence = raw_input("Set 'keep_silence' (default: 200):")
set_keep_silence = int(input_set_keep_silence or 200)
print "Value 'set_keep_silence':", set_keep_silence

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

	print "dBFS of file:", sound_file.dBFS
	input_set_dbfs = raw_input("Set 'dbfs' (now: " + str(set_silence_thresh) + "):")
	set_silence_thresh = int(input_set_dbfs or set_silence_thresh)
	print "Value 'set_dbfs':", set_silence_thresh

	audio_chunks = split_on_silence(sound_file, 
	    # (in ms) minimum length of a silence to be used for a split. default: 1000ms
	    min_silence_len = set_min_silence_len,

	    # (in dBFS) anything quieter than this will be considered silence. default: -16dBFS
	    silence_thresh = set_silence_thresh,

	    # (in ms) amount of silence to leave at the beginning and end of the chunks. 
	    # Keeps the sound from sounding like it is abruptly cut off. (default: 100ms)
	    keep_silence = set_keep_silence
	)

	for i, chunk in enumerate(audio_chunks):

	    out_file = os.path.join(OUTPUT_FOLDER, audio.split('.')[0] + "-out-{0}.flac".format(i))
	    print "Exporting", out_file
	    chunk.export(out_file, format="flac", bitrate="44k" , parameters=["-ac", "1"])