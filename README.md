# id3_converter
Converts ID3 Tags of .mp3 files from CP1251 codepage (Russian Cyrillic) to UTF-8.

## to convert files inside of a dir
```ruby
dir = '/Volumes/Music/MySongs/'

# this *WONT* save the files (debug)
Id3Converter.convert_dir dir
Id3Converter.convert_dir dir, debug: true

# this *WILL* save the files!
Id3Converter.convert_dir dir, debug: false
```

---
> Note that v1 tags can be removed if try to save non ASCII text into.

