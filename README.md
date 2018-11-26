## upvid.sh
### bash script for downloading upvid files

##### Download single file from upvid

```bash
./upvid.sh url
```

##### Batch-download files from URL list (url-list.txt must contain one upvid.mobi url per line)

```bash
./upvid.sh url-list.txt
```

##### Example:

```bash
./upvid.sh http://upvid.mobi/9hSdaL6EXli
```

upvid.sh uses `wget` with the `-C` flag, which skips over completed files and attempts to resume partially downloaded files.

### Requirements: `coreutils`, `grep`, `sed`, **`wget`**
