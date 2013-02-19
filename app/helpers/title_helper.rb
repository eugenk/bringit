module TitleHelper
  
  def full_title(page_title)
    return "bringit" if page_title.empty?
    "#{page_title} | bringit"
  end
  
end
