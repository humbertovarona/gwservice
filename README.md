# GWService Docker Image Documentation

## Introduction

This repository contains the Docker setup for the `gwservice`, a service designed to run a web application stack with `nginx` and `PHP-FPM`. The Docker image is built on either `Debian bullseye-slim` or `Ubuntu`, with various software packages installed, including `nginx`, `php-fpm`, and additional utilities like `mariadb-client` and `postgresql-client`.

The image is prepared to serve a PHP-based website, with configurations for both `nginx` and `PHP-FPM`. It also includes mechanisms to check the health of services and manage the startup of necessary processes.

## Version

1.0

## Release date

2024-07-21

## DOI

[https://doi.org/10.5281/zenodo.13328949](https://doi.org/10.5281/zenodo.13328949)

## License

This project is licensed under the MIT License. Feel free to use and modify the code as per the terms of the license.

## Cite as

Silena Herold-Garcia, Humberto L. Varona. (2024). Docker for georeferenced web services (gwservice). (1.0). Zenodo. https://doi.org/10.5281/zenodo.13328949

## How to make this docker

```bash
docker build -t gwservice .
```

## Installation from [Docker](https://hub.docker.com/u/humbertovarona)

### Debian-based Version

To pull the Debian-based version of the `gwservice` Docker image, run the following command:

```bash
docker pull humbertovarona/gwservice:deb.v1
```

### Ubuntu-based Version

To pull the Ubuntu-based version of the `gwservice` Docker image, run the following command:

```bash
docker pull humbertovarona/gwservice:ubu.v1
```

## Running the Container

### Running the Debian-based Version

To run the Debian-based version of the container, use the following command:

```bash
docker run -d --name gwebsite -p 8083:8083 \
-v $(pwd)/configs/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
-v $(pwd)/configs/php/php-fpm.conf:/etc/php/7.4/fpm/php-fpm.conf:ro \
-v $(pwd)/websites/website_directory:/var/www/html \
humbertovarona/gwservice:deb.v1
```

### Running the Ubuntu-based Version

To run the Ubuntu-based version of the container, use the following command:

```bash
docker run -d --name gwebsite -p 8083:8083 \
-v $(pwd)/configs/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
-v $(pwd)/configs/php/php-fpm.conf:/etc/php/7.4/fpm/php-fpm.conf:ro \
-v $(pwd)/websites/website_directory:/var/www/html \
humbertovarona/gwservice:ubu.v1
```

## Accessing the Container

To access the running container and open a bash shell, use the following command:

```bash
docker exec -it gwebsite /bin/bash
```

## Project Directory Structure

The project is structured as follows:

```plaintext
work_directory/
├── configs/
│   └── nginx/
│       └── nginx.conf
│   └── php/
│       └── php-fpm.conf
└── websites/
    └── website_directory/
        ├── index.html
        ├── styles.css
        ├── ...
        ├── ...
        └── script.js 
```

## Configuration Details

### Nginx Configuration (`nginx.conf`)

The `nginx.conf` file is configured to run `nginx` as the `www-data` user with a default worker process setting. The HTTP block includes settings for MIME types, connection handling, and file serving.

The server block listens on port `8083` and is configured to serve files from `/var/www/html`. It handles both static file requests and PHP file execution via `PHP-FPM`.

Key directives include:

- **listen 8083**: Specifies the port on which `nginx` will listen for incoming HTTP requests.
- **root /var/www/html**: Defines the document root for serving files.
- **index index.php index.html**: Specifies the default files to serve.
- **location ~ \.php$**: Configures `nginx` to process PHP files using `PHP-FPM`.

The `nginx.conf` file is configured to run `nginx` as the `www-data` user with optimized settings for serving a PHP-based web application. Below is the content of the `nginx.conf` file:

```nginx
user  www-data;
worker_processes  auto;
pid /run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout  65;
    types_hash_max_size 2048;

    server {
        listen 8083 default_server;
        listen [::]:8083 default_server;

        root /var/www/html;
        index index.php index.html;

        charset utf-8;

        server_name _;

        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        }

        location ~ /\.ht {
            deny all;
        }
    }
}
``` 
- **Nginx Configuration:**
  - The `nginx.conf` file sets up Nginx to listen on port `8083` and serve files from the `/var/www/html` directory. PHP files are processed by PHP-FPM using a Unix socket located at `/run/php/php7.4-fpm.sock`.

### PHP-FPM Configuration (`php-fpm.conf`)

The `php-fpm.conf` file configures the PHP FastCGI Process Manager (FPM) to listen on a Unix socket `/run/php/php7.4-fpm.sock`. The FPM pool is configured with dynamic child processes, with limits on the number of children and spare servers.

Key directives include:

- **listen = /run/php/php7.4-fpm.sock**: Specifies the socket path for `PHP-FPM`.
- **user = www-data**: Runs PHP processes as the `www-data` user.
- **pm = dynamic**: Enables dynamic process management.
- **pm.max_children = 5**: Limits the maximum number of child processes.

The `php-fpm.conf` file is configured to manage PHP processes using a Unix socket. Below is the content of the `php-fpm.conf` file:

```php-fpm
[global]
daemonize = no

[www]
listen = /run/php/php7.4-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
user = www-data
group = www-data

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

chdir = /
```

This enhanced `php-fpm.conf` file includes a comprehensive SMTP configuration, covering port, allowed networks, security settings, and more. It also handles file uploads with a specified maximum size. Below is the content of the enhanced `php-fpm.conf` file:

```php-fpm
[global]
daemonize = no

[www]
listen = /run/php/php7.4-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
user = www-data
group = www-data

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

chdir = /

; SMTP settings
php_flag[mail.add_x_header] = On
php_admin_value[sendmail_path] = "/usr/sbin/sendmail -t -i"
php_admin_value[smtp_port] = 587
php_admin_value[smtp] = "smtp.example.com"
php_admin_value[smtp_server] = "smtp.example.com"
php_admin_value[smtp_user] = "user@example.com"
php_admin_value[smtp_password] = "your_password"
php_admin_value[smtp_security] = "tls"
php_admin_value[smtp_auth] = "login"
php_admin_value[smtp_allowed_networks] = "127.0.0.0/8,192.168.0.0/16"

; File upload settings
php_admin_value[upload_max_filesize] = 10M
php_admin_value[post_max_size] = 12M
```

### Explanation

- **SMTP Configuration:**
  - `php_flag[mail.add_x_header]`: Adds an X-PHP-Originating-Script header in the emails sent using the `mail()` function.
  - `php_admin_value[sendmail_path]`: Specifies the path to the sendmail binary, ensuring that PHP can send emails using the server's SMTP configuration.
  - `php_admin_value[smtp_port] = 587`: Sets the SMTP port to 587, commonly used for secure mail submission.
  - `php_admin_value[smtp]`: Specifies the SMTP server address.
  - `php_admin_value[smtp_server]`: Alias for `smtp`, specifying the SMTP server.
  - `php_admin_value[smtp_user]`: Sets the username for SMTP authentication.
  - `php_admin_value[smtp_password]`: Specifies the password for SMTP authentication.
  - `php_admin_value[smtp_security]`: Sets the security protocol to `tls`, ensuring secure transmission.
  - `php_admin_value[smtp_auth]`: Specifies the authentication method, set to `login`.
  - `php_admin_value[smtp_allowed_networks]`: Defines the networks allowed to connect to the SMTP server, including local and private networks.

- **File Upload Configuration:**
  - `php_admin_value[upload_max_filesize] = 10M`: Limits the maximum size of individual files that can be uploaded to 10 MB.
  - `php_admin_value[post_max_size] = 12M`: Limits the maximum size of POST data, which includes files, to 12 MB.

These settings ensure secure and efficient handling of email transmission via SMTP and control over file upload sizes.

- **PHP-FPM Configuration:**
  - The `php-fpm.conf` file configures PHP-FPM to run as the `www-data` user and group, with a dynamic process manager that adjusts the number of child processes based on demand.

These configuration files are essential for ensuring that Nginx and PHP-FPM work together efficiently to serve a PHP-based website.
 

## Shell Scripts

### `startservices.sh`

This script is used to start the `PHP-FPM` service and `nginx` when the container is launched. It includes the following commands:

```bash
#!/bin/bash

service php7.4-fpm start

nginx -g "daemon off;"
```

### `checkservices.sh`

The `checkservices.sh` script is designed to monitor the health of the `PHP-FPM` and `nginx` services. It logs the status of these services to `/var/log/gwservice.log`.

Key checks include:

- **PHP-FPM Socket Check**: Ensures that the PHP-FPM socket `/run/php/php7.4-fpm.sock` is available.
- **Nginx Process Check**: Verifies that the `nginx` process is running by checking the PID file.

The script logs either a successful message or an error if any of the services are not running properly.

```bash
#!/bin/bash

LOGFILE="/var/log/gwservice.log"

if [ ! -S /run/php/php7.4-fpm.sock ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') php-fpm is NOT working properly." >> "$LOGFILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') php-fpm is working PROPERLY." >> "$LOGFILE"
fi

PIDFILE="/run/nginx.pid"
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if ps -p $PID > /dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') nginx is running (PID: $PID)" >> "$LOGFILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') nginx PID file exists but process is not running" >> "$LOGFILE"
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') nginx is not running" >> "$LOGFILE"
fi

```


## Additional Information

### Environment Variables

The Docker image uses the following environment variables:

- **DEBIAN_FRONTEND=noninteractive**: Ensures that `apt-get` installs packages without interactive prompts, suitable for Docker builds.

### Exposed Ports

- **Port 8083**: The container exposes port `8083` to the host system, allowing access to the web service hosted inside the container.

### Volumes

The following volumes are mounted when running the container:

- **Nginx Configuration**: `-v $(pwd)/configs/nginx/nginx.conf:/etc/nginx/nginx.conf:ro`
- **PHP-FPM Configuration**: `-v $(pwd)/configs/php/php-fpm.conf:/etc/php/7.4/fpm/php-fpm.conf:ro`
- **Web Content**: `-v $(pwd)/websites/website_directory:/var/www/html`

These volumes allow you to customize configurations and content without rebuilding the Docker image.

## Example Web Site for Testing

To test the `gwservice` Docker container, you can create a simple yet visually appealing website with enhanced CSS and JavaScript effects. This website will be placed in the `website_directory` directory under the `websites` folder. Below is an example of how to set up a more advanced website.


### `index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to GWService</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>Welcome to GWService</h1>
        <p>This is a visually enhanced HTML page served by Nginx and PHP-FPM running in a Docker container.</p>
        <button onclick="showMessage()">Click me</button>
        <div id="dynamicContent"></div>
    </div>
    <script src="script.js"></script>
</body>
</html>
```

### `styles.css`

```css
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(to right, #4facfe 0%, #00f2fe 100%);
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
}

.container {
    text-align: center;
    background: rgba(255, 255, 255, 0.9);
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

h1 {
    color: #333;
    font-size: 2.5em;
    margin-bottom: 20px;
}

p {
    color: #555;
    font-size: 1.2em;
    margin-bottom: 30px;
}

button {
    padding: 10px 20px;
    font-size: 16px;
    color: #fff;
    background-color: #4facfe;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

button:hover {
    background-color: #00f2fe;
}
```

### `script.js`

```javascript
function showMessage() {
    alert("GWService Docker Container is running successfully!");
    loadDynamicContent();
}

function loadDynamicContent() {
    const dynamicContent = document.getElementById('dynamicContent');
    dynamicContent.innerHTML = '<p>Dynamic content loaded successfully!</p>';
    dynamicContent.style.fontSize = '1.5em';
    dynamicContent.style.color = '#4facfe';
    dynamicContent.style.marginTop = '20px';
    dynamicContent.style.animation = 'fadeIn 1s ease-in-out';
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}
```

### Testing the Example Website

1. **Start the Docker Container**: Ensure the container is running by following the instructions in the previous README files.
2. **Access the Website**: Open a web browser and navigate to `http://localhost:8083`. You should see the improved example website displayed.
3. **Test Functionality**: Click the button on the website to ensure the JavaScript is functioning correctly and enjoy the visual effects.

This improved example provides a more aesthetically pleasing setup to verify that the `gwservice` Docker container is working as expected. You can further expand this by adding more features and complexity to your website.

