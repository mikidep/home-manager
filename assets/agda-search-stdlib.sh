sqlite3 @docset@/standard-library.docset/Contents/Resources/docSet.dsidx "select * from searchIndex" \
  | fzf \
  | cut -d '|' -f 4 \
  | xargs -I % firefox --new-window @docset@/standard-library.docset/Contents/Resources/Documents/%
