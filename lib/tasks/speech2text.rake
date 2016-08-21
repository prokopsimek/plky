desc "This is rake task for speech2text"

namespace :speech2text do

  task :test, [:any_arg, :any_arg_sec] => :environment do |t, args|
    ap args
  end

  task :split_input, [:min_silence_len, :silence_thresh] => :environment do |t, args|
    parse_audio_with_python = "python #{Rails.root}/audio_splitter/src/audio_splitter.py"
    system(parse_audio_with_python)
  end

  task :audio_to_text => :environment do
    all_sound_files = Dir.glob(Rails.root + 'audio_splitter/output/*')
    raise 'There are no files in output folder!' if all_sound_files.blank?

    STDOUT.puts "How many files do you want to transcript? (Output files: #{all_sound_files.size})"
    files_to_process = STDIN.gets.strip.to_i

    result_array = []

    all_sound_files.first(files_to_process).each do |file_path|
      ap "====== START of parsing ======"
      ap "Processing file: #{file_path}"
      result_array << one_audio_speech_to_text(file_path)
    end

    ap result_array
  end

  def one_audio_speech_to_text(file_path)
    result_hash = { 'name' => file_path.split('/').last }

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
        transcripted_text = result_json['results'].first['alternatives'].first['transcript']
        confidence = result_json['results'].first['alternatives'].first['confidence']
        ap "Transcripted text: '#{transcripted_text}'"
        ap "Confidence: #{confidence}"
        ap "====== END of parsing ======"
        puts
        puts
        splitted_path = file_path.split('/')

        File.rename(
          file_path,
          splitted_path[0...-1].join('/').to_s + "/#{transcripted_text.to_s.parameterize.downcase}.#{file_path.split('.').last}"
        )

        result_hash['transcripted_text'] = transcripted_text
        result_hash['confidence'] = confidence
      rescue => error
        ap "Something bad happened :-("
        ap result_json
        err_msg = error.to_s.first(100)
        ap err_msg
        ap result_json.to_s.first(300)
        result_hash['error'] = err_msg
        result_hash['result_json'] = result_json.to_s.first(300)
      end

      result_hash
    end

  end
end
