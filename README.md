Software
========

This ruby snippet is an extension for optsparse which takes a JSON config file and turns it into managed command line parameters. Command line parameters are defined in the JSON config including short version, long version, description, has parameter etc. and creates a single dictionary hash out of the incomming params specified. 

Example:

"OPTION": [
        {
           "variablename": "VERSION",
             "longformat": "--version",
            "shortformat": "-v",
            "description": "gets version number for this build",
                        "required": false,
                          "value": true
        },
        ]

This allows you to quickly define your apps required parameters and display a unified help without the overhead of placing the in-code commandline switches and how to handle them.


