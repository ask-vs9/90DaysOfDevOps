# Day 06 - Linux Fundamentals: Read and Write Text Files

## Objective

Practice basic file read/write operations using Linux commands.

## Commands Used

### 1. Create a File

```bash
touch notes.txt
```

Creates an empty file named `notes.txt`.

### 2. Write to File

```bash
echo "Learning Linux file operations" > notes.txt
```

Creates the file content or overwrites existing content.

### 3. Append Text

```bash
echo "Practicing redirection operators" >> notes.txt
echo "Using cat to read files" >> notes.txt
```

Adds new lines without overwriting existing content.

### 4. Use tee Command

```bash
echo "Using tee command for output" | tee -a notes.txt
```

Displays output on the screen and appends it to the file.

### 5. Read Entire File

```bash
cat notes.txt
```

Displays all file contents.

### 6. Read First Two Lines

```bash
head -n 2 notes.txt
```

Displays the first two lines.

### 7. Read Last Two Lines

```bash
tail -n 2 notes.txt
```

Displays the last two lines.

## Final notes.txt Content

```text
Learning Linux file operations
Practicing redirection operators
Using cat to read files
Using tee command for output
Reading files with head
Reading files with tail
DevOps engineers work with logs
Text files are important in Linux
Day 06 completed successfully
```

## Key Learnings

* `touch` creates files.
* `>` writes and overwrites data.
* `>>` appends data.
* `tee` writes and displays output simultaneously.
* `cat` reads entire files.
* `head` displays the beginning of a file.
* `tail` displays the end of a file.

