# assert = require("assert")
chai = require('chai')
chai.Assertion.includeStack = true
expect = chai.expect

scraper = require("../scraper")


describe 'getDays', () ->
  it "should return monday when M is present", ->
    expect(scraper.getDays 'M').to.deep.equal(['monday'])
  it "should return ['monday', 'wednesday'] when M and W is present", ->
    expect(scraper.getDays 'MW').to.deep.equal(['monday', 'wednesday'])


describe 'getHours', () ->
  it "should return ['4:30', '5:30'] when 4:30 and 5:30 are present", ->
    expect(scraper.getHours "M 4:30-5:30PM").to.deep.equal(['4:30', '5:30'])


describe 'parseCourse', () ->
  it "should grab course num", ->
    line = "ACCT-718  AUDITING 1 CU"
    num = '718'
    course = scraper.parseCourse(line)
    expect(course.num).to.equal(num)
  it "should grab course name", ->
    line = "ACCT-718  AUDITING 1 CU"
    title = 'AUDITING'
    course = scraper.parseCourse(line)
    expect(course.title).to.equal(title)
  it "should grab course names with non-word characters", ->
    line = "ACCT-705 TAX PLANNING AND ADMIN. 1 CU"
    title = 'TAX PLANNING AND ADMIN.'
    course = scraper.parseCourse(line)
    expect(course.title).to.equal(title)
  it "should grab credits", ->
    line = "ACCT-718  AUDITING 1 CU"
    credits = '1'
    course = scraper.parseCourse(line)
    expect(course.credits).to.equal(credits)
  it "should grab half credits", ->
    line = "ACCT-612 ACCELERATED FIN ACCT 0.5 CU"
    credits = '0.5'
    course = scraper.parseCourse(line)
    expect(course.credits).to.equal(credits)
  it "should return undefined if there is no match", ->
    line = "     MBA COURSE"
    expect(scraper.parseCourse(line)).to.equal(undefined)
