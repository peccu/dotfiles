# -*- shell-script -*-
# https://stackoverflow.com/a/55077451/514411
function setup_locale(){
    sudo apt-get clean \
	&& sudo apt-get update \
	&& sudo apt-get install locales \
	&& echo "LC_ALL=en_US.UTF-8" | sudo tee -a /etc/environment \
	&& echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen \
	&& echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf \
	&& sudo locale-gen en_US.UTF-8
}
