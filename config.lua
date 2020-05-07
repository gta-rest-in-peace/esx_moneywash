Config = {}
Config.Locale = 'fr'

Config.number = '666-6666'

Config.washrefresh = 60000 * 5 -- Refresh rate to check if money is washed (every 5 minutes is enough)
Config.washminamount = 10000 -- Minimum amount of money for deposit
Config.washtime = 24 -- Not used if washmult != 0, Hours before washing complete
Config.washmult = 0 -- if 0 not used, if 10 it will take 1h every 10$ so for 100$ it will take 10h (good setting is 10000 so 10h for 100000$)
Config.rate = 75 -- Percent given back (0% return 0$, 100% return everything)


Config.position = {
    { x=0,y=0,z=0,h=0.0 },
    --{ x=0,y=0,z=0,h=0.0 }
}