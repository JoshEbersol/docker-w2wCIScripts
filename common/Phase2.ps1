#-----------------------
# Phase2.ps1
#-----------------------

$ErrorActionPreference='Stop'

echo "$(date) Phase2.ps1 started" >> $env:SystemDrive\packer\configure.log

try {
    echo "$(date) Phase2.ps1 starting" >> $env:SystemDrive\packer\configure.log    

    #--------------------------------------------------------------------------------------------
    # Install privates
    echo "$(date) Phase2.ps1 Installing privates..." >> $env:SystemDrive\packer\configure.log    
    powershell -command "$env:SystemDrive\packer\InstallPrivates.ps1"

    #--------------------------------------------------------------------------------------------
    # Initiate Phase3
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-command c:\packer\Phase3.ps1"
    $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:01:00
    Register-ScheduledTask -TaskName "Phase3" -Action $action -Trigger $trigger -User SYSTEM -RunLevel Highest
}
Catch [Exception] {
    echo "$(date) Phase2.ps1 complete with Error '$_'" >> $env:SystemDrive\packer\configure.log
    exit 1
}
Finally {
    # Disable the scheduled task
    echo "$(date) Phase2.ps1 disabling scheduled task.." >> $env:SystemDrive\packer\configure.log
    $ConfirmPreference='none'
    Get-ScheduledTask 'Phase2' | Disable-ScheduledTask

    # Reboot
    echo "$(date) Phase2.ps1 completed. Rebooting" >> $env:SystemDrive\packer\configure.log
    shutdown /t 0 /r /f /c "Phase1"
    echo "$(date) Phase2.ps1 complete successfully at $(date)" >> $env:SystemDrive\packer\configure.log

} 

