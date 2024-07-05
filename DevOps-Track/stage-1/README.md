# DevOps Stage 1: Linux User Creation Bash Script

## Task Overview
Your company has employed many new developers. As a SysOps engineer, you are tasked with writing a bash script called `create_users.sh` that reads a text file containing employee usernames and group names, formatted as `user;groups`. The script should create users and groups as specified, set up home directories with appropriate permissions and ownership, generate random passwords for the users, and log all actions to `/var/log/user_management.log`. Additionally, store the generated passwords securely in `/var/secure/user_passwords.txt`.

## Requirements
1. Each user must have a personal group with the same group name as the username. This group name will not be written in the text file.
2. A user can have multiple groups, each group delimited by a comma `","`.
3. Usernames and user groups are separated by a semicolon `";"` - Ignore whitespace.

Example:
    light;sudo,dev,www-data
    idimma;sudo
    mayowa;dev,www-data

For the first line, `light` is the username and groups are `sudo`, `dev`, `www-data`.

## Script Usage
The mentors will test your script by supplying the name of the text file containing usernames and groups as the first argument to your script (i.e., `bash create_users.sh <name-of-text-file>`).

## Acceptance Criteria
- **User Creation**: All users should be created and assigned to their groups appropriately.
- **Logging**: The file `/var/log/user_management.log` should be created and contain a log of all actions performed by your script.
- **Password Storage**: The file `/var/secure/user_passwords.txt` should be created and contain a list of all users and their passwords delimited by a comma, and only the file owner should be able to read it.
- **Documentation**: A technical article is required, clear and concise, capturing the reasoning behind each step in your script.

## Submission Mode
- **GitHub Repository**: Use a new repository for this task. Your script should be in the root directory.
- **Files**: Your repo should contain only 2 files - `README.md` and `create_users.sh`.
- **Submission Deadline**: Submit your task through the designated submission form by Wed 3rd July, at 11:59 PM GMT.

## Script Outline
The `create_users.sh` script will:
1. Read the input text file line by line.
2. Parse each line to extract the username and groups.
3. Create the user and their personal group.
4. Add the user to the specified groups.
5. Generate a random password for each user.
6. Set up the user's home directory with appropriate permissions.
7. Log all actions to `/var/log/user_management.log`.
8. Store the generated passwords in `/var/secure/user_passwords.txt`.

