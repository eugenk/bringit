module MimeTypeHelper
  
  def get_mime_string(filename, mimetype) 
    
    extension = File.extname(filename)[1..-1]
    
    case extension
    when 'rb'
      'text/x-ruby'
    when 'xml'
      'text/html'
    else
      mimetype.to_s
    end
    
  end
  
end
