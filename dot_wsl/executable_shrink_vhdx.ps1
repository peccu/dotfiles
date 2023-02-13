# needs admin
wsl --shutdown
diskpart /s $PSScriptRoot\shrink_vhdx.diskpart
wsl -l -v
# https://github.com/microsoft/WSL/issues/5401#issuecomment-1017987976
Restart-Service vmcompute
