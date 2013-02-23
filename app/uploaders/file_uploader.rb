require 'carrierwave/processing/mime_types'

class FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  
  process :set_content_type
  
  storage :file

  def store_dir
    "uploads"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end


  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    SecureRandom.hex(20)
    #"something.jpg" if original_filename
  end

end
