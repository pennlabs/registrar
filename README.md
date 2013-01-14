UPenn Registrar Course Scraper
================

A CoffeeScript module that scrapes the UPenn Registrar. Please install [node](http://nodejs.org) and [CoffeeScript](http://coffeescript.org).

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
> [ { dept: 'cis',
      title: 'INTRO TO COMP PROG',
      courseNumber: '110',
      credits: '1',
      sectionNumber: '001',
      type: 'LEC',
      times: 'MWF 10-11AM',
      days: [ 'monday', 'wednesday', 'friday' ],
      hours: [ '10', '11' ],
      building: 'TOWN',
      roomNumber: '100',
      prof: 'BROWN B' },
    ...
  ]
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
