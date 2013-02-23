case Rails.env
when 'production'
  Bringit::Application.config.ssh_base_url = "git@bringit.digineo.de/"
  Bringit::Application.config.git_root = "/tmp/gitroot/"
when 'test'
  Bringit::Application.config.ssh_base_url = "git@localhost/"
  Bringit::Application.config.git_root = "/tmp/gitroot-test/"
else
  Bringit::Application.config.ssh_base_url = "git@localhost/"
  Bringit::Application.config.git_root = "/tmp/gitroot/"
end
