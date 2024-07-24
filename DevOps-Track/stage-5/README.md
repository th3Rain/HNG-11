
# Devopsfetch Documentation

## Overview

Devopsfetch is a tool for DevOps professionals to collect and display system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses. It also provides a systemd service for continuous monitoring and logging of these activities.

## Before installing Devopsfetch, ensure you have the following prerequisites and requirements met:

1.	**Operating System:**
   -	Devopsfetch is designed for Linux systems. It has been tested primarily on Ubuntu.

2.	**Administrative Access:**
	-	You need to have root or sudo privileges to install dependencies, copy scripts to system directories, and set up systemd services.

3.	**Dependencies:**
   -	The installation script installs necessary dependencies, but you should be aware of them:
      -	iproute2 for the ss command to list active ports.
      -	docker.io for managing Docker images and containers.
      -	finger for displaying user information.
      -	nginx for Nginx server configuration information.
      -	logrotate for log rotation to manage log file size and retention.
      -	systemd for managing the service and timer.

4.	**Internet Connection:**
   - An active internet connection is required to download and install the necessary packages.

5.	**Basic Knowledge:**
   - Familiarity with Linux command-line operations.
   - Understanding of systemd for managing services and timers.
   - Basic knowledge of Docker, Nginx, and general system administration.

## Installation

To install Devopsfetch, follow these steps:

1. **Download the Scripts:**
   - Download the `devopsfetch.sh` script and the `install_devopsfetch.sh` installation script.

2. **Run the Installation Script:**
   ```bash
   chmod -x install_devopsfetch.sh
   ./install_devopsfetch.sh
   ```

   The installation script will:
   - Install necessary dependencies.
   - Copy the `devopsfetch.sh` script to `/usr/local/bin`.
   - Set up systemd service and timer for continuous monitoring and logging.
   - Configure log rotation.

## Usage

Devopsfetch provides several command-line options to retrieve and monitor system information. Here are the available options:

```bash
Usage: devopsfetch [OPTIONS]
Options:
  -p, --port [PORT]       Display active ports and services or details of a specific port
  -d, --docker [CONTAINER] List Docker images and containers or details of a specific container
  -n, --nginx [DOMAIN]    Display Nginx domains and ports or details of a specific domain
  -u, --users [USERNAME]  List users and their last login times or details of a specific user
  -t, --time [STARTTIME] [STOPTIME] Display activities within a specified time range
  -i, --install           Install missing required services
  -h, --help              Show this help message
```

## Examples

1. **Display Active Ports and Services:**
   ```bash
   devopsfetch -p
   ```

2. **Display Details of a Specific Port:**
   ```bash
   devopsfetch -p 80
   ```

3. **List Docker Images and Containers:**
   ```bash
   devopsfetch -d
   ```

4. **Display Details of a Specific Docker Container:**
   ```bash
   devopsfetch -d <container_name>
   ```

5. **Display Nginx Domains and Ports:**
   ```bash
   devopsfetch -n
   ```

6. **Display Details of a Specific Nginx Domain:**
   ```bash
   devopsfetch -n <domain>
   ```

7. **List Users and Their Last Login Times:**
   ```bash
   devopsfetch -u
   ```

8. **Display Details of a Specific User:**
   ```bash
   devopsfetch -u <username>
   ```

9. **Display Activities Within a Specified Time Range:**
   ```bash
   devopsfetch -t "starttime 00:00:00" "stoptime 23:59:59"
   ```

10. **Install Missing Required Services:**
    ```bash
    devopsfetch -i
    ```

## Service and Timer Configuration

The `devopsfetch` tool uses systemd for continuous monitoring and logging. The following configurations are created during installation:

### Service File: `/etc/systemd/system/devopsfetch.service`

