module Breadcrubs
  def repository_breadcrumbs(repository, crumbs)
    result = [{ 
        name: 'Home',
        last: false,
        path: repository_path(repository.path)
      }].concat(crumbs.map do | i, c |
         {
           name: c,
           last: false,
           path: repository_path(repository.path, crumbs[0..i].join('/'))
         }
        end)
    result.last[:last] = true
    
    result
  end
end