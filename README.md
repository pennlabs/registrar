UPenn Registrar Course Scraper
================

A CoffeeScript module that scrapes the UPenn Registrar. Please install [node](nodejs.org) and [CoffeeScript](coffeescript.org).

# Quick Start

To build the CoffeeScript simple run `npm install && cake build`

Start an interactive CoffeeScript shell with `coffee`

Create a scraper object
``` coffeescript
Scraper = require "./scraper"
```

Print the list of departments
``` coffeescript
Scraper.getDepartments (depts) -> console.log depts
> [ 'ACCT',
    'AFST',
    'AFRC',
    'AMCS',
    'ANCH',
    'ANEL',
    'ANTH',
    'ARAB',
    'ARCH',
    'AAMW',
    'ARTH',
    ...
  ]
```

Print all the CIS courses
``` coffeescript
Scraper.getCourses "cis", (courses) ->
  console.log courses
> [ { num: '099', title: 'UGRAD RESRCH/IND STUDY', credits: '1' },
    { num: '110', title: 'INTRO TO COMP PROG', credits: '1' },
    { num: '120', title: 'PROG LANG & TECH I', credits: '1' },
    { num: '121', title: 'PROG LANG AND TECH II', credits: '1' },
    ...
  ]
```

Print all the CIS courses with their sections
``` coffeescript
Scraper.getSections "cis", (sections) ->
  console.log sections
```

Get all the courses and sections for each department
``` coffeescript
Scraper.getDepartments (depts) ->
  for dept in depts
    Scraper.getSections dept, (sections) ->
      console.log sections
```

# Contributors

- Geoffrey Vedernikoff <veg@seas.upenn.edu>
- Ceasar Bautista <ceasarb@seas.upenn.edu>
