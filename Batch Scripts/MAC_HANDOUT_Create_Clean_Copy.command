#!/bin/sh

cd "${0%/*}"
cd ..

#Set project specific variables
PROJNAME="IntroToShaders"
FINALPATH="$root_vol$HOME/Desktop/$PROJNAME"

#Copy relevant folders to desktop (changes with each project)
ditto "../IntroToShaders/Assets" "$FINALPATH/Assets"
ditto "../IntroToShaders/ProjectSettings" "$FINALPATH/ProjectSettings"

#Copy relevant loose files to desktop (changes with each project)
