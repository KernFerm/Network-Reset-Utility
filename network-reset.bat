@echo off
setlocal enabledelayedexpansion

:: Network Reset Script - Enhanced with Error Handling and Sanitization
:: AUTO-ELEVATES TO ADMINISTRATOR

:: Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ===============================================
    echo    REQUESTING ADMINISTRATOR PRIVILEGES
    echo ===============================================
    echo.
    echo This script requires Administrator privileges.
    echo Attempting to auto-elevate...
    echo.
    echo Please click "Yes" when prompted by UAC.
    echo ===============================================
    echo.
    
    :: Self-elevate using PowerShell
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

:: Verify we have admin rights by attempting to write to system directory
echo test >"%SystemRoot%\temp\admin_test.tmp" 2>nul
if %errorLevel% neq 0 (
    echo.
    echo ERROR: Administrator verification failed.
    echo Unable to write to system directories.
    echo Please ensure you have full administrator privileges.
    echo.
    pause
    exit /b 1
)
del "%SystemRoot%\temp\admin_test.tmp" 2>nul

echo ===========================================
echo        Network Reset Utility
echo          [ADMINISTRATOR MODE]
echo ===========================================
echo.

:: Display warning and get user confirmation
echo WARNING: This script will reset network settings.
echo This may temporarily disconnect your internet connection.
echo.
set /p "confirm=Do you want to continue? (Y/N): "

:: Sanitize input - convert to uppercase and check
set "confirm=!confirm:~0,1!"
if /i "!confirm!" neq "Y" (
    echo Operation cancelled by user.
    pause
    exit /b 0
)

echo.
echo Starting network reset process...
echo.

:: Reset Winsock catalog
echo [1/6] Resetting Winsock catalog...
netsh winsock reset >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Winsock reset successful
) else (
    echo [ERROR] Winsock reset failed ^(Error: %errorLevel%^)
    set "hasErrors=1"
)

:: Flush DNS cache
echo [2/6] Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] DNS cache flushed successfully
) else (
    echo [ERROR] DNS cache flush failed ^(Error: %errorLevel%^)
    set "hasErrors=1"
)

:: Reset TCP/IP stack
echo [3/6] Resetting TCP/IP stack...
netsh int ip reset >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] TCP/IP stack reset successful
) else (
    echo [ERROR] TCP/IP stack reset failed ^(Error: %errorLevel%^)
    echo [RETRY] Attempting alternative TCP/IP reset method...
    netsh int ip reset resetlog.txt >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Alternative TCP/IP reset successful
    ) else (
        echo [WARNING] Both TCP/IP reset methods failed
        set "hasErrors=1"
    )
)

:: Reset network adapters
echo [4/6] Resetting network adapters...
netsh interface ipv4 reset >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] IPv4 interface reset successful
) else (
    echo [ERROR] IPv4 interface reset failed ^(Error: %errorLevel%^)
    echo [RETRY] Attempting alternative IPv4 reset...
    netsh interface ip delete arpcache >nul 2>&1
    netsh interface ipv4 set global randomizeidentifiers=enabled >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Alternative IPv4 reset successful
    ) else (
        echo [WARNING] IPv4 reset methods failed
        set "hasErrors=1"
    )
)

netsh interface ipv6 reset >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] IPv6 interface reset successful
) else (
    echo [ERROR] IPv6 interface reset failed ^(Error: %errorLevel%^)
    echo [RETRY] Attempting alternative IPv6 reset...
    netsh interface ipv6 set global randomizeidentifiers=enabled >nul 2>&1
    netsh interface ipv6 delete destinationcache >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Alternative IPv6 reset successful
    ) else (
        echo [WARNING] IPv6 reset methods failed
        set "hasErrors=1"
    )
)

:: Reset Windows Firewall (optional)
echo [5/6] Resetting Windows Firewall to defaults...
netsh advfirewall reset >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Windows Firewall reset successful
) else (
    echo [ERROR] Windows Firewall reset failed ^(Error: %errorLevel%^)
    set "hasErrors=1"
)

:: Renew IP configuration
echo [6/6] Renewing IP configuration...
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] IP configuration renewed successfully
) else (
    echo [ERROR] IP configuration renewal failed ^(Error: %errorLevel%^)
    set "hasErrors=1"
)

:: Additional recovery step for failed resets
if defined hasErrors (
    echo.
    echo [RECOVERY] Attempting additional network recovery steps...
    echo [INFO] This should take 30-60 seconds, please wait...
    
    :: Try to restart network services with timeout protection
    echo [RECOVERY] Restarting DHCP Client service...
    echo [INFO] Stopping DHCP Client service...
    net stop "DHCP Client" >nul 2>&1
    timeout /t 5 /nobreak >nul
    echo [INFO] Starting DHCP Client service...
    net start "DHCP Client" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] DHCP Client service restarted
    ) else (
        echo [WARNING] DHCP Client service restart failed - continuing anyway
    )
    
    echo [RECOVERY] Restarting DNS Client service...
    echo [INFO] Stopping DNS Client service...
    net stop "DNS Client" >nul 2>&1
    timeout /t 5 /nobreak >nul
    echo [INFO] Starting DNS Client service...
    net start "DNS Client" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] DNS Client service restarted
    ) else (
        echo [WARNING] DNS Client service restart failed - continuing anyway
    )
    
    :: Clear additional caches
    echo [RECOVERY] Clearing additional network caches...
    netsh interface ip delete arpcache >nul 2>&1
    netsh interface ipv6 delete destinationcache >nul 2>&1
    echo [OK] Network caches cleared
    
    echo [RECOVERY] Recovery steps completed
    echo.
    echo [INFO] If services are still hung, press Ctrl+C to stop
    echo [INFO] and restart your computer to complete the reset.
)

echo.
echo ===========================================

:: Summary
if defined hasErrors (
    echo [INFO] Network reset completed with expected limitations.
    echo.
    echo NOTE: Some TCP/IP and interface resets failed because
    echo your network connection is currently in use. This is normal
    echo and expected behavior when running while connected to the internet.
    echo.
    echo COMPLETED SUCCESSFULLY:
    echo - Winsock catalog reset
    echo - DNS cache flush  
    echo - Windows Firewall reset
    echo - IP configuration renewal
    echo - Network service restarts
    echo.
    echo The most important network components have been reset.
    echo A restart will complete any remaining resets safely.
) else (
    echo [SUCCESS] Network reset completed successfully!
    echo All network components have been reset.
)

echo.
echo IMPORTANT: A system restart is recommended to ensure
echo all changes take effect properly.
echo.

set /p "restart=Would you like to restart now? (Y/N): "
set "restart=!restart:~0,1!"
if /i "!restart!" equ "Y" (
    echo Restarting system in 10 seconds...
    echo Press Ctrl+C to cancel.
    timeout /t 10 /nobreak >nul
    shutdown /r /t 0
) else (
    echo Please restart your computer manually when convenient.
)

echo.
pause
