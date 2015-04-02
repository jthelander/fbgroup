# fbgroup

fbgroup is a command-line tool for downloading and archiving Facebook groups. The output is in JSON and it does not download photos and such. It uses the Facebook Graph API and requires an access token, which can be obtained here: https://developers.facebook.com/tools/explorer/. The output can be compressed with zlib using the `-z` option.

## Usage

```
  NAME:

    fbgroup.rb

  DESCRIPTION:

    Facebook group archiving tool

  COMMANDS:
        
    get                  Saves a group to JSON
    help                 Display global or [command] help documentation
    list                 Lists all groups available for a given access token

  GLOBAL OPTIONS:
        
    -h, --help 
        Display help documentation
        
    -v, --version 
        Display version information
        
    -t, --trace 
        Display backtrace when an error occurs

```
