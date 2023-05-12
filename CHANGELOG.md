## 1.2.1
- Fixed #7. Script is not restarting without --watch argument

## 1.2.0
- Added argument --exec to call custom command on source changes
```bash
darttrack ./lib --exec "dart test"
```


## 1.1.0
- Added github action to test pushed updates and deploy github pages

- Added argument --watch to set watch dir. Now you can start script with:

```bash
dartrack --watch "./watch/this/dir/to/changes" ...
```

- Added argument --script to set run sciprt. Now you can set run dart script with:

```bash
darttrack ./watch/dir --script "./path/to/run/script.dart"
```

## 1.0.1
- Added web card https://paveltretyakovru.github.io/argenius/

## 1.0.0
- Initial version.
