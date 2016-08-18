desc "This is rake task for speech2text"

namespace :speech2text do
  task :test => :environment do
    all_sound_files = Dir.glob(Rails.root + 'sound_splitter/output/*')
    ap all_sound_files
    all_sound_files.each do |sound_file|
      audio = Speech::AudioToText.new(sound_file)
      ap "========================="
      ap "==========AUDIO=========="
      ap "========================="
      ap audio.to_text.inspect
      ap "========================="
    end

    ap "Processed #{all_sound_files.size} files"

  end

  task :test_gcloud => :environment do
    require "google/cloud/speech"
    gcloud = Google::Cloud.new "speech2text@test-23f9c.iam.gserviceaccount.com", "#{Rails.root}/config/gauth.json"

    gcloud.speech(scope: "https://www.googleapis.com/auth/cloud-platform")
    # all_sound_files = Dir.glob(Rails.root + 'sound_splitter/output/*')
    # ap all_sound_files
    # all_sound_files.each do |sound_file|
    #   audio = Speech::AudioToText.new(sound_file)
    #   ap "========================="
    #   ap "==========AUDIO=========="
    #   ap "========================="
    #   ap audio.to_text.inspect
    #   ap "========================="
    # end

    # ap "Processed #{all_sound_files.size} files"
    ap gcloud
  end

  task :new => :environment do
    recognizer = Pocketsphinx::AudioFileSpeechRecognizer.new

    all_sound_files = Dir.glob(Rails.root + 'sound_splitter/input/*')
    ap all_sound_files
    all_sound_files.each do |sound_file|
      recognizer.recognize(sound_file) do |speech|
        ap speech # => "go forward ten meters"
      end
    end
  end
end
