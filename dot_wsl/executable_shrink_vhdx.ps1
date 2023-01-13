wsl --shutdown
diskpart /s $PSScriptRoot\shrink_vhdx.diskpart
wsl -l -v
echo maybe you need restart machine
