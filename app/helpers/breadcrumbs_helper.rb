module BreadcrumbsHelper
  def repository_breadcrumbs(repository, crumbs, is_head, oid) 
    result = [{ 
        name: 'Home',
        last: false,
        path: is_head ? repository_path(repository.path) : browse_commits_root_path(repository.path, oid)
    }]
      
    crumbs.each_with_index do | c, i |
      url = crumbs[0..i].join('/')
      result << {
        name: c,
        last: false,
        path: is_head ? browse_repository_path(repository.path, url) : browse_commits_path(repository.path, oid, url)
      }
    end
    
    result.last[:last] = true
    
    result
  end
end