# NGINX

```
brew install nginx
```


Start nginx (require [Brew services](./brew-services.md))

```shell
sudo brew services start nginx
```

You can start nginx manually and check if running in browser

```shell
sudo brew servic es reload nginx
sudo brew services start nginx
sudo brew services stop nginx
```

Check if running `open http://localhost:8080` or `open http://localhost:80`

## Configuration

nginx configuration files can be found here `code /usr/local/etc/nginx`

Here is my basic `nginx.conf` file (do not forgot change root path):

```conf
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    include       sites-enabled/*; # load virtuals config
    sendfile        on;
    keepalive_timeout  65;

    # gzip  on;
    # gzip_disable "MSIE [1-6]\.(?!.*SV1)";

    server {
        listen       80;
        server_name  localhost;

        location / {
            root  /Users/roman/Sites;
            try_files  $uri  $uri/  /index.php?$args ;
            index  index.php;
        }

        # configure *.PHP requests

        location ~ \.php$ {
            root  /Users/roman/Sites;
            try_files  $uri  $uri/  /index.php?$args ;
            index  index.html index.htm index.php;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_intercept_errors on;
            include fastcgi_params;
        }
    }
}
```

## Setup virtuals

First prepare follow dirs

```shell
mkdir /usr/local/etc/nginx/sites-available
mkdir /usr/local/etc/nginx/sites-enabled
```

Create first nginx configuration:

```shell
code /usr/local/etc/nginx/sites-available/omdesign.local
```

Here is an example configuration:

```conf
server {
  listen                *:80;
  server_name           omdesign.local;
  #access_log           /Users/roman/Work/omdesign.cz/log/omdesign.local.access.log;
  #error_log            /Users/roman/Work/omdesign.cz/log/omdesign.local.error.log;

  location / {
    root  /Users/roman/Work/omdesign.cz;
    try_files  $uri  $uri/  /index.php?$args;
    index index.php;
  }

  location ~ \.php$ {
    root  /Users/roman/Work/omdesign.cz;
    try_files  $uri  $uri/  /index.php?$args;
    index  index.html index.htm index.php;

    fastcgi_param PATH_INFO $fastcgi_path_info;
    fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;


    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_intercept_errors on;
    include fastcgi_params;
  }

}
```

Create symlink to sites-enabled:

```shell
sudo ln -s /usr/local/etc/nginx/sites-available/omdesign.local /usr/local/etc/nginx/sites-enabled/omdesign.local
```

Update your `code /etc/hosts` file with follow line:

```shell
127.0.0.1   omdesign.local
```

Restart nginx (`sudo brew service reload nginx`) and check if working (`open http://omdesign.local`)