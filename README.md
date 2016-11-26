# id3_converter
Converts ID3 Tags of .mp3 files from CP1251 codepage (Russian Cyrillic) to UTF-8

## to convert files inside of a dir
`dir = "/Volumes/Music/MySongs"`

`Id3Converter.convert_dir dir` <- this *wont* save the file! (debug)

`Id3Converter.convert_dir dir, debug: false` <- this *will* save the file!
