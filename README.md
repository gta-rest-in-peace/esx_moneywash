# esx_moneywash
Yet another ESX Script to wash your money

- Send a text to get the current NPC location
- NPC send you a text when money laundry is done
- If cops find the NPC they get all the current black money managed by the NPC

## Requirements

It needs :
- [es_extended](https://github.com/ESX-Org/es_extended)
- [gcphone](https://github.com/N3MTV/gcphone)

## Installation
- Import `moneywash.sql` in your database
- Configure the script through the `config.lua` file
- Add this in your `server.cfg`:

```
start esx_moneywash
```