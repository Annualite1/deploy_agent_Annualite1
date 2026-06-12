# Automated Project Bootstrapping and Process Management

## Project Description

This project uses a shell script called `setup_project.sh` to automatically create a Student Attendance Tracker project.

The script creates the required folders and files, allows the user to change attendance threshold values, checks if Python3 is installed, and verifies that the project structure was created correctly.

The script also handles interruptions using `Ctrl+C`. If the setup is stopped before completion, it creates an archive of the project and removes the incomplete directory.

## Files

* setup_project.sh
* README.md

## How to Run

Open Git Bash in the project folder and run:

```bash
bash setup_project.sh
```

Enter a project name when prompted.

## Updating Thresholds

The script asks whether you want to update the attendance thresholds.

If you choose "yes", enter new values for:

* Warning threshold
* Failure threshold

The script uses `sed` to update the values in `config.json`.

## Health Check

The script checks whether Python3 is installed using:

```bash
python3 --version
```

A success or warning message is displayed.

## Testing the Archive Feature

1. Run the script.
2. Enter a project name.
3. Press `Ctrl+C` when prompted.
4. The script creates an archive and removes the incomplete project directory.

## Video Demonstration

Video Link:
