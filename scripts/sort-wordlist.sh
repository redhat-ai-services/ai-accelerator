#!/bin/bash

set -e

lint_sort_wordlist(){
  LC_COLLATE=C sort -u < .wordlist-txt > .tmp-wordlist
  mv .tmp-wordlist .wordlist-txt
}

lint_sort_wordlist