```bash
[Unit]
Description=Devopsfetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch -t "starttime 00:00:00" "stoptime 23:59:59"
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

### Timer File: `/etc/systemd/system/devopsfetch.timer`

```bash
[Unit]
Description=Run devopsfetch every hour

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
```

## Log Rotation Configuration

Log rotation is configured to manage the size and retention of log files. The configuration file for log rotation is:

```bash
# /etc/logrotate.d/devopsfetch
/var/log/devopsfetch/*.log {
    daily
    missingok
    rotate 14
    compress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        systemctl restart devopsfetch.service
    endscript
}
```

## Steps to Enable and Start the Timer and Service

1. **Reload Systemd Daemon:**
   ```bash
   sudo systemctl daemon-reload
   ```

2. **Enable the Timer:**
   ```bash
   sudo systemctl enable devopsfetch.timer
   ```

3. **Start the Timer:**
   ```bash
   sudo systemctl start devopsfetch.timer
   ```

4. **Enable the Service:**
   ```bash
   sudo systemctl enable devopsfetch.service
   ```

5. **Start the Service:**
   ```bash
   sudo systemctl start devopsfetch.service
   ```

## Conclusion

Devopsfetch is a comprehensive tool for monitoring and logging critical system information, making it invaluable for DevOps professionals. With its easy installation and configuration, it ensures continuous monitoring and easy access to important system metrics.

## Sample Command and Output

To display activities from the last 2 hours using `devopsfetch`, you can use the following command:

### Sample Command

```bash
devopsfetch -t "starttime 12:00:00" "stoptime 14:00:00"
```

### Sample Output

```plaintext
Displaying activities from 2 hours ago to now:
-- Logs begin at Mon 2024-07-22 12:00:00 UTC, end at Mon 2024-07-22 14:00:00 UTC. --
TIME                          _HOSTNAME           MESSAGE
2024-07-22 12:01:22           hostname            Started Session 1 of user root.
2024-07-22 12:05:10           hostname            docker0: port 1(veth1234abcd) entered blocking state
2024-07-22 12:05:10           hostname            docker0: port 1(veth1234abcd) entered disabled state
2024-07-22 12:05:10           hostname            device veth1234abcd entered promiscuous mode
2024-07-22 12:05:10           hostname            IPv6: ADDRCONF(NETDEV_UP): veth1234abcd: link is not ready
2024-07-22 12:05:10           hostname            IPv6: ADDRCONF(NETDEV_CHANGE): veth1234abcd: link becomes ready
2024-07-22 12:05:10           hostname            docker0: port 1(veth1234abcd) entered blocking state
2024-07-22 12:05:10           hostname            docker0: port 1(veth1234abcd) entered forwarding state
2024-07-22 12:05:10           hostname            br-5678efgh: port 1(veth5678efgh) entered blocking state
2024-07-22 12:05:10           hostname            br-5678efgh: port 1(veth5678efgh) entered disabled state
2024-07-22 12:05:10           hostname            device veth5678efgh entered promiscuous mode
2024-07-22 12:05:10           hostname            IPv6: ADDRCONF(NETDEV_UP): veth5678efgh: link is not ready
2024-07-22 12:05:10           hostname            IPv6: ADDRCONF(NETDEV_CHANGE): veth5678efgh: link becomes ready
2024-07-22 12:05:10           hostname            br-5678efgh: port 1(veth5678efgh) entered blocking state
2024-07-22 12:05:10           hostname            br-5678efgh: port 1(veth5678efgh) entered forwarding state
2024-07-22 12:10:15           hostname            dockerd[1234]: Container abcdefgh1234 started
2024-07-22 12:12:35           hostname            sshd[1234]: Accepted password for user1 from 192.168.1.100 port 12345 ssh2
2024-07-22 12:12:35           hostname            sshd[1234]: pam_unix(sshd:session): session opened for user user1 by (uid=0)
2024-07-22 12:12:36           hostname            systemd[1]: Started Session 2 of user user1.
2024-07-22 12:20:22           hostname            sshd[1234]: Received disconnect from 192.168.1.100 port 12345:11: disconnected by user
2024-07-22 12:20:22           hostname            sshd[1234]: Disconnected from user1 192.168.1.100 port 12345
2024-07-22 12:20:22           hostname            sshd[1234]: pam_unix(sshd:session): session closed for user user1
2024-07-22 12:22:10           hostname            device veth5678efgh left promiscuous mode
2024-07-22 12:22:10           hostname            br-5678efgh: port 1(veth5678efgh) entered disabled state
2024-07-22 12:22:15           hostname            dockerd[1234]: Container abcdefgh1234 stopped
2024-07-22 12:25:30           hostname            systemd[1]: Started Session 3 of user root.
...
```
