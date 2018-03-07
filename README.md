# netdata-cockatrice-plugin

![](screenshot.png)

### Installing
```
git clone https://github.com/skwerlman/netdata-cockatrice-plugin && cd netdata-cockatrice-plugin
sudo cp cockatrice.chart.sh /usr/libexec/netdata/charts.d
sudo chmod +x /usr/libexec/netdata/charts.d/cockatrice.chart.sh
```

### Configuring
Open a new file at `/etc/netdata/charts.d/cockatrice.conf`. Add the following lines:
```ini
cockatrice_database_user=<servatrice databse user>
cockatrice_database_password=<your password here>
cockatrice_database_table=<servatrice table name>
cockatrice_database_prefix=<servatrice table prefix>
```
Remember to edit them according to your setup!
