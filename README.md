# DartTrack

Application to watch files changes and restart dart script.

![Demo image](web_src/demo.gif "Demo")

## Installation

### With dart pub
You can use the application like a global cli application with dart pub uitilete
```bash
dart pub global activate darttrack
# or
flutter pub global activate darttrack
```

### From source
Olso you can compile application from source

```bash
# Clone sources
git clone https://github.com/paveltretyakovru/darttrack.git
cd darttrack

# Compile it to executable file
dart compile exe bin/darttrack.dart -o build/darttrack

# Moving exe file to bin (you can move it to any PATH bin folder)
# /usr/bin/ - work example, but need sudo access to move
sudo mv build/darttrack /usr/bin/
```

## Usage
```bash
darttrack ./lib ./bin/yourscript.dart
```

It's run *./bin/yourscript.dart* script and start watching *./lib* diretory to changes.
If files in the directory is changed, script will be restarted