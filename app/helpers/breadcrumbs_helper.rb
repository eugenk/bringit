module BreadcrumbsHelper
  def repository_breadcrumbs(repository, crumbs) 
    result = [{ 
        name: 'Home',
        last: false,
        path: repository_path(repository.path)
    }]
      
    crumbs.each_with_index do | c, i |
      result << {
        name: c,
        last: false,
        path: browse_repository_path(repository.path, url: crumbs[0..i].join('/'))
      }
    end
    
    result.last[:last] = true
    
    puts "xxxxx"
    puts result
    
    result
  end
end