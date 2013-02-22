case Rails.env
when :deploy
  Bringit::Application.config.ssh_base_url = "git@bringit.digineo.de/"
  Bringit::Application.config.git_root = "/tmp/gitroot/"
else
  Bringit::Application.config.ssh_base_url = "git@localhost/"
  Bringit::Application.config.git_root = "/tmp/gitroot/"
end
