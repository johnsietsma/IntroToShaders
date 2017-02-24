@ECHO OFF

::Set project specific variables
SET projName=IntroToShaders
SET finalPath=%USERPROFILE%\Desktop\%projName%

::Copy relevant folders to desktop (changes with each project)
xcopy /s/y/i "..\IntroToShaders\Assets" "%finalPath%\Assets"
xcopy /s/y/i "..\IntroToShaders\ProjectSettings" "%finalPath%\ProjectSettings"

::Copy relevant loose files to desktop (changes with each project)
