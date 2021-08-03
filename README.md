# LuvitWeb

Module that handle mixed luahtml files with https://github.com/Be1zebub/LuaHTML & route it with luvit http/https modules.

Usage example:
```
local luahtml_server = require("luahtml_server")
luahtml_server("/var/www/mysite", "incredible-gmod.ru", 1000, 2000)
             -- string path, string domainname (to find a cert) - optional (can be nil), number http port, number https port - optional
```

![Example](https://i.imgur.com/nA0uH67.png)
![Example 2](https://i.imgur.com/UikjNLt.png)
