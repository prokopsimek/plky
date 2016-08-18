class SpeechToText

  def self.process_all
    gcloud = ::Gcloud.new "speech2text@test-23f9c.iam.gserviceaccount.com",
                               "#{Rails.root}/config/gauth.json"
  end

end
