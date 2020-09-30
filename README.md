# Wiktionary

A package to extract Kanji Information from the Japanese language Wiktionary file (downloaded eg. from https://dumps.wikimedia.org/jawiktionary/20200920]).
The Wiktionary format is rather complicated and I have tried my best to clean up the formatting while preserving as much fo the original information as possible. Caution is nevertheless advisable.

# Usage

Add a Wiktionary dump (in Japanese) to the Wiktionary folder and rename to ```jawiktionary.xml```
Parse the dump using

```
let parser=WiktionaryImporter()
parser.parse()
let entry=parser.entry(character: "菅")
```

You can dump all entries as human-readable text files using  ```try parser.dump(to: url, useTable: true)```.` useTable: true` exports in a tab-delimted format to inspect the dumped file in a spreadsheet program. 
