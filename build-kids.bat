@echo off
rem Kids-plezy: codegen + release APK build
cd /d "%~dp0"
call flutter pub get || goto :fail
call dart run slang || goto :fail
call dart run build_runner build --delete-conflicting-outputs || goto :fail
call flutter build apk --release || goto :fail
echo.
echo BUILD OK: %~dp0build\app\outputs\flutter-apk\app-release.apk
explorer "%~dp0build\app\outputs\flutter-apk"
pause
exit /b 0
:fail
echo.
echo BUILD FAILED - copy the errors above into the chat.
pause
exit /b 1
