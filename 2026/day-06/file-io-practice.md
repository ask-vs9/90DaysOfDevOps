# File I/O Practice

## Files Created
- notes.txt

## Commands Used

### `touch notes.txt`
Created an empty file.

### `echo "Line 1" > notes.txt`
Wrote first line to file (overwrite mode).

### `echo "Line 2" >> notes.txt`
Appended a new line.

### `echo "Line 3" | tee -a notes.txt`
Displayed output and appended to file.

### `cat notes.txt`
Displayed complete file content.

### `head -n 2 notes.txt`
Displayed first two lines.

### `tail -n 2 notes.txt`
Displayed last two lines.

## Key Learning

Text files are everywhere in DevOps:
logs, configs, scripts, Dockerfiles, YAML files.

Fast file handling improves troubleshooting and automation speed.
