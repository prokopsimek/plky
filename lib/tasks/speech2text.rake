desc "This is rake task for speech2text"

namespace :speech2text do

  task :test, [:any_arg, :any_arg_sec] => :environment do |t, args|
    ap args
  end

  task :split_input, [:min_silence_len, :silence_thresh] => :environment do |t, args|
    min_silence_len = args.min_silence_len || 200
    silence_thresh = args.silence_thresh || -29

    parse_audio_with_python = "python #{Rails.root}/audio_splitter/src/audio_splitter.py #{min_silence_len} #{silence_thresh}"
    system(parse_audio_with_python)
  end

  task :audio_to_text, [:files_to_process_count] => :environment do |t, args|
    files_to_process = args.files_to_process_count.to_i || 1
    all_sound_files = Dir.glob(Rails.root + 'audio_splitter/output/*')

    raise 'There are no files in output folder!' if all_sound_files.blank?

    all_sound_files.first(files_to_process).each do |file_path|
      ap "====== START of parsing ======"
      ap "Processing file: #{file_path}"
      one_audio_speech_to_text(file_path)
    end

  end

  def one_audio_speech_to_text(file_path)
    json_body = {
      config: {
        encoding: "FLAC",
        sample_rate: 44100,
        languageCode: 'cs-cz',
        profanityFilter: 'false'
      },
      audio: {
        content: Base64.strict_encode64(File.read(file_path))
      }
    }

    response = HTTParty.post(
      "https://speech.googleapis.com/v1beta1/speech:syncrecognize?key=#{ENV.fetch('GOOGLE_API_BROWSER_KEY')}",
      headers: {
        'Content-Type' => 'application/json'
      },
      body: json_body.to_json
    )

    result_json = JSON.parse(response.body)

    if result_json['error']
      ap result_json['error']
    else
      begin
        ap "Transcripted text: '#{result_json['results'].first['alternatives'].first['transcript']}'"
        ap "Confidence: #{result_json['results'].first['alternatives'].first['confidence']}"
        ap "====== END of parsing ======"
        puts
        puts
      rescue => error
        ap "Something bad happened :-("
        ap result_json
        raise error
      end
    end

  end
end
