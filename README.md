# lbry-Docker

## Currently supported platforms

**X64 cpu architecture**

**More will be added on request and over time**

## Documentation is WIP
Currently this repository is a WIP and is under heavy construction, use at your own risk make sure you keep regular backups of your wallets.  Your milage may vary as how far this will work for you be sure to file good and concise issues if you plan to and keep in mind we're allergic to regressions when filing PR's.

## Debugpaste
I'll be including a function to get a self destructing debugpaste of your LBRY appliances logs you'll be able to execute something similar to the following in all containers to export raw logs to a paste service where you can then either modify them removing sensitive data or just take that URL and create a new issue after you [(Use Issue Search)](https://github.com/lbryio/lbry-docker/issues?utf8=%E2%9C%93&q=is%3Aissue) to make sure there isn't already an open thread for your issue.

#### Example debugpaste
```
cd chainquery/
docker-compose exec chainquery debugpaste
https://haste.nixc.us/ocatumatozaq.nginx
```
You can then take output given in the response from the debugpaste command and put that into your github issue.
