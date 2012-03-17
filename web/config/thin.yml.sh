thin -d -u www-data -g www-data -s 2 -e development -l /var/log/thin/thin.log -P /var/run/thin.pid -a 127.0.0.1 -p 3003 --debug --trace -A rails -C thin.yml config
