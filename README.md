About
===========

Dockerized oictest, OpenID Connect Test Suite GUI.

Usage
===========

Mac
------
### Requirement
* Docker-Machine

### Howto

* Launch Docker by Docker-Machine(the machine name is default, or please set MACHINE_NAME env variable.)

```
cd example
sh ./run.sh
```

and

open "https://$(docker-machine ip $MACHINE_NAME):8000"
