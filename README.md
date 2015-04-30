# Alfred workflow to use a dict.cc wordbook offline

## Features

* translates in both directions (using sqlite databse with FTS4)
* translate via keyword
* translate from selected text in OS X via global hotkey
* save favorite words (by clicking the translation in Alfred)
* retrieve list of favorite words (using keyword)

![Alfred Workflow for dict.cc offline](http://res.cloudinary.com/danielpichel/image/upload/w_500/v1430257766/dictcc_alfred.png)

## Getting Started

As it is not allowed to distribute copies of dict.cc dictionary you need to do some steps manually to get your offline dictionary working with Alfred:

1. download the [dict.cc - offline dictionary.alfredworkflow](https://github.com/danielpichel/dict.cc/blob/master/dict.cc%20-%20offline%20dictionary.alfredworkflow) and install via Alfred
2. download a wordbook of your choice at [dict.cc download site](http://www1.dict.cc/translation_file_request.php?l=e) (always select the UTF-8 version)
3. go to your workflow directory in Alfred and copy the downloaded dictionary file to the "db" directory (e.g. db/de_en.txt) 
4. run *ruby scripts/creatdb.rb* from your terminal (while being in the Alfred workflow folder), this convertes the dictionary into a sqlite database

## Configuration

* use config.yaml in this workflow directory
* setup storage/file to a file of your choice (otherwise favoring is inactive), use full path + filename, e.g. /Users/username/vocab.tsv
* use `homepath` to point to your home directory, e.g. `"homepath/Dropbox/dict.txt"`

## Tip

Your favorite translations are stored tab separated in a file of your choice (-> see configuration). You can share it with other apps in order to learn your vocabulary. 

I highly recommend using [Flashcards](http://flashcardsdeluxe.com/Flashcards/) for iOS for this purpose. It also supports Dropbox Sync. You can point your vocabulary file to a folder in your Dropbox and access it via Flashcards.

